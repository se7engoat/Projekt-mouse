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
    input SWITCH,

    //mouse
    inout CLK_MOUSE,
    inout DATA_MOUSE,
    
    //Seven Segment
    output [3:0] SEG_SELECT,
    output [7:0] HEX_OUT,
    
    //LEDs
    output [15:0] LED_OUT,

    //VGA
    output HS,               // Horizontal Sync for VGA
    output VS,               // Vertical Sync for VGA
    output [7:0] COLOUR_OUT  // VGA Colour Output
    
    );

    //IO bus
    wire [7:0] BusData;
    wire [7:0] BusAddr;
    wire BusWE;
    
    //Interrupt bus
    wire [1:0] BusInterruptsRaise;
    wire [1:0] BusInterruptsAck;

    //Instruction bus
    wire [7:0] RomAddress;
    wire [7:0] RomData;


    Processor CPU (
        .CLK(CLK),
        .RESET(RESET),
        .BUS_DATA(BusData),
        .BUS_ADDR(BusAddr),
        .BUS_WE(BusWE),
        .ROM_ADDRESS(RomAddress),
        .ROM_DATA(RomData),
        .BUS_INTERRUPTS_RAISE(BusInterruptsRaise),
        .BUS_INTERRUPTS_ACK(BusInterruptsAck)
    );
    
    
    RAM ram(
        .CLK(CLK),
        .BUS_DATA(BusData),
        .BUS_ADDR(BusAddr),
        .BUS_WE(BusWE)
    );
    
    ROM rom(
        .CLK(CLK),
        .DATA(RomData),
        .ADDR(RomAddress)
    );
    
    Timer timer(
        .CLK(CLK),
        .RESET(RESET),
        .BUS_DATA(BusData),
        .BUS_ADDR(BusAddr),
        .BUS_WE(BusWE),
        .BUS_INTERRUPT_RAISE(BusInterruptsRaise[1]),
        .BUS_INTERRUPT_ACK(BusInterruptsAck[1])
    );
    
    BusInterfaceSevenSegment seg7(
        .CLK(CLK),
        .RESET(RESET),
        .BUS_ADDR(BusAddr),
        .BUS_DATA(BusData),
        .BUS_WE(BusWE),
        .SEG_SELECT(SEG_SELECT),
        .HEX_OUT(HEX_OUT)
    );
    
    BusInterfaceMouse mouse(
        .RESET(RESET),  
        .CLK(CLK),
        .BUS_ADDR(BusAddr),
        .BUS_DATA(BusData),
        .BUS_WE(BusWE),  
        .CLK_MOUSE(CLK_MOUSE),    
        .DATA_MOUSE(DATA_MOUSE), 
        .BUS_INTERRUPT_RAISE(BusInterruptsRaise[0]),
        .BUS_INTERRUPT_ACK(BusInterruptsAck[0])
    );
    
    
    BusInterfaceLED led(
        .CLK(CLK),
        .RESET(RESET),
        .BUS_DATA(BusData),
        .BUS_ADDR(BusAddr),
        .BUS_WE(BusWE),
        .LEDS(LED_OUT)
    );

    SwitchPeripheral switch (
        .CLK(CLK),
        .RESET(RESET),
        .SWITCH_IN(SWITCH),
        .BUS_DATA(BusData),
        .BUS_ADDR(BusAddr),
        .BUS_WE(BusWE)
    );
    
    VGA_Driver vga(
        .CLK(CLK),
        .RESET(RESET),
        .BUS_DATA(BusData),
        .BUS_ADDR(BusAddr),
        .BUS_WE(BusWE),
        .COLOUR_OUT(COLOUR_OUT),
        .HS(HS),
        .VS(VS)
    );
    
endmodule
