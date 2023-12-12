def successor(i, k):
    if i % (3 * k) > k:
        return i - 2*k
    return i + k

def predecessor(i, k):
    if i % (3 * k) < k:
        return i + 2*k
    return i - k

def adj(i, j, k):
    if j == 0:
        return i
    elif j == 1:
        return successor(i, k)
    else:
        return predecessor(i, k)

def interweave(x, w, trit):
    k = 3 ** trit
    s = len(x)
    
    x = [
        ((x[adj(i,0,k)] ^ w[3*i]) + (x[adj(i,1,k)] ^ w[3*i+1]) + (x[adj(i,2,k)] ^ w[3*i+2])) > 1
        for i in range(s)
    ]

    return x

def interstitial(x, ww, trit, m):
    y = [xi * (m-1) for xi in x]
    xx = []
    for i in range(m):
        z = interweave(x, ww[i], trit)
        xx.append(z)
        y = [yi + zi for yi, zi in zip(y, z)]
    x = [yi >= m for xi, yi in zip(x, y)]
    xx.append(x)
    return x, xx

def fc(x, www, m, n):
    xxx = []
    for trit in range(n):
        x, xx = interstitial(x, www[trit], trit, m)
        xxx.append(xx)
    return x, xxx

def network(x, wwww, m, n, layers):
    xxxx = []
    for layer in range(layers):
        x, xxx = fc(x, wwww[layer], m, n)
        xxxx.append(xxx)
    return x, xxxx