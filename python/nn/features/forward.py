def adj(i, j, k, s):
    return (i + j*k) % s

def feature(x, f, k):
    s = len(x)
    return [
        int(all(x[adj(i,j-1,k,s)] == f[i][j] for j in range(3)))
        for i in range(s)
    ]

def conv(x, ff, k, h):
    xx = []
    xx.append(x)
    x = feature(x, ff[0], k)
    xx.append(x)
    x = feature(x, ff[1], k * 3 ** h)
    return x, xx

def features(x, fff, k, h, m):
    z = [0 for _ in x]
    xxx = []
    for i in range(m):
        y, xx = conv(x, fff[i], k, h)
        xxx.append(xx)
        z = [yi | zi for yi, zi in zip(y, z)]
    x = z
    return z, xxx

def fc(x, ffff, m, n):
    h = n // 2
    xxxx = []
    for i in range(h):
        x, xxx = features(x, ffff[i], 3**i, h, m)
        xxxx.append(xxx)
    return x, xxxx

def network(x, fffff, m, n, layers):
    xxxxx = []
    for i in range(layers):
        x, xxxx = fc(x, fffff[i], m, n)
        xxxxx.append(xxxx)
    return x, xxxxx