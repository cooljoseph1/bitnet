from forward import network
from backward import bnetwork

import matplotlib.pyplot as plt
from copy import deepcopy

import os
import random
random.seed(1)

m, n, layers = 4, 6, 3
wwww_init = [[[[random.randint(0, 1) for r in range(3 ** (n+1))] for s in range(m)] for t in range(n)]for l in range(layers)]
x = [random.randint(0, 1) for r in range(3 ** n)]
y = [random.randint(0, 1) for r in range(3 ** n)]

def update(w, gw, lr=1e-1):
    if isinstance(w, list):
        return [update(wi, gwi, lr) for wi, gwi in zip(w, gw)]
    return w ^ gw if random.random() < lr else w

for lr in [1e-0, 5e-1, 2e-1, 1e-1]:
    loss = []
    wwww = deepcopy(wwww_init)
    iters = 50
    for i in range(iters):
        o, xxxx = network(x, wwww, m, n, layers)
        grad = [oi ^ yi for oi, yi in zip(o, y)]
        loss.append(sum(grad))

        gx, gwwww = bnetwork(xxxx, wwww, m, n, layers, grad)
        wwww = update(wwww, gwwww, lr)

    plt.plot(range(iters), loss, label=f"lr={lr:.1f}")

plt.legend()
plt.xlabel("Training Iteration")
plt.ylabel("Incorrect Bits")
plt.show()