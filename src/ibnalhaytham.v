`default_nettype none
`timescale 1ns/1ns

/* 
This module combines the processor and the memory_controler
it also takes care of clk and sources
*/

// `include "/home/farhad/Projects/rv32i_tapeout/src/processor.v"
// `include "/home/farhad/Projects/rv32i_tapeout/src/memory_controler.v"
// `include "/home/farhad/bin/Caravel_user_project/openlane/designs/wrapped_processor/src/processor.v"
// `include "/home/farhad/bin/Caravel_user_project/openlane/designs/wrapped_processor/src/memory_controler.v"

module ibnalhaytham(
	// wishbone clock
    input wire          wb_clk_i,                            // clock, runs at system clock
	
	// logic analyzer io
    input wire [31:0]    la1_data_in,                // from CPU to your project
    output wire [31:0]   buf_la1_data_out,
    input wire [31:0]    la1_oenb, 
	
	// GPIO
    input wire [6:0]     io_in,           // in to your project
    output wire [20:0]   io_out,          // out from your project

	// user_clock2
    input wire           user_clock2
    );
	

    //io_in
    // [1:0] sets mem_controler mode
    // [2] reset
    // [4:3] clk source select
    // [5] stall
    // [6] clk

    // stall and reset signals
    reg stall_la, reset_la;
    always @(negedge clk) begin // detect reset and stall from the logic analyzer
        if (reset_io) begin
            stall_la <= 0;
            reset_la <= 0;
        end else if (la1_oenb == 32'hFFFFFFF0) begin
            stall_la <= la1_data_in[0]; 
            reset_la <= la1_data_in[1];
        end
    end
    wire reset, reset_io; 
    assign reset_io = io_in[2];
    assign reset = reset_io | reset_la;
    wire stall_m, stall_io;
    assign stall_io = io_in[5];
    assign stall = stall_io | stall_m | stall_la;

    //select clk source
    wire clk;
    assign clk =(io_in[4:3] == 2'd0) ? 
                    la1_data_in[0] :
                (io_in[4:3] == 2'd1) ?
                    wb_clk_i :
                (io_in[4:3] == 2'd2) ?
                    io_in[6] :
                (io_in[4:3] == 2'd3) ?
                    user_clock2 : 1'b0; 

	// wires to connect the processor and the memory_controler together
    wire [31:0] data_mem_read;
    wire [31:0] inst_mem_read;
    wire data_mem_we;
    wire [31:0] inst_mem_addr, data_mem_addr, data_mem_write_data;
    wire stall;

	// processor
    processor processor_1(stall, reset, clk, inst_mem_read, data_mem_read, data_mem_we, inst_mem_addr, data_mem_addr, data_mem_write_data);

    // memory controler 
    memory_controler memcon1(
        data_mem_read,
        inst_mem_read,
        data_mem_we,
        inst_mem_addr, data_mem_addr, data_mem_write_data,
        stall_m, 

        //logic analyzer
        la1_data_in,
        buf_la1_data_out,
        la1_oenb,

        io_in[1:0],
        io_out,

        clk, reset
    );
endmodule
