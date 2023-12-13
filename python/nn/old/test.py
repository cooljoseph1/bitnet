from forward import network
from backward import bnetwork
import random
import time

random.seed(1)

m, n, layers = 2, 6, 1
wwww = [[[[random.randint(0, 1) for r in range(3 ** (n+1))] for s in range(m)] for t in range(n)]for l in range(layers)]
x = [1,0,1]*(3**(n-1))
y = [0,1,0]*(3**(n-1))
x = [random.randint(0, 1) for r in range(3 ** n)]
y = [random.randint(0, 1) for r in range(3 ** n)]

def update(w, gw):
    if isinstance(w, list):
        return [update(wi, gwi) for wi, gwi in zip(w, gw)]
    return w ^ gw if random.random() < 0.1 else w

for iteration in range(10000):
    x = [random.randint(0, 1) for r in range(3 ** n)]
    y = [1-xi for xi in x]
    # time.sleep(0.1)
    o, xxxx = network(x, wwww, m, n, layers)
    grad = [oi ^ yi for oi, yi in zip(o, y)]
    print("GRAD SUM =", sum(grad))
    # print("".join(str(int(i)) for i in o[:10]))
    # print("".join(str(int(i)) for i in grad[:10]))
    gx, gwwww = bnetwork(xxxx, wwww, m, n, layers, grad)
    for layer in range(layers):
        for i in range(n):
            for j in range(m):
                pass
                # print(f"LAYER {layer}, INTERWEAVE {i}, RESIDUAL {j}:\n\t", end="")
                # print("".join(str(int(k)) for k in gwwww[layer][i][j][:20]))
    wwww = update(wwww, gwwww)
