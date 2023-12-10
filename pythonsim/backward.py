import random

def swap(x, bit):
    k = 2 ** bit
    return [x[i ^ k] for i in range(len(x))]

def binterweave(x, w, b, bit, grad):
    b_grad = grad
    rand = [random.randint(0, 1) for _ in range(len(grad))]
    grad = swap(grad, bit)
    x_grad = [(wi ^ gi) for wi, gi in zip(w, grad)]
    w_grad = [(xi ^ gi) for xi, gi in zip(x, grad)]
    # x_grad = [x_grad[(i + 1)%len(x_grad)] | x_grad[i] for i in range(len(x_grad))]
    # w_grad = [w_grad[(i + 1)%len(w_grad)] | w_grad[i] for i in range(len(w_grad))]
    x_grad = swap(x_grad, bit)

    return x_grad, w_grad, b_grad

def bfc(xx, ww, bb, n, grad):
    ww_grad = []
    bb_grad = []
    for bit in range(n)[::-1]:
        x, w, b = xx[bit], ww[bit], bb[bit]
        grad, w_grad, b_grad = binterweave(x, w, b, bit, grad)
        ww_grad.append(w_grad)
        bb_grad.append(b_grad)
    ww_grad = ww_grad[::-1]
    bb_grad = bb_grad[::-1]
    return grad, ww_grad, bb_grad

def bresidual(xxx, www, bbb, n, m, grad):
    www_grad = []
    bbb_grad = []
    y = [1 for _ in range(len(grad))]
    yp = xxx[-1]
    grad = [gradi ^ yi for gradi, yi in zip(grad, yp)]
    for i in range(m)[::-1]:
        xx, zp, ww, bb = xxx[2 * i], xxx[2 * i + 1], www[i], bbb[i]
        x_grad, ww_grad, bb_grad = bfc(xx, ww, bb, n, grad)
        y = [yi & z for yi, z in zip(y, x_grad)]
        www_grad.append(ww_grad)
        bbb_grad.append(bb_grad)

    www_grad = www_grad[::-1]
    bbb_grad = bbb_grad[::-1]
    #grad = [gradi ^ yi for gradi, yi in zip(grad, y)]
    return grad, www_grad, bbb_grad

def bnetwork(xxxx, wwww, bbbb, n, m, layers, grad):
    wwww_grad = []
    bbbb_grad = []
    for layer in range(layers)[::-1]:
        xxx, www, bbb = xxxx[layer], wwww[layer], bbbb[layer]
        grad, www_grad, bbb_grad = bresidual(xxx, www, bbb, n, m, grad)
        wwww_grad.append(www_grad)
        bbbb_grad.append(bbb_grad)
    wwww_grad = wwww_grad[::-1]
    bbbb_grad = bbbb_grad[::-1]
    return grad, wwww_grad, bbbb_grad