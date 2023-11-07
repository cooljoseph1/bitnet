First, we need to implement a neural network architecture. Verilog's "typing" actually makes this very easy to do, because you must specify the number of dimensions for every input/output! We're going to keep it as simple as possible, with single bits. Although it's possible to make nonlinearities with NAND gates, Joseph noticed that the 3-bit majority function is 1) nonlinear, and 2) has symmetrical forward- and back-passes. I'd add that ternary is a superior system in terms of data-per-unit ($\log(b)\log_b(\text{data})$ which is minimized for $b=e,$ but 3 is the closest integer). Our weights will be single bits that XOR with the output.

With a nonlinearity, you can build any neural net. The first two things to build are of course fully-connected layers and residual layers. We've opted to do a kind of trit-flipping scheme for the fully connected layers:
- Suppose you have $3^n$ inputs, indexed from $\overline{00\dots0}_3$ to $\overline{22\dots2}_3$.
- For each trit position $0$ to $n-1$:
	- Toggle the trit to get two other indices, and perform the majority function on these.
	- XOR with three weights.
	- Overall we should have $3\cdot 3^{n-1} = 3^{n}$ new values for the next trit position.

It's basically a tree, but instead of $3\to 1$ each layers, we keep the same number of nodes. I'm pretty sure for universality you need at least $O(N\log N)$ comparisons, so this hits that intuitive minimum. Also, note that if we didn't do the XOR'ing with weights, all the outputs would be the same (equals a kind of volume).

Anyways, our first goal is to get MNIST running. I doubt we'll have time, but a chess engine would also be really cool. Memory-wise, we should be able to fit both on the FPGA, but unfortunately there aren't enough logic cells to hold the entire network. Instead, we'll store the weights in BRAM and load them for each residual layer. Or, maybe we don't even have enough logic units for an entire residual layer and we'll have to do one fully connected layer at a time.

For our data, we'll need to transfer it from the CPU to the FPGA. We haven't decided exactly how to do this, but right now the plan is to download some USB IP. Honestly, it'd probably be best to talk to you about this step, because Xilinx's website says "contact your local sales representative" which isn't encouraging.

We'll store the data on the registers, and we'll update it with the new values after each layer of the neural network. Our architecture doesn't need to store them for the back-propagation.

One thing we need to be careful about is the input/output bit structure. If we simply use binary numbers, it will be very sensitive to errors, so we'll use Gray encoding.

![[nn_blocks.png]]
![[cpu_blocks.png]]

### Modules:

**Weight/Data Transfer over USB:**
- (Xilinx)

**BRAM:**
- We'll use the one you gave us, one for data, one for weights, and another for weight accumulating (see below).

**3-in-3-out:**
- Combinational
- Implements the majority function, then adds weights.
- Inputs: `[2:0] x_in, [2:0] w_in`
- Outputs: `[2:0] x_out`. 

**Interleave Layer:**
- Combinational
- Parameters: `N`
- Inputs: `[N-1:0] x_in, [N-1:0] w_in, trit_pos`
- Outputs: `[N-1:0] x_out`.
- We can actually implement the backwards pass by sending $$x_\text{in} = \text{gradient},\qquad w_\text{in} = 0,\qquad \text{trit pos} = \log_3(N) - 1 - \text{trit pos}.$$
**Fully Connected Layer:**
- Combinational
- Parameters: `N`
- Inputs: `[N-1:0] x_in, [N-1:0] w_in
- Outputs: `[N-1:0] x_out`.
This is a bunch of interleave layers with all possible `trit_pos` in order.

**Residual Layer:**
- Combinational
- Parameters: `N`, `BRANCHES`
- Inputs: `[N-1:0] x_in, [N-1:0] w_in`
- Outputs: `[N-1:0] x_out`.
This makes `BRANCHES` different fully connected layers, and only changes the value at an input if all of the fully connected layers agree it should change.

**Central Processing Unit:**
- A state machine containing the architecture of the neural network: what layers we have, which BRAM indices to grab data/weights from, etc.
- Inputs: `x_in`, (training inputs) `y_in` (correct outputs), `y'_in` (output of the neural network block) `w_in`, `grad_in`, `flip_weight_in`
- Outputs: `x_out`, `w'_out`, `grad_out`.

**Neural Net Block:**
- Either a residual layer or fully connected layer depending on which can fit on our FPGA.
- If it's a fully connected layer, the central processing unit will contain some extra logic to feed in the correct trits.
- If it's a residual layer, the neural net block will contain some extra logic to handle forward/backward trits.

**Weight Accumulator:**
- If we flip the weights every backwards pass, that's way too high of a learning rate! Instead, we'll accumulate many training runs and only flip once it reaches a threshold.
- Parameters: `THRESHOLD`
- Inputs: `grad_in`, `accum_in` (saved accumulations from the  BRAM)
- Outputs: `flip_weight_out`, `accum_out` (new accumulations to be saved in BRAM)
- It interacts with the two BRAMS and the central processing unit.

