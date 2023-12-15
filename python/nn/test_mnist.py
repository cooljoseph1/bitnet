from forward import network
from backward import bnetwork
from gray import to_gray, from_gray

import matplotlib.pyplot as plt
from copy import deepcopy

import os
import random
random.seed(1)

from torchvision.datasets import MNIST
import torchvision.transforms as transforms

file_dir = os.path.dirname(os.path.abspath(__file__))
mnist_path = os.path.join(file_dir, "..", "data/")
mnist = MNIST(root=mnist_path, train=True, download=True, transform=transforms.ToTensor())

def sample():
    image, label = random.choice(mnist)
    x = [int(xi) for xi in (image.squeeze()[:27, :27] > 0.5).flatten()]
    y = [i//72 == label for i in range(729)]
    return x, y, label

def update(w, gw, lr=1e-1):
    if isinstance(w, list):
        return [update(wi, gwi, lr) for wi, gwi in zip(w, gw)]
    return w ^ gw if random.random() < lr else w

m, n, layers = 4, 6, 3
wwww_init = [[[[random.randint(0, 1) for r in range(3 ** (n+1))] for s in range(m)] for t in range(n)]for l in range(layers)]

for lr in [1e-1]:
    loss = []
    wwww = deepcopy(wwww_init)
    iters = 100
    for i in range(iters):
        x, y, l = sample()
        o, xxxx = network(x, wwww, m, n, layers)
        grad = [oi ^ yi for oi, yi in zip(o, y)]
        loss.append(sum(grad))
        print(i, loss[-1])

        p = [sum(o[72*i:72*(i+1)]) for i in range(10)]
        p = [pi / sum(p) for pi in p]

        gx, gwwww = bnetwork(xxxx, wwww, m, n, layers, grad)
        wwww = update(wwww, gwwww, lr)

    plt.plot(range(iters), loss, label=f"lr={lr:.1f}")

plt.legend()
plt.xlabel("Training Iteration")
plt.ylabel("Incorrect Bits")
plt.show()