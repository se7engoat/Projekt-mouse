`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.03.2025 19:20:30
// Design Name: 
// Module Name: BusInterfaceMouse
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


module BusInterfaceMouse(
      //Standard Inputs  
      input RESET,  
      input CLK,  
      //BUS Signals
      inout [7:0] BUS_ADDR,
      inout [7:0] BUS_DATA,
      input BUS_WE,
      //IO - Mouse side  
      inout CLK_MOUSE,    
      inout DATA_MOUSE, 
      output BUS_INTERRUPT_RAISE,
      input BUS_INTERRUPT_ACK
    );
    
    // Mouse Outputs
	wire [7:0] MouseStatus;
	wire [7:0] MouseX;
//	wire [7:0] MouseDx;
	wire [7:0] MouseY;
//	wire [7:0] MouseDy;
	wire [7:0] MouseZ;
    //Mouse Interrupt signal
    wire SendInterrupt;
    MouseTransceiver MT (
        .RESET(RESET),
        .CLK(CLK),
        .CLK_MOUSE(CLK_MOUSE),
        .DATA_MOUSE(DATA_MOUSE),
        .MouseStatus(MouseStatus),
        .MouseX(MouseX),
        .MouseY(MouseY),
        .MouseZ(MouseZ),
        .SendInterrupt(SendInterrupt)
    );
    
    //Mouse signal to raise an interrupt when it is moved
    reg InterruptRaise;
    
    always @(posedge CLK) begin
        if (RESET)
            InterruptRaise <= 1'b0; //RESET the InterruptRaise 
        else if (SendInterrupt) 
            InterruptRaise <= 1'b1; //Raise an interrupt to the CPU if the mouse is moved
        else if (BUS_INTERRUPT_ACK)
            InterruptRaise <= 1'b0; //Reset InterruptRaise signal when the cpu acknowledges the interrupt raised.
    end
    
    assign BUS_INTERRUPT_RAISE = InterruptRaise;
   
    //The bus is tristate
    //need to check if the bus is being written to by the CPU, if not, write enable and then send
    
    wire [7:0] BusDataBuffer;
    reg [7:0] BusOut;
    reg BusInterfaceWE;
    assign BUS_DATA = (BusInterfaceWE) ? BusOut : 8'hZZ;
    assign BusDataBuffer = BUS_DATA;
    
    // Interface design
    parameter BaseAddr = 8'hA0;
    parameter AddrWidth = 3;     //width of bus depends on bits we sending from mouse, 5 bits, so width = 3
    reg [7:0] Memory [2**(AddrWidth)-1 : 0]; //Byte Addressable memory. 
    //Totally 2**(3) memory elements each of size 8bits.
    
    always @(posedge CLK) begin
        //Mouse Data is sent
        Memory[0] <= MouseStatus;
        Memory[1] <= MouseX;
        Memory[2] <= MouseY;
        Memory[3] <= MouseZ;
        
        //Checking if the right peripheral is called
        if ((BUS_ADDR >= BaseAddr) & (BUS_ADDR < BaseAddr+ (2**AddrWidth))) begin
            if (BUS_WE) begin
                Memory[BUS_ADDR[3:0]] <= BusDataBuffer;
                BusInterfaceWE <= 1'b0;
            end else 
                BusInterfaceWE <= 1'b1;
        end else
            BusInterfaceWE <= 1'b0; //If this is not the write peripheral do not write to it
        
        BusOut <= Memory[BUS_ADDR[3:0]]; 
    end
    
    
    
    
    
endmodule
