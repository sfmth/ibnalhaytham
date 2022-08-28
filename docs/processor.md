# Entity: processor

- **File**: processor.v
## Diagram

![Diagram](processor.svg "Diagram")
## Description




## Ports

| Port name    | Direction | Type   | Description |
| ------------ | --------- | ------ | ----------- |
| stall        | input     | wire   |             |
| reset        | input     | wire   |             |
| clk          | input     | wire   |             |
| inst_f       | input     | [31:0] |             |
| read_data_m  | input     |        |             |
| mem_write_m  | output    |        |             |
| pc_f         | output    | [31:0] |             |
| alu_result_m | output    |        |             |
| write_data_m | output    |        |             |
## Signals

| Name                | Type        | Description |
| ------------------- | ----------- | ----------- |
| pc_f                | reg [31:0]  |             |
| inst_d              | reg [31:0]  |             |
| pc_d                | reg [31:0]  |             |
| pc_plus4_d          | reg [31:0]  |             |
| rd1_e               | reg [31:0]  |             |
| rd2_e               | reg [31:0]  |             |
| pc_e                | reg [31:0]  |             |
| imm_ext_e           | reg [31:0]  |             |
| pc_plus4_e          | reg [31:0]  |             |
| alu_result_m        | reg [31:0]  |             |
| write_data_m        | reg [31:0]  |             |
| pc_plus4_m          | reg [31:0]  |             |
| read_data_w         | reg [31:0]  |             |
| alu_result_w        | reg [31:0]  |             |
| pc_plus4_w          | reg [31:0]  |             |
| rs1_e               | reg [4:0]   |             |
| rs2_e               | reg [4:0]   |             |
| rd_e                | reg [4:0]   |             |
| rd_m                | reg [4:0]   |             |
| rd_w                | reg [4:0]   |             |
| reg_write_e         | reg         |             |
| reg_write_m         | reg         |             |
| reg_write_w         | reg         |             |
| mem_write_e         | reg         |             |
| mem_write_m         | reg         |             |
| jump_e              | reg         |             |
| branch_e            | reg         |             |
| alu_src_e           | reg         |             |
| result_src_e        | reg [1:0]   |             |
| result_src_m        | reg [1:0]   |             |
| result_src_w        | reg [1:0]   |             |
| alu_control_e       | reg [4:0]   |             |
| stall_f             | wire        |             |
| flush_f             | wire        |             |
| stall_d             | wire        |             |
| flush_d             | wire        |             |
| stall_e             | wire        |             |
| flush_e             | wire        |             |
| stall_m             | wire        |             |
| flush_m             | wire        |             |
| stall_w             | wire        |             |
| flush_w             | wire        |             |
| pc_plus4_f          | wire [31:0] |             |
| pc_f_next           | wire [31:0] |             |
| result_w            | wire [31:0] |             |
| src_a_e             | wire [31:0] |             |
| src_b_e             | wire [31:0] |             |
| write_data_e        | wire [31:0] |             |
| pc_target_e         | wire [31:0] |             |
| imm_ext_d           | wire [31:0] |             |
| rd1_d               | wire [31:0] |             |
| rd2_d               | wire [31:0] |             |
| inst_f              | wire [31:0] |             |
| alu_result_e        | wire [31:0] |             |
| read_data_m         | wire [31:0] |             |
| zero_e              | wire        |             |
| pc_src_e            | wire        |             |
| reg_write_d         | wire        |             |
| mem_write_d         | wire        |             |
| jump_d              | wire        |             |
| branch_d            | wire        |             |
| alu_src_d           | wire        |             |
| result_src_d        | wire [1:0]  |             |
| imm_src_d           | wire [1:0]  |             |
| forward_a_e         | wire [1:0]  |             |
| forward_b_e         | wire [1:0]  |             |
| rs1_d               | wire [4:0]  |             |
| rs2_d               | wire [4:0]  |             |
| rd_d                | wire [4:0]  |             |
| alu_control_d       | wire [4:0]  |             |
| stall_f_h           | wire        |             |
| stall_d_h           | wire        |             |
| stall_1             | reg         |             |
| stall_2             | reg         |             |
| stall_3             | reg         |             |
| flush_d_h           | wire        |             |
| flush_w_h           | wire        |             |
| flush_e_h           | wire        |             |
| flush_m_h           | wire        |             |
| pc_f_next_not_stall | wire [31:0] |             |
| pc_src_e_hold       | reg         |             |
| flush_e_hold        | reg         |             |
| flush_d_hold        | reg         |             |
| pc_target_e_hold    | reg [31:0]  |             |
| flush_f_h           | wire        |             |
## Processes
- unnamed: ( @(posedge clk) )
  - **Type:** always
- unnamed: ( @(posedge clk) )
  - **Type:** always
- unnamed: ( @(posedge clk) )
  - **Type:** always
- unnamed: ( @(posedge clk) )
  - **Type:** always
- unnamed: ( @(posedge clk) )
  - **Type:** always
- unnamed: ( @(posedge clk) )
  - **Type:** always
- unnamed: ( @(posedge clk) )
  - **Type:** always
- unnamed: ( @(posedge clk) )
  - **Type:** always
## Instantiations

- mux3_1: mux3
- mux3_2: mux3
- mux3_3: mux3
- control_1: control_unit
- regfile_1: register_file
- extend_1: extend
- hazardu_1: hazard_unit
- alu_1: alu
