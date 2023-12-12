import interface
import time
from bitarray import bitarray

import serial
ser = serial.Serial('/dev/ttyUSB1', 4_000_000, stopbits=serial.STOPBITS_ONE, timeout=0.1) # helps it not lose bytes

# Seed DATA
zero = bitarray('0'*1024)
for i in range(80):
    print(i)
    x = bitarray(format(i + 100, 'b').zfill(1024))
    y = bitarray(format(i + 27, 'b').zfill(1024))
    interface.send(ser, 'data', i, y + x)
# x = bitarray('0011' * 256)
# y = bitarray('0101' * 256)
# interface.send(ser, 'data', 0, zero*2)
# interface.send(ser, 'data', 0, y + x)
# print(interface.recv(ser, 'data', 3))

ops = [
    "SET_XY_TO_VALUE_AT_D",
    "SET_TRIT_TO_NEXT_VALUE",
    7,
    "SET_TRIT_TO_NEXT_VALUE",
    11,
    "INTERWEAVE",
    "SET_Y_TO_X",
    "SET_INFERENCE_TO_Y",
    "SET_I_TO_0"
    ] # Should have at inference the value of data.x at 0"""


def flash_ops(ops):
    bits = interface.prepare_op("SET_I_TO_0")
    interface.send(ser, 'op', 0, bits)

    for i, op  in enumerate(ops):
        if i == 0:
            continue
        bits = interface.prepare_op(op)
        interface.send(ser, 'op', i, bits)

    op0 = ops[0]
    bits = interface.prepare_op(op0)
    interface.send(ser, 'op', 0, bits)

flash_ops(ops)

time.sleep(0.1)
inf = interface.recv(ser, 'inf', 0)
print(inf)
assert inf == zero

# bits = interface.prepare_op("D_INCREMENT")
# interface.send(ser, 'op', 3, bits)

# time.sleep(0.01)
# inf = interface.recv(ser, 'inf', 0)
# print(inf)
# assert inf == x | y

# print("TEST PASSED WITH INSTRUCTIONS:\n")
# print(*ops, sep="\n")

ser.close()