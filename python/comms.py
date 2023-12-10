io_bits = {
    'send': '0',
    'recv': '1'
    }

loc_bits = {
      'data': '00',
      'weight': '01',
      'op': '10',
      'inf': '11'
    }

loc_size = {
    'data': 2048//2,
    'weight': 3072,
    'op': 8,
    'inf': 2048//2
    }

def prepare_message(io, loc, addr, bits=None):
    """
    io - 'send' to the FPGA or 'recv' bits from it
    loc - 'data', 'weight', or 'op' BRAMS, or you can read from the 'inf'erence.
    addr - the address to read/write from, as an integer
    """
    addr_bits = bin(addr & 0xffff)[2:].zfill(16) # last 16 bits
    header = '00000' + io_bits[io] + loc_bits[loc] + addr_bits
    msg = header + (bits or '')

    return int(msg, 2).to_bytes(len(msg)//8, byteorder='big')

def send(ser, loc, addr, bits):
    msg = prepare_message('send', loc, addr, bits)
    ser.write(msg)

def recv(ser, loc, addr):
    msg = prepare_message('recv', loc, addr)
    ser.write(msg)
    return ser.read(loc_size[loc] // 8)


if __name__ == "__main__":
    import serial
    import serial.tools.list_ports

    ports = serial.tools.list_ports.comports()
    for port, desc, hwid in sorted(ports):
            print("{}: {} [{}]".format(port, desc, hwid))
    
    ser = serial.Serial('/dev/ttyUSB1', 4_000_000)
    send(ser, 'data', 1, '10'*512)
    print(recv(ser, 'inf', 0))
    ser.close()