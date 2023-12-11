import interface
import time
from bitarray import bitarray

import serial
ser = serial.Serial('/dev/ttyUSB1', 4_000_000, stopbits=serial.STOPBITS_ONE, timeout=0.1) # helps it not lose bytes

# Seed DATA
zero = bitarray('0'*1024)
for i in range(512):
    print(i)
    z = bitarray(format(i, 'b').zfill(1024))
    interface.send(ser, 'data', i, z + zero)
x = bitarray('0011' * 256)
y = bitarray('0101' * 256)
# interface.send(ser, 'data', 0, zero*2)
# interface.send(ser, 'data', 0, y + x)
# print(interface.recv(ser, 'data', 3))

ops = [
    "SET_XY_TO_VALUE_AT_D",
    # "SET_Y_TO_X_OR_Y",
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

time.sleep(0.01)
inf = interface.recv(ser, 'inf', 0)
print(inf)
# assert inf == x | y

print("TEST PASSED WITH INSTRUCTIONS:\n")
print(*ops, sep="\n")

ser.close()