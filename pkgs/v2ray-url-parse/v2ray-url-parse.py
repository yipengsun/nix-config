#!/usr/bin/env python
#
# Adapted from: https://liolok.com/v2ray-subscription-parse/

from urllib.parse import urlsplit
from urllib.request import urlopen
from argparse import ArgumentParser
from base64 import b64decode

import json

ALLOWED_SCHEMA = ['vmess', 'ss', 'socks']


def parse_input():
    parser = ArgumentParser(description='download v2ray subscription link.')
    parser.add_argument('url', help='specify v2ray subscription URL.')

    return parser.parse_args()


if __name__ == '__main__':
    args = parse_input()
    links = b64decode(urlopen(args.url).read()).decode('utf-8').splitlines()

    config = []
    for l in links:
        url = urlsplit(l)
        if url.scheme not in ALLOWED_SCHEMA:
            raise RuntimeError('Invalid share link')
        print(url)
