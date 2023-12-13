from forward import interweave
from backward import binterweave

import random

x = [random.randint(0, 1) for i in range(27)]
w = [random.randint(0, 1) for i in range(81)]
y = [random.randint(0, 1) for i in range(27)]

def update(w, dw):
    if type(w) == list: 
        return [update(wi, dwi) for wi, dwi in zip(w, dw)]
    return dw ^ w if random.random() < 0.1 else w

for i in range(20):
    o = interweave(x, w, 1)
    g = [oi ^ yi for oi, yi in zip(o, y)]
    print("GRAD SUM =", sum(g))
    dx, dw = binterweave(x, w, 1, g)
    # x = update(x, dx)
    w = update(w, dw)