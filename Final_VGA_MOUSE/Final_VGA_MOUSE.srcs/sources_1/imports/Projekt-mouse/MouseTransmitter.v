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
//	output [3:0] STATE
);

	// Delayed version of CLK MOUSE to detect clock edges
	reg PrevMouseClk;
	always@(posedge CLK)
		PrevMouseClk <= CLK_MOUSE_IN;
		
	//Now a state machine to control the flow of write data
	reg [3:0] CurrState, NextState;
	reg CurrMouseClkOutWE, NextMouseClkOutWE;
	reg CurrMouseDataOut, NextMouseDataOut;
	reg CurrMouseDataOutWE, NextMouseDataOutWE;
	reg [15:0] CurrSendCounter, NextSendCounter;
	reg CurrByteSent, NextByteSent;
	reg [7:0] CurrByteToSend, NextByteToSend;
	
	parameter IDLE = 4'b0000, CLK_LINE_LOW = 4'b0001, DATA_LINE_LOW = 4'b0010, START_SEND = 4'b0011, SEND_BYTE_TX = 4'b0100, 
	SEND_PARITY = 4'b0101, SEND_STOP_BIT = 4'b0110, RELEASE_DATA_LINE = 4'b0111, CHECK_DATA_MOUSE_IN = 4'b1000, CHECK_CLK_MOUSE_IN = 4'b1001, CHECK_DATA_CLK_MOUSE_IN = 4'b1010;

	// sequential Reset logic;
	always@(posedge CLK) begin 
		if(RESET) begin
			CurrState <= 4'b0;
			CurrMouseClkOutWE <= 1'b0;
			CurrMouseDataOut <= 1'b0;
			CurrMouseDataOutWE <= 1'b0;
			CurrSendCounter <= 0;
			CurrByteSent <= 1'b0;
			CurrByteToSend <= 0;
		end else begin
			CurrState <= NextState;
			CurrMouseClkOutWE <= NextMouseClkOutWE;
			CurrMouseDataOut <= NextMouseDataOut;
			CurrMouseDataOutWE <= NextMouseDataOutWE;
			CurrSendCounter <= NextSendCounter;
			CurrByteSent <= NextByteSent;
			CurrByteToSend <= NextByteToSend;
		end
	end
	
	
	
	//combinational state logic
	always@(*) begin
		// default values
		NextState = CurrState;
		NextMouseClkOutWE = 1'b0;
		NextMouseDataOut = 1'b0;
		NextMouseDataOutWE = CurrMouseDataOutWE;
		NextSendCounter = CurrSendCounter;
		NextByteSent = 1'b0;
		NextByteToSend = CurrByteToSend;
			
		case(CurrState)
			//IDLE
			IDLE: begin
				if(SEND_BYTE) begin
					NextState = CLK_LINE_LOW;
					NextByteToSend = BYTE_TO_SEND;
				end
				NextMouseDataOutWE = 1'b0;
			end
			//Bring Clock line low for at least 100 microsecs i.e. 5000 clock cycles @ 50MHz
			CLK_LINE_LOW: begin
				if(CurrSendCounter == 6000) begin
					NextState = DATA_LINE_LOW;
					NextSendCounter = 0;
				end else
					NextSendCounter = CurrSendCounter + 1'b1;
				NextMouseClkOutWE = 1'b1;
			end
			//Bring the Data Line Low and release the Clock line
			DATA_LINE_LOW: begin
				NextState = START_SEND;
				NextMouseDataOutWE = 1'b1;
			end
			//Start Sending
			START_SEND: begin // change data at falling edge of clock, start bit = 0
				if(PrevMouseClk & ~CLK_MOUSE_IN)
					NextState = SEND_BYTE;
			end
				//Send Bits 0 to 7 - We need to send the byte
			SEND_BYTE: begin // change data at falling edge of clock
				if(PrevMouseClk & ~CLK_MOUSE_IN) begin
					if(CurrSendCounter == 7) begin
						NextState = SEND_PARITY;
						NextSendCounter = 0;
					end else
						NextSendCounter = CurrSendCounter + 1'b1;
				end
					
				NextMouseDataOut = CurrByteToSend[CurrSendCounter];
			end
			
			//Send the parity bit
			SEND_PARITY: begin // change data at falling edge of clock
				if(PrevMouseClk & ~CLK_MOUSE_IN)
					NextState = SEND_STOP_BIT;
				NextMouseDataOut = ~^CurrByteToSend[7:0]; //Odd parrity conversion
			end
				
			//Send the stop bit
			SEND_STOP_BIT: begin 
				if(PrevMouseClk & ~CLK_MOUSE_IN)
					NextState = RELEASE_DATA_LINE;
				NextMouseDataOut = 1'b1;
			end
				
			//Release Data line
			RELEASE_DATA_LINE: begin
				NextState = CHECK_DATA_MOUSE_IN;
				NextMouseDataOutWE = 1'b0;
			end
				
			/*
			Wait for Device to bring Data line low, then wait for Device to bring Clock line low, and finally wait for
			Device to release both Data and Clock.
			*/
			CHECK_DATA_MOUSE_IN: begin
				if(~DATA_MOUSE_IN) // returns to S7 if data line not pulled low by mouse
					NextState = CHECK_CLK_MOUSE_IN;
			end
					
			CHECK_CLK_MOUSE_IN: begin
				if(~CLK_MOUSE_IN) // returns to S8 if CLK not pulled low by mouse
					NextState = CHECK_DATA_CLK_MOUSE_IN;
			end
					
			//Wait for both lines to be released by the mouse
			CHECK_DATA_CLK_MOUSE_IN: begin
				if(DATA_MOUSE_IN & CLK_MOUSE_IN) begin // returns to S9 if data line not released (let rise high) by mouse
					NextState = IDLE;	// returns to S9 if CLK not released (let rise high) by mouse
					NextByteSent = 1'b1; // confirms byte was sent out
				end
			end
				
			default: begin
				NextState = IDLE;
				NextMouseClkOutWE = 1'b0;
				NextMouseDataOut = 1'b0;
				NextMouseDataOutWE = 1'b0;
				NextSendCounter = 0;
				NextByteSent = 1'b0;
				NextByteToSend = 8'hFF;
			end				
		endcase
	end
	
	//Assign OUTPUTs
	//Mouse IO - CLK
	assign CLK_MOUSE_OUT_EN = CurrMouseClkOutWE;
	//Mouse IO - DATA
	assign DATA_MOUSE_OUT = CurrMouseDataOut;
	assign DATA_MOUSE_OUT_EN = CurrMouseDataOutWE;
	//Control
	assign BYTE_SENT = CurrByteSent;

endmodule