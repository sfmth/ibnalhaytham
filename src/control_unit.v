`default_nettype none
`timescale 1ns/1ns

/* 
This module is used in the decode stage of the processor and decodes the fetched instruction to generate appropriate
control signals for different parts of the processor.
*/


// alu_control signal values
`define ALU_CONTROL_ADD   5'd0
`define ALU_CONTROL_SUB   5'd1
`define ALU_CONTROL_SLT   5'd2
`define ALU_CONTROL_SLTU  5'd3
`define ALU_CONTROL_XOR   5'd4
`define ALU_CONTROL_OR    5'd5
`define ALU_CONTROL_AND   5'd6
`define ALU_CONTROL_SLL   5'd7
`define ALU_CONTROL_SRL   5'd8
`define ALU_CONTROL_SRA   5'd9

// op signal values
`define OP_LW             7'b0000011
`define OP_SW             7'b0100011
`define OP_R_TYPE         7'b0110011
`define OP_BEQ            7'b1100011
`define OP_I_TYPE_ALU     7'b0010011
`define OP_JAL            7'b1101111


module control_unit (
    input wire [6:0] op, // bits [6:0] from the fetched instruction
    input wire [2:0] funct3, // bits [14:12] from the fetched instruction
    input wire funct7_5, // bit 30 from the fetched instruction
    output reg reg_write, // register write enable used for instructions with a destination register rd
            mem_write, // data memory write enable used for S type instructions
            jump, // detects jal instruction
            branch, // detects beq instruction
            alu_src, // used as a select signal for src_b of the alu module that chooses between register 2 (rs2) and the extend module's output
			// it is 0 when we want rs2 as the source or 1 when we want the
			// extended signal as the src_b for the ALU
    output reg [1:0] result_src, // selects the output of the writeback stage: 01 for lw instruction, 10 for jal instruction and 00 for other instructions
            imm_src, // control signal for the extend module: 00 for type I, 01 for type S, 10 for type B, 11 for jal
    output reg [4:0] alu_control // ALU control signal
    // input wire [127:0] inst,
    // input wire clk
    );
    
    reg [1:0] alu_op; // decoded ALU information from OP code

	// main decoder
    always @(*) begin
        case (op)
            `OP_LW: begin // 1_00_1_0_01_0_00_0;
                reg_write <= 1'b1 ;
                imm_src <= 2'b00 ;
                alu_src <= 1'b1 ;
                mem_write <= 1'b0 ;
                result_src <= 2'b01 ;
                branch <= 1'b0 ;
                alu_op <= 2'b00 ;
                jump <= 1'b0 ;
            end
            `OP_SW: begin // 0_01_1_1_00_0_00_0;
                reg_write <= 1'b0 ;
                imm_src <= 2'b01 ;
                alu_src <= 1'b1 ;
                mem_write <= 1'b1 ;
                result_src <= 2'b00 ;
                branch <= 1'b0 ;
                alu_op <= 2'b00 ;
                jump <= 1'b0 ;
            end
            `OP_R_TYPE: begin // 1_xx_0_0_00_0_10_0;
                reg_write <= 1'b1 ;
                imm_src <= 2'bxx ;
                alu_src <= 1'b0 ;
                mem_write <= 1'b0 ;
                result_src <= 2'b00 ;
                branch <= 1'b0 ;
                alu_op <= 2'b10 ;
                jump <= 1'b0 ;
            end
            `OP_BEQ: begin // 0_10_0_0_00_1_01_0;
                reg_write <= 1'b0 ;
                imm_src <= 2'b10 ;
                alu_src <= 1'b0 ;
                mem_write <= 1'b0 ;
                result_src <= 2'b00 ;
                branch <= 1'b1 ;
                alu_op <= 2'b01 ;
                jump <= 1'b0 ;
            end
            `OP_I_TYPE_ALU: begin // 1_00_1_0_00_0_10_0; 
                reg_write <= 1'b1 ;
                imm_src <= 2'b00 ;
                alu_src <= 1'b1 ;
                mem_write <= 1'b0 ;
                result_src <= 2'b00 ;
                branch <= 1'b0 ;
                alu_op <= 2'b10 ;
                jump <= 1'b0 ;
            end
            `OP_JAL: begin // b1_11_0_0_10_0_00_1;
                reg_write <= 1'b1 ;
                imm_src <= 2'b11 ;
                alu_src <= 1'b0 ;
                mem_write <= 1'b0 ;
                result_src <= 2'b10 ;
                branch <= 1'b0 ;
                alu_op <= 2'b00 ;
                jump <= 1'b1 ;
            end
            default: begin
                reg_write <= 1'b0 ;
                imm_src <= 2'b00 ;
                alu_src <= 1'b0 ;
                mem_write <= 1'b0 ;
                result_src <= 2'b00 ;
                branch <= 1'b0 ;
                alu_op <= 2'b00 ;
                jump <= 1'b0 ;
            end
        endcase
    end

    wire r_type_sub; // a signal to differentiate between add and sub instructions since their funct3 is identical
    assign r_type_sub = funct7_5 & op[5]; 

    always @(*) begin
        case(alu_op)
            2'b00: alu_control = `ALU_CONTROL_ADD; // addition
            2'b01: alu_control = `ALU_CONTROL_SUB; // subtraction
            default: case(funct3) // R–type or I–type ALU
                        3'b000: if (r_type_sub)
									alu_control = `ALU_CONTROL_SUB; // sub
								else
									alu_control = `ALU_CONTROL_ADD; // add, addi
                        3'b010: alu_control = `ALU_CONTROL_SLT; // slt, slti
                        3'b110: alu_control = `ALU_CONTROL_OR; // or, ori
                        3'b111: alu_control = `ALU_CONTROL_AND; // and, andi
                        default: alu_control = 5'b0; // ???
                     endcase
        endcase
    end



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
    // $dumpfile ("control_unit.vcd");
    // $dumpvars (0, control_unit);
    // #1;
    // end
    // `endif
endmodule
