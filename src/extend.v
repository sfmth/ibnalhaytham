`default_nettype none
`timescale 1ns/1ns

/* 
This module is used in the decode stage of the processor and extends the input data based on the control signal "immsrc". 
*/


module extend (
    input wire [31:7] instr, // bits [31:7] from the fetched instruction
    input wire [1:0] immsrc, // control signal coming from the control_unit
    output reg [31:0] immext // extended result
    );
	
	// do the appropriate extension operation based on the control signal
    always @(*) begin
        case(immsrc)
            2'b00: immext = {{20{instr[31]}}, instr[31:20]}; // I type instructions with an immediate
            2'b01: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // sw instruction
            2'b10: immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // beq instruction
            2'b11: immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; // jal instruction
            default: immext = 32'bx; // undefined
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
    // $dumpfile ("data_memory.vcd");
    // $dumpvars (0, data_memory);
    // #1;
    // end
    // `endif
endmodule
