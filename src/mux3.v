`default_nettype none
`timescale 1ns/1ns

module mux3 (
    input wire [31:0] first, second, third,
    input wire [1:0] select,
    output reg [31:0] out
    );

    always @(*) begin
        case (select)
            2'b00: out = first;
            2'b01: out = second;
            2'b10: out = third;
            default: out = 1'bx;
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