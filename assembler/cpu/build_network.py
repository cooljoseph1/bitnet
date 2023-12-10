import json

with open('instructions.json', 'r') as f:
    instruction_set = json.load(f)

def to_machine_code(instr):
    return instruction_set.index(instr)

def f_fc(T):
    ops = []
    for t in range(trits):
        ops += [
            f"TRIT = {t}",
            f"W = *A",
            f"PUSH X",
            f"INTERWEAVE",
            f"A_INCREMENT",
        ]
    return ops

def b_fc(T):
    ops = []
    for t in range(T-1, 0, -1):
        ops += [
            f"A_DECREMENT",
            f"W = *A",
            f"TRIT = {t}",
            f"POP X",
            f"BACKPROP",
            f"STOCH GRAD"
        ]
    return ops

def f_res(N, T):
    ops = ["Y = X"]
    for i in range(N):
        ops += ["X = Y"]
        ops += fc(T)
        # oops we need another register for residual...