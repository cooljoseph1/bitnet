# Communication Protocol

## Bit Structure

A message is split by bytes due to UART. The header is three bytes:
- 1: 00000<span style="color:magenta">01</span><span style="color:red">1</span>
- 2-3: <span style="color:green">00110110</span> <span style="color:tan">00110110</span>
Potentially followed by bytes streaming in:
- 4+: <span style="color:orange">10010101110...</span>

-----

Header bits:
- BYTE 1:
    - The first five bits are unused.
    - The <span style="color:magenta">next two bits</span> tells the computer which BRAM to query:
        - <span style="color:magenta">00</span> - DATA.
        - <span style="color:magenta">01</span> - WEIGHT.
        - <span style="color:magenta">10</span> - OP.
    - The <span style="color:cyan">next bit</span> tells whether to receive (0) or send (1) data, from the persepctive of the FPGA.
- BYTES 2-3:
    - The <span style="color:green">next 16 bits</span> are the address.
        - DATA has 2^10 addresses.
        - WEIGHT has 2^7 addresses.
        - OP has 2^10 addresses.
        - These numbers are subject to change.
- BYTES 4+:
    - The <span style="color:orange">varying bits at the end</span> are being streamed in.
        - DATA is always 1024 wide.
        - WEIGHT is always 3072 wide.
        - OP is always 8 wide. See [control_unit/instruction_set.md](../control_unit/instruction_set.md) for the op codes.


