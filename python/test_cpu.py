import comms
import time

import serial
import serial.tools.list_ports

ports = serial.tools.list_ports.comports()
for port, desc, hwid in sorted(ports):
        print("{}: {} [{}]".format(port, desc, hwid))

ser = serial.Serial('/dev/ttyUSB1', 4_000_000)

# Seed DATA
comms.send(ser, 'data', 0, '01'*1024)
print(comms.recv(ser, 'data', 0))


# Set INFERENCE to the OR of all DATA X's.
ops = [3, 4, 7, 23, 10]#, 3, 0]
for i, op in enumerate(ops):
    comms.send(ser, 'op', i, bin(op)[2:].zfill(8))

# Read INFERENCE
time.sleep(0.1)
print(comms.recv(ser, 'inf', 0))

ser.close()