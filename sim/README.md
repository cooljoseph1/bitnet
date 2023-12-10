# Test Benching

## Running a simulation

```
iverilog -g2012 your_test_bench.sv hdl/**/*.sv hdl/**/*.v hdl/*sv -o test.out
vvp test.out
gtkwave dump.vcd
```