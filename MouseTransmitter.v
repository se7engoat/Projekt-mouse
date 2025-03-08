`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Sriram Jagathisan
// 
// Create Date: 30.01.2025 18:29:17
// Design Name: 
// Module Name: MouseTransmitter
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

module MouseTransmitter(
    //Standard inputs
    input RESET,
    input CLK,
    
    //Mouse IO - CLK
    input CLK_MOUSE_IN,
    output CLK_MOUSE_OUT_EN, //Allows for the control of the clock line
    
    //Mouse IO - DATA
    input DATA_MOUSE_IN,
    output DATA_MOUSE_OUT, 
    output DATA_MOUSE_OUT_EN,
    
    //Control
    input SEND_BYTE,
    input [7:0] BYTE_TO_SEND,
    output BYTE_SENT
    );

	// Clk Mouse delayed to detect clock edges - falling here
	reg clkMouseInDly;
	always@(posedge CLK)
		clkMouseInDly <= CLK_MOUSE_IN;
		
	//Now a state machine to control the flow of write data
	reg [3:0] presentState, nextState;
	reg presentMouseClkOutWE, nextMouseClkOutWE;
	reg presentMouseDataOut, nextMouseDataOut;
	reg presentMouseDataOutWE, nextMouseDataOutWE;
	reg [15:0] presentSendCounter, nextSendCounter;
	reg presentByteSent, nextByteSent;
	reg [7:0] presentByteToSend, nextByteToSend;
	parameter IDLE = 4'b0000, CLK_LINE_LOW = 4'b0001, DATA_LINE_LOW = 4'b0010, START_SEND = 4'b0011, SEND_BYTE_TX = 4'b0100, 
	SEND_PARITY = 4'b0101, SEND_STOP_BIT = 4'b0110, RELEASE_DATA_LINE = 4'b0111, CHECK_DATA_MOUSE_IN = 4'b1000, CHECK_CLK_MOUSE_IN = 4'b1001, CHECK_DATA_CLK_MOUSE_IN = 4'b1010;

	// sequential Reset logic;
	always@(posedge CLK)
		begin
			if(RESET) 
				begin
					presentState <= 4'b0;
					presentMouseClkOutWE <= 1'b0;
					presentMouseDataOut <= 1'b0;
					presentMouseDataOutWE <= 1'b0;
					presentSendCounter <= 0;
					presentByteSent <= 1'b0;
					presentByteToSend <= 0;
				end
			else
				begin
					presentState <= nextState;
					presentMouseClkOutWE <= nextMouseClkOutWE;
					presentMouseDataOut <= nextMouseDataOut;
					presentMouseDataOutWE <= nextMouseDataOutWE;
					presentSendCounter <= nextSendCounter;
					presentByteSent <= nextByteSent;
					presentByteToSend <= nextByteToSend;
				end
		end
	
	
	
	//combinational state logic
	always@(*) 
		begin
			// default values
			nextState = presentState;
			nextMouseClkOutWE = 1'b0;
			nextMouseDataOut = 1'b0;
			nextMouseDataOutWE = presentMouseDataOutWE;
			nextSendCounter = presentSendCounter;
			nextByteSent = 1'b0;
			nextByteToSend = presentByteToSend;
			
			case(presentState)
				//IDLE
				IDLE: 
					begin
						if(SEND_BYTE) 
							begin
								nextState = 1;
								nextByteToSend = BYTE_TO_SEND;
							end
						nextMouseDataOutWE = 1'b0;
					end
				//Bring Clock line low for at least 100 microsecs i.e. 5000 clock cycles @ 50MHz
				CLK_LINE_LOW: 
					begin
							if(presentSendCounter == 6000)
								begin
									nextState = 2;
									nextSendCounter = 0;
								end
							else
								nextSendCounter = presentSendCounter + 1'b1;
								
							nextMouseClkOutWE = 1'b1;
					end
				//Bring the Data Line Low and release the Clock line
				DATA_LINE_LOW: 
					begin
						nextState = 3;
						nextMouseDataOutWE = 1'b1;
					end
				//Start Sending
				START_SEND: 
					begin // change data at falling edge of clock, start bit = 0
						if(clkMouseInDly & ~CLK_MOUSE_IN)
						//(~clkMouseInDly & CLK_MOUSE_IN) use this if the clk edge is in pos edge
							nextState = 4;
					end
				//Send Bits 0 to 7 - We need to send the byte
				SEND_BYTE: 
					begin // change data at falling edge of clock
						if(clkMouseInDly & ~CLK_MOUSE_IN)
						//(~clkMouseInDly & CLK_MOUSE_IN) use this if clk edge is in pos edge
							begin
								if(presentSendCounter == 7) 
									begin
										nextState = 5;
										nextSendCounter = 0;
									end 
								else
									nextSendCounter = presentSendCounter + 1'b1;
						end
						
						nextMouseDataOut = presentByteToSend[presentSendCounter];
					end
				//Send the parity bit
				SEND_PARITY:
					begin // change data at falling edge of clock
						if(clkMouseInDly & ~CLK_MOUSE_IN)
						//(~clkMouseInDly & CLK_MOUSE_IN)
							nextState = 6;
							
						nextMouseDataOut = ~^presentByteToSend[7:0];
					end
				//Send the stop bit... this state was forgotten in the original partial code
				SEND_STOP_BIT: 
					begin 
						if(clkMouseInDly & ~CLK_MOUSE_IN)
						// (~clkMouseInDly & CLK_MOUSE_IN)
							nextState = 7;
							
						nextMouseDataOut = 1'b1;
					end
				//Release Data line
				RELEASE_DATA_LINE: 
					begin
						nextState = 8;
						nextMouseDataOutWE = 1'b0;
					end
				/*
				Wait for Device to bring Data line low, then wait for Device to bring Clock line low, and finally wait for
				Device to release both Data and Clock.
				*/
				CHECK_DATA_MOUSE_IN: 
					begin
						if(!DATA_MOUSE_IN) // returns to S7 if data line not pulled low by mouse
							nextState = 9;
					end
					
				CHECK_CLK_MOUSE_IN: 
					begin
						if(!CLK_MOUSE_IN) // returns to S8 if CLK not pulled low by mouse
							nextState = 10;
					end
					
				CHECK_DATA_CLK_MOUSE_IN: 
					begin
						if(DATA_MOUSE_IN & CLK_MOUSE_IN) // returns to S9 if data line not released (let rise high) by mouse
							begin
								nextState = 0;	// returns to S9 if CLK not released (let rise high) by mouse
								nextByteSent = 1'b1; // confirms byte was sent out
							end
					end				
			endcase
		end
	
	//Assign OUTPUTs
	//Mouse IO - CLK
	assign CLK_MOUSE_OUT_EN = presentMouseClkOutWE;

	//Mouse IO - DATA
	assign DATA_MOUSE_OUT = presentMouseDataOut;
	assign DATA_MOUSE_OUT_EN = presentMouseDataOutWE;

	//Control
	assign BYTE_SENT = presentByteSent;

endmodule