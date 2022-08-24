import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, Timer
import random

def text_to_decimal(text):
    ascii_values = [ord(character) for character in text]
    a =int(''.join(str(bin(i)[2:].zfill(8)) for i in ascii_values), 2)
    return a

def int_16(a):
    return int(a,16)
def int_2(a):
    return int(bin(a),2)

async def reset(dut):
    dut.io_in[12].value = 1

    await ClockCycles(dut.wb_clk_i, 5)
    dut.io_in[12].value = 0

async def la_inst_mem(dut, inst, delay, unit):

    while True:
        await Timer(random.randint(11, delay), units=unit)
        
        # await RisingEdge(dut.clk)
        print(int(bin(dut.la1_data_out.value),2))
        # print(int(dut.la1_data_out.value,2))
        # if (dut.la1_data_out.value != 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'):
        dut.la1_data_in.value = int_16(inst[int(int_2(dut.la1_data_out.value)/4)])
        await Timer(random.randint(11, delay), units=unit)
        dut.la1_oenb.value = 0
        await Timer(random.randint(11, delay), units=unit)
        # while True:
        #     in_1 = dut.la1_data_out.value
        #     await Timer(random.randint(0, delay), units=unit)
        #     if (in_1 != dut.la1_data_out.value):
        #         break
        # await Timer(random.randint(0, delay), units=unit)
        dut.la1_oenb.value = 1

# async def set_write(i):
#     dut.address_3.value = i
# async def write_m(data):
#     dut.write_data.value = data

@cocotb.test()
async def test_pwm(dut):
    dut.io_in.value = 0 # initialize
    dut.la1_data_in.value = 0
    dut.la1_oenb.value = 1
    dut.active.value = 1

    await Timer(10, units='us')

    dut.io_in[13].value = 1 # set clock input
    dut.io_in[14].value = 0
    clock = Clock(dut.wb_clk_i, 10, units="us")
    cocotb.fork(clock.start())

    dut.io_in[10].value = 1 # set inst_mem mode
    dut.io_in[11].value = 1

    await reset(dut) # reset
    # dut.io_in[15].value = 0
    # dut.write_enable.value = 1
    # instruction = ["addi", "or", "and", "add", "beq", "slt", "sub", "sw", "lw", "jal" ]
    # op = [opb("00500113"), opb("0023E233"), opb("0041F2B3"), opb("004282B3"), opb("02728863"), opb("0041A233"), opb("402383B3"), opb("0471AA23"), opb("06002103"), opb("008001EF")]
    # funct3 = [funct3b("00500113"), funct3b("0023E233"), funct3b("0041F2B3"), funct3b("004282B3"), funct3b("02728863"), funct3b("0041A233"), funct3b("402383B3"), funct3b("0471AA23"), funct3b("06002103"), funct3b("008001EF")]
    # funct7_5 = [funct7_5b("00500113"), funct7_5b("0023E233"), funct7_5b("0041F2B3"), funct7_5b("004282B3"), funct7_5b("02728863"), funct7_5b("0041A233"), funct7_5b("402383B3"), funct7_5b("0471AA23"), funct7_5b("06002103"), funct7_5b("008001EF")]

    inst = [
        "00500113", 
        "00C00193",
        "FF718393",
        "0023E233",
        "0041F2B3",
        "004282B3",
        "02728863",
        "0041A233",
        "00020463",
        "00000293",
        "0023A233",
        "005203B3",
        "402383B3",
        "0471AA23",
        "06002103",
        "005104B3",
        "008001EF",
        "00100113",
        "00910133",
        "0221A023",
        "00210063",
        "00210063",
        "00210063"
    ]
    cocotb.fork(la_inst_mem(dut, inst, 100, 'us'))
    # print(op)
    # print(funct3)
    # print(funct7_5)
    # print(len(op))
    # test a range of values
    for i in range(0, 200):
        # pass
        # dut.op.value = op[i]
        # dut.funct3.value = funct3[i]
        # dut.funct7_5.value = funct7_5[i]
        # dut.inst.value = text_to_decimal(instruction[i])


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
        await ClockCycles(dut.wb_clk_i, 5)

        # # assert still high
        # if (i != 0):
        #     assert(dut.read_data_1.value == data)
        #     assert(dut.read_data_2.value == data)
    
