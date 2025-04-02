`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.02.2025 14:43:53
// Design Name: 
// Module Name: MouseMasterSM
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


module MouseMasterSM(
    input 			CLK,
	input 			RESET,
	//Transmitter Control
	output 			SEND_BYTE,
	output [7:0] 	BYTE_TO_SEND,
	input 			BYTE_SENT,
	//Receiver Control
	output 			READ_ENABLE,
	input [7:0] 	BYTE_READ,
	input [1:0] 	BYTE_ERROR_CODE,
	input 			BYTE_READY,
	//Data Registers
	output [7:0] 	MOUSE_DX,
	output [7:0] 	MOUSE_DY,
	// output [7:0]	MOUSE_DZ,
	output [7:0] 	MOUSE_STATUS,
	output 			SEND_INTERRUPT,
	output [3:0] 	CURR_STATE

    );


	reg [3:0] Curr_State, Next_State;
	reg [23:0] Curr_Counter, Next_Counter;

	//Transmitter Control
	reg Curr_SendByte, Next_SendByte;
	reg [7:0] 	Curr_ByteToSend, Next_ByteToSend;

	//Receiver Control
	reg Curr_ReadEnable, Next_ReadEnable;

	//Data Registers
	reg [7:0] 	Curr_Status, Next_Status;
	reg [7:0] 	Curr_Dx, Next_Dx;
	reg [7:0] 	Curr_Dy, Next_Dy;
	// reg [7:0]	Curr_Dz, Next_Dz;
	reg Curr_SendInterrupt, Next_SendInterrupt;

	parameter INIT = 4'h0, 
	SEND_FF = 4'h1, 
	AWAIT_FF_SENT = 4'h2, 
	ACK_BYTE_RECEIVED = 4'h3,
	SELF_TEST_PASS_ACK = 4'h4, 
	BYTE_ACK = 4'h5,
	MOUSE_TRANSMIT = 4'h6,
	BYTE_SENT_ACK = 4'h7,
	BYTE_RECEIVED = 4'h8,
	MOUSE_MODE_EN = 4'h9,
	BYTE_SENT_ACK_10 = 4'hA,
	BYTE_RECEIVED_11 = 4'hB,
	SET_SAMPLE_RATE_200 = 4'hC,
	;

	//Sequential
	always@(posedge CLK) begin
		if(RESET) begin
			Curr_State 	<= INIT;
			Curr_Counter <= 0;
			Curr_SendByte <= 1'b0;
			Curr_ByteToSend <= 8'h00;
			Curr_ReadEnable <= 1'b0;
			Curr_Status <= 8'h00;
			Curr_Dx <= 8'h00;
			Curr_Dy <= 8'h00;
			// Curr_Dz	<= 8'h00;
			Curr_SendInterrupt 	<= 1'b0;
		end
		else begin
			Curr_State <= Next_State;
			Curr_Counter <= Next_Counter;
			Curr_SendByte <= Next_SendByte;
			Curr_ByteToSend <= Next_ByteToSend;
			Curr_ReadEnable <= Next_ReadEnable;
			Curr_Status <= Next_Status;
			Curr_Dx <= Next_Dx;
			Curr_Dy <= Next_Dy;
			// Curr_Dz	<= Next_Dz;
			Curr_SendInterrupt <= Next_SendInterrupt;
		end
	end
	
	//Combinatorial
	always @(*) begin
		Next_State 					= Curr_State;
		Next_Counter 				= Curr_Counter;
		Next_SendByte 				= 1'b0;
		Next_ByteToSend 			= Curr_ByteToSend;
		Next_ReadEnable 			= 1'b0;
		Next_Status 				= Curr_Status;
		Next_Dx 					= Curr_Dx;
		Next_Dy 					= Curr_Dy;
		// Next_Dz						= Curr_Dz;
		Next_SendInterrupt 		= 1'b0;
			
		case(Curr_State)
			//Initialise State - Wait here for 10ms before trying to initialise the mouse.
			INIT: begin //0000	
				if(Curr_Counter == 5000000) begin // 1/100th sec at 50MHz clock
					Next_State = SEND_FF;
					Next_Counter = 0;
				end 
				else	
					Next_Counter = Curr_Counter + 1'b1;
			end

			//Start initialisation by sending FF - 0001
			SEND_FF: begin
				Next_State 					= AWAIT_FF_SENT;
				Next_SendByte 				= 1'b1;
				Next_ByteToSend 			= 8'hFF;
			end
				
			//Wait for confirmation of the byte being sent - 0002
			AWAIT_FF_SENT: begin
				if(BYTE_SENT)
					Next_State 	= ACK_BYTE_RECEIVED;
			end

			//Wait for confirmation of a byte being received
			//If the byte is FA goto next state, else re-initialise.
			ACK_BYTE_RECEIVED: begin //0003
				if(BYTE_READY) begin
					if((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00))
						Next_State 		= SELF_TEST_PASS_ACK;
					else
						Next_State 		= INIT;
				end
				Next_ReadEnable 			= 1'b1;
			end

			//Wait for self-test pass confirmation
			//If the byte received is AA goto next state, else re-initialise
			SELF_TEST_PASS_ACK: begin //0004
				if(BYTE_READY) begin
					if((BYTE_READ == 8'hAA) & (BYTE_ERROR_CODE == 2'b00))
						Next_State 		= BYTE_ACK;
					else
						Next_State 		= INIT;
				end	
				Next_ReadEnable              = 1'b1;
			end
				
			//Wait for confirmation of a byte being received
			//If the byte is 00 goto next state (MOUSE ID) else re-initialise
			BYTE_ACK: begin //5
				if(BYTE_READY) 
					begin
						if((BYTE_READ == 8'h00) & (BYTE_ERROR_CODE == 2'b00))
							Next_State 		= MOUSE_TRANSMIT;
						else
							Next_State 		= 0;
					end
				
				Next_ReadEnable = 1'b1;
			end
				
			//Send F4 - to start mouse transmit
			MOUSE_TRANSMIT: //0006 
				begin
					Next_State 	= BYTE_SENT_ACK;
					Next_SendByte = 1'b1;
					Next_ByteToSend = 8'hF4;
				end
					
				//Wait for confirmation of the byte being sent
				
			BYTE_SENT_ACK: //0007
				if(BYTE_SENT) 
					Next_State = BYTE_RECEIVED;
				
			//Wait for confirmation of a byte being received
			//If the byte is FA goto next state, else re-initialise
			BYTE_RECEIVED: //0008
				begin
					if(BYTE_READY) begin
						if(BYTE_READ == 8'hFA)
							Next_State 		= MOUSE_MODE_EN;
						else
							Next_State 		= INIT;
					end
					Next_ReadEnable 			= 1'b1;
				end

			// From here on out this is to enable microsoft mouse mode (scoll wheel)
			// Send sample rate change request (next byte is value)
			MOUSE_MODE_EN: begin //0009
				if (BYTE_READY) begin
					if(BYTE_ERROR_CODE == 2'b00) begin
						Next_State 		= BYTE_SENT_ACK_10;
						Next_Status = BYTE_READ;
					end
					else
						Next_State 		= INIT;
				end
				Next_ReadEnable = 1'b1;
			end

			//Wait for confirmation of the byte being sent
			BYTE_SENT_ACK_10: begin //000A
				if (BYTE_READY) begin
					if(BYTE_ERROR_CODE == 2'b00) begin
						Next_State = BYTE_RECEIVED_11;
						Next_Dx = BYTE_READ;
					end else
						Next_State = INIT;
				end

				Next_ReadEnable = 1'b1;
			end
				

			//Wait for confirmation of a byte being received
			//If the byte is FA goto next state, else re-initialise.
			BYTE_RECEIVED_11: begin //000B
				if(BYTE_READY) begin
					if(BYTE_ERROR_CODE == 2'b00) begin
						Next_Dy = BYTE_READ;
						Next_State 		= SET_SAMPLE_RATE_200;
					end else
						Next_State 		= IDLE;
				end
				Next_ReadEnable = 1'b1;
			end

			SET_SAMPLE_RATE_200: begin
				Next_State = MOUSE_MODE_EN;
				Next_SendInterrupt = 1'b1;
			end
		endcase
	end
	
	///////////////////////////////////////////////////
	//Tie the SM signals to the IO
	//Transmitter
	assign SEND_BYTE = Curr_SendByte;
	assign BYTE_TO_SEND = Curr_ByteToSend;
	//Receiver
	assign READ_ENABLE = Curr_ReadEnable;
	//Output Mouse Data
	assign MOUSE_DX = Curr_Dx;
	assign MOUSE_DY = Curr_Dy;
	assign MOUSE_STATUS = Curr_Status;
	assign SEND_INTERRUPT = Curr_SendInterrupt;
	assign CURR_STATE = Curr_State;

endmodule