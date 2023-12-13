from forward import adj
def binterweave(x, maj, w, trit, grad):
    k = 3**trit
    # print("::::", grad)
    # print("....", maj)
    x_grad = [
        sum(grad[adj(i,j,k)] ^ maj[adj(i,j,k)][2-j] for j in range(3)) > 1
        for i in range(len(grad))
    ]

    w_grad = [grad[i//3] for i in range(3*len(grad))] # strangely trains better if not worrying about majority
    w_grad = [grad[i//3]^maj[i//3][i%3] for i in range(3*len(grad))]
    return x_grad, w_grad

def binterstitial(xx, ww, trit, m, grad):
    ww_grad = []
    y = [gi*(m-1) for gi in grad]
    maj = xx[-1]
    for i in range(m)[::-1]:
        x, maj, w = xx[2*i], xx[2*i+1], ww[i]
        x_grad, w_grad = binterweave(x, maj, w, trit, grad)
        y = [yi + z for yi, z in zip(y, x_grad)]
        ww_grad.append(w_grad)
    ww_grad = ww_grad[::-1]
    # Strangely trains better if we just punt the gradients backwards...
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