var instructionSet = [
    "TRIT = 0",
    "TRIT = 1",
    "TRIT = 2",
    "TRIT = 3",
    "TRIT = 4",
    "TRIT = 5",
    "TRIT = 6",
    "TRIT = 7",
    "TRIT = 8",
    "TRIT = 9",
    "TRIT = 10",
    "TRIT = 11",
    "TRIT = 12",
    "TRIT = 13",
    "TRIT = 14",
    "TRIT = 15",
    "I = 0",
    "D++",
    "D--",
    "A++",
    "A--",
    "X = *D[0]",
    "Y = *D[1]",
    "X, Y = *D",
    "*D[0] = X",
    "*D[1] = Y",
    "*D = X, Y",
    "W = *A",
    "*A = W",
    "X, Y = Y, X",
    "X = Y",
    "Y = X",
    "PUSH X",
    "PUSH Y",
    "POP X",
    "POP Y",
    "X = X ^ Y",
    "Y = X ^ Y",
    "X = X & Y",
    "Y = X & Y",
    "X = X | Y",
    "Y = X | Y",
    "FIX X", // sets X[i] = 0 if the trit in position TRIT of i is a 2
    "FIX Y", // sets Y[i] = 0 if the trit in position TRIT of i is a 2
    "RAND X", // sets X[i] = {a random nuber} if the trit in position TRIT of i is a 2
    "RAND Y", // sets Y[i] = {a random nuber} if the trit in position TRIT of i is a 2
    "INTERWEAVE",
    "STOCH GRAD",
]

var instructionDictionary = instructionSet.reduce((acc, value, index) => {
    acc[index] = value.trim().replaceAll(' ', '').toUpperCase();
    return acc;
  }, {});

console.log(instructionDictionary);