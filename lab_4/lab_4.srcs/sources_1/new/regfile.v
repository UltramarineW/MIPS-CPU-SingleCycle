`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/29 18:52:59
// Design Name: 
// Module Name: regfile
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


module regfile(
    input clk,
    input [4:0] raddr1,
    input [4:0] raddr2,
    input we,
    input [4:0] waddr,
    input [31:0] wdata,
    output [31:0] rdata1,
    output [31:0] rdata2
    );

    reg [31:0] reg_files [31:0];
    integer i;

    initial begin
        $readmemh("E:\\HIT_Project\\lab_4\\lab_4\\lab4.data\\reg_data.txt", reg_files);
    end

    always @(posedge clk) begin 
        if (we) begin 
            reg_files[waddr] <= wdata;
        end
    end

    assign rdata1 = reg_files[raddr1];
    assign rdata2 = reg_files[raddr2];
endmodule
