`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Sriram Jagathisan
// 
// Create Date: 06.03.2025 22:54:17
// Design Name: 
// Module Name: LED
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


module BusInterfaceLED(
        input CLK,
        input RESET,
        input [7:0] BUS_DATA,
        input [7:0] BUS_ADDR,
        input BUS_WE,
        output reg [15:0] LEDS
    );
    
    parameter [7:0] BaseAddr = 8'hC0;
    // parameter AddrWidth = 1;
    
    // wire [7:0] BufferedDataBus; //for BUS_DATA output
    // reg DataOut; //for LED output
    // reg BusInterfaceWE; //for BUS_WE output
    
    
    // assign BUS_DATA = BUS_WE ? DataOut : 8'hZZ;
    // assign BufferedDataBus = BUS_DATA;
    
    
    // reg [7:0] Memory [(2**AddrWidth)-1:0]; 
    
    always @(posedge CLK) begin
        if (RESET)
            LEDS <= 0;
        else if (BUS_WE) begin
            if (BUS_ADDR == BaseAddr)
                LEDS[7:0] <= BUS_DATA;
            else if (BUS_ADDR == BaseAddr + 1)
                LEDS[15:8] <= BUS_DATA << 4;
        end
    end
    
    
endmodule
