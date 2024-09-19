#!/usr/bin/env python
#
# Author: Yipeng Sun
# License: BSD
# Last Change: Fri Apr 09, 2021 at 04:38 AM +0200
#
# Description: Processing volume control multi-media keys for newer thinkpad
#              models. This is a PulseAudio version. Also please make sure
#              'pamixer' has installed on you system to adjust the volume
#              properly.
#
# Thanks: Chiyuan Zhang <pluskid at gmail dot com>. I stole the main framework
#         from his python volume control script (python 2 version).

import os
from subprocess import call
from argparse import ArgumentParser

volstep = 5
barstep = 20


def parse_input():
    parser = ArgumentParser(description='''
        control PulseAudio volume via command line. generate notify events at
        the same time. note that this script is only meant to control volume, if
        you need more control, please use 'pamixer' directly.''')

    parser.add_argument("-u", "--vol-up",
                        dest="volUp",
                        nargs="?",
                        const=volstep,
                        default=False,
                        help='''
            increase volume. default step is 5. one optional argument can
            be given to modify the default step.''')

    parser.add_argument("-d", "--vol-down",
                        dest="volDown",
                        nargs="?",
                        const=volstep,
                        default=False,
                        help='''
            decrease volume. default step is 5. one optional argument can
            be given to modify the default step.''')

    parser.add_argument("-M", "--mute-input",
                        dest="muteInput",
                        action="store_true",
                        default=False,
                        help="mute PulseAudio input.")

    parser.add_argument("-m", "--mute-output",
                        dest="muteOutput",
                        action="store_true",
                        default=False,
                        help="mute PulseAudio output.")

    parser.add_argument("-i", "--index",
                        default="1",
                        help="specify index of the source/sink.")

    return parser


def notify_awesome_wm(notify):
    os.popen('''echo "volnotify:notify('{0}')" | \
            awesome-client'''.format(notify))


def notify_vol(cur_vol=0):
    percent = int(cur_vol * barstep/100)
    graph = '|' * percent + '-' * (barstep - percent)
    # Construct graphical volume bar
    vol_bar = "Volume: {0}".format(graph)
    # Output notify to awesome wm
    notify_awesome_wm(vol_bar)


def adjust_volume(step):
    cur_vol = int(os.popen('pamixer --get-volume').read())
    adj_vol = cur_vol + step
    # You'll want to unmute the channel anyway
    call(["pamixer", "--unmute"])

    if step > 0:
        if adj_vol < 100:
            call(["pamixer", "--increase", str(step)])
            notify_vol(adj_vol)
        else:
            call(["pamixer", "--set-volume", "100"])
            notify_vol(100)

    if step < 0:
        if adj_vol > 0:
            call(["pamixer", "--decrease", str(-step)])
            notify_vol(adj_vol)
        else:
            call(["pamixer", "--set-volume", "0"])
            notify_vol(0)


def toggle_mute(toggle_type, index):
    if toggle_type == "input":
        cur_stat = str(os.popen('pamixer --source {} --get-mute'.format(
            index)).read())
        if len(cur_stat) == 0:
            cur_stat = str(os.popen('pamixer --source 1 --get-mute').read())
            index = "1"

        if "false" in cur_stat:
            call(["pamixer", "--source", index, "--mute"])
            notify_awesome_wm("Microphone: Mute")
        else:
            call(["pamixer", "--source", index, "--unmute"])
            notify_awesome_wm("Microphone: Unmute")

    if toggle_type == "output":
        cur_stat = str(os.popen('pamixer --get-mute').read())
        if "false" in cur_stat:
            call(["pamixer", "--mute"])
            notify_awesome_wm("Volume: Mute")
        else:
            call(["pamixer", "--unmute"])
            notify_awesome_wm("Volume: Unmute")


if __name__ == "__main__":
    parser = parse_input()
    args = parser.parse_args()

    if args.volUp:
        adjust_volume(int(args.volUp))
    if args.volDown:
        adjust_volume(int(-args.volDown))

    if args.muteInput:
        toggle_mute("input", args.index)
    if args.muteOutput:
        toggle_mute("output", args.index)
