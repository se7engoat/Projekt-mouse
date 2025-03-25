`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/9 09:54:06
// Design Name: 
// Module Name: Top
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


module Top(
    input CLK,               // System Clock
    input RESET,             // Reset Signal
    output HS,               // Horizontal Sync for VGA
    output VS,               // Vertical Sync for VGA
    output [7:0] COLOUR_OUT,  // VGA Colour Output
    inout CLK_MOUSE,
    inout DATA_MOUSE,
    output [3:0] SEG_SELECT,
    output [7:0] HEX_OUT,
    output [15:0] LED_OUT
);
  
  // ======================
  // Internal Signals
  // ======================
  wire [7:0] BusData;          // Data Bus
  wire [7:0] BusAddr;          // Address Bus
  wire BusWE;                  // Write Enable
  wire [7:0] RomAddress;       // ROM Address Output
  wire [7:0] RomData;          // ROM Data Input
  wire [1:0] BusInterruptsRaise; // Interrupt Raise Signals
  wire [1:0] BusInterruptsAck;   // Interrupt Acknowledge Signals
  

  // ======================
  // Microprocessor Instantiation
  // ======================
  Microprocessor proc (
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

  // ======================
  // ROM Instantiation
  // ======================
  // The ROM provides program instructions to the Microprocessor.
  ROM rom (
      .CLK(CLK),
      .ADDR(RomAddress),
      .DATA(RomData)
  );

  // ======================
  // RAM Instantiation
  // ======================
  // RAM is used as general-purpose storage for the processor.
  RAM ram (
      .CLK(CLK),
      .BUS_DATA(BusData),
      .BUS_ADDR(BusAddr),
      .BUS_WE(BusWE)
  );

  // ======================
  // Timer Instantiation
  // ======================
  // The Timer generates periodic interrupts for time-based operations.
  Timer timer (
      .CLK(CLK),
      .RESET(RESET),
      .BUS_DATA(BusData),
      .BUS_ADDR(BusAddr),
      .BUS_WE(BusWE),
      .BUS_INTERRUPT_RAISE(BusInterruptsRaise[1]),
      .BUS_INTERRUPT_ACK(BusInterruptsAck[1])
  );
  
  // ======================
  // VGA Driver Instantiation
  // ======================
  // The VGA Driver generates video output signals for display.
  VGA_Driver vga (
      .CLK(CLK),
      .RESET(RESET),
      .BUS_DATA(BusData),
      .BUS_ADDR(BusAddr),
      .BUS_WE(BusWE),
      .COLOUR_OUT(COLOUR_OUT),
      .HS(HS),
      .VS(VS)
  );
  
  MousePeripheral mouse(
      .CLK(CLK),
      .RESET(RESET),
      // mouse signals
      .DATA_MOUSE(DATA_MOUSE),
      .CLK_MOUSE(CLK_MOUSE),
      // bus signals
      .BUS_DATA(BusData),
      .BUS_ADDR(BusAddr),
      .BUS_WE(BusWE),
      // interrupt signals
      .BUS_INTERRUPT_RAISE(BusInterruptsRaise[0]),
      .BUS_INTERRUPT_ACK(BusInterruptsAck[0])
  );
  

  Seg7Peripheral SevenSegment(
       .CLK(CLK),
       .BUS_ADDR(BUS_ADDR),
       .BUS_DATA(BUS_DATA),
       .BUS_WE(BUS_WE),
       .SEG_SELECT(SEG_SELECT),
       .HEX_OUT(HEX_OUT)
  );
  
  
  LedPeripheral LED(
       .CLK(CLK),
       .BUS_DATA(BUS_DATA),
       .BUS_ADDR(BUS_ADDR),
       .BUS_WE(BUS_WE),
       .LEDS(LED_OUT)
  );
  
  
//  TenHz_cnt Timer(
//          .CLK(CLK),
//          .RESET(RESET),
//          .BUS_DATA(BUS_DATA),
//          .BUS_ADDR(BUS_ADDR),
//          .BUS_WE(BUS_WE),
//          .BUS_INTERRUPT_RAISE(BUS_INTERRUPT_RAISE[1]),
//          .BUS_INTERRUPT_ACK(BUS_INTERRUPT_ACK[1])
//  );
  
  
  
  
endmodule