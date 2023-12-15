import interface
from ops import train

import time
from bitarray import bitarray

import serial
ser = serial.Serial('/dev/ttyUSB1', 4_000_000, stopbits=serial.STOPBITS_ONE, timeout=0.1) # helps it not lose bytes

x = bitarray('1010'*32)
y = bitarray('1110'*32)
for i in range(512):
    interface.send(ser, 'data', i, y + x)

def flash_ops(ops):
    bits = interface.prepare_op("SET_I_TO_0")
    print(bits)
    interface.send(ser, 'op', 0, bits)

    for i, op  in enumerate(ops):
        print(op, bits)
        if i == 0:
            continue
        bits = interface.prepare_op(op)
        interface.send(ser, 'op', i, bits)

    op0 = ops[0]
    bits = interface.prepare_op(op0)
    interface.send(ser, 'op', 0, bits)

ops = train(4, 3)
flash_ops(ops)

inf = interface.recv(ser, 'inf', 0)
print(inf)

time.sleep(1.0)
inf = interface.recv(ser, 'inf', 0)
print(inf)

time.sleep(1.0)
inf = interface.recv(ser, 'inf', 0)
print(inf)

ser.close()