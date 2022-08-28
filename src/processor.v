`default_nettype none
`timescale 1ns/1ns

/* 
This module is the processor itself and wires different modules together
it also houses the pipeline flip flops with stall and flush signals

Note that signals ending in f, d, e, m, w, means that the signal is used in 
Fetch, Decode, Execute, Memory, Writeback stage of the pipeline respectively
*/

// `include "/home/farhad/Projects/rv32i_tapeout/src/mux3.v"
// `include "/home/farhad/Projects/rv32i_tapeout/src/alu.v"
// `include "/home/farhad/Projects/rv32i_tapeout/src/control_unit.v"
// `include "/home/farhad/Projects/rv32i_tapeout/src/extend.v"
// `include "/home/farhad/Projects/rv32i_tapeout/src/hazard_unit.v"
// `include "/home/farhad/Projects/rv32i_tapeout/src/register_file.v"

// `include "/home/farhad/Projects/rv32i_tapeout/src/instruction_memory.v"
// `include "/home/farhad/Projects/rv32i_tapeout/src/data_memory.v"


module processor (
    input wire stall, // memory stall signal
    input wire reset,
    input wire clk,

	// memory io
    input [31:0] inst_f, read_data_m,
    output mem_write_m,
    output [31:0] pc_f, alu_result_m, write_data_m    
    );

    // Net instantiations:

    // 32bits coming out of flops
    reg [31:0] pc_f, // program counter in the fetch stage
		inst_d, // fetched instruction in decode stage
		pc_d, pc_plus4_d, // one word ahead of the current program counter in decode stage
		rd1_e, rd2_e, // Read data 1 & 2 coming out of the register file in execute stage
		pc_e, imm_ext_e, // output of the extend module in execute stage
		pc_plus4_e, alu_result_m, // Result of the ALU operation in the memory stage
		write_data_m, // data that is going to be written in the data memory in the memory stage
		pc_plus4_m, read_data_w, // Read data from the data memory in the writeback stage
		alu_result_w, pc_plus4_w;
    
    // 5 bits coming out of flops
    reg [4:0] rs1_e, rs2_e, // source registers 1 & 2
		rd_e, rd_m, rd_w; // destination register in different stages of the pipeline

    // control signals out of flops 
	// refer to the control_unit for description
    reg reg_write_e, reg_write_m, reg_write_w, mem_write_e, mem_write_m, jump_e, branch_e, alu_src_e;
    reg [1:0] result_src_e, result_src_m, result_src_w;
    reg [4:0] alu_control_e;

    // control signals for pipeline flip flops
    wire stall_f, flush_f, stall_d, flush_d, stall_e, flush_e, stall_m, flush_m, stall_w, flush_w;

	// 32bit wires
    wire [31:0] pc_plus4_f, pc_f_next, // program counter signal that is going to be clocked into pc_f
		result_w, // output of the writeback stage
		src_a_e, src_b_e, // ALU sources
		write_data_e, pc_target_e, // calculated PC for jal and beq instructions
		imm_ext_d, rd1_d, rd2_d, inst_f, 
        alu_result_e, read_data_m;

    // 1bit wires
    wire zero_e, // ALU output zero signal
		pc_src_e, reg_write_d, mem_write_d, jump_d, branch_d, alu_src_d; // see control_unit

    // 2bit wires
    wire [1:0] result_src_d, imm_src_d, // see control_unit
		forward_a_e, forward_b_e; // see hazard_unit

    // 5bit wires
    wire [4:0] rs1_d, rs2_d, rd_d, alu_control_d;

   












	// Module instantiations


	// signal for changing the PC value when jumping or branching (jal, beq)
    assign pc_src_e = (zero_e & branch_e) | jump_e;

    // fetched instruction outputs
    assign rs1_d = inst_d[19:15];
    assign rs2_d = inst_d[24:20];
    assign rd_d = inst_d[11:7];

    // mux2s
	// assigns value to to pc_f_next based on the memory stall status and whether
	// a branch or jump has to happen
    assign pc_f_next = (pc_src_e_hold) ? pc_target_e_hold : pc_f_next_not_stall;
	// assigns value to pc_f_next when there is no memory stall happening during a branch or jump
    assign pc_f_next_not_stall = (pc_src_e) ? pc_target_e : pc_plus4_f;
	// select the src_b of the ALU based on alu_src(see control_unit)
    assign src_b_e = (alu_src_e) ? imm_ext_e : write_data_e;

    // mux3s
	// select src_a of the ALU based on the forward_a_e signal coming from the
	// hazard_unit
    mux3 mux3_1(rd1_e, result_w, alu_result_m, forward_a_e, src_a_e);
	// select src_b of the ALU based on the forward_b_e signal coming from the
	// hazard_unit
    mux3 mux3_2(rd2_e, result_w, alu_result_m, forward_b_e, write_data_e);
	// select the output of the writeback stage based on the result_src signal
	// coming from the control_unit
    mux3 mux3_3(alu_result_w, read_data_w, pc_plus4_w, result_src_w, result_w);

    // adders
    assign pc_plus4_f = pc_f + 4;
    assign pc_target_e = pc_e + imm_ext_e;

    // control unit
    control_unit control_1(inst_d[6:0],inst_d[14:12], inst_d[30], reg_write_d,
        mem_write_d, jump_d, branch_d, alu_src_d, result_src_d, imm_src_d, alu_control_d);
    
    //register file
    register_file regfile_1(inst_d[19:15], inst_d[24:20], rd_w, result_w, rd1_d, rd2_d, reg_write_w, clk, reset);
    
    // extend
    extend extend_1(inst_d[31:7], imm_src_d, imm_ext_d);

	// handle memory stall hazards
	// signals ending with _h are coming from the hazard_unit
    wire stall_f_h, stall_d_h;
    reg stall_1, stall_2, stall_3;
    always @(posedge clk) begin // save the stall state for using it on different pipeline stages 
        if (reset) begin
            stall_1 <= 0;
            stall_2 <= 0;
            stall_3 <= 0;
        end else begin
            stall_1 <= stall;
            stall_2 <= stall_1;
            stall_3 <= stall_2;
        end
    end
    wire flush_d_h;
    assign flush_d = flush_e_h | flush_d_hold; // flush the d stage (idk why it uses flush_e_h but it works!)
    wire flush_w_h;
    assign flush_w = stall_3 | flush_w_h; // flush the w stage when the processor is stalled and there is nothing to do
    wire flush_e_h;
    assign flush_e = stall_1 | flush_e_h | flush_e_hold; // flush the e stage 
    wire flush_m_h;
    assign flush_m = stall_2 | flush_m_h;
    assign stall_f = stall | stall_f_h; // stall the pipeline for memory stall
    assign stall_d = stall | stall_d_h;
    assign stall_e = stall_1; 
    assign stall_m = stall_2;
    assign stall_w = stall_3;
    wire [31:0] pc_f_next_not_stall; // pc_f_next when there is a beq or jal instruction but the processor is not under memory stall
    reg pc_src_e_hold, flush_e_hold, flush_d_hold; // hold these signals when a memory stall occurs
    reg [31:0] pc_target_e_hold;
    always @(posedge clk) begin
        if (reset) begin
            flush_d_hold <= 0;
            flush_e_hold <= 0;
            pc_src_e_hold <= 0;
            pc_target_e_hold <= 0;
        end else if (!(stall & stall_2)) begin
            pc_src_e_hold <= pc_src_e & stall; // hold pc_src_e on memory stall
            pc_target_e_hold <= pc_target_e; // hold pc_target on memory stall
            flush_e_hold <= pc_src_e & stall; // hold flush_e on stall
            flush_d_hold <= pc_src_e & stall; // hold flush_d on stall
        end        
    end
    wire flush_f_h;
    assign flush_f = (stall & stall_1 & pc_src_e) | flush_f_h; // flush pc_f when a stall occurs to avoid reading unwanted instructions

	// hazard unit
    hazard_unit hazardu_1(reg_write_m, reg_write_w, result_src_e[0], pc_src_e,
        rs1_e, rs1_d, rs2_e, rs2_d, rd_e, rd_m, rd_w,
        stall_f_h, stall_d_h, flush_d_h, flush_e_h,
        forward_a_e, forward_b_e,
        flush_f_h, flush_m_h, flush_w_h, reset);

    // alu
    alu alu_1(src_a_e, src_b_e, alu_control_e, alu_result_e, zero_e);











	


	// Pipeline flipflop instantiations

    // fetch flip flop
    always @(posedge clk) begin
        if (flush_f) begin
            pc_f <= 0;
        end else if (!stall_f) begin
            pc_f <= pc_f_next;
        end
    end

    // decode flip flop
    always @(posedge clk) begin
        if (flush_d) begin
            pc_plus4_d <= 0;
            pc_d <= 0;
            inst_d <= 0;
        end else if (!stall_d) begin
            pc_plus4_d <= pc_plus4_f;
            pc_d <= pc_f;
            inst_d <= inst_f;
        end
    end

    // execute flip flop
    always @(posedge clk) begin
        if (flush_e) begin
            pc_plus4_e <= 0;
            imm_ext_e <= 0;
            pc_e <= 0;
            rs1_e <= 0;
            rs2_e <= 0;
            rd_e <= 0;
            rd1_e <= 0;
            rd2_e <= 0;
            reg_write_e <= 0;
            result_src_e <= 0;
            mem_write_e <= 0;
            jump_e <= 0;
            branch_e <= 0;
            alu_control_e <= 0;
            alu_src_e <= 0;
        end else if (!stall_e) begin
            pc_plus4_e <= pc_plus4_d;
            imm_ext_e <= imm_ext_d;
            pc_e <= pc_d;
            rs1_e <= rs1_d;
            rs2_e <= rs2_d;
            rd_e <= rd_d;
            rd1_e <= rd1_d;
            rd2_e <= rd2_d;
            result_src_e <= result_src_d;
            mem_write_e <= mem_write_d;
            jump_e <= jump_d;
            branch_e <= branch_d;
            alu_control_e <= alu_control_d;
            alu_src_e <= alu_src_d;
            reg_write_e <= reg_write_d;
        end
    end

    // memory flip flop
    always @(posedge clk) begin
        if (flush_m) begin
            pc_plus4_m <= 0;
            reg_write_m <= 0;
            result_src_m <= 0;
            mem_write_m <= 0;
            alu_result_m <= 0;
            write_data_m <= 0;
            rd_m <= 0;
        end else if (!stall_m) begin
            pc_plus4_m <= pc_plus4_e;
            result_src_m <= result_src_e;
            mem_write_m <= mem_write_e;
            alu_result_m <= alu_result_e;
            write_data_m <= write_data_e;
            rd_m <= rd_e;
            reg_write_m <= reg_write_e;
        end
    end

    // writeback flip flop
    always @(posedge clk) begin
        if (flush_w) begin
            pc_plus4_w <= 0;
            reg_write_w <= 0;
            result_src_w <= 0;
            alu_result_w <= 0;
            read_data_w <= 0;
            rd_w <= 0;
        end else if (!stall_w) begin
            pc_plus4_w <= pc_plus4_m;
            result_src_w <= result_src_m;
            alu_result_w <= alu_result_m;
            read_data_w <= read_data_m;
            rd_w <= rd_m;
            reg_write_w <= reg_write_m;
        end
    end


    
	// The following code is used for verification and tests
    `ifdef FORMAL
        initial assume(reset);
        initial assume(!stall);
        initial assume(alu_result_m == 0);
        // initial assume(reg_file[0] == 32'b0);
        always @(posedge clk) begin
            if ((mem_write_m == 1) && (alu_result_m == 'd100))
                cover (write_data_m == 25); // check if the processor generates the required output for the program
        end
    `endif

    // `ifdef COCOTB_SIM
    // initial begin
    // $dumpfile ("processor.vcd");
    // $dumpvars (0, processor);
    // #1;
    // end
    // `endif
endmodule
