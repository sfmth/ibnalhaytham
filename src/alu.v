`default_nettype none
`timescale 1ns/1ns

/* 
This module is used in the execution stage of the processor and performs arithmetic operations on it's sources. 
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

module alu (
    input wire [31:0] src_a, src_b, // operands
    input wire [4:0] alu_control, // control signal coming from the control unit
    output reg [31:0] alu_result, // result
    output wire zero // will be "1" when alu_result is "0", it is used for detecting conditional branches
    );

    assign zero = (alu_result) ? 1'b0 : 1'b1; // will be "1" when alu_result is "0", it is used for detecting conditional branches
	
	// decode the alu_control signal and perform the appropriate operation
    always @(*) begin
        case (alu_control)
			// Control signal:               Operation:                                                Instruction:  
            `ALU_CONTROL_ADD:   alu_result = src_a + src_b;                                            // ADD 
            `ALU_CONTROL_SUB:   alu_result = src_a - src_b;                                            // SUB
            `ALU_CONTROL_SLT:   alu_result = ($signed(src_a) < $signed(src_b)) ? 32'b1 : 32'b0 ;       // SLT
            `ALU_CONTROL_SLTU:  alu_result = (src_a < src_b) ? 32'b1 : 32'b0;                          // SLTU
            `ALU_CONTROL_XOR:   alu_result = src_a ^ src_b;                                            // XOR
            `ALU_CONTROL_OR:    alu_result = src_a | src_b;                                            // OR
            `ALU_CONTROL_AND:   alu_result = src_a & src_b;                                            // AND
            `ALU_CONTROL_SLL:   alu_result = src_a << src_b[4:0];                                      // SLL
            `ALU_CONTROL_SRL:   alu_result = $signed({1'b0, src_a}) >>> src_b[4:0];                    // SRL
            `ALU_CONTROL_SRA:   alu_result = $signed({src_a[31], src_a}) >>> src_b[4:0];               // SRA
            default:            alu_result = 32'b0;
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
    // $dumpfile ("alu.vcd");
    // $dumpvars (0, alu);
    // #1;
    // end
    // `endif
endmodule
