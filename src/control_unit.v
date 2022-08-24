`default_nettype none
`timescale 1ns/1ns

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
    input wire [6:0] op,
    input wire [2:0] funct3,
    input wire funct7_5,
    output reg reg_write, // write to register. instructions with rd
            mem_write, // write to memory. S type
            jump, // jal
            branch, // beq
            alu_src, // 0 when using a register as src_b
    output reg [1:0] result_src, // 01 for S type, 10 for jal
            imm_src, // 00 for type I, 01 for type S, 10 for type B, 11 for jal
    output reg [4:0] alu_control
    // input wire [127:0] inst,
    // input wire clk
    );
    
    //RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump}

    reg [1:0] alu_op;

    // initial begin
    //     jump = 0;
    //     branch = 0;
    // end
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

    wire r_type_sub;
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