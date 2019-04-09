#!/usr/bin/env python3

import sys
from typing import List, Dict, Any

ccinfo = '''
0	bank select
1	modulation
2	breath controller
3	undefined
4	foot controller
5	portamento time
6	data entry most significant bit(msb)
7	volume
8	balance
9	undefined
10	pan
11	expression
12	effect controller 1
13	effect controller 2
14-15	undefined
16–19	general purpose
20–31	undefined
32–63	controller 0-31 least significant bit (lsb)
64	damper pedal / sustain pedal
65	portamento on/off switch
66	sostenuto on/off switch
67	soft pedal on/off switch
68	legato footswitch
69	hold 2
70-79	sound controller 1-10
80-83 general purpose control
84	portamento cc control
85 – 90	undefined
91-95	effect 1-5 depth
96	(+1) data increment
97	(-1) data decrement
98	NRPN lsb
99	NRPN msb
100	RPN lsb 
101	RPN msb
102–119	undefined

channel mode messages:
120	all sound off
121	reset all controllers
122	local on/off switch
123	all notes off
124	omni mode off
125	omni mode on
126	mono mode
127	poly mode
'''

def SerialSend(valuesToSend: List[int]):
    for i in valuesToSend:
        print(i)
#        serial.send(i)


def sendNoteOff(ch: int, note: int, velo: int):
    SerialSend([0x80+ch, note, velo])


def sendNoteOn(ch: int, note: int, velo: int):
    SerialSend([0x90+ch, note, velo])


def sendCC(ch: int, cc: int, value: int):
    SerialSend([0xB0+ch, cc, value])


def sendPC(ch: int, value: int):
    SerialSend([0xC0+ch, value])


if __name__ == "__main__":
    argNumber = 1
    if len(sys.argv) == 1:
        print("Usage: option|command parameters")
        print("  --cc for list of control changes)")
        print("non <ch> <height> <velo>  velo default 127")
        print("noff <ch> <height> <velo>  velo default 63")
        print("cc <ch> <cc> <value>")
        sys.exit(1)

    if sys.argv[1] == '--cc':
        print(ccinfo)

    if sys.argv[1] == 'non':
        sendNoteOn(int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4]))
    if sys.argv[1] == 'noff':
        sendNoteOff(int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4]))
    if sys.argv[1] == 'cc':
        sendCC(int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4]))
    if sys.argv[1] == 'pc':
        sendPC(int(sys.argv[2]), int(sys.argv[3]))

