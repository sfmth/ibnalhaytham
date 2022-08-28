`default_nettype none
`timescale 1ns/1ns

/* 
This module handles memory reads and writes from the processor and stalls the processor 
until the results are available
*/


module memory_controler (

    // interface with processor
    output wire [31:0] data_mem_read, // data memory read data port
    output reg [31:0] inst_mem_read, // instruction memory read port
    input data_mem_we, // data memory write enable
    input [31:0] inst_mem_addr, // instruction memory input address
		data_mem_addr, // data memory input address
		data_mem_write_data, // data we want to write into data memory
    output reg stall, // the stall signal to stall the processor for memory operations to complete

    //logic analyzer io coming from caravel management core
    input  wire [31:0] la_data_in,
    output wire [31:0] la_data_out,
    input  wire [31:0] la_oenb,

	// GPIO
    input  wire [1:0] io_in,
    output reg [20:0] io_out,

    input wire clk, reset // clock and reset
    );

    // Data Memory:
    reg [31:0]data_mem_array[9:0];

	// Convenience signals for simulation:
    // wire [31:0] mem0, mem1, mem96, mem100;
    // wire [29:0] mem_addr;
    // assign mem0 = data_mem_array[0];
    // assign mem1 = data_mem_array[1];
    // assign mem96 = data_mem_array[8];
    // assign mem100 = data_mem_array[9];
    // assign mem_addr = data_mem_addr[31:2];

    // manage read and writes from processor:
    // read
    assign data_mem_read = (data_mem_addr[31:2] < 8) ? 
                                data_mem_array[data_mem_addr[31:2]] :
                            (data_mem_addr[31:0] == 'd96) ? // custom address
                                data_mem_array[8] : 
                            (data_mem_addr[31:0] == 'd100) ? // custom address
                                data_mem_array[9] :
                            32'b0;
    //write
    always @(posedge clk) begin
        if (data_mem_we && data_mem_addr[31:2] < 8) begin
            data_mem_array[data_mem_addr[31:2]] <= data_mem_write_data;
        end else if (data_mem_we && data_mem_addr[31:0] == 'd96) begin // custom address
            data_mem_array[8] <= data_mem_write_data;
        end else if (data_mem_we && data_mem_addr[31:0] == 'd100) begin // custom address
            data_mem_array[9] <= data_mem_write_data;
        end
            
    end

	// output data memory to logic analyzer when io_in[1:0] != 2'd3
    reg [31:0] la_data_out_inst_addr;
    assign la_data_out = (io_in[1:0] == 2'd3) ? la_data_out_inst_addr : data_mem_array[la_data_in[11:4]];

    // output data_mem to io_out periodically 
    reg [5:0] cnt;
    always @(posedge clk) begin
        if (reset) begin
            cnt <= 0;
        end else begin
            cnt <= cnt + 1;
            io_out[15:0] <= data_mem_array[cnt[5:2]]; // output data
            io_out[20:16] <= cnt[5:2]; // output the address
        end
    end

    // Convenience signals 
    // wire [15:0] data_mem_io_out; 
    // wire [4:0] data_addr_io_out;
    // assign data_addr_io_out = io_out[20:16];
    // assign data_mem_io_out = io_out[15:0];



    // Instruction Memory:

    reg [31:0] inst_mem_addr_1;
    reg [31:0] la_oenb_1;
	// communicate with the logic analyzer to receive new instructions
    always @(posedge clk) begin
        if (reset) begin
            la_data_out_inst_addr <= 0;
            inst_mem_read <= 0;
            stall <= 1;
        end else if (io_in[1:0] == 2'd3) begin
            inst_mem_addr_1 <= inst_mem_addr; // store the incoming instruction address to detect a change and request for its data
            la_oenb_1 <= la_oenb; // store the logic analyzer output enable to detect a change and read the incoming data when it's 0
            if (inst_mem_addr != inst_mem_addr_1 || reset) begin // detect changes in instruction address and stall the processor until its data is received
                stall <= 1'b1;
                la_data_out_inst_addr <= inst_mem_addr;
            end else if (la_oenb_1 != la_oenb && la_oenb == 0) begin // detect changes in la_oenb and read the data and zero the stall to let the processor process the instruction 
                stall <= 1'b0;
                inst_mem_read <= la_data_in;
            end else begin
                stall <= 1'b1; // a fix for bugs arising from the above code
            end
        end
    end



	// The following code is used for verification and tests
    // initial $dumpvars(0, );
    // `ifdef FORMAL
    //     // initial assume(reset);
    //     // initial assume(reg_file[0] == 32'b0);
    //     initial assume(write_enable == 0);
    //     initial assume(mem_array[0] == 100);
    //     always @(posedge clk) begin
    //         assume(write_enable == 0);
    //         cover (mem_array[0] == 0);
    //     end
    // `endif

    // `ifdef COCOTB_SIM
    // initial begin
    // $dumpfile ("memory_controler.vcd");
    // $dumpvars (0, memory_controler);
    // #1;
    // end
    // `endif
endmodule
