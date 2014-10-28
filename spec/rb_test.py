#!/usr/bin/env python

import optparse
import logging
import sys
import optparse
from rbtools.api.client import RBClient

FORMAT = "[%(levelname)s %(filename)s:%(lineno)s - %(funcName)20s() ] %(message)s"
logging.basicConfig(level=logging.INFO, format=FORMAT)
logger = logging.getLogger(__name__)

def get_api_root(user, password):
    client = RBClient('http://localhost/', username=user, password=password)
    root = client.get_root()
    return root

def create_repo(root):
    """ create a repo and add it to reviewboard """
    res = root.get_repositories().create(name='puppet-reviewboard',
                                         path='/tmp/puppet-reviewboard',
                                         tool='Git',
                                         trust_host=True,
    )
    if not res:
        print(res)
        print("create_repo FAILED")
        raise SystemExit(1)
    for i in root.get_repositories():
        print(i)
    return True

def main(action, user='admin', password='rbadminpass'):
    root = get_api_root(user, password)
    if action == 'login':
        if root._payload['stat'] != 'ok':
            logger.error("login failed - payload stat not ok")
            return False
        if not root:
            logger.error("login failed")
            return False
        logger.info("login succeeded")
        return True
    elif action == 'createrepo':
        create_repo(root)
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

if __name__ == "__main__":
    opts = parse_args(sys.argv[1:])

    if opts.verbose > 1:
        logger.setLevel(logging.DEBUG)
    elif opts.verbose > 0:
        logger.setLevel(logging.INFO)

    res = main(opts.action, user=opts.username, password=opts.password)
    if not res:
        raise SystemExit("tests failed")

