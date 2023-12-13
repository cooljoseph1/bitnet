from forward import network
from backward import bnetwork
from gray import to_gray, from_gray

import random
random.seed(1)
import time
import os

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

m, n, layers = 4, 6, 3
wwww = [[[[random.randint(0, 1) for r in range(3 ** (n+1))] for s in range(m)] for t in range(n)]for l in range(layers)]
x = [1,0,1]*(3**(n-1))
y = [0,1,0]*(3**(n-1))
x = [random.randint(0, 1) for r in range(3 ** n)]
y = [random.randint(0, 1) for r in range(3 ** n)]

def update(w, gw):
    if isinstance(w, list):
        return [update(wi, gwi) for wi, gwi in zip(w, gw)]
    return w ^ gw if random.random() < 0.1 else w

a = 0
for iteration in range(10000):
    x, y, l = sample()
    o, xxxx = network(x, wwww, m, n, layers)
    grad = [oi ^ yi for oi, yi in zip(o, y)]

    # ps = [int("".join(str(int(oi)) for oi in from_gray(o[72*i:72*(i+1)])), 2) for i in range(10)]
    ps = [sum(o[72*i:72*(i+1)]) for i in range(10)]
    ps = [p / sum(ps) for p in ps]

    a += ps[l]
    print("GRAD SUM =", sum(grad), "LABEL =", l, "ACC =", a/(1+iteration))
    print("".join(str(int(i)) for i in o[:10]))
    gx, gwwww = bnetwork(xxxx, wwww, m, n, layers, grad)
    wwww = update(wwww, gwwww)
