def to_gray(x):
    # x is a list of bits in least significant order
    x = [xi ^ si for xi, si in zip(x, x[1:])] + [x[-1]]
    return x

def from_gray(x):
    # x is a list of bits in least significant order
    n = 2 * len(x).bit_length()
    i = 1
    while i < n:
        x = [xi ^ si for xi, si in zip(x, x[i:])] + x[-i:]
        i *= 2
    return x