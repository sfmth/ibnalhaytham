`default_nettype none
`timescale 1ns/1ns

/* 
This module is used in the decode stage of the processor and handles read/writes for registers
It houses 16 32bit registers, writes @negedge clk and reads asynchronously.
2 read ports and 1 write port
*/


module register_file (
    input wire [4:0] address_1, address_2, // 2 input addresses for the 2 read ports
		address_3, // third address for writing
    input wire [31:0] write_data, // data to be written
    output wire [31:0] read_data_1, read_data_2, // output read signals
    input wire write_enable, // write enable
    input wire clk, reset
    );

    integer i;
    reg [31:0]reg_file[16:0];

	// Handle asynchronous reads
    assign read_data_1 = reg_file[address_1];
    assign read_data_2 = reg_file[address_2];

	// @negedge clk writes
    always @(negedge clk) begin
    	if (reset) begin
            for (i = 0; i < 16; i = i + 1) begin // set all registers to 0
                reg_file[i] = 32'b0;
            end
        end else if (address_3 && write_enable) // if address is not 0 and write enable is on then write
            reg_file[address_3] <= write_data;
    end

    // Convenience signals 
    // wire [31:0] reg0, reg1, reg2, reg3, reg4, reg5, reg7, reg9;
    // assign reg0 = reg_file[0];
    // assign reg1 = reg_file[1];
    // assign reg2 = reg_file[2];
    // assign reg3 = reg_file[3];
    // assign reg4 = reg_file[4];
    // assign reg5 = reg_file[5];
    // assign reg7 = reg_file[7];
    // assign reg9 = reg_file[9];
    

	// The following code is used for verification and tests
    // `ifdef FORMAL
    //     initial assume(reset);
    //     initial assume(reg_file[0] == 32'b0);
    //     always @(posedge clk) begin
    //         cover (reg_file[0] != 0);
    //     end
    // `endif
    
    // `ifdef COCOTB_SIM
    // initial begin
    // $dumpfile ("register_file.vcd");
    // $dumpvars (0, register_file);
    // #1;
    // end
    // `endif
endmodule
