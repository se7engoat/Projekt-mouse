`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.03.2025 16:00:12
// Design Name: 
// Module Name: BusInterfaceSevenSegment
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Handles communication between seven segment wrapper and the processor
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module BusInterfaceSevenSegment(
    input CLK,
    input RESET,
    input [7:0] BUS_ADDR,
    input [7:0] BUS_DATA,
    input BUS_WE,
    output [3:0] SEG_SELECT,
    output [7:0] HEX_OUT
    );

    parameter [7:0] BaseAddr = 8'hD0;
    reg [15:0] segment7_Input;

    SevenSegmentWrapper SevenSegmentWrapper (
        .CLK(CLK),
        .DIGIT_IN(segment7_Input),
        .HEX_OUT(HEX_OUT),
        .SEG_SELECT(SEG_SELECT)
    );
    

    always @(posedge CLK) begin
        if (RESET)
            segment7_Input <= 0;
        else if (BUS_WE) begin
            if (BUS_ADDR == BaseAddr)
                segment7_Input[15:8] <= BUS_DATA; //First two segments
            else if (BUS_ADDR == BaseAddr + 1)
                segment7_Input[7:0] <= BUS_DATA; //Last two segments
        end
    end
endmodule

