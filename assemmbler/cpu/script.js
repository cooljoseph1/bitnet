function assemble() {
    const inputTextarea = document.getElementById('inputCode');
    const outputTextarea = document.getElementById('outputCode');

    const inputCode = inputTextarea.value.trim().split('\n');
    let machineCode = '';

    for (let i = 0; i < inputCode.length; i++) {
        const instruction = inputCode[i].trim().replaceAll(' ', '').toUpperCase();

        if (instructionDictionary.hasOwnProperty(instruction)) {
            machineCode += instructionDictionary[instruction];
        } else {
            inputTextarea.setCustomValidity(`Invalid instruction on line ${i + 1}`);
            inputTextarea.reportValidity();
            return;
        }

        machineCode += '\n'; // Separate lines for each instruction
    }

    // Remove the last newline
    machineCode = machineCode.trim();

    inputTextarea.setCustomValidity('');

    // Display the machine code
    outputTextarea.value = machineCode;
}

function assembleAndUpdateLineNumbers() {
    const inputTextarea = document.getElementById('inputCode');
    const lineNumbers = document.getElementById('lineNumbers');

    const lines = inputTextarea.value.split('\n');
    const lineCount = lines.length;

    let invalidInstructionIndexes = [];

    lines.forEach((line, index) => {
        const instruction = line.trim().replaceAll(' ', '').toUpperCase();
        if (!instructionDictionary.hasOwnProperty(instruction)) {
            invalidInstructionIndexes.push(index + 1);
        }
    });

    lineNumbers.innerHTML = Array.from({ length: lineCount }, (_, index) => {
        const lineNumber = index + 1;
        const isValid = !invalidInstructionIndexes.includes(lineNumber);
        return `<span class="${isValid ? '' : 'invalid-instruction'}">${lineNumber}</span>`;
    }).join('<br>');
}
