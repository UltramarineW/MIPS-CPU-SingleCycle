`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/31 21:13:35
// Design Name: 
// Module Name: cpu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module cpu(
    input clk,
    input resetn,

    output [31:0] debug_wb_pc,
    output debug_wb_rf_wen,
    output [4:0] debug_wb_rf_addr,
    output [31:0] debug_wb_rf_wdata
    );

    wire reg_write_enable,  // regfile write enable
         imem_write_enable,  // imem write enable
         dmem_write_enable,  
         A_write_enable,
         B_write_enable, 
         pc_enable,
         npc_enable,
         ir_enable,
         imm_enable, 
         lmd_write_enable, 
         aluoutput_write_enable, 
         mux_A_select, 
         mux_B_select, 
         mux_pc_select, 
         write_back_mux_select, 
         mux_write_back_addr_select, 
         mux_sll_select, 
         equal_output, 
         adder_jump_select;

    wire [4:0] write_back_addr;

    wire [5:0] alu_op;

    wire [31:0] pc_input, 
         pc_output, 
         if_adder_output, 
         next_address, 
         imem_output, 
         npc, 
         reg_files_outputA, 
         reg_files_outputB, 
         ext_instr_index, 
         reg_A_output, 
         reg_B_output, 
         reg_imm_output, 
         ir_output, 
         write_back_data, 
         alu_A_input, 
         alu_B_input, 
         alu_output, 
         alureg_output, 
         dmem_data_output, 
         lmd_output, 
         alu_A_sll_input, 
         npc_adder_output, 
         jump_select_output;

    assign debug_wb_rf_wen = reg_write_enable;
    assign debug_wb_pc = pc_output;
    assign debug_wb_rf_addr = write_back_addr;
    assign debug_wb_rf_wdata = write_back_data;

    // 模块例化
    CU U_CU (
        .clk (clk),
        .reset (resetn),
        .equal (equal_output),
        .instruction (imem_output),
        .pc_enable (pc_enable),
        .npc_enable (npc_enable),
        .ir_enable (ir_enable),
        .A_write_enable (A_write_enable),
        .B_write_enable (B_write_enable),
        .Imm_write_enable (imm_enable),
        .mux_A_select (mux_A_select),
        .mux_B_select (mux_B_select),
        .mux_sll_select (mux_sll_select),
        .aluoutput_write_enable (aluoutput_write_enable),
        .mux_pc_select (mux_pc_select),
        .mux_write_back_addr_select (mux_write_back_addr_select),
        .lmd_write_enable (lmd_write_enable),
        .adder_jump_select (adder_jump_select),
        .write_back_mux_select (write_back_mux_select),
        .imem_write_enable (imem_write_enable),
        .dmem_write_enable (dmem_write_enable),
        .reg_write_enable (reg_write_enable),
        .alu_op (alu_op)
    );

    equal U_equal(
        .A (reg_A_output),
        .B (reg_B_output),
        .equal_output (equal_output)
    );

    pc U_pc(
        .clk (clk),
        .rst (resetn),
        .write_enable(pc_enable),
        .pc_input (pc_input),
        .pc_output (pc_output)
    );   

    adder U_if_adder (
        .A (pc_output),
        .B (32'h4),
        .F (if_adder_output)
    );

    npc U_npc (
        .clk (clk),
        .reset (resetn),
        .write_enable (npc_enable),
        .pc_input (if_adder_output),
        .npc (npc)
    );

    IMEM U_IMEM (
        .clk (clk),
        .raddr (pc_output),
        .waddr (),
        .write_enable(imem_write_enable),
        .wdata (),
        .rdata (imem_output)
    );

    IR U_IR (
        .clk (clk),
        .reset (resetn),
        .write_enable (ir_enable),
        .instr_input(imem_output),
        .instr_output (ir_output)
    );

    extender U_extender (
        .instr_index (ir_output[15:0]),
        .ext_instr_index (ext_instr_index) 
    );
    
    addr_mux U_write_back_addr_mux (
        .A (ir_output[15:11]),
        .B (ir_output[20:16]),
        .select (mux_write_back_addr_select),
        .out (write_back_addr)
    );

    regfile U_regfile (
        .clk (clk),
        .raddr1 (ir_output[25:21]),
        .raddr2 (ir_output[20:16]),
        .we (reg_write_enable),
        .waddr (write_back_addr),
        .wdata (write_back_data),
        .rdata1 (reg_files_outputA),
        .rdata2 (reg_files_outputB)
    );

    data_reg U_A (
        .clk (clk),
        .reset(resetn),
        .write_enable (A_write_enable),
        .reg_input (reg_files_outputA),
        .reg_output (reg_A_output)
    );

    data_reg U_B (
        .clk (clk),
        .reset (resetn),
        .write_enable (B_write_enable),
        .reg_input (reg_files_outputB),
        .reg_output (reg_B_output)
    );

    mux U_alu_mux1 (
        .A (reg_A_output),
        .B (npc),
        .select (mux_A_select),
        .out (alu_A_input)
    ); 

    mux U_alu_mux2 (
        .A (reg_B_output),
        .B (reg_imm_output),
        .select (mux_B_select),
        .out (alu_B_input)
    ); 

    alu U_alu (
        .A (alu_A_sll_input),
        .B (alu_B_input),
        .Card (alu_op),
        .result(alu_output)
    );

    imm U_imm (
        .clk (clk),
        .reset (resetn),
        .write_enable (imm_enable),
        .reg_input (ext_instr_index),
        .reg_output (reg_imm_output)
    );
    
    data_reg U_aluoutput(
        .clk (clk),
        .reset (resetn),
        .write_enable (aluoutput_write_enable),
        .reg_input (alu_output),
        .reg_output (alureg_output)
    );

    DMEM U_DMEM (
        .clk(clk),
        .raddr (alureg_output),
        .waddr (alureg_output),
        .write_enable (dmem_write_enable),
        .wdata (reg_B_output),
        .rdata (dmem_data_output)
    );

    data_reg U_LMD (
        .clk (clk),
        .reset (resetn),
        .write_enable (lmd_write_enable),
        .reg_input (dmem_data_output),
        .reg_output (lmd_output)
    );

    mux U_write_back_mux (
        .A (lmd_output),
        .B (alureg_output),
        .select (write_back_mux_select),
        .out (write_back_data)
    );

    npc_adder U_npc_adder (
        .A (npc),
        .B (alureg_output),
        .F (npc_adder_output)
    );

    mux U_jump_select (
        .A ({npc[31:28], ir_output[25:0], {2'b0}}),
        .B (npc_adder_output),
        .select (adder_jump_select),
        .out (jump_select_output)
    );

    mux U_mux_pc_select (
        .A (npc),
        .B (jump_select_output),
        .select (mux_pc_select),
        .out (pc_input)
    );

    mux U_sll_mux (
        .A ({{27'd0}, ir_output[10:6]}),
        .B (alu_A_input),
        .select (mux_sll_select),
        .out (alu_A_sll_input)
    );

endmodule
