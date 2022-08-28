# The Ibnalhaytham CPU

This project is consisted of a memory controller and a processor; The processor is a RISC-V based pipelined processor with 16 registers. The memory controller simulates an instruction memory and has 10 32bit words as the data memory, the contents of which are outputted to io_out periodically. The simulated instruction memory is in fact an interface between the caravel management core and the processor, it can stall the processor until the next instruction arrives from the management core.

diagram

## Processor
supported instructions
signals
## Memory Controller
what it does
signals
## Test it yourself

## Final GDS

## TODO
use smaller memory and register addresses
test the memory controler for openram

