`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/01 21:10:39
// Design Name: 
// Module Name: IMEM
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


module IMEM(
    input clk,
    input [31:0] raddr,
    input [31:0] waddr,
    input write_enable,
    input [31:0] wdata,
    output [31:0] rdata
);

    reg [31:0] imem_reg_files [255:0];
    integer i;

    initial begin 
        $readmemh("E:\\HIT_Project\\lab_4\\lab_4\\lab4.data\\inst_data.txt", imem_reg_files);
    end

    always @(posedge clk) begin
        if (write_enable) begin
            imem_reg_files[waddr/4] <= wdata;
        end
    end

    assign rdata = imem_reg_files[raddr/4];
    
endmodule

