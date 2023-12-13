def swap(x, trit, reverse=False):
    k = 3 ** trit
    n = len(x)
    if reverse:
        new_x = [x[i] if i%3 == 0 else x[(i + k) % n] if i%3 == 1 else x[(i - k) % n] for i in range(n)]
    else:
        new_x = [x[i] if i%3 == 0 else x[(i - k) % n] if i%3 == 1 else x[(i + k) % n] for i in range(n)]
    return new_x

def F(x, W):
    xnew = [
        (x[0] ^ W[0]) + (x[1] ^ W[1]) + (x[2] ^ W[2]) > 1,
        (x[0] ^ W[3]) + (x[1] ^ W[4]) + (x[2] ^ W[5]) > 1,
        (x[0] ^ W[6]) + (x[1] ^ W[7]) + (x[2] ^ W[8]) > 1
    ]
    return xnew

def interweave(x, w, trit):
    x = swap(x, trit)
    n = len(x) // 3
    x = [
        F(x[3 * i : 3 * i + 3], w[9 * i : 9 * i + 9])
        for i in range(n)
    ]
    x = [xi for f in x for xi in f]
    x = swap(x, trit, reverse=True)
    return x
