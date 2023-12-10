import serial
import serial.tools.list_ports
ports = serial.tools.list_ports.comports()

for port, desc, hwid in sorted(ports):
        print("{}: {} [{}]".format(port, desc, hwid))

ser = serial.Serial('/dev/ttyUSB1', 4_000_000) # CLK_BAUD_RATIO = 25

def prepare_message(dir, bram, addr, data=None):
    """
    dir - 'send' or 'recv' (from the perspective of your laptop)
    bram - 'data', 'weight', or 'op'
    addr - address within bram
    data - None for recv'ing, otherwise:
        'data' is 1024 bits
        'weight' is 3072 bits
        'op' is 8 bits
        e.g. '00011001' for an op.
    """
    op = '0'*5 + '01'[dir == "recv"] + {'data': '00', 'weight': '01', 'op': '10'}[bram]
    bits = (data or '') + addr.zfill(16) + op.zfill(8)

    return int(bits, 2).to_bytes(len(bits)//8, byteorder='little')

addr = '0000000000100101'
msg = prepare_message('send', 'data', addr, '01'*512)
ser.write(msg)
msg = prepare_message('send', 'weight', addr, '101110'*512)
ser.write(msg)
msg = prepare_message('send', 'op', addr, bin(ord("V"))[2:].zfill(8))
ser.write(msg)
msg = prepare_message('send', 'op', addr, bin(ord("Z"))[2:].zfill(8))
ser.write(msg)

msg = prepare_message('recv', 'data', addr)
ser.write(msg)
print(ser.read(128))

ser.close()