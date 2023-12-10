var instructionDictionary = {
  "SET_I_TO_0": 0,
  "SET_TRIT_TO_NEXT_VALUE": 1,
  "SET_H_TO_NEXT_VALUE": 2,
  "D_INCREMENT": 3,
  "D_DECREMENT": 4,
  "A_INCREMENT": 5,
  "A_DECREMENT": 6,
  "SET_X_TO_VALUE_AT_D0": 7,
  "SET_Y_TO_VALUE_AT_D1": 8,
  "SET_XY_TO_VALUE_AT_D": 9,
  "SET_INFERENCE_TO_Y": 10,
  "SET_W_TO_VALUE_AT_A": 11,
  "SET_VALUE_AT_A_TO_W": 12,
  "SET_X_TO_VALUE_AT_H": 13,
  "SET_VALUE_AT_H_TO_X": 14,
  "SWAP_XY": 15,
  "SET_X_TO_Y": 16,
  "SET_Y_TO_X": 17,
  "SET_X_TO_X_XOR_Y": 18,
  "SET_Y_TO_X_XOR_Y": 19,
  "SET_X_TO_X_AND_Y": 20,
  "SET_Y_TO_X_AND_Y": 21,
  "SET_X_TO_X_OR_Y": 22,
  "SET_Y_TO_X_OR_Y": 23,
  "INTERWEAVE": 24,
  "BACKPROP": 25,
  "STOCH_GRAD": 26
};

// var instructionDictionary = instructionSet.reduce((acc, value, index) => {
//     acc[index] = value.trim().replaceAll(' ', '').toUpperCase();
//     return acc;
//   }, {});

console.log(instructionDictionary);