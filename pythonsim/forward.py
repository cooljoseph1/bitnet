def swap(x, bit):
    k = 2 ** bit
    return [x[i ^ k] for i in range(len(x))]

def interweave(x, w, b, bit):
    x = swap(x, bit)
    x = [i ^ j for i, j in zip(x, w)]
    x = [(x[i - 1] + x[i] + b[i]) > 1 for i in range(len(x))]
    x = swap(x, bit)
    return x

def fc(x, ww, bb, n):
    # x is of length 2 ** n
    xx = []
    for bit in range(n):
        w, b = ww[bit], bb[bit]
        xx.append(x)
        x = interweave(x, w, b, bit)
    return x, xx

def residual(x, www, bbb, n, m):
    y = [1 for _ in range(len(x))]
    xxx = []
    for i in range(m):
        ww, bb = www[i], bbb[i]
        z, xx = fc(x, ww, bb, n)
        xxx.append(xx)
        xxx.append(z)
        y = [yi & zi for yi, zi in zip(y, z)]
    xxx.append(y)
    x = [xi ^ yi for xi, yi in zip(x, y)]
    return x, xxx

def network(x, wwww, bbbb, n, m, layers):
    xxxx = []
    for layer in range(layers):
        www, bbb = wwww[layer], bbbb[layer]
        x, xxx = residual(x, www, bbb, n, m)
        xxxx.append(xxx)
    return x, xxxx