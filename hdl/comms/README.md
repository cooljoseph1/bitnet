# Communication Protocol

## Bit Structure

A message is split by bytes due to UART. It looks like:
- 1: 00000<span style="color:magenta">01</span><span style="color:red">1</span>
- 2-3: <span style="color:green">00110110</span> <span style="color:tan">00110110</span>
- 4+: <span style="color:orange">10010101110...</span>

-----

- The first five bits are unused.
- The <span style="color:magenta">next two bits</span> tells the computer which BRAM to query:
    - <span style="color:magenta">00</span> - DATA.
    - <span style="color:magenta">01</span> - WEIGHT.
    - <span style="color:magenta">10</span> - OP.
- The <span style="color:cyan">next bit</span> tells whether to receive (0) or send (1) data, from the persepctive of the FPGA.
- The <span style="color:green">next 16 bits</span> are the address.
    - DATA has 2^16 addresses.
    - WEIGHT has 2^16 addresses.
    - OP has 2^8 addresses, so the last eight bits should be zero.
- The <span style="color:orange">varying bits at the end</span> are being streamed in.
    - DATA is always 1024 wide.
    - WEIGHT is always 1024 wide.
    - OP is always 8 wide. See `control_unit/instruction_set.md` for the op codes.


