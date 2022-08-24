import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, Timer
import random

def text_to_decimal(text):
    ascii_values = [ord(character) for character in text]
    a =int(''.join(str(bin(i)[2:].zfill(8)) for i in ascii_values), 2)
    return a

def opb(a):
    return int(bin(int(a, 16))[2:].zfill(32)[-7:], 2)
def funct3b(a):
    return int(bin(int(a, 16))[2:].zfill(32)[-15:-12], 2)
def funct7_5b(a):
    return int(bin(int(a, 16))[2:].zfill(32)[-31], 2)
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
    # dut.write_enable.value = 1
    instruction = ["addi", "or", "and", "add", "beq", "slt", "sub", "sw", "lw", "jal" ]
    op = [opb("00500113"), opb("0023E233"), opb("0041F2B3"), opb("004282B3"), opb("02728863"), opb("0041A233"), opb("402383B3"), opb("0471AA23"), opb("06002103"), opb("008001EF")]
    funct3 = [funct3b("00500113"), funct3b("0023E233"), funct3b("0041F2B3"), funct3b("004282B3"), funct3b("02728863"), funct3b("0041A233"), funct3b("402383B3"), funct3b("0471AA23"), funct3b("06002103"), funct3b("008001EF")]
    funct7_5 = [funct7_5b("00500113"), funct7_5b("0023E233"), funct7_5b("0041F2B3"), funct7_5b("004282B3"), funct7_5b("02728863"), funct7_5b("0041A233"), funct7_5b("402383B3"), funct7_5b("0471AA23"), funct7_5b("06002103"), funct7_5b("008001EF")]
    # print(op)
    # print(funct3)
    # print(funct7_5)
    # print(len(op))
    # test a range of values
    for i in range(0, len(op)):
        dut.op.value = op[i]
        dut.funct3.value = funct3[i]
        dut.funct7_5.value = funct7_5[i]
        dut.inst.value = text_to_decimal(instruction[i])


        # print(op[i])
        # set pwm to this level
        # await FallingEdge(dut.clk)
        # # dut.address_1.value = i
        # await Timer(1, units='us')
        # # dut.address_2.value = i
        # await Timer(1, units='us')
        # dut.address_3.value = i
        # await Timer(1, units='us')
        # data = random.randint(0, 4294967295)
        # dut.write_data.value = data
        # await Timer(1000, units='ps')
        # wait pwm level clock steps
        await ClockCycles(dut.clk, 5)

        # # assert still high
        # if (i != 0):
        #     assert(dut.read_data_1.value == data)
        #     assert(dut.read_data_2.value == data)
