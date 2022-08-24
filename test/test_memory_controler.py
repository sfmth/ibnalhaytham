import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, Timer
import random

async def reset(dut):
    dut.reset.value = 1

    await ClockCycles(dut.clk, 5)
    dut.reset.value = 0

async def processor_sim(dut):
    while True:
        await RisingEdge(dut.clk)
        if (not dut.stall.value):
            # assert(dut.inst_mem_read.value == dut.inst_mem_addr.value)
            dut.inst_mem_addr.value = random.randint(0, 4294967295)

async def rambus(dut):
    dut.io_in.value = 1
    while True:
        await FallingEdge(dut.clk)
        if (dut.rambus_wb_cyc_o.value and dut.rambus_wb_stb_o.value  ):
            await RisingEdge(dut.clk)
            dut.rambus_wb_dat_i.value = dut.inst_mem_addr.value
            dut.rambus_wb_ack_i.value = 1
        else:
            dut.rambus_wb_ack_i.value = 0

async def la_inst_mem(dut):
    dut.io_in.value = 3
    while True:
        await Timer(random.randint(0, 100), units='us')
        
        # await RisingEdge(dut.clk)
        dut.la_data_in.value = dut.inst_mem_addr.value
        await Timer(random.randint(0, 100), units='us')
        dut.la_oenb.value = 0
        await Timer(random.randint(0, 100), units='us')
        dut.la_oenb.value = 1
        # else:
            # dut.rambus_wb_ack_i.value = 0
# async def wishbone_inst_write()  
        
# async def set_write(i):
#     dut.address_3.value = i
# async def write_m(data):
#     dut.write_data.value = data

@cocotb.test()
async def test_pwm(dut):
    clock = Clock(dut.clk, 10, units="us")
    cocotb.fork(clock.start())
    await reset(dut)
    # dut.src_a.value = 45
    # dut.src_b.value = -67
    delay = []
    data = []
    for i in range(0, 100):
        delay.append(random.randint(1, 6))
        data.append(random.randint(0, 150))

    dut.stall.value = 0
    cocotb.fork(processor_sim(dut))
    cocotb.fork(la_inst_mem(dut))
    # test a range of values
    for i in range(0, 150):
        # set pwm to this level
        # await FallingEdge(dut.clk)
        # dut.alu_control.value = i
        # await Timer(1, units='us')


        # for j in range(0,100):
        #     if (data[j]==i):
        #         dut.stall.value = 1
        #         await ClockCycles(dut.clk, delay[j])
        #         dut.stall.value = 0


        # data = random.randint(0, 4294967295)
        # dut.write_data.value = data
        # await Timer(1000, units='ps')
        # wait pwm level clock steps
        await ClockCycles(dut.clk, 1)

        # assert still high
        # if (i != 0):
        # if ( i <= 126):
        #     assert(dut.read_data.value == data)
        # else:
        #     assert(dut.read_data.value == 0)
        # if (i == 149):
        #     assert(dut.data_mem_1.mem100.value == 25)
        #     assert(dut.write_data_m.value == 25)
        #     assert(dut.alu_result_m.value == 100 & dut.mem_write_m.value == 1)
        # if (dut.alu_result_m.value == 100 & dut.mem_write_m.value == 1):
        #     assert(dut.write_data_m.value == 25)

