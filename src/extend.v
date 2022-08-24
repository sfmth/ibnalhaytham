`default_nettype none
`timescale 1ns/1ns

module extend (
    input wire [31:7] instr,
    input wire [1:0] immsrc,
    output reg [31:0] immext
    );

    always @(*) begin
        case(immsrc)
            // I−type
            2'b00: immext = {{20{instr[31]}}, instr[31:20]};
            // S−type (stores)
            2'b01: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            // B−type (branches)
            2'b10: immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            // J−type (jal)
            2'b11: immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            default: immext = 32'bx; // undefined
        endcase
    end

    
    
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