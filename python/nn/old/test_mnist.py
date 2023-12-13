from forward import network
from backward import bnetwork
import random
import time

random.seed(1)

m, n, layers = 4, 6, 3
wwww = [[[[random.randint(0, 1) for r in range(3 ** (n+1))] for s in range(m)] for t in range(n)]for l in range(layers)]
x = [random.randint(0, 1) for r in range(3 ** n)]
y = [random.randint(0, 1) for r in range(3 ** n)]

def update(w, gw):
    if isinstance(w, list):
        return [update(wi, gwi) for wi, gwi in zip(w, gw)]
    return w ^ gw if random.random() < 0.5 else w

for iteration in range(10000):
    time.sleep(0.1)
    o, xxxx = network(x, wwww, m, n, layers)
    grad = [oi ^ yi for oi, yi in zip(o, y)]
    print("GRAD SUM =", sum(grad))
    gx, gwwww = bnetwork(xxxx, wwww, m, n, layers, grad)
    wwww = update(wwww, gwwww)
