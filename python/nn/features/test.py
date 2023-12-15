from forward import network
from backward import bnetwork

import random
random.seed(1)
import time
import os
import numpy as np

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

n, m, layers = 6, 3, 1
fffff = [[[[[[random.randint(0, 1) for q in range(3)] for q in range(3 ** n)] for r in range(2)] for s in range(m)] for t in range(n//2)] for l in range(layers)]
x = [1,0,1]*(3**(n-1))
y = [0,1,0]*(3**(n-1))
x = [random.randint(0, 1) for r in range(3 ** n)]
y = [random.randint(0, 1) for r in range(3 ** n)]

def update(f, bf):
    if isinstance(f, list):
        return [update(fi, bfi) for fi, bfi in zip(f, bf)]
    return bf if random.random() < 0.1 else f

def sample():
    x = [random.randint(0, 1) for r in range(3 ** n)]
    y = x
    return x, y, 0

a = 0.1
for iteration in range(10000):
    x, y, l = sample()
    time.sleep(0.1)
    o, xxxxx = network(x, fffff, m, n, layers)
    grad = [oi ^ yi for oi, yi in zip(o, y)]
    # print(fffff)

    # ps = [sum(o[72*i:72*(i+1)])**2 for i in range(10)]
    # ps = [p / sum(ps) for p in ps]
    # a = 0.99 * a + 0.01 * ps[l]
    print("GRAD SUM =", sum(grad), "LABEL =", l, "ACC =", a)
    # print("".join(str(int(i)) for i in grad[:30]))
    # print(ps[l])
    # bx = []
    # for j in range(len(x)):
    #     i = j // 72
    #     if i == 10:
    #         bx.append(0)
    #     elif i == l:
    #         bx.append(random.random() > 1-ps[i])
    #     else:
    #         bx.append(random.random() > ps[i])
    bx, bfffff = bnetwork(xxxxx, fffff, m, n, layers, y)
    fffff = update(fffff, bfffff)
