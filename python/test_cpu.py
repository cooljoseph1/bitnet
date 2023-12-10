import interface
import time
from bitarray import bitarray

import serial
ser = serial.Serial('/dev/ttyUSB1', 4_000_000, stopbits=serial.STOPBITS_TWO) # helps it not lose bytes

# Seed DATA
zero = bitarray('0'*1024)

for i in range(512):
    y = bitarray(format(i, 'b').zfill(1024))
    time.sleep(0.1)
    interface.send(ser, 'data', i, y + zero)
    time.sleep(0.1)
    print(interface.recv(ser, 'data', i)[1016:1024])
# x = bitarray('0011' * 256)
# y = bitarray('0101' * 256)
# # interface.send(ser, 'data', 3, zero*2)
# interface.send(ser, 'data', 3, y + x)

ops = [
    "SET_XY_TO_VALUE_AT_D",
    "SET_INFERENCE_TO_Y",
    "D_INCREMENT",
    ]
for i, op in enumerate(ops):
    bits = interface.prepare_op(op)
    interface.send(ser, 'op', i, bits)

inf = interface.recv(ser, 'inf', 0)
print(inf)
# assert inf == zero

# bits = interface.prepare_op("D_INCREMENT")
# interface.send(ser, 'op', 3, bits)

time.sleep(0.5)
inf = interface.recv(ser, 'inf', 0)
print(inf)
assert inf == x | y

print("TEST PASSED WITH INSTRUCTIONS:\n")
print(*ops, sep="\n")

ser.close()