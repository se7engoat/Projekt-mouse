`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2025 19:18:41
// Design Name: 
// Module Name: TopModule
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


module TopModule(
    input CLK,
    input RESET,

    //mouse
    inout CLK_MOUSE,
    inout DATA_MOUSE,
    
    //Seven Segment
    output [3:0] SEG_SELECT,
    output [7:0] LED_OUT,
    
    //LEDs
    output [15:0] LED_LIGHTS
    
    );

    //IO bus
    wire [7:0] BUS_DATA;
    wire [7:0] BUS_ADDR;
    wire BUS_WE;
    
    //Interrupt bus
    wire [1:0] BUS_INTERRUPT_ACK;
    wire [1:0] BUS_INTERRUPT_RAISE;

    //Instruction bus
    wire [7:0] ROM_ADDRESS;
    wire [7:0] ROM_DATA;


    Processor CPU (
        .CLK(CLK),
        .RESET(RESET),
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        .ROM_ADDRESS(ROM_ADDRESS),
        .ROM_DATA(ROM_DATA),
        .BUS_INTERRUPT_RAISE(BUS_INTERRUPT_RAISE),
        .BUS_INTERRUPT_ACK(BUS_INTERRUPT_ACK)
    );
    
    
    RAM Memory(
        .CLK(CLK),
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE)
    );
    
    ROM ROM(
        .CLK(CLK),
        .DATA(ROM_DATA),
        .ADDR(ROM_ADDRESS)
    );
    
    Timer Timer(
        .CLK(CLK),
        .RESET(RESET),
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        .BUS_INTERRUPT_RAISE(BUS_INTERRUPT_RAISE[1]),
        .BUS_INTERRUPT_ACK(BUS_INTERRUPT_ACK[1])
    );
    
    BusInterfaceSevenSegment SevenSegment(
        .CLK(CLK),
        .BUS_ADDR(BUS_ADDR),
        .BUS_DATA(BUS_DATA),
        .BUS_WE(BUS_WE),
        // .BUS_INTERRUPT_RAISE(BUS_INTERRUPT_RAISE),
        // .BUS_INTERRUPT_ACK(BUS_INTERRUPT_ACK),
        .SEG_SELECT(SEG_SELECT),
        .LED_OUT(LED_OUT)
    );
    
    BusInterfaceMouse MouseInterface(
        .RESET(RESET),  
        .CLK(CLK),
        .BUS_ADDR(BUS_ADDR),
        .BUS_DATA(BUS_DATA),
        .BUS_WE(BUS_WE),  
        .CLK_MOUSE(CLK_MOUSE),    
        .DATA_MOUSE(DATA_MOUSE), 
        .BUS_INTERRUPT_RAISE(BUS_INTERRUPT_RAISE[0]),
        .BUS_INTERRUPT_ACK(BUS_INTERRUPT_ACK[0])
    );
    
    
    BusInterfaceLED LED_IO(
        .CLK(CLK),
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        .LED_LIGHTS(LED_LIGHTS)
    );
    
    
endmodule
