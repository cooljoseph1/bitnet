from forward import network
from backward import bnetwork
import random

n, m, layers = 10, 6, 10
wwww = [[[[random.randint(0, 1) for r in range(2 ** n)] for s in range(n)] for z in range(m)] for l in range(layers)]
bbbb = [[[[random.randint(0, 1) for r in range(2 ** n)] for s in range(n)] for z in range(m)] for l in range(layers)]

x = [1, 0, 1, 0] * 256
y = [1] * 1024

def update(w, gw):
    if isinstance(w, list):
        return [update(wi, gwi) for wi, gwi in zip(w, gw)]
    return w if random.random() < 0.95 else gw


for iteration in range(100):
    o, xxxx = network(x, wwww, bbbb, n, m, layers)
    grad = [oi ^ yi for oi, yi in zip(o, y)]
    print("GRAD SUM =", sum(grad))
    gx, gwwww, gbbbb = bnetwork(xxxx, wwww, bbbb, n, m, layers, grad)
    wwww = update(wwww, gwwww)
    bbbb = update(bbbb, gbbbb)
