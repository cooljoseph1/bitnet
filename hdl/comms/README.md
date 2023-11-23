# Communication Protocol

## Bit Structure

A message might look like:
<span style="color:red">1</span>
<span style="color:magenta">0010</span>
<span style="color:orange">10010101110...</span>

- The <span style="color:red">first bit</span> tells the receiver that a message is being sent.
- The <span style="color:magenta">next four bits</span> tells the computer what operation to apply. Operations:
    - RECV - Stream in 1024 bits.
    - SEND - Stream out 1024 bits.
    - SET - Sets the value at the `X` register to the `C` register.
    - GET - Gets the value from the `Y` register for the `C` register.
    - FFC - Runs an fast-fully connected layer.

- The <span style="color:orange">varying bits at the end</span> are for streaming data back and forth etc.