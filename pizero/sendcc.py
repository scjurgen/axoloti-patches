#!/usr/bin/env python3

import time
import serial

ser = serial.Serial(
    port='/dev/ttyS0',
    baudrate = 115200,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS,
    timeout=1
    )

ser.write(bytearray([0xb0, 1, 62]))
time.sleep(1)
ser.write(bytearray([0xb0, 2, 42]))

