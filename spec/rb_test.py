#!/usr/bin/env python

import sys

if sys.version_info[0] < 2 or ( sys.version_info[0] == 2 and sys.version_info[1] < 7):
    raise SystemExit("rb_test.py must be run with Python >= 2.7")

import optparse
import logging
import optparse
import subprocess
import os
import time
import requests
import memcache
import re
import platform
from rbtools.api.client import RBClient

FORMAT = "[%(levelname)s %(filename)s:%(lineno)s - %(funcName)20s() ] %(message)s"
logging.basicConfig(level=logging.INFO, format=FORMAT)
logger = logging.getLogger(__name__)

clone_path = '/tmp/puppet-reviewboard'
github_url = 'https://github.com/jantman/puppet-reviewboard.git'

def get_api_root(user, password):
    client = RBClient('http://localhost/', username=user, password=password)
    root = client.get_root()
    return root

def create_repo(root):
    """ create a repo and add it to reviewboard """
    if not os.path.exists(clone_path):
        logger.info("cloning repository into {c}".format(c=clone_path))
        command_or_fail(['git',
                         'clone',
                         github_url,
                         clone_path])
    else:
        logger.info("repository already cloned")
    for r in root.get_repositories():
        if r.name == 'puppet-reviewboard':
            logger.info("Repository puppet-reviewboard already added.")
            return True
    logger.info("adding repository to RB via API...")
    res = root.get_repositories().create(name='puppet-reviewboard',
                                         path='file://{p}'.format(p=os.path.join(clone_path, '.git')),
                                         mirror_path=github_url,
                                         tool='Git',
                                         trust_host=True,
    )
    if not res:
        logger.debug(res)
        logger.critical("create_repo FAILED")
        return False
    for r in root.get_repositories():
        if r.name == 'puppet-reviewboard':
            logger.info("Repository puppet-reviewboard successfully added.")
            return True
    logger.critical("repository creation appeared successful, but repo not in list")
    return False

def post_review(root):
    """ post a review """
    branch_name = 'test_{t}'.format(t=time.time())
    command_or_fail(['git',
                     '--git-dir={p}'.format(p=os.path.join(clone_path, '.git')),
                     '--work-tree={p}'.format(p=clone_path),
                     'checkout',
                     'master'])
    fpath = os.path.join(clone_path, 'README.md')
    command_or_fail(['git',
                     '--git-dir={p}'.format(p=os.path.join(clone_path, '.git')),
                     '--work-tree={p}'.format(p=clone_path),
                     'checkout',
                     '-b',
                     branch_name])
    logger.info("appending string to {f}".format(f=fpath))
    with open(fpath, 'a') as fh:
        fh.write("rb_test.py testing")
    command_or_fail(['git',
                     '--git-dir={p}'.format(p=os.path.join(clone_path, '.git')),
                     '--work-tree={p}'.format(p=clone_path),
                     'add',
                     'README.md'])
    command_or_fail(['git',
                     '--git-dir={p}'.format(p=os.path.join(clone_path, '.git')),
                     '--work-tree={p}'.format(p=clone_path),
                     'commit',
                     '-m',
                     'test_commit'])
    commit_id = command_or_fail(['git',
                                 '--git-dir={p}'.format(p=os.path.join(clone_path, '.git')),
                                 '--work-tree={p}'.format(p=clone_path),
                                 'rev-parse',
                                 'HEAD']).strip()
    logger.info("commit id: {c}".format(c=commit_id))
    logger.info("posting review with rbt:")
    rbt_cmd = ' '.join(['cd',
                        clone_path,
                        '&&'
                        '/tmp/rbtest/bin/rbt',
                        'post',
                        '--parent=master',
                        '--tracking-branch=origin/master',
                        '--guess-fields',
                        '--server=http://localhost/',
                        '--debug',
                        '--publish',
                        '--branch={b}'.format(b=branch_name),
    ])
    command_or_fail(rbt_cmd, shell=True)
    req = root.get_review_requests()
    logger.debug("found {r} review requests".format(r=req.total_results))
    for review in req:
        if review.branch != branch_name:
            continue
        logger.info("found review request id {i} with matching branch".format(i=review.id))
        found_file = False
        for d in review.get_diffs():
            for f in d.get_files():
                pd = f.get_patch().data
                if 'a/README.md' in pd and "rb_test.py testing" in pd:
                    found_file = True
        if not found_file:
            logger.critical("review diffs did not include README.md changes")
            return False
        logger.info("appropriate changes found in review diff")
        return True
    logger.critical("Could not find review request for branch {b}".format(b=branch_name))
    return False

def attach_file(root):
    """ attach a file to a review """
    req = root.get_review_requests()
    logger.debug("found {r} review requests".format(r=req.total_results))
    latest = None
    latest_id = 0
    for review in req:
        if review.id > latest_id:
            latest = review
    logger.debug("found latest review as id {i} for branch {b}".format(i=latest.id, b=latest.branch))
    logger.info("attaching Rakefile as a file attachment...")
    with open(os.path.join(clone_path, 'Rakefile'), 'r') as fh:
        c = fh.read()
    r = latest.get_file_attachments().upload_attachment(filename='Rakefile', content=c, caption='uploaded_Rakefile_attachment')
    if not r:
        logger.critical("Error uploading attachment")
        return False
    logger.info("attachment uploaded")
    d = latest.get_draft()
    logger.info("publishing draft")
    d.update(public=True)
    logger.debug("checking web UI for review with attachments...")
    rev_url = 'http://localhost/r/{i}/'.format(i=latest.id)
    r = requests.get(rev_url)
    if r.status_code != 200:
        logger.critical("ERROR: request to {u} failed with status code {c}".format(u=rev_url, c=r.status_code))
        return False
    if 'uploaded_Rakefile_attachment</a>' not in r.text:
        logger.critical("ERROR: string 'uploaded_Rakefile_attachment</a>' not found on review page {u}".format(u=rev_url))
        return False
    logger.info("file attachments found on review.")
    return True

def diff_viewer(root):
    """ check that diff viewer works """
    req = root.get_review_requests()
    logger.debug("found {r} review requests".format(r=req.total_results))
    rev_id = None
    diff_id = None
    file_id = None
    for review in req:
        rev_id = review.id
        for d in review.get_diffs():
            diff_id = d.id
            for f in d.get_files():
                file_id = f.id
                break
    if rev_id is None or diff_id is None or file_id is None:
        logger.critical("could not find any reviews with diffs")
        return False
    url = "http://localhost/r/{r}/diff/{d}/fragment/{f}/?index=0&None&api_format=json".format(r=rev_id, d=diff_id, f=file_id)
    logger.info("getting web UI review diff: {u}".format(u=url))
    r = requests.get(url)
    if r.status_code != 200:
        logger.critical("ERROR: request to {u} failed with status code {c}".format(u=rev_url, c=r.status_code))
        return False
    if '<span' not in r.text:
        logger.critical("ERROR: diff does not appear to be HTML as it should - {u}".format(u=rev_url))
        return False
    logger.info("diff viewer appears to be working")
    return True

def check_memcached():
    """ check that memcached is working and being written to """
    conn = '127.0.0.1:11211'
    logger.info("connecting to memcached {c}".format(c=conn))
    mc = memcache.Client([conn], debug=0)
    stats = mc.get_stats()[0][1]
    if int(stats['curr_items']) < 3:
        logger.critical("memcached stats report only {i} current items".format(i=stats['curr_items']))
        return False
    logger.info("memcached stats reports {i} current items".format(i=stats['curr_items']))
    slabstats = mc.get_stats(stat_args='items')[0][1]
    slabre = re.compile(r'^items:(\d+):number$')
    slab = None
    for statname in slabstats:
        m = slabre.match(statname)
        if m and int(slabstats[statname]) > 1:
            slab = m.group(1)
            logger.info("found slap {slab} with {n} items".format(slab=slab, n=slabstats[statname]))
            break
    if slab is None:
        logger.critical("could not find a memcache slab with more than 1 item")
        return False
    itemstats = mc.get_stats(stat_args='cachedump {slab} 100'.format(slab=slab))[0][1]
    hostname = platform.node()
    for cachekey in itemstats:
        if hostname in cachekey:
            logger.info("Found valid reviewboard-generated cache key in memcached: {c}".format(c=cachekey))
            return True
    logger.critical("Did not find any reviewboard-generated cache keys in memcached.")
    return False

def main(action, user='admin', password='rbadminpass'):
    logger.info("connecting and logging in to RB API...")
    root = get_api_root(user, password)
    logger.info("connected.")
    if action == 'login':
        if root._payload['stat'] != 'ok':
            logger.error("login failed - payload stat not ok")
            return False
        if not root:
            logger.error("login failed - get_api_root returned false")
            return False
        logger.info("login succeeded")
        return True
    elif action == 'createrepo':
        res = create_repo(root)
    elif action == 'post':
        res = post_review(root)
    elif action == 'attach':
        res = attach_file(root)
    elif action == 'diffview':
        res = diff_viewer(root)
    elif action == 'memcached':
        res = check_memcached()
    if not res:
        raise SystemExit(1)
    return True

def parse_args(argv):
    """ parse arguments/options """
    p = optparse.OptionParser()

    p.add_option('-u', '--username', dest='username', action='store', default='admin',
                 help='RB username')

    p.add_option('-p', '--password', dest='password', action='store', default='rbadminpass',
                 help='RB password')

    p.add_option('-v', '--verbose', dest='verbose', action='count', default=0,
                 help='verbose output. specify twice for debug-level output.')

    p.add_option('-a', '--action', dest='action', action='store', default='login',
                 help='action to take')

    options, args = p.parse_args(argv)

    return options

def command_or_fail(cmd, shell=False):
    """ run a command, log output and raise exception on failure. on success return output """
    s = ''
    if shell:
        s = ' with shell=True'
    if type(cmd) == type([]):
        logger.info("running command{s}: {c}".format(c=' '.join(cmd), s=s))
    else:
        logger.info("running command{s}: {c}".format(c=cmd, s=s))
    try:
        r = subprocess.check_output(cmd, stderr=subprocess.STDOUT, shell=shell)
        logger.info("command ran successfully")
        logger.debug("OUTPUT: %s", r)
    except subprocess.CalledProcessError as ex:
        logger.error("Command exited %d: %s", ex.returncode, cmd)
        logger.error("OUTPUT: %s", ex.output)
        raise SystemExit("ERROR: rb_test.py - command execution failed")
    return r

if __name__ == "__main__":
    opts = parse_args(sys.argv[1:])

    if opts.verbose > 1:
        logger.setLevel(logging.DEBUG)

    res = main(opts.action, user=opts.username, password=opts.password)
    if not res:
        raise SystemExit("tests failed")

