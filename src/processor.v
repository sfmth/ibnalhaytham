`default_nettype none
`timescale 1ns/1ns
// `include "/home/farhad/Projects/rv32i_tapeout/src/mux3.v"
// `include "/home/farhad/Projects/rv32i_tapeout/src/alu.v"
// `include "/home/farhad/Projects/rv32i_tapeout/src/control_unit.v"
// `include "/home/farhad/Projects/rv32i_tapeout/src/extend.v"
// `include "/home/farhad/Projects/rv32i_tapeout/src/hazard_unit.v"
// `include "/home/farhad/Projects/rv32i_tapeout/src/register_file.v"

// `include "/home/farhad/Projects/rv32i_tapeout/src/instruction_memory.v"
// `include "/home/farhad/Projects/rv32i_tapeout/src/data_memory.v"


module processor (
    input wire stall,
    input wire reset,
    input wire clk,
    input [31:0] inst_f, read_data_m,
    output mem_write_m,
    output [31:0] pc_f, alu_result_m, write_data_m    
    );

    // data_memory data_mem_1(alu_result_m, write_data_m, read_data_m, mem_write_m, clk);
    // instruction_memory inst_mem_1(pc_f, inst_f, clk);
    // reg stall; initial stall <= 0;
    // wire stall;

    // net instantiations

    // 32bits coming out of flops
    reg [31:0] pc_f, inst_d, pc_d, pc_plus4_d, rd1_e, rd2_e, pc_e, imm_ext_e, pc_plus4_e,
        alu_result_m, write_data_m, pc_plus4_m, read_data_w, alu_result_w, pc_plus4_w;
    
    // 5 bits coming out of flops
    reg [4:0] rs1_e, rs2_e, rd_e, rd_m, rd_w;

    // control signals out of flops
    reg reg_write_e, reg_write_m, reg_write_w, mem_write_e, mem_write_m, jump_e, branch_e, alu_src_e;
    reg [1:0] result_src_e, result_src_m, result_src_w;
    reg [4:0] alu_control_e;

    // control signals for ffs
    wire stall_f, flush_f, stall_d, flush_d, stall_e, flush_e, stall_m, flush_m, stall_w, flush_w;
    // assign flush_f = 0;
    // assign flush_m = 0;
    // assign flush_w = 0;
    // assign stall_e = 0;
    // assign stall_m = 0;
    // assign stall_w = 0;

    // 32bit wires
    wire [31:0] pc_plus4_f, pc_f_next, result_w, src_a_e, src_b_e, write_data_e, pc_target_e, imm_ext_d, rd1_d, rd2_d, inst_f, 
        alu_result_e, read_data_m;

    // 1bit wires
    wire zero_e, pc_src_e, reg_write_d, mem_write_d, jump_d, branch_d, alu_src_d;

    // 2bit wires
    wire [1:0] result_src_d, imm_src_d, forward_a_e, forward_b_e;

    // 5bit wires
    wire [4:0] rs1_d, rs2_d, rd_d, alu_control_d;

    





    // assign write_data_e = write_data_e; // fix this later

    assign pc_src_e = (zero_e & branch_e) | jump_e;

    // instruction wire outs
    assign rs1_d = inst_d[19:15];
    assign rs2_d = inst_d[24:20];
    assign rd_d = inst_d[11:7];

    // mux2s
    assign pc_f_next = (pc_src_e_hold) ? pc_target_e_hold : pc_f_next_not_stall;
    assign pc_f_next_not_stall = (pc_src_e) ? pc_target_e : pc_plus4_f;
    assign src_b_e = (alu_src_e) ? imm_ext_e : write_data_e;

    // mux3s
    mux3 mux3_1(rd1_e, result_w, alu_result_m, forward_a_e, src_a_e);
    mux3 mux3_2(rd2_e, result_w, alu_result_m, forward_b_e, write_data_e);
    mux3 mux3_3(alu_result_w, read_data_w, pc_plus4_w, result_src_w, result_w);

    // adders
    assign pc_plus4_f = pc_f + 4;
    assign pc_target_e = pc_e + imm_ext_e;

    // instruction memory
    // instruction_memory inst_mem_1(pc_f, inst_f, clk);
    
    // control unit
    control_unit control_1(inst_d[6:0],inst_d[14:12], inst_d[30], reg_write_d,
        mem_write_d, jump_d, branch_d, alu_src_d, result_src_d, imm_src_d, alu_control_d);
    
    //register file
    register_file regfile_1(inst_d[19:15], inst_d[24:20], rd_w, result_w, rd1_d, rd2_d, reg_write_w, clk, reset);
    
    // extend
    extend extend_1(inst_d[31:7], imm_src_d, imm_ext_d);


    // hazard unit
    wire stall_f_h, stall_d_h;
    // wire flush_d_h, flush_e_h;
    // 
    // assign stall_f = (stall_f_h) ? stall_f_h : stall;
    // assign stall_d = (stall_d_h) ? stall_d_h : stall;
    // assign stall_e = (stall_f_h) ? 1'b0 : stall;
    // assign stall_m = (stall_f_h) ? 1'b0 : stall;
    // assign stall_w = (stall_f_h) ? 1'b0 : stall;
    // reg flush_d_reg;
    // assign flush_d = flush_d_reg | flush_d_h;
    // // reg reg_write_w_1;
    // always @(posedge clk) begin
    //     // reg_write_w_1 <= reg_write_w;
    //     if (stall && reg_write_w) begin
    //         flush_d_reg <= !stall;
    //         // reg_write_w <= 0;
    //         // reg_write_d <= 0;
    //         // reg_write_e <= 0;
    //         // reg_write_m <= 0;
    //     end else if (!stall) begin
    //         flush_d_reg <= 0;
    //     end
    // end
    // always @(posedge clk) begin
    //     if (stall && reg_write_w) begin
    //         reg_write_w <= 0;
    //         // reg_write_d <= 0;
    //         reg_write_e <= 0;
    //         reg_write_m <= 0;
    //     end
    // end
    reg stall_1, stall_2, stall_3;
    always @(posedge clk) begin
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
    assign flush_d = flush_e_h | flush_d_hold;
    wire flush_w_h;
    assign flush_w = stall_3 | flush_w_h;
    wire flush_e_h;
    assign flush_e = stall_1 | flush_e_h | flush_e_hold;
    wire flush_m_h;
    assign flush_m = stall_2 | flush_m_h;
    assign stall_f = stall | stall_f_h;
    assign stall_d = stall | stall_d_h;
    assign stall_e = stall_1;
    assign stall_m = stall_2;
    assign stall_w = stall_3;

    wire [31:0] pc_f_next_not_stall;
    reg pc_src_e_hold, flush_e_hold, flush_d_hold;
    reg [31:0] pc_target_e_hold;
    always @(posedge clk) begin
        if (reset) begin
            flush_d_hold <= 0;
            flush_e_hold <= 0;
            pc_src_e_hold <= 0;
            pc_target_e_hold <= 0;
        end else if (!(stall & stall_2)) begin
            pc_src_e_hold <= pc_src_e & stall;
            pc_target_e_hold <= pc_target_e;
            flush_e_hold <= pc_src_e & stall;
            flush_d_hold <= pc_src_e & stall;
        end        
    end
    wire flush_f_h;
    assign flush_f = (stall & stall_1 & pc_src_e) | flush_f_h;
    // forward flushes when stall is 1 to avoid data loss
    // reg flush_d_flag, flush_e_flag;
    // always @(posedge clk) begin
    //     if (flush_d_h && stall && !reset)
    //         flush_d_flag <= 1;
    //     else
    //         flush_d_flag <= 0;
    //     if (flush_e_h && stall && !reset)
    //         flush_e_flag <= 1;
    //     else
    //         flush_e_flag <= 0;
    // end
    // reg flush_d_reg, flush_e_reg, stall_1;
    // always @(stall) begin
    //     // if (reset) begin
    //     //     flush_d_reg <= 0;
    //     //     flush_e_reg <= 0;
    //     // end else begin
    //     //     stall_1 <= stall;
    //     //     if (stall_1 && !stall) begin
    //     //         if (flush_d_flag) begin
    //     //         flush_d_reg <= 1;
    //     //         flush_d_flag <= 0;
    //     //         end
    //     //         if (flush_e_flag) begin
    //     //         flush_e_reg <= 1;
    //     //         flush_e_flag <= 0;
    //     //         end
    //     //     end else if (stall && !stall_1) begin
    //     //         flush_e_reg <= 0;
    //     //         flush_d_reg <= 0;
    //     //     end
    //     // end
        
    //     if (flush_d_flag) begin
    //         flush_d_reg <= 1;
    //         flush_d_flag <= 0;
    //     end else
    //         flush_d_reg <= 0;
    //     if (flush_e_flag) begin
    //         flush_e_reg <= 1;
    //         flush_e_flag <= 0;
    //     end else
    //         flush_e_reg <= 0;   
    // end
    // assign flush_d = (flush_d_reg) ? flush_d_reg : (stall && !reset) ? 1'b0 : flush_d_h;
    // assign flush_e = (flush_e_reg) ? flush_e_reg : (stall && !reset) ? 1'b0 : flush_e_h;
    hazard_unit hazardu_1(reg_write_m, reg_write_w, result_src_e[0], pc_src_e,
        rs1_e, rs1_d, rs2_e, rs2_d, rd_e, rd_m, rd_w,
        stall_f_h, stall_d_h, flush_d_h, flush_e_h,
        forward_a_e, forward_b_e,
        flush_f_h, flush_m_h, flush_w_h, reset);

    // alu
    alu alu_1(src_a_e, src_b_e, alu_control_e, alu_result_e, zero_e);

    // data memory
    // data_memory data_mem_1(alu_result_m, write_data_m, read_data_m, mem_write_m, clk);



    // fetch flip flop
    always @(posedge clk) begin
        if (flush_f) begin
            // pc_plus4_d <= 0;
            pc_f <= 0;
            // flush_f_reg <= 0;
        end else if (!stall_f) begin
            // pc_plus4_d <= pc_plus4_f;
            pc_f <= pc_f_next;
        end
    end

    // decode flip flop
    always @(posedge clk) begin
        if (flush_d) begin
            pc_plus4_d <= 0;
            pc_d <= 0;
            inst_d <= 0;
            // flush_d_reg <= 0;
        end else if (!stall_d) begin
            pc_plus4_d <= pc_plus4_f;
            pc_d <= pc_f;
            inst_d <= inst_f;
        end
    end

    // initial begin
    //     jump_e = 0;
    //     branch_e = 0;
    // end
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
            // flush_e_reg <= 0;
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
            // if (stall && reg_write_w)
            //     reg_write_e <= 0;
            // else
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
            // flush_m_reg <= 0;
        end else if (!stall_m) begin
            pc_plus4_m <= pc_plus4_e;
            // reg_write_m <= reg_write_e;
            result_src_m <= result_src_e;
            mem_write_m <= mem_write_e;
            alu_result_m <= alu_result_e;
            write_data_m <= write_data_e;
            rd_m <= rd_e;
            // if (stall && reg_write_w)
            //     reg_write_m <= 0;
            // else
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
            // flush_w_reg <= 0;
        end else if (!stall_w) begin
            pc_plus4_w <= pc_plus4_m;
            // reg_write_w <= reg_write_m;
            result_src_w <= result_src_m;
            alu_result_w <= alu_result_m;
            read_data_w <= read_data_m;
            rd_w <= rd_m;
            // if (stall && reg_write_w)
            //     reg_write_w <= 0;
            // else
            reg_write_w <= reg_write_m;
        end
    end


    
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
