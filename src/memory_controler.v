`default_nettype none
`timescale 1ns/1ns

module memory_controler (

    // interface with processor
    output wire [31:0] data_mem_read,
    output reg [31:0] inst_mem_read,
    input data_mem_we,
    input [31:0] inst_mem_addr, data_mem_addr, data_mem_write_data,
    output reg stall,

    // wishbone interface
    // input wire wbs_stb_i,
    // input wire wbs_cyc_i,
    // input wire wbs_we_i,
    // input wire wbs_sel_i_0, // first bit to select data_mem_mode
    // input wire [31:0] wbs_dat_i,
    // input wire [31:0] wbs_adr_i,
    // output reg wbs_ack_o,
    // output wire [31:0] wbs_dat_o,

    //logic analyzer
    input  wire [31:0] la_data_in,
    output wire [31:0] la_data_out,
    input  wire [31:0] la_oenb,

    input  wire [1:0] io_in,
    output reg [20:0] io_out,
    // output wire [1:0] io_oeb,

    // shared openram
    // RAMBus controller ports
    // output wire         rambus_wb_clk_o,        // clock, must run at system clock
    // output wire         rambus_wb_rst_o,        // reset
    // output reg          rambus_wb_stb_o,        // write strobe
    // output reg          rambus_wb_cyc_o,        // cycle
    // output wire          rambus_wb_we_o,         // write enable
    // output wire  [3:0]   rambus_wb_sel_o,        // write word select
    // output reg  [31:0]  rambus_wb_dat_o,        // data out
    // output reg  [9:0]   rambus_wb_adr_o,        // address
    // input wire          rambus_wb_ack_i,        // ack
    // input wire  [31:0]  rambus_wb_dat_i,        // data in

    input wire clk, reset
    );

    // keep stall after reset
    // reg reset_1, reset_2;
    // always @(posedge clk) begin
    //     // if (reset) begin
    //     //     reset_1 <= 1;
    //     //     reset_2 <= 1;
    //     // end else begin
    //         reset_1 <= reset;
    //         reset_2 <= reset;
    //     // end
        
    //     if (reset_2 && !reset_1) begin
    //         stall <= 1'b0;
    //     end
    // end
    // always @(reset) begin
    //     stall <= 1'b1;
    // end
    // Inst_mem Modes:
    // io_in = 0 wishbone
    // io_in = 1
    // io_in = 2 output data_mem to logic analyzer
    // io_in = 3

    // assign io_oeb = 2'b0;
    always @(negedge clk) begin
        if (reset) begin
            // inst_mem_read <= 0;
            // la_oenb_1 <= 0;
            // inst_mem_addr_1 <= 0;
            // stall <= 0;
            // io_out <= 0;
            // rambus_wb_adr_o <= 0;
            // rambus_wb_dat_o <= 0;
            // rambus_wb_cyc_o <= 0;
            // rambus_wb_stb_o <= 0;
            // wbs_ack_o <= 0;
        end
    end

    // Data Memory:
    reg [31:0]data_mem_array[9:0];

    // wire [31:0] mem0, mem1, mem96, mem100;
    // wire [29:0] mem_addr;
    // assign mem0 = data_mem_array[0];
    // assign mem1 = data_mem_array[1];
    // assign mem96 = data_mem_array[8];
    // assign mem100 = data_mem_array[9];
    // assign mem_addr = data_mem_addr[31:2];

    // reg [31:0] data_mem_96;
    // reg [31:0] data_mem_100;
    // manage read and writes from processor:
    // read
    assign data_mem_read = (data_mem_addr[31:2] < 8) ? 
                                data_mem_array[data_mem_addr[31:2]] :
                            (data_mem_addr[31:0] == 'd96) ?
                                data_mem_array[8] : 
                            (data_mem_addr[31:0] == 'd100) ?
                                data_mem_array[9] :
                            32'b0;
    //write
    always @(posedge clk) begin
        if (data_mem_we && data_mem_addr[31:2] < 8) begin
            data_mem_array[data_mem_addr[31:2]] <= data_mem_write_data;
        end else if (data_mem_we && data_mem_addr[31:0] == 'd96) begin
            data_mem_array[8] <= data_mem_write_data;
        end else if (data_mem_we && data_mem_addr[31:0] == 'd100) begin
            data_mem_array[9] <= data_mem_write_data;
        end
            
    end
    // handle data memory reads from wishbone bus
    // always @(posedge clk) begin
    //     if (wbs_stb_i && wbs_cyc_i && wbs_sel_i_0 && !wbs_we_i) begin
    //         wbs_ack_o <= 1'b1;
    //         wbs_dat_o_data_read <= data_mem_array[wbs_adr_i[15:0]];
    //     end else if (wbs_stb_i && wbs_cyc_i && wbs_sel_i_0 && wbs_we_i && (io_in[1:0] != 2'd0)) begin
    //         data_mem_array[wbs_adr_i[15:0]] <= wbs_dat_i;
    //         wbs_ack_o <= 1'b1;
    //     end else
    //         wbs_ack_o <= 1'b0;
    // end
    // output data_mem to logic analyzer if io_in[1:0] != 'd3
    reg [31:0] la_data_out_inst_addr;
    assign la_data_out = (io_in[1:0] == 2'd3) ? la_data_out_inst_addr : data_mem_array[la_data_in[11:4]];
    // output data_mem to io_out 
    // assign io_out[15:0] = data_mem_array;
    reg [5:0] cnt;
    always @(posedge clk) begin
        if (reset) begin
            cnt <= 0;
        end else begin
            cnt <= cnt + 1;
            io_out[15:0] <= data_mem_array[cnt[5:2]];
            io_out[20:16] <= cnt[5:2];
        end
    end

    // remove
    // wire [15:0] data_mem_io_out; 
    // wire [4:0] data_addr_io_out;
    // assign data_addr_io_out = io_out[20:16];
    // assign data_mem_io_out = io_out[15:0];



    // Instruction Memory:

    // mode wishbone io_in[1:0] = 'd0
    // reg [31:0] wbs_dat_o_data_read;
    // assign wbs_dat_o = (io_in[1:0] == 2'd0 && !wbs_sel_i_0) ? inst_mem_addr : wbs_dat_o_data_read;
    // always @(negedge clk) begin
    //     if (io_in[1:0] == 2'd0 && !wbs_sel_i_0)
    //         inst_mem_addr_1 <= inst_mem_addr;
    //         if (inst_mem_addr != inst_mem_addr_1)
    //             stall <= 1'b1;
    // end
    // reg [31:0] wbs_dat_i_1;
    // always @(posedge clk) begin
    //     if (io_in[1:0] == 2'd0 && !wbs_sel_i_0) begin
    //         wbs_dat_i_1 <= wbs_dat_i;
    //         if (wbs_dat_i != wbs_dat_i_1) begin
    //             stall = 1'b0;
    //             inst_mem_read = wbs_dat_i;
    //         end
    //     end
    // end


    // mode shared openram io_in[1:0] = 'd1
    // assign rambus_wb_we_o = 1'b0;
    // assign rambus_wb_sel_o = 4'hF;
    // assign rambus_wb_clk_o = (io_in[1:0] == 2'd1) ? clk : 1'b0;
    // assign rambus_wb_rst_o = (io_in[1:0] == 2'd1) ? reset : 1'b0;
    // always @(posedge clk) begin
    //     if (io_in[1:0] == 2'd1) begin
        
    // end

    reg [31:0] inst_mem_addr_1;
    // always @(negedge clk) begin // detect new request
    //     if (io_in[1:0] == 2'd1) begin
    //         inst_mem_addr_1 <= inst_mem_addr;
    //         if (inst_mem_addr != inst_mem_addr_1) begin
    //             stall <= 1'b1; // stall the processor until the data is ready
    //         rambus_wb_stb_o <= 1'b1;
    //         rambus_wb_cyc_o <= 1'b1;
    //         rambus_wb_adr_o <= inst_mem_addr[11:2];
    //         end
    //     end
    // end
    // always @(posedge clk) begin
    //     if (io_in[1:0] == 2'd1) begin
    //         if (rambus_wb_ack_i && rambus_wb_cyc_o && rambus_wb_stb_o) begin
    //             stall <= 1'b0;
    //             inst_mem_read <= rambus_wb_dat_i;
    //             rambus_wb_stb_o <= 1'b0;
    //             rambus_wb_cyc_o <= 1'b0;
    //         end
    //     end  
    // end

    // mode logic analyzer io_in[1:0] = 'd3
    // assign la_data_out_inst_addr = inst_mem_addr;
    // always @(*) begin
    //     if (io_in[1:0] == 2'd3)
    //         inst_mem_read <= la_data_in;
    // end


    // always @(negedge clk) begin
    //     // if (reset) begin
    //     //     stall <= 1;
    //     //     // inst_mem_addr_1 <= 0;
    //     //     // la_data_out_inst_addr <= 0;
    //     // end else 
    //     if (io_in[1:0] == 2'd3) begin
    //         inst_mem_addr_1 <= inst_mem_addr;
    //         if (inst_mem_addr != inst_mem_addr_1 || reset) begin
    //             stall <= 1'b1;
    //             la_data_out_inst_addr <= inst_mem_addr;
    //         end
    //     end
    // end
    reg [31:0] la_oenb_1;
    // always @(posedge clk) begin
    //     // if (reset) begin
    //     //     // la_oenb_1 <= 0;
            
    //     // end else 
    //     if (io_in[1:0] == 2'd3 && stall) begin
    //         la_oenb_1 <= la_oenb;
    //         if (la_oenb_1 != la_oenb && la_oenb == 0) begin
    //             stall <= 1'b0;
    //             inst_mem_read <= la_data_in;
    //         end
    //     end else
    //         la_oenb_1 <= 0;
    // end
    
    always @(posedge clk) begin
        if (reset) begin
            la_data_out_inst_addr <= 0;
            inst_mem_read <= 0;
            stall <= 1;
        end else if (io_in[1:0] == 2'd3) begin
            inst_mem_addr_1 <= inst_mem_addr;
            la_oenb_1 <= la_oenb;
            if (inst_mem_addr != inst_mem_addr_1 || reset) begin
                stall <= 1'b1;
                la_data_out_inst_addr <= inst_mem_addr;
            end else if (la_oenb_1 != la_oenb && la_oenb == 0) begin
                stall <= 1'b0;
                inst_mem_read <= la_data_in;
            end else begin
                stall <= 1'b1;
            end

        end
    end
    // reg new_inst;
    // always @(negedge clk) begin
    //     if (io_in[1:0] == 2'd3) begin
    //         inst_mem_addr_1 <= inst_mem_addr;
    //         if (inst_mem_addr != inst_mem_addr_1 || reset) begin
    //             new_inst <= 1'b1;
    //             la_data_out_inst_addr <= inst_mem_addr;
    //         end else
    //     end
    // end
    // reg stall_flag;
    // always @(*) begin
    //     if (new_inst) begin
    //         stall_flag <= 1;
    //     end else if (la_oenb == 0) begin
    //         stall_flag <= 0;
    //     end
    // end
    // always @(negedge) begin
        
    // end

    // check for infinite loops and force stall = 0 after a while
    // wire parity_inst_mem_read;
    // assign parity_inst_mem_read = ^inst_mem_read;
    // reg [63:0] loop;
    // integer i;
    // always @(posedge clk) begin
    //     if (stall) begin
    //         loop[0] <= parity_inst_mem_read;
    //         for (i = 1; i < 64; i = i + 1) begin
    //                 loop[i] <= loop[i-1];
    //         end
    //         if ((loop == 64'b0) || (loop == 64'b1))
    //             stall <= 1'b0;
    //     end else
    //         loop <= 64'bx;            
    // end


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