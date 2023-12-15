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
wwww = [[[[random.randint(0, 1) for r in range(3 ** (n+1))] for s in range(m)] for t in range(n)]for l in range(layers)]


fig, ax1 = plt.subplots(figsize=(8, 5))

ax1.set_xlabel("Training Iteration")
ax1.set_ylabel("Incorrect Bits")
ax2 = ax1.twinx()
ax2.set_ylabel("Prediction Accuracy")

lr = 1e-1
loss = []
acc = []
iters = 100
for i in range(iters):
    x, y, l = sample()
    o, xxxx = network(x, wwww, m, n, layers)
    grad = [oi ^ yi for oi, yi in zip(o, y)]
    loss.append(sum(grad))

    p = [sum(o[72*i:72*(i+1)]) for i in range(10)]
    p = [pi / sum(p) for pi in p]
    acc.append(p[l])
    print(i, loss[-1], acc[-1])

    gx, gwwww = bnetwork(xxxx, wwww, m, n, layers, grad)
    wwww = update(wwww, gwwww, lr)

ax1.plot(range(iters), loss, label=f"Incorrect Bits", color="red")
ax2.plot(range(iters), acc, label=f"Accuracy", color="blue")
line1, label1 = ax1.get_legend_handles_labels()
line2, label2 = ax2.get_legend_handles_labels()
plt.legend(line1 + line2, label1 + label2, loc="best")
plt.tight_layout()
plt.show()