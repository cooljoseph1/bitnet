from forward import adj

def bfeature(x, f, k, back_x):
    s = len(x)
    bx = [
        int(sum(1 ^ back_x[adj(i,1-j,k,s)] ^ f[adj(i,1-j,k,s)][j] for j in range(3)) > 1)
        for i in range(s)
    ]
    
    bf = [
        [1 ^ back_x[i] ^ x[adj(i,1-j,k,s)] for j in range(3)]
        for i in range(s)
    ]

    return bx, bf

def bconv(xx, ff, k, h, back_x):
    bff = []
    x, f = xx[1], ff[1]
    back_x, bf = bfeature(x, f, k * 3** h, back_x)
    bff.append(bf)
    x, f = xx[0], ff[0]
    back_x, bf = bfeature(x, f, k, back_x)
    bff.append(bf)
    return back_x, bff[::-1]

def bfeatures(xxx, fff, k, h, m, back_x):
    z = [0 for _ in back_x]
    bfff = []
    for i in range(m)[::-1]:
        xx, ff = xxx[i], fff[i]
        bx, bff = bconv(xx, ff, k, h, back_x)
        bfff.append(bff)
        z = [zi + bxi for zi, bxi in zip(z, bx)]
    bfff = bfff[::-1]
    # back_x = [zi > m//2 for zi in z]
    # print(back_x)
    return back_x, bfff

def bfc(xxxx, ffff, m, n, back_x):
    h = n // 2
    bffff = []
    for i in range(h)[::-1]:
        xxx, fff = xxxx[i], ffff[i]
        back_x, bfff = bfeatures(xxx, fff, 3**i, h, m, back_x)
        bffff.append(bfff)
    bffff = bffff[::-1]
    return back_x, bffff

def bnetwork(xxxxx, fffff, m, n, layers, back_x):
    bfffff = []
    for i in range(layers)[::-1]:
        xxxx, ffff = xxxxx[i], fffff[i]
        back_x, bffff = bfc(xxxx, ffff, m, n, back_x)
        bfffff.append(bffff)
    bfffff = bfffff[::-1]
    return back_x, bfffff