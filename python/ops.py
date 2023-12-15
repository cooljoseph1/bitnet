def interweave(stack, trit):
    stack = stack + 1
    return stack, [
        "SET_H_TO_NEXT_VALUE",
        stack,
        "SET_VALUE_AT_H_TO_X",
        "SET_TRIT_TO_NEXT_VALUE",
        trit,
        "SET_W_TO_VALUE_AT_A",
        "A_INCREMENT",
        "INTERWEAVE",
    ]

def fc(stack, trits):
    ops = []
    for trit in range(trits):
        stack, op = interweave(stack, trit)
        ops += op
    return stack, ops

def network(stack, trits, layers):
    ops = []
    for layer in range(layers):
        stack, op = fc(stack, trits)
        ops += op
    return stack, ops

def binterweave(stack, trit):
    return stack-1, [
        "SET_H_TO_NEXT_VALUE",
        stack,
        "SET_X_TO_VALUE_AT_H",
        "SET_TRIT_TO_NEXT_VALUE",
        trit,
        "A_DECREMENT",
        "SET_W_TO_VALUE_AT_A",
        "BACKPROP",
        "STOCH_GRAD",
        "SET_VALUE_AT_A_TO_W"
    ]

def bfc(stack, trits):
    ops = []
    for trit in range(trits)[::-1]:
        stack, op = binterweave(stack, trit)
        ops += op
    return stack, ops

def bnetwork(stack, trits, layers):
    ops = []
    for layer in range(layers):
        stack, op = bfc(stack, trits)
        ops += op
    return stack, ops

def train(trits, layers):
    stack = 0
    ops = ["SET_X_TO_VALUE_AT_D0", "D_INCREMENT"]
    stack, op = network(stack, trits, layers)
    ops += op
    ops += ["SET_Y_TO_VALUE_AT_D1", "SET_Y_TO_X_XOR_Y"]
    ops += ["SET_INFERENCE_TO_Y"] # For gradient readout
    stack, op = bnetwork(stack, trits, layers)
    ops += op
    return ops