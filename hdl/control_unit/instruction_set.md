# Instruction Set

Here is the documentation for our instruction set. Each instruction is 4 bits.
// The control unit directly passes these two on to the data unit
0 = increase data pointer by 1
1 = set data pointer to 0
// The control unit handles this directly. It saves the (x, y) pair at the current data pointer to the x and y registers
2 = fetch data from data unit
// The control unit directly passes these two on to the weight unit
3 = increase weight pointer by 1
4 = set weight pointer to 0
// The control unit handles this directly. It "fetches" weights by storing the weights to the w register
5 = fetch weights from address in weight register
// These three are handled by the control unit by passing stuff through peripherals
6 = run a forward prop through the fully connected unit using the value stored in the x register. Save the output to the y register
7 = run a forward prop through the residual unit using the value in the x register. Save the output to the y register
8 = move the contents of the y register to the x register
9 = push the contents of the x register onto the stack
10  = pop from the stack to the y register
11 = run a backward prop for the fc unit
12 = run a backward prop for the residual unit
13 = randomly change some of the weights given the back propagation "gradients"
// This is done by passing the weights to the weight unit with this instruction--it's mostly handled by the weight unit
14 = set the weights at the current address in the weight register to the current weights we hold

// This is handled by the program counter and the control unit does not even see it!
15 = read the next two instructions (8 bits) and jump to their location.
