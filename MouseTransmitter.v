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
	reg [3:0] currentState, nextState;
	reg currentMouseClkOutWE, nextMouseClkOutWE;
	reg currentMouseDataOut, nextMouseDataOut;
	reg currentMouseDataOutWE, nextMouseDataOutWE;
	reg [15:0] currentSendCounter, nextSendCounter;
	reg currentByteSent, nextByteSent;
	reg [7:0] currentByteToSend, nextByteToSend;
	
	parameter IDLE = 4'b0000, CLK_LINE_LOW = 4'b0001, DATA_LINE_LOW = 4'b0010, START_SEND = 4'b0011, SEND_BYTE_TX = 4'b0100, 
	SEND_PARITY = 4'b0101, SEND_STOP_BIT = 4'b0110, RELEASE_DATA_LINE = 4'b0111, CHECK_DATA_MOUSE_IN = 4'b1000, CHECK_CLK_MOUSE_IN = 4'b1001, CHECK_DATA_CLK_MOUSE_IN = 4'b1010;

	// sequential Reset logic;
	always@(posedge CLK)
		begin
			if(RESET) 
				begin
					currentState <= 4'b0;
					currentMouseClkOutWE <= 1'b0;
					currentMouseDataOut <= 1'b0;
					currentMouseDataOutWE <= 1'b0;
					currentSendCounter <= 0;
					currentByteSent <= 1'b0;
					currentByteToSend <= 0;
				end
			else
				begin
					currentState <= nextState;
					currentMouseClkOutWE <= nextMouseClkOutWE;
					currentMouseDataOut <= nextMouseDataOut;
					currentMouseDataOutWE <= nextMouseDataOutWE;
					currentSendCounter <= nextSendCounter;
					currentByteSent <= nextByteSent;
					currentByteToSend <= nextByteToSend;
				end
		end
	
	
	
	//combinational state logic
	always@(*) 
		begin
			// default values
			nextState = currentState;
			nextMouseClkOutWE = 1'b0;
			nextMouseDataOut = 1'b0;
			nextMouseDataOutWE = currentMouseDataOutWE;
			nextSendCounter = currentSendCounter;
			nextByteSent = 1'b0;
			nextByteToSend = currentByteToSend;
			
			case(currentState)
				//IDLE
				IDLE: 
					begin
						if(SEND_BYTE) 
							begin
								nextState = CLK_LINE_LOW;
								nextByteToSend = BYTE_TO_SEND;
							end
						nextMouseDataOutWE = 1'b0;
					end
				//Bring Clock line low for at least 100 microsecs i.e. 5000 clock cycles @ 50MHz
				CLK_LINE_LOW: 
					begin
							if(currentSendCounter == 6000)
								begin
									nextState = DATA_LINE_LOW;
									nextSendCounter = 0;
								end
							else
								nextSendCounter = currentSendCounter + 1'b1;
								
							nextMouseClkOutWE = 1'b1;
					end
				//Bring the Data Line Low and release the Clock line
				DATA_LINE_LOW: 
					begin
						nextState = START_SEND;
						nextMouseDataOutWE = 1'b1;
					end
				//Start Sending
				START_SEND: 
					begin // change data at falling edge of clock, start bit = 0
						if(clkMouseInDly & ~CLK_MOUSE_IN)
							nextState = SEND_BYTE;
					end
				//Send Bits 0 to 7 - We need to send the byte
				SEND_BYTE: 
					begin // change data at falling edge of clock
						if(clkMouseInDly & ~CLK_MOUSE_IN)
							begin
								if(currentSendCounter == 7) 
									begin
										nextState = SEND_PARITY;
										nextSendCounter = 0;
									end 
								else
									nextSendCounter = currentSendCounter + 1'b1;
						end
						
						nextMouseDataOut = currentByteToSend[currentSendCounter];
					end
				//Send the parity bit
				SEND_PARITY:
					begin // change data at falling edge of clock
						if(clkMouseInDly & ~CLK_MOUSE_IN)
							nextState = SEND_STOP_BIT;
							
						nextMouseDataOut = ~^currentByteToSend[7:0];
					end
				//Send the stop bit
				SEND_STOP_BIT: 
					begin 
						if(clkMouseInDly & ~CLK_MOUSE_IN)
							nextState = RELEASE_DATA_LINE;
						nextMouseDataOut = 1'b1;
					end
				//Release Data line
				RELEASE_DATA_LINE: 
					begin
						nextState = CHECK_DATA_MOUSE_IN;
						nextMouseDataOutWE = 1'b0;
					end
				/*
				Wait for Device to bring Data line low, then wait for Device to bring Clock line low, and finally wait for
				Device to release both Data and Clock.
				*/
				CHECK_DATA_MOUSE_IN: 
					begin
						if(~DATA_MOUSE_IN) // returns to S7 if data line not pulled low by mouse
							nextState = CHECK_CLK_MOUSE_IN;
					end
					
				CHECK_CLK_MOUSE_IN: 
					begin
						if(~CLK_MOUSE_IN) // returns to S8 if CLK not pulled low by mouse
							nextState = CHECK_DATA_CLK_MOUSE_IN;
					end
					
				CHECK_DATA_CLK_MOUSE_IN: 
					begin
						if(DATA_MOUSE_IN & CLK_MOUSE_IN) // returns to S9 if data line not released (let rise high) by mouse
							begin
								nextState = IDLE;	// returns to S9 if CLK not released (let rise high) by mouse
								nextByteSent = 1'b1; // confirms byte was sent out
							end
					end
				default: begin
					nextState <= IDLE;
					nextMouseClkOutWE <= 1'b0;
					nextMouseDataOut <= 1'b0;
					nextMouseDataOutWE <= 1'b0;
					nextSendCounter <= 0;
					nextByteSent <= 1'b0;
					nextByteToSend <= 0;
            	end				
			endcase
		end
	
	//Assign OUTPUTs
	//Mouse IO - CLK
	assign CLK_MOUSE_OUT_EN = currentMouseClkOutWE;

	//Mouse IO - DATA
	assign DATA_MOUSE_OUT = currentMouseDataOut;
	assign DATA_MOUSE_OUT_EN = currentMouseDataOutWE;

	//Control
	assign BYTE_SENT = currentByteSent;

endmodule