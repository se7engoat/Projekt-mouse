`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.03.2025 16:15:19
// Design Name: 
// Module Name: SevenSegmentWrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Wrapper for the seven segment handling interfacing with it.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SevenSegmentWrapper(
        input CLK,
        input [3:0] NUM0, NUM1, NUM2, NUM3,
        output [7:0] LED_OUT,
        output [3:0] SEG_SELECT
    );
    
    // Defining trigger output, strobe output and mutiplexer output
    wire Bit17TrigOut;
    wire [1:0] StrobeCount;
    wire [3:0] MuxOut;
    
    //Instantiating a 17 bit counter. This will provide a refresh rate of 1kHz for the 7 seg display.
    // (On board clock is 100MHz) 
    GenericCounter # (
        .COUNTER_WIDTH(17),
        .COUNTER_MAX(99999)
        )
        Bit17Counter (
        .CLK(CLK),
        .RESET(1'b0),
        .ENABLE(1'b1),
        .TRIG_OUT(Bit17TrigOut)
    );
    
    //Instantiating a 2 bit counter. This counter will provide the strobe output to
    // select one of the 4 available 7 segment displays to be currently displayed
    // at a refresh rate of 1kHz (Obtained from the trigger output of the 17 bit counter).
    GenericCounter # (
        .COUNTER_WIDTH(2),
        .COUNTER_MAX(3)
        )
        Bit2Counter (
        .CLK(CLK),
        .RESET(1'b0),
        .ENABLE(Bit17TrigOut),
        .COUNT(StrobeCount)
    );
    
    // Instantiating a multiplexer. This will output one of the 4 hex digits, corresponding
    // to the mouse coordinates, depending on the strobe output value.
    MUX Mux(
        .CONTROL(StrobeCount),
        .IN0(NUM0),
        .IN1(NUM1),
        .IN2(NUM2),
        .IN3(NUM3),
        .OUT(MuxOut)
    );
    
    // Instantiate a 7 segment display decoder. This will decode the binary values of
    // each digit to be displayed and decodes them into another binary value that
    // corresponds to which pin should be lit up in the seven segment display.
    SevenSegment Seg7 (
        .SEG_SELECT_IN(StrobeCount),
        .BIN_IN(MuxOut),
        .DOT_IN(1'b0),
        .SEG_SELECT_OUT(SEG_SELECT),
        .HEX_OUT(LED_OUT)
    );
    
endmodule
