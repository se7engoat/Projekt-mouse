`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
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
        //standard signals
        input CLK,
        //BUS signals
        inout [7:0] BUS_DATA,
        output [7:0] BUS_ADDR,
        output BUS_WE,
        output reg [15:0] LEDs
    );
    
    parameter BaseAddr = 8'hC0;
    parameter AddrWidth = 1;
    
    
    //Tristate
    wire [7:0] BufferedDataBus; //for BUS_DATA output
    reg DataOut; //for LED output
    reg BusInterfaceWE; //for BUS_WE output
    
    
    assign BUS_DATA = BUS_WE ? DataOut : 8'hZZ;
    assign BufferedDataBus = BUS_DATA;
    
    
    reg [7:0] Memory [(2**AddrWidth)-1:0]; 
    always @(posedge CLK) begin
        LEDs[15:8] <= Memory[0];
        LEDs[7:0] <= Memory[1];
        
        if (BUS_ADDR >= BaseAddr & BUS_ADDR < BaseAddr + (2**AddrWidth)) begin
            if (BUS_WE) begin
                Memory[BUS_ADDR[3:0]] <= BufferedDataBus;
                BusInterfaceWE <= 1'b0;
            end else 
                BusInterfaceWE <= 1'b1;
        end else
            BusInterfaceWE <= 1'b0;
            
        
        DataOut <= Memory[BUS_ADDR[3:0]];
    end
    
    
endmodule
