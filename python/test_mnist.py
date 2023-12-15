import interface
from ops import train

import os
import time
import random
from bitarray import bitarray

import serial
ser = serial.Serial('/dev/ttyUSB1', 4_000_000, stopbits=serial.STOPBITS_ONE, timeout=0.1) # helps it not lose bytes

from torchvision.datasets import MNIST
import torchvision.transforms as transforms

file_dir = os.path.dirname(os.path.abspath(__file__))
mnist_path = os.path.join(file_dir, "..", "data/")
mnist = MNIST(root=mnist_path, train=True, download=True, transform=transforms.ToTensor())

def sample():
    image, label = random.choice(mnist)
    x = [int(xi) for xi in (image.squeeze()[::3, ::3] > 0.5).flatten()]
    x = x + [0] * (128 - len(x))
    y = [i//12 == label for i in range(len(x))]
    return x, y, label

for i in range(512):
    x, y, l = sample()
    x = bitarray("".join(str(int(xi)) for xi in x))
    y = bitarray("".join(str(int(yi)) for yi in y))
    interface.send(ser, 'data', i, y + x)

def flash_ops(ops):
    bits = interface.prepare_op("SET_I_TO_0")
    interface.send(ser, 'op', 0, bits)

    for i, op  in enumerate(ops):
        if i == 0:
            continue
        bits = interface.prepare_op(op)
        interface.send(ser, 'op', i, bits)

    op0 = ops[0]
    bits = interface.prepare_op(op0)
    interface.send(ser, 'op', 0, bits)

ops = train(4, 3)
flash_ops(ops)
for i in range(100):
    x, y, l = sample()
    x = bitarray("".join(str(int(xi)) for xi in x))
    y = bitarray("".join(str(int(yi)) for yi in y))
    interface.send(ser, 'data', i, y + x)
    grad = interface.recv(ser, 'inf', 0)
    print(grad)

ser.close()