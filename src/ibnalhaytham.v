`default_nettype none
`timescale 1ns/1ns
// `include "/home/farhad/Projects/rv32i_tapeout/src/processor.v"
// `include "/home/farhad/Projects/rv32i_tapeout/src/memory_controler.v"
// `include "/home/farhad/bin/Caravel_user_project/openlane/designs/wrapped_processor/src/processor.v"
// `include "/home/farhad/bin/Caravel_user_project/openlane/designs/wrapped_processor/src/memory_controler.v"

module ibnalhaytham(
    input wire          wb_clk_i,                            // clock, runs at system clock
 // caravel wishbone peripheral
// `ifdef USE_WB
    // input wire          wb_rst_i,                   // main system reset
    // input wire           wbs_stb_i,                  // wishbone write strobe
    // input wire           wbs_cyc_i,                  // wishbone cycle
    // input wire           wbs_we_i,                   // wishbone write enable
    // input wire           wbs_sel_i_0,                  // wishbone write word select
    // input wire [31:0]    wbs_dat_i,                  // wishbone data in
    // input wire [31:0]    wbs_adr_i,                  // wishbone address
    // output wire          buf_wbs_ack_o,                  // wishbone ack
    // output wire [31:0]   buf_wbs_dat_o,                  // wishbone data out
// `endif

    // output wire          buf_rambus_wb_clk_o,            // clock
    // output wire          buf_rambus_wb_rst_o,            // reset
    // output wire          buf_rambus_wb_stb_o,            // write strobe
    // output wire          buf_rambus_wb_cyc_o,            // cycle
    // output wire          buf_rambus_wb_we_o,             // write enable
    // output wire [3:0]    buf_rambus_wb_sel_o,            // write word select
    // output wire [31:0]   buf_rambus_wb_dat_o,            // ram data out
    // output wire [9:0]    buf_rambus_wb_adr_o,            // 10bit address
    // input wire           rambus_wb_ack_i,            // ack
    // input wire [31:0]    rambus_wb_dat_i,            // ram data in
// `endif

    input wire [31:0]    la1_data_in,                // from CPU to your project
    output wire [31:0]   buf_la1_data_out,
    input wire [31:0]    la1_oenb, 

    input wire [6:0]     io_in,           // in to your project
    output wire [20:0]   io_out,          // out from your project
    // output wire [37:0] io_oeb,   

    input wire           user_clock2

    // input wire reset
    );

    //io_in
    // [1:0] mem_controler mode
    // [2] reset
    // [4:3] clk src select
    // [5] stall
    // [6] clk

    // stall and reset signals
    reg stall_la, reset_la;
    always @(negedge clk) begin
        if (reset_io) begin
            stall_la <= 0;
            reset_la <= 0;
        end else if (la1_oenb == 32'hFFFFFFF0) begin
            stall_la <= la1_data_in[0]; 
            reset_la <= la1_data_in[1];
        end
    end
    wire reset, reset_io; // fix
    assign reset_io = io_in[2];
    assign reset = reset_io | reset_la;
    wire stall_m, stall_io;
    assign stall_io = io_in[5];
    assign stall = stall_io | stall_m | stall_la;

    //clk
    wire clk;
    assign clk =(io_in[4:3] == 2'd0) ? 
                    la1_data_in[0] :
                (io_in[4:3] == 2'd1) ?
                    wb_clk_i :
                (io_in[4:3] == 2'd2) ?
                    io_in[6] :
                (io_in[4:3] == 2'd3) ?
                    user_clock2 : 1'b0; 


    // wire reset;
    wire [31:0] data_mem_read;
    wire [31:0] inst_mem_read;
    wire data_mem_we;
    wire [31:0] inst_mem_addr, data_mem_addr, data_mem_write_data;
    wire stall;

    processor processor_1(stall, reset, clk, inst_mem_read, data_mem_read, data_mem_we, inst_mem_addr, data_mem_addr, data_mem_write_data);

    // memory controler 
    memory_controler memcon1(
        data_mem_read,
        inst_mem_read,
        data_mem_we,
        inst_mem_addr, data_mem_addr, data_mem_write_data,
        stall_m, 

        // wishbone interface 
        // wbs_stb_i,
        // wbs_cyc_i,
        // wbs_we_i,
        // wbs_sel_i_0, // first bit to select data_mem_mode
        // wbs_dat_i,
        // wbs_adr_i,
        // buf_wbs_ack_o,
        // buf_wbs_dat_o,

        //logic analyzer
        la1_data_in,
        buf_la1_data_out,
        la1_oenb,

        io_in[1:0],
        io_out,
        // buf_io_oeb[1:0],

        // shared openram
        // RAMBus controller ports
        // buf_rambus_wb_clk_o,        // clock, must run at system clock
        // buf_rambus_wb_rst_o,        // reset
        // buf_rambus_wb_stb_o,        // write strobe
        // buf_rambus_wb_cyc_o,        // cycle
        // buf_rambus_wb_we_o,         // write enable
        // buf_rambus_wb_sel_o,        // write word select
        // buf_rambus_wb_dat_o,        // data out
        // buf_rambus_wb_adr_o,        // address
        // rambus_wb_ack_i,        // ack
        // rambus_wb_dat_i,        // data in

        clk, reset
    );




endmodule
