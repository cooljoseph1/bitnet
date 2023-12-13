from forward import swap

def g_times_dFdx(g, m):
    return [
        ((g[0] ^ m[0]) + (g[1] ^ m[3]) + (g[2] ^ m[6])) > 1,
        ((g[0] ^ m[1]) + (g[1] ^ m[4]) + (g[2] ^ m[7])) > 1,
        ((g[0] ^ m[2]) + (g[1] ^ m[5]) + (g[2] ^ m[8])) > 1 
    ]

def g_times_dFdW(g, m):
    return [
        g[0] ^ m[0],
        g[0] ^ m[1],
        g[0] ^ m[2],
        g[1] ^ m[3],
        g[1] ^ m[4],
        g[1] ^ m[5],
        g[2] ^ m[6],
        g[2] ^ m[7],
        g[2] ^ m[8]
    ]

def min_flag(x, W):
    return [
        (x[0] ^ W[0] ^ x[1] ^ W[1]) & (x[0] ^ W[0] ^ x[2] ^ W[2]),
        (x[1] ^ W[1] ^ x[0] ^ W[0]) & (x[1] ^ W[1] ^ x[2] ^ W[2]),
        (x[2] ^ W[2] ^ x[0] ^ W[0]) & (x[2] ^ W[2] ^ x[1] ^ W[1]),
        (x[0] ^ W[3] ^ x[1] ^ W[4]) & (x[0] ^ W[3] ^ x[2] ^ W[5]),
        (x[1] ^ W[4] ^ x[0] ^ W[3]) & (x[1] ^ W[4] ^ x[2] ^ W[5]),
        (x[2] ^ W[5] ^ x[0] ^ W[3]) & (x[2] ^ W[5] ^ x[1] ^ W[4]),
        (x[0] ^ W[6] ^ x[1] ^ W[7]) & (x[0] ^ W[6] ^ x[2] ^ W[8]),
        (x[1] ^ W[7] ^ x[0] ^ W[6]) & (x[1] ^ W[7] ^ x[2] ^ W[8]),
        (x[2] ^ W[8] ^ x[0] ^ W[6]) & (x[2] ^ W[8] ^ x[1] ^ W[7])
    ]

def binterweave(x, w, trit, grad):
    grad = swap(grad, trit)
    x = swap(x, trit)
    n = len(x) // 3
    min_flags = [
        min_flag(x[3 * i : 3 * i + 3], w[9 * i : 9 * i + 9])
        for i in range(n)
    ]
    min_flags = [mi for f in min_flags for mi in f]
    x_grad = [
        g_times_dFdx(grad[3 * i : 3 * i + 3], min_flags[9 * i : 9 * i + 9])
        for i in range(n)
    ]
    x_grad = [xi for f in x_grad for xi in f]

    w_grad = [
        g_times_dFdW(grad[3 * i : 3 * i + 3], min_flags[9 * i : 9 * i + 9])
        for i in range(n)
    ]
    w_grad = [wi for f in w_grad for wi in f]

    x_grad = swap(x_grad, trit, reverse=True)
    return x_grad, w_grad
