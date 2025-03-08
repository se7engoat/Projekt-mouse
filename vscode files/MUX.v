`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.03.2025 19:39:46
// Design Name: 
// Module Name: MUX
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


module MUX(
    input [1:0] CONTROL,
    input [3:0] IN0,
    input [3:0] IN1,
    input [3:0] IN2,
    input [3:0] IN3,
    output reg [3:0] OUT
    );
    
    always @(CONTROL or IN0 or IN1 or IN2 or IN3) begin
        case (CONTROL)
            2'b00: OUT <= IN0;
            2'b01: OUT <= IN1;
            2'b10: OUT <= IN2;
            2'b11: OUT <= IN3;
            default: OUT <= 4'b0000;
        endcase
     end
endmodule
