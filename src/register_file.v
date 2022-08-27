`default_nettype none
`timescale 1ns/1ns

module register_file (
    input wire [4:0] address_1, address_2, address_3,
    input wire [31:0] write_data,
    output wire [31:0] read_data_1, read_data_2,
    input wire write_enable,
    input wire clk, reset
    );
    integer i;
    reg [31:0]reg_file[16:0];

    // initial reg_file[0] = 0;
    assign read_data_1 = reg_file[address_1];
    assign read_data_2 = reg_file[address_2];

    // always @(posedge clk) begin
    //     // reg_file[0] <= 32'b0;
    //     if (reset) begin
    //         for (i = 0; i < 32; i = i + 1) begin
    //             reg_file[i] = 32'b0;
    //         end
    //     end
    //         // read_data_1 <= reg_file[address_1];
    //         // read_data_2 <= reg_file[address_2];
    //     //     if (address_3 && write_enable)
    //     //         reg_file[address_3] <= write_data;
    //     // end
    // end

    // always @(negedge clk) begin
    //     if (address_3 && write_enable)
    //         reg_file[address_3] <= write_data;
    // end
    always @(negedge clk) begin
    	if (reset) begin
            for (i = 0; i < 16; i = i + 1) begin
                reg_file[i] = 32'b0;
            end
        end else if (address_3 && write_enable)
            reg_file[address_3] <= write_data;

    end

    // wire [31:0] reg0, reg1, reg2, reg3, reg4, reg5, reg7, reg9;
    // assign reg0 = reg_file[0];
    // assign reg1 = reg_file[1];
    // assign reg2 = reg_file[2];
    // assign reg3 = reg_file[3];
    // assign reg4 = reg_file[4];
    // assign reg5 = reg_file[5];
    // assign reg7 = reg_file[7];
    // assign reg9 = reg_file[9];
    
    // integer idx;
    // initial for (idx = 0; idx < 32; idx = idx + 1) $dumpvars(0, reg_file[idx]);

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
