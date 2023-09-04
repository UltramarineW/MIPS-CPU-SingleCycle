`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/03 15:06:24
// Design Name: 
// Module Name: CU
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

`define OPERATION 6'b000000
`define SW 6'b101011
`define LW 6'b100011
`define BNE 6'b000101
`define J 6'b000010

`define ADD  6'b100000
`define SUB  6'b100010
`define AND  6'b100100
`define OR   6'b100101
`define XOR  6'b100110
`define SLT  6'b101010
`define MOVZ 6'b001010
`define SLL  6'b000000
`define A    6'b000001
`define B    6'b000010

module CU(
    input clk,
    input reset,
    input equal,
    input [31:0] instruction,

    output reg pc_enable,
    output reg npc_enable,
    output reg ir_enable,
    output reg A_write_enable,
    output reg B_write_enable,
    output reg Imm_write_enable,
    output reg aluoutput_write_enable,
    output reg lmd_write_enable,
    output reg imem_write_enable,
    output reg dmem_write_enable,
    output reg reg_write_enable,
    output reg mux_A_select,
    output reg mux_B_select,
    output reg mux_sll_select,
    output reg mux_pc_select,
    output reg mux_write_back_addr_select,
    output reg adder_jump_select,
    output reg write_back_mux_select,
    output reg [5:0] alu_op
    );

    parameter [4:0] IF = 5'b00001;
    parameter [4:0] ID = 5'b00010;
    parameter [4:0] EX = 5'b00100;
    parameter [4:0] MEM = 5'b01000;
    parameter [4:0] WB = 5'b10000;

    reg [4:0] state;
    reg [5:0] opcode;

    initial begin
        // initialize state
        state = IF;
        // initialize register write_enable
        pc_enable <= 1'b0;
        npc_enable <= 1'b0;
        ir_enable <= 1'b0;
        A_write_enable <= 1'b0;
        B_write_enable <= 1'b0;
        Imm_write_enable <= 1'b0;
        aluoutput_write_enable <= 1'b0;
        lmd_write_enable <= 1'b0;
        imem_write_enable <= 1'b0;
        dmem_write_enable <= 1'b0;
        reg_write_enable <= 1'b0;
        // initialize mux select register
        mux_A_select <= 1'b0;
        mux_B_select <= 1'b0;
        mux_sll_select <= 1'b1;
        mux_pc_select <= 1'b0;
        write_back_mux_select <= 1'b0;
        mux_write_back_addr_select <= 1'b0;
        adder_jump_select <= 1'b1;
        alu_op <= `ADD;
    end

    always @(*) begin
        opcode = instruction[31:26];
    end

    // reset and state transition
    always @(posedge clk) begin
        if (!reset) begin
            state = IF;
        end
        else begin
            case (state)
                IF: state <= ID;
                ID: state <= EX;
                EX: state <= MEM;
                MEM: state <= WB;
                WB: state <= IF;
            endcase
        end
    end

    // opcode 相关的ALU选择和二路选择器的选择线选择 共8个
    // mux_A_select,
    // mux_B_select,
    // mux_sll_select, 
    // mux_pc_select, 
    // write_back_mux_select, 
    // mux_write_back_addr_select, 
    // adder_jump_select, 
    // alu_op 
    always @(instruction) begin
        case (opcode)
            `OPERATION: begin
                alu_op <= instruction[5:0];
                mux_A_select <= 1'b0;
                mux_B_select <= 1'b0;
                write_back_mux_select <= 1'b1;
                mux_write_back_addr_select <= 1'b0;
                adder_jump_select <= 1'b1;
                mux_pc_select <= 1'b0;
                if (instruction[5:0] == 6'b000000) begin
                    mux_sll_select <= 1'b0;
                end else begin
                    mux_sll_select <= 1'b1;
                end
            end
            `SW: begin
                alu_op <= `ADD;
                mux_A_select <= 1'b0;
                mux_B_select <= 1'b1;
                mux_pc_select <= 1'b0;
                write_back_mux_select <= 1'b0;
                mux_write_back_addr_select <= 1'b1;
                adder_jump_select <= 1'b1;
                mux_sll_select <= 1'b1;
            end
            `LW: begin
                alu_op <= `ADD;
                mux_A_select <= 1'b0;
                mux_B_select <= 1'b1;
                mux_pc_select <= 1'b0;
                write_back_mux_select <= 1'b0;
                mux_write_back_addr_select <= 1'b1;
                adder_jump_select <= 1'b1;
                mux_sll_select <= 1'b1;
            end
            `BNE: begin
                mux_A_select <= 1'b0;
                mux_B_select <= 1'b1;
                if (equal) begin
                    alu_op <= `B;
                end
                mux_pc_select <= 1'b1;
                adder_jump_select <= 1'b1;
                write_back_mux_select <= 1'b1;
                // mux_write_back_addr_select <= 1'b1;
                mux_sll_select <= 1'b1;
            end
            `J: begin
                mux_A_select <= 1'b0;
                mux_B_select <= 1'b1;
                alu_op <= `B;
                mux_pc_select <= 1'b1;
                write_back_mux_select <= 1'b1;
                adder_jump_select <= 1'b0;
                // mux_write_back_addr_select <= 1'b1;
                mux_sll_select <= 1'b1;
            end
            default: 
                $display("false opcode: $h", opcode);
        endcase
    end


    // 机器周期相关的寄存器写使能信号 共10个
    // pc_enable, 
    // npc_enable,
    // ir_enable, 
    // A_write_enable,  
    // B_write_enable,        
    // aluoutput_write_enable, 
    // Imm_write_enable,      
    // lmd_write_enable,      
    // imem_write_enable,     
    // dmem_write_enable,
    // reg_write_enable 
    always @(state) begin
        case (state) 
            IF: begin
                // close WB register write enable
                pc_enable <= 1'b0;
                dmem_write_enable <= 1'b0;
                reg_write_enable <= 1'b0;
                // open IF register write enable
                npc_enable <= 1'b1;
                ir_enable <= 1'b1;
            end
            ID: begin
                // close IF register write enable
                npc_enable <= 1'b0;
                ir_enable <= 1'b0;
                // open ID register write enable
                A_write_enable <= 1'b1;
                B_write_enable <= 1'b1;
                Imm_write_enable <= 1'b1;
            end
            EX: begin
                // close ID register write enable
                A_write_enable <= 1'b0;
                B_write_enable <= 1'b0;
                Imm_write_enable <= 1'b0;
                // open EX register write enable
                aluoutput_write_enable <= 1'b1;
            end
            MEM: begin
                // close EX write enable 
                aluoutput_write_enable <= 1'b0;
                // open MEM write enable
                lmd_write_enable <= 1'b1;
                if (instruction[31:26] == `SW ) begin
                    dmem_write_enable <= 1'b1;
                end
            end
            WB: begin
                // close MEM write enable 
                lmd_write_enable <= 1'b0;
                // open WB write enable
                pc_enable <= 1'b1;
                if (opcode == `OPERATION || opcode == `LW)
                    reg_write_enable <= 1'b1;
            end
        endcase 
    end
    
endmodule
