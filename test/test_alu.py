import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, Timer
import random

async def reset(dut):
    dut.reset.value = 1

    await ClockCycles(dut.clk, 5)
    dut.reset.value = 0

# async def set_write(i):
#     dut.address_3.value = i
# async def write_m(data):
#     dut.write_data.value = data

@cocotb.test()
async def test_pwm(dut):
    clock = Clock(dut.clk, 10, units="us")
    cocotb.fork(clock.start())
    # await reset(dut)
    dut.src_a.value = 45
    dut.src_b.value = -67


    # test a range of values
    for i in range(0, 11):
        # set pwm to this level
        # await FallingEdge(dut.clk)
        dut.alu_control.value = i
        # await Timer(1, units='us')

        # data = random.randint(0, 4294967295)
        # dut.write_data.value = data
        # await Timer(1000, units='ps')
        # wait pwm level clock steps
        await ClockCycles(dut.clk, 5)

        # assert still high
        # if (i != 0):
        # if ( i <= 126):
        #     assert(dut.read_data.value == data)
        # else:
        #     assert(dut.read_data.value == 0)

