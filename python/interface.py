import os
import time
from bitarray import bitarray

file_dir = os.path.dirname(os.path.abspath(__file__))
instr_path = os.path.join(file_dir, "..", "hdl/control_unit/", "cpu.sv")


def extract_params(path):
    with open(path, "r") as f:
        localparams = f.read().split(
                r"/* ----- PYTHON PARSING BEGINS HERE ----- */"
            )[1].split(
                r"/* ----- PYTHON PARSING ENDS HERE ----- */"
            )[0]
        
    params = dict()
    for line in localparams.split("\n"):
        try:
            var, other, *_ = line.split("localparam ")[1].split("=")
            var = var.strip()
            val = int(other.split(";")[0].strip())
            params[var] = val
        except:
            pass
    return params

instruction_set = extract_params(instr_path)

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
    'data': 2 * 128,
    'weight': 3 * 128,
    'op': 8,
    'inf': 128
    }

def prepare_message(io, loc, addr, bits=None):
    """
    io - 'send' to the FPGA or 'recv' bits from it
    loc - 'data', 'weight', or 'op' BRAMS, or you can read from the 'inf'erence.
    addr - the address to read/write from, as an integer
    """
    addr_bits = bitarray(format(addr & 0xffff, 'b').zfill(16)) # last 16 bits of addr
    msg_type = bitarray('00000') + io_bits[io] + loc_bits[loc]
    bits = bitarray(bits or '')
    msg = msg_type.tobytes() + addr_bits.tobytes()[::-1] + bits.tobytes()
    # b = bitarray()
    # b.frombytes(msg)
    # print(msg)
    # print(b)
    return msg

    msg = bitarray(bits or '') + addr_bits + msg_type
    print(msg.tobytes())
    return int(msg, 2).to_bytes(len(msg)//8, byteorder='little')

    
    return msg
    
def prepare_op(op):
    if type(op) == str:
        op = instruction_set[op]
    return bin(op)[2:].zfill(8)

def send(ser, loc, addr, bits, error_check=True):
    bits = bitarray(bits or '')
    msg = prepare_message('send', loc, addr, bits)
    ser.write(msg)
    ser.flush()
    # print(ser.in_waiting)
    x = ser.out_waiting
    if x > 0:
        print(x)
        raise

    if error_check:
        ser.reset_input_buffer()
        b = recv(ser, loc, addr)
        while b != bits:
            ser.reset_input_buffer()
            ser.write(msg)
            b = recv(ser, loc, addr)


def recv(ser, loc, addr):
    msg = prepare_message('recv', loc, addr)
    ser.write(msg)
    b = bitarray()
    b.frombytes(ser.read(loc_size[loc] // 8))
    return b
if __name__ == "__main__":
    import serial
    import serial.tools.list_ports
    import time

    ports = serial.tools.list_ports.comports()
    for port, desc, hwid in sorted(ports):
            print("{}: {} [{}]".format(port, desc, hwid))
    
    ser = serial.Serial('/dev/ttyUSB1', 4_000_000, stopbits=serial.STOPBITS_TWO)
    send(ser, 'op', 3, '00001010')
    time.sleep(1.0)
    print(recv(ser, 'op', 3))
    ser.close()