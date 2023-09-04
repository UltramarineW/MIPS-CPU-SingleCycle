`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/01 10:47:24
// Design Name: 
// Module Name: pc
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


module pc(
    input clk,
    input rst,
    input write_enable,
    input [31:0] pc_input,
    output reg [31:0] pc_output 
    );

    initial begin
        pc_output <= 32'h0000_0000;
    end

    always @(posedge clk) begin
        if (!rst) begin
            pc_output <= 32'd0;
        end
        else begin
            if (write_enable) begin
                pc_output <= pc_input;
            end
        end
    end
endmodule
