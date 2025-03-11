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
    
    //Bus control signals
    inout [7:0] BUS_ADDR,
    inout [7:0] BUS_DATA,
    inout BUS_WE,
    output BUS_INTERRUPT_RAISE,
    input BUS_INTERRUPT_ACK,
    
    //IO signals
    output SEG_SELECT,
    output LED_OUT
    
    );
    
    reg [15:0] segment7;
    SevenSegmentWrapper SevenSegmentWrapper (
        .CLK(CLK),
        .RESET(RESET),
        .NUM0(segment7[15:12]),
        .NUM1(segment7[11:8]),
        .NUM2(segment7[7:4]),
        .NUM3(segment7[3:0]),
        .LED(LED),
        .SEG_SELECT(SEG_SELECT)
    );
    
    parameter BaseAddr = 8'hD0;
    parameter AddrWidth = 1;
    
    //Tristate wires
    reg [7:0] BufferedDataBus; 
    reg [7:0] DataOut;
    reg BusInterfaceWE;
    
    assign BUS_DATA =  BusInterfaceWE ? DataOut : 8'hZZ; 
    assign BufferedDataOut = BUS_DATA;
    
    reg [7:0] Memory [(2**AddrWidth) - 1:0];
    
    always @(posedge CLK) begin
        segment7[7:0] <= Memory[0];
        segment7[15:8] <= Memory[1];
        
        //Check target device
        if ((BUS_ADDR >= BaseAddr) && (BUS_ADDR < BaseAddr + (2**AddrWidth))) begin
            if (BUS_WE) begin
                Memory[BUS_ADDR[3:0]] <= BufferedDataBus;
                BusInterfaceWE <= 1'b0;
            end else
                BusInterfaceWE <= 1'b1;
        end else
            BusInterfaceWE <= 1'b0;
            
        DataOut = Memory[BUS_DATA[3:0]];
    end
endmodule

