from forward import adj
def binterweave(x, maj, w, trit, grad):
    k = 3**trit
    s = len(x)
    x_grad = [
        sum(grad[adj(i,j,k,s)] ^ maj[adj(i,j,k,s)][2-j] for j in range(3)) > 1
        for i in range(len(grad))
    ]

    # w_grad = [grad[i//3] for i in range(3*len(grad))] # strangely trains better if not worrying about majority
    w_grad = [grad[i//3]^maj[i//3][i%3] for i in range(3*len(grad))]
    
    return x_grad, w_grad

def binterstitial(xx, ww, trit, m, grad):
    ww_grad = []
    y = [1 for gi in grad]
    for i in range(m)[::-1]:
        x, maj, w = xx[2*i], xx[2*i+1], ww[i]
        x_grad, w_grad = binterweave(x, maj, w, trit, grad)
        y = [yi & z for yi, z in zip(y, x_grad)]
        ww_grad.append(w_grad)
    ww_grad = ww_grad[::-1]
    # Strangely trains about as well if we just punt the gradients backwards...
    # i.e. comment out the below line
    grad = [gi & (1 ^ yi) for gi, yi in zip(grad, y)]
    return grad, ww_grad

def bconv(xxx, www, m, n, grad):
    h = n // 2
    www_grad = []
    for trit in range(h)[::-1]:
        xx, ww = xxx[2*trit+1], www[2*trit+1]
        grad, ww_grad = binterstitial(xx, ww, trit + h, m, grad)
        www_grad.append(ww_grad)
        xx, ww = xxx[2*trit], www[2*trit]
        grad, ww_grad = binterstitial(xx, ww, trit, m, grad)
        www_grad.append(ww_grad)
    www_grad = www_grad[::-1]
    return grad, www_grad

def bnetwork(xxxx, wwww, m, n, layers, grad):
    wwww_grad = []
    for layer in range(layers)[::-1]:
        grad, www_grad = bconv(xxxx[layer], wwww[layer], m, n, grad)
        wwww_grad.append(www_grad)
    wwww_grad = wwww_grad[::-1]
    return grad, wwww_grad