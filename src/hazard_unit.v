`default_nettype none
`timescale 1ns/1ns

/* 
This module is used alongside the processor and takes care of pipeline hazards. 
It is also tasked with resetting the processor by flushing the pipeline
*/

module hazard_unit (
    input wire reg_write_m, reg_write_w, result_src_e_0, pc_src_e,
    input wire [4:0] rs1_e, rs1_d, rs2_e, rs2_d, rd_e, rd_m, rd_w, // forwarded register addresses to detect and manage hazards
    output wire stall_f, stall_d, flush_d, flush_e, // stall and flush signals for different pipeline stages
    output reg [1:0] forward_a_e, forward_b_e, // forward ALU sources from different stages of the pipeline to solve hazards
    output wire flush_f, flush_m, flush_w, // additional flush signals for resetting the processor
    input wire reset // reset
    // input wire clk
    );
	
	// wire to detect the need for lw stall
    wire lwstall;

    always @(*) begin

        // forwarding to solve data hazards

        // forwarding alu's src_a
        if (((rs1_e == rd_m) & reg_write_m) & (rs1_e != 0)) begin
            forward_a_e <= 2'b10;
        end else if (((rs1_e == rd_w) & reg_write_w) & (rs1_e != 0)) begin
            forward_a_e <= 2'b01;
        end else
            forward_a_e <= 2'b0;

        // forwarding alu's src_b
        if (((rs2_e == rd_m) & reg_write_m) & (rs2_e != 0)) begin
            forward_b_e <= 2'b10;
        end else if (((rs2_e == rd_w) & reg_write_w) & (rs2_e != 0)) begin
            forward_b_e <= 2'b01;
        end else
            forward_b_e <= 2'b0;
    end

    // handling load and branch hazards
    assign lwstall = result_src_e_0 & ((rs1_d == rd_e) | (rs2_d == rd_e));
    assign stall_f = lwstall;
    assign stall_d = lwstall;

    assign flush_d = pc_src_e | reset;
    assign flush_e = lwstall | pc_src_e | reset;

    //reset signal
    assign flush_f = reset;
    assign flush_m = reset;
    assign flush_w = reset;






	// The following code is used for verification and tests
    // `ifdef FORMAL
    //     initial assume(reset);
    //     // initial assume(reg_file[0] == 32'b0);
    //     always @(posedge clk) begin
    //         cover (reg_file[0] != 0);
    //     end
    // `endif

    // `ifdef COCOTB_SIM
    // initial begin
    // $dumpfile ("alu.vcd");
    // $dumpvars (0, alu);
    // #1;
    // end
    // `endif
endmodule
