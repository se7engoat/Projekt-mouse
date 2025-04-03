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
        input [15:0] DIGIT_IN,
        output [7:0] HEX_OUT,
        output [3:0] SEG_SELECT
    );
    
    // Defining trigger output, strobe output and mutiplexer output
    wire ClockTrigger;
    wire [1:0] StrobeCount;
    wire [4:0] MuxOut;
    
    //Instantiating a 17 bit counter. This will provide a refresh rate of 1kHz for the 7 seg display.
    // (On board clock is 100MHz) 
    GenericCounter # (
        .COUNTER_WIDTH(17),
        .COUNTER_MAX(99999)
        )
        ClockDivider (
        .CLK(CLK),
        .RESET(1'b0),
        .ENABLE(1'b1),
        .TRIG_OUT(ClockTrigger)
    );
    
    //Instantiating a 2 bit counter. This counter will provide the strobe output to
    // select one of the 4 available 7 segment displays to be currently displayed
    // at a refresh rate of 1kHz (Obtained from the trigger output of the 17 bit counter).
    GenericCounter # (
        .COUNTER_WIDTH(2),
        .COUNTER_MAX(3)
        )
        DigitSelector (
        .CLK(CLK),
        .RESET(1'b0),
        .ENABLE(ClockTrigger),
        .COUNT(StrobeCount)
    );
    
    // Instantiating a multiplexer. This will output one of the 4 hex digits, corresponding
    // to the mouse coordinates, depending on the strobe output value.
    MUX SegmentSelector(
        .CONTROL(StrobeCount),
        .IN0({1'b0, DIGIT_IN[3:0]}),
        .IN1({1'b0, DIGIT_IN[7:4]}),
        .IN2({1'b0, DIGIT_IN[11:8]}),
        .IN3({1'b0, DIGIT_IN[15:12]}),
        .OUT(MuxOut)
    );
    
    // Instantiate a 7 segment display decoder. This will decode the binary values of
    // each digit to be displayed and decodes them into another binary value that
    // corresponds to which pin should be lit up in the seven segment display.
    SevenSegment Seg7 (
        .SEG_SELECT_IN(StrobeCount),
        .BIN_IN(MuxOut[3:0]),
        .DOT_IN(MuxOut[4]),
        .SEG_SELECT_OUT(SEG_SELECT),
        .HEX_OUT(HEX_OUT)
    );
    
endmodule
