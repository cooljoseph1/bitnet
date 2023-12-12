from forward import adj
def binterweave(x, w, trit, grad):
    k = 3**trit
    s = len(grad)
    x_grad = [
        sum(grad[adj(i,j,k)] for j in range(3)) > 1
        for i in range(s)
    ]

    w_grad = [grad[i//3] for i in range(3*s)]
    return x_grad, w_grad

def binterstitial(xx, ww, trit, m, grad):
    ww_grad = []
    y = [gi*(m-1) for gi in grad]
    maj = xx[-1]
    for i in range(m)[::-1]:
        x, w = xx[i], ww[i]
        x_grad, w_grad = binterweave(x, w, trit, grad)
        y = [yi + z for yi, z in zip(y, x_grad)]
        ww_grad.append(w_grad)
    ww_grad = ww_grad[::-1]
    grad = [yi >= m for gi, yi in zip(grad, y)]
    return grad, ww_grad

def bfc(xxx, www, m, n, grad):
    www_grad = []
    for trit in range(n)[::-1]:
        xx, ww = xxx[trit], www[trit]
        grad, ww_grad = binterstitial(xx, ww, trit, m, grad)
        www_grad.append(ww_grad)
    www_grad = www_grad[::-1]
    return grad, www_grad

def bnetwork(xxxx, wwww, m, n, layers, grad):
    wwww_grad = []
    for layer in range(layers)[::-1]:
        xxx, www = xxxx[layer], wwww[layer]
        grad, www_grad = bfc(xxx, www, m, n, grad)
        wwww_grad.append(www_grad)
    wwww_grad = wwww_grad[::-1]
    return grad, wwww_grad