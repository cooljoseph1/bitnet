def successor(i, k, s):
    return (i + k) % s

def predecessor(i, k, s):
    return (i - k) % s

def adj(i, j, k, s):
    if j%3 == 0:
        return i
    elif j%3 == 1:
        return successor(i, k, s)
    else:
        return predecessor(i, k, s)

def interweave(x, w, trit):
    k = 3 ** trit
    s = len(x)
    
    xor = [
        [(x[adj(i,j,k,s)] ^ w[3*i+j]) for j in range(3)] for i in range(s)
    ]
    x = [(xori[0] + xori[1] + xori[2]) > 1 for xori in xor]
    maj = [
        [xi ^ j for j in xori] for xi, xori in zip(x, xor)
    ]

    return x, maj


def interstitial(x, ww, trit, m):
    y = [xi * (m-1) for xi in x]
    xx = []
    for i in range(m):
        z, maj = interweave(x, ww[i], trit)
        xx.append(z)
        xx.append(maj)
        y = [yi + zi for yi, zi in zip(y, z)]
    x = [yi >= m for xi, yi in zip(x, y)]
    xx.append(x)
    return x, xx

def conv(x, www, m, n):
    h = n // 2
    xxx = []
    for trit in range(h):
        x, xx = interstitial(x, www[2*trit], trit, m)
        xxx.append(xx)
        x, xx = interstitial(x, www[2*trit+1], trit + h, m)
        xxx.append(xx)
    return x, xxx

def network(x, wwww, m, n, layers):
    xxxx = []
    for layer in range(layers):
        x, xxx = conv(x, wwww[layer], m, n)
        xxxx.append(xxx)
    return x, xxxx