import comms

# Set INFERENCE to the OR of all DATA X's.
ops = [7, 22, 15, 10, 3]
for i, op in enumerate(ops):
    comms.send('op', i, bin(op)[2:])

# Seed DATA
comms.send('data', 0, '01'*1024)

# Read INFERENCE
for i in range(100):
    print(recv('inf', 0))