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
      input RESET,  
      input CLK,
      input [7:0] BUS_ADDR,
      output [7:0] BUS_DATA,
      input BUS_WE, 
      inout CLK_MOUSE,    
      inout DATA_MOUSE, 
      output BUS_INTERRUPT_RAISE,
      input BUS_INTERRUPT_ACK
    );
    
    // Mouse Outputs
	wire [7:0] MouseStatus;
	wire [7:0] MouseX;
	wire [7:0] MouseY;
    wire SendInterrupt;

    MouseTransceiver MT (
        .RESET(RESET),
        .CLK(CLK),
        .CLK_MOUSE(CLK_MOUSE),
        .DATA_MOUSE(DATA_MOUSE),
        .MouseStatus(MouseStatus),
        .MouseX(MouseX),
        .MouseY(MouseY),
        .INTR(SendInterrupt)
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
    
    reg [7:0] BusOut;
    reg BusInterfaceWE;
    assign BUS_DATA = (BusInterfaceWE) ? BusOut : 8'hZZ;
    
    // Interface design
    parameter BaseAddr = 8'hA0;
    reg [7:0] MouseBytes [4:0]; //Byte Addressable memory. 
    assign MouseBytes[0] = MouseStatus;
    assign MouseBytes[1] = MouseX;
    assign MouseBytes[2] = MouseY;

    always @(posedge CLK) begin
        //Checking if the right peripheral is called
        if ((BUS_ADDR >= BaseAddr) & (BUS_ADDR < BaseAddr + 3)) begin
            if (BUS_WE)
                BusInterfaceWE <= 1'b0;
            else 
                BusInterfaceWE <= 1'b1;
        end else
            BusInterfaceWE <= 1'b0; //If this is not the write peripheral do not write to it
        
        BusOut <= MouseBytes[BUS_ADDR[3:0]]; 
    end

endmodule
