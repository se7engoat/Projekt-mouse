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
	output [7:0]	MOUSE_DZ,
	output [7:0] 	MOUSE_STATUS,
	output 			SEND_INTERRUPT

    );
	reg [5:0] 	Curr_State, Next_State;
	reg [23:0] 	Curr_Counter, Next_Counter;

	//Transmitter Control
	reg 			Curr_SendByte, Next_SendByte;
	reg [7:0] 	Curr_ByteToSend, Next_ByteToSend;

	//Receiver Control
	reg 			Curr_ReadEnable, Next_ReadEnable;

	//Data Registers
	reg [7:0] 	Curr_Status, Next_Status;
	reg [7:0] 	Curr_Dx, Next_Dx;
	reg [7:0] 	Curr_Dy, Next_Dy;
	reg [7:0]	Curr_Dz, Next_Dz;
	reg 			Curr_SendInterrupt, Next_SendInterrupt;
	reg 			Curr_Intellimouse_Mode, Next_Intellimouse_Mode;

	//Sequential
	always@(posedge CLK)
		begin
			if(RESET)
				begin
					Curr_State 					<= 4'h0;
					Curr_Counter 				<= 0;
					Curr_SendByte 				<= 1'b0;
					Curr_ByteToSend 			<= 8'h00;
					Curr_ReadEnable 			<= 1'b0;
					Curr_Status 				<= 8'h00;
					Curr_Dx 						<= 8'h00;
					Curr_Dy 						<= 8'h00;
					Curr_Dz						<= 8'h00;
					Curr_SendInterrupt 		<= 1'b0;
					Curr_Intellimouse_Mode	<= 0;
				end
			else 
				begin
					Curr_State 					<= Next_State;
					Curr_Counter 				<= Next_Counter;
					Curr_SendByte 				<= Next_SendByte;
					Curr_ByteToSend 			<= Next_ByteToSend;
					Curr_ReadEnable 			<= Next_ReadEnable;
					Curr_Status 				<= Next_Status;
					Curr_Dx 						<= Next_Dx;
					Curr_Dy 						<= Next_Dy;
					Curr_Dz						<= Next_Dz;
					Curr_SendInterrupt 		<= Next_SendInterrupt;
					Curr_Intellimouse_Mode	<= Next_Intellimouse_Mode;
				end
		end
	
	
	parameter INIT = 0, 
	SEND_FF = 1, 
	AWAIT_FF_SENT = 2, 
	ACK_BYTE_RECEIVED =3,
	SELF_TEST_PASS_ACK = 4, 
	BYTE_ACK = 5,
	MOUSE_TRANSMIT = 6,
	BYTE_SENT_ACK = 7,
	BYTE_RECEIVED = 8,
	MOUSE_MODE_EN = 9,
	BYTE_SENT_ACK_10 = 10,
	BYTE_RECEIVED_11 = 11,
	SET_SAMPLE_RATE_200 = 12,
	BYTE_SENT_ACK_13 = 13,
	BYTE_RECEIVED_14 = 14,
	REQ_SAMPLE_RATE_CHANGE = 15,
	BYTE_SENT_ACK_16 = 16,
	BYTE_RECEIVED_17 = 17,
	SET_SAMPLE_RATE_100 = 18,
	BYTE_SENT_ACK_19 = 19,
	BYTE_RECEIVED_20 = 20,
	REQ_SAMPLE_RATE_CHANGE_21 = 21,
	BYTE_SENT_ACK_22 = 22,
	BYTE_RECEIVED_23 = 23,
	SET_SAMPLE_RATE_80 = 24,
	BYTE_SENT_ACK_25 = 25,
	BYTE_RECEIVED_26 = 26,
	REQ_DEVICE_ID = 27,
	BYTE_SENT_ACK_28 = 28,
	BYTE_RECEIVED_29 = 29,
	AWAIT_BYTE_4 = 34,
	SEND_INTR = 35
	;
	
	
	//Combinatorial
	always @(*) 
		begin
			Next_State 					= Curr_State;
			Next_Counter 				= Curr_Counter;
			Next_SendByte 				= 1'b0;
			Next_ByteToSend 			= Curr_ByteToSend;
			Next_ReadEnable 			= 1'b0;
			Next_Status 				= Curr_Status;
			Next_Dx 						= Curr_Dx;
			Next_Dy 						= Curr_Dy;
			Next_Dz						= Curr_Dz;
			Next_SendInterrupt 		= 1'b0;
			Next_Intellimouse_Mode	= Curr_Intellimouse_Mode;
			
			case(Curr_State)
				//Initialise State - Wait here for 10ms before trying to initialise the mouse.
				INIT: 
					begin
						Next_Intellimouse_Mode 	= 0;
						if(Curr_Counter == 5000000)
							begin // 1/100th sec at 50MHz clock
								Next_State 			= SEND_FF;
								Next_Counter 		= 0;
							end 
						else	
							Next_Counter 			= Curr_Counter + 1'b1;
					end
					//Start initialisation by sending FF
				SEND_FF: 
					begin
						Next_State 					= AWAIT_FF_SENT;
						Next_SendByte 				= 1'b1;
						Next_ByteToSend 			= 8'hFF;
					end
				//Wait for confirmation of the byte being sent
				AWAIT_FF_SENT: 
					begin
						if(BYTE_SENT)
							Next_State 				= ACK_BYTE_RECEIVED;
					end
				//Wait for confirmation of a byte being received
				//If the byte is FA goto next state, else re-initialise.
				ACK_BYTE_RECEIVED: 
					begin
						if(BYTE_READY)
							begin
								if((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00))
									Next_State 		= SELF_TEST_PASS_ACK;
								else
									Next_State 		= INIT;
							end
						
						Next_ReadEnable 			= 1'b1;
					end
				//Wait for self-test pass confirmation
				//If the byte received is AA goto next state, else re-initialise
				SELF_TEST_PASS_ACK: //4					
				    begin
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
				BYTE_ACK: //5 
					begin
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
				MOUSE_TRANSMIT: //6 
					begin
						Next_State 					= BYTE_SENT_ACK;
						Next_SendByte 				= 1'b1;
						Next_ByteToSend 			= 8'hF4;
					end
					
				//Wait for confirmation of the byte being sent
				
				BYTE_SENT_ACK: //7
				    if(BYTE_SENT) 
				        Next_State = BYTE_RECEIVED;
				
				//Wait for confirmation of a byte being received
				//If the byte is FA goto next state, else re-initialise
				BYTE_RECEIVED: //8
					begin
						if(BYTE_READY) 
							begin
								if((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00))
									Next_State 		= MOUSE_MODE_EN;
								else
									Next_State 		= INIT;
							end
						
						Next_ReadEnable 			= 1'b1;
					end

				// From here on out this is to enable microsoft mouse mode (scoll wheel)
				// Send sample rate change request (next byte is value)
				MOUSE_MODE_EN: //9
					begin
						Next_State 					= BYTE_SENT_ACK_10;
						Next_SendByte 				= 1'b1;
						Next_ByteToSend 			= 8'hF3;
					end

				//Wait for confirmation of the byte being sent
				BYTE_SENT_ACK_10: //10
				    if(BYTE_SENT) 
				        Next_State = BYTE_RECEIVED_11;

				//Wait for confirmation of a byte being received
				//If the byte is FA goto next state, else re-initialise.
				BYTE_RECEIVED_11: //11
					begin
						if(BYTE_READY)
							begin
								if((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00))
									Next_State 		= SET_SAMPLE_RATE_200;
								else
									Next_State 		= 0;
							end
						
						Next_ReadEnable 			= 1'b1;
					end


				// Send sample rate change to 200
				SET_SAMPLE_RATE_200: //12
					begin
						Next_State 					= BYTE_SENT_ACK_13;
						Next_SendByte 				= 1'b1;
						Next_ByteToSend 			= 8'hC8;
					end

				//Wait for confirmation of the byte being sent
				BYTE_SENT_ACK_13: 
				    if(BYTE_SENT) 
				        Next_State = BYTE_RECEIVED_14;

				//Wait for confirmation of a byte being received
				//If the byte is FA goto next state, else re-initialise.
				BYTE_RECEIVED_14: 
					begin
						if(BYTE_READY)
							begin
								if((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00))
									Next_State 		= REQ_SAMPLE_RATE_CHANGE;
								else
									Next_State 		= 0;
							end
						
						Next_ReadEnable 			= 1'b1;
					end

				// Send sample rate change request (next byte is value)
				REQ_SAMPLE_RATE_CHANGE:
					begin
						Next_State 					= BYTE_SENT_ACK_16;
						Next_SendByte 				= 1'b1;
						Next_ByteToSend 			= 8'hF3;
					end

				//Wait for confirmation of the byte being sent
				BYTE_SENT_ACK_16: 
				    if(BYTE_SENT) 
				        Next_State = BYTE_RECEIVED_17;

				//Wait for confirmation of a byte being received
				//If the byte is FA goto next state, else re-initialise.
				BYTE_RECEIVED_17: 
					begin
						if(BYTE_READY)
							begin
								if((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00))
									Next_State 		= SET_SAMPLE_RATE_100;
								else
									Next_State 		= INIT;
							end
						
						Next_ReadEnable 			= 1'b1;
					end

				// Send sample rate change to 100
				SET_SAMPLE_RATE_100: //18
					begin
						Next_State 					= 19;
						Next_SendByte 				= 1'b1;
						Next_ByteToSend 			= 8'h64;
					end

				//Wait for confirmation of the byte being sent
				BYTE_SENT_ACK_19: 
				    if(BYTE_SENT) 
				        Next_State = BYTE_RECEIVED_20;

				//Wait for confirmation of a byte being received
				//If the byte is FA goto next state, else re-initialise.
				BYTE_RECEIVED_20: 
					begin
						if(BYTE_READY)
							begin
								if((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00))
									Next_State 		= REQ_SAMPLE_RATE_CHANGE_21;
								else
									Next_State 		= INIT;
							end
						
						Next_ReadEnable 			= 1'b1;
					end

				// Send sample rate change request (next byte is value)
				REQ_SAMPLE_RATE_CHANGE_21:
					begin
						Next_State 					= BYTE_SENT_ACK_22;
						Next_SendByte 				= 1'b1;
						Next_ByteToSend 			= 8'hF3;
					end

				//Wait for confirmation of the byte being sent
				BYTE_SENT_ACK_22: 
				    if(BYTE_SENT) 
				        Next_State = BYTE_RECEIVED_23;

				//Wait for confirmation of a byte being received
				//If the byte is FA goto next state, else re-initialise.
				BYTE_RECEIVED_23: 
					begin
						if(BYTE_READY)
							begin
								if((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00))
									Next_State 		= SET_SAMPLE_RATE_80;
								else
									Next_State 		= INIT;
							end
						
						Next_ReadEnable 			= 1'b1;
					end

				// Send sample rate change to 80
				SET_SAMPLE_RATE_80: //24
					begin
						Next_State 					= BYTE_SENT_ACK_25;
						Next_SendByte 				= 1'b1;
						Next_ByteToSend 			= 8'h50;
					end

				//Wait for confirmation of the byte being sent
				BYTE_SENT_ACK_25: 
				    if(BYTE_SENT) 
				        Next_State = BYTE_RECEIVED_26;

				//Wait for confirmation of a byte being received
				//If the byte is FA goto next state, else re-initialise.
				BYTE_RECEIVED_26: 
					begin
						if(BYTE_READY)
							begin
								if((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00))
									Next_State 		= REQ_DEVICE_ID;
								else
									Next_State 		= INIT;
							end
						
						Next_ReadEnable 			= 1'b1;
					end

				// Send device ID request
			    REQ_DEVICE_ID: //27
					begin
						Next_State 					= BYTE_SENT_ACK_28;
						Next_SendByte 				= 1'b1;
						Next_ByteToSend 			= 8'hF2;
					end

				//Wait for confirmation of the byte being sent
				BYTE_SENT_ACK_28: 
				    if(BYTE_SENT) 
				        Next_State = BYTE_RECEIVED_29;

				//Wait for confirmation of a byte being received
				//If the byte is FA goto next state, else re-initialise.
				BYTE_RECEIVED_29: 
					begin
						if(BYTE_READY)
							begin
								if((BYTE_READ == 8'hFA) & (BYTE_ERROR_CODE == 2'b00))
									Next_State 		= 30;
								else
									Next_State 		= INIT;
							end
						
						Next_ReadEnable 			= 1'b1;
					end

				30: 
					begin
						if(BYTE_READY) 
							begin
								if((BYTE_READ == 8'h03) & (BYTE_ERROR_CODE == 2'b00))
									begin
										Next_State 					= 31;
										Next_Intellimouse_Mode 	= 1;
									end	
								else if ((BYTE_READ == 8'h00) & (BYTE_ERROR_CODE == 2'b00))
									begin
										Next_State 					= 31;
										Next_Intellimouse_Mode 	= 0;
									end
								else
									Next_State		= 0;
							end
						
						Next_ReadEnable 			= 1'b1;
					end






				///////////////////////////////////////////////////////////
				//At this point the SM has initialised the mouse.
				//Now we are constantly reading. If at any time
				//there is an error, we will re-initialise
				//the mouse - just in case.
				///////////////////////////////////////////////////////////
				//Wait for the confirmation of a byte being received.
				//This byte will be the first of three, the status byte.
				//If a byte arrives, but is corrupted, then we re-initialise
	/*
				4'h9: begin
					if(BYTE_READY & (BYTE_ERROR_CODE == 2'b00)) begin
						Next_State = 4'hA;
						Next_Status = BYTE_READ;
					end else
						Next_State = 4'h9;
						
					Next_Counter = 0;
					Next_ReadEnable = 1'b1;
				end
	*/

			
				//Wait for confirmation of a byte being received
				//This byte will be the second of three, the Dx byte.
				/*
				………………..
				FILL IN THIS AREA
				……………….
				*/
				31:
					begin
						if(BYTE_READY)
							begin
								if(BYTE_ERROR_CODE == 2'b00)
									begin
										Next_State 					= 32;
										Next_Status 				= BYTE_READ;	
									end
								else
									Next_State 						= INIT;					// actually reinit on corrupted byte
							end			

						Next_ReadEnable 							= 1'b1;
					end
						
				32:
					begin
						if(BYTE_READY)
							begin
								if(BYTE_ERROR_CODE == 2'b00)
									begin
										Next_State 					= 33;
										Next_Dx 						= BYTE_READ;
									end
								else
									Next_State 						= 0;
							end
							
						Next_ReadEnable 							= 1'b1;
					end
				//Wait for confirmation of a byte being received
				//This byte will be the third of three, the Dy byte.
				/*
				………………..
				FILL IN THIS AREA
				……………….
				*/
				33:
					begin
						if(BYTE_READY)
							begin
								if(BYTE_ERROR_CODE == 2'b00)
									begin
										if(Curr_Intellimouse_Mode)
											Next_State 				= AWAIT_BYTE_4;
										else
											Next_State				= SEND_INTR;
										Next_Dy 						= BYTE_READ;
									end
								else
									Next_State 						= 0;
							end
							
						Next_ReadEnable 							= 1'b1;
					end

				// Wait for fourth byte in intellimouse mode
				AWAIT_BYTE_4: //34
					begin
						if(BYTE_READY)
							begin
								if(BYTE_ERROR_CODE == 2'b00)
									begin
										Next_Dz						= BYTE_READ;
										Next_State					= SEND_INTR;
									end
								else
									Next_State 						= INIT;
							end
							
						Next_ReadEnable 							= 1'b1;
					end

				//Send Interrupt State
				SEND_INTR: //35
				begin
					Next_State 										= 31;
					Next_SendInterrupt 							= 1'b1;
				end

				//Default State
				default: begin
					Next_State 				= 4'h0;
					Next_Counter 			= 0;
					Next_SendByte 			= 1'b0;
					Next_ByteToSend 		= 8'hFF;
					Next_ReadEnable 		= 1'b0;
					Next_Status 			= 8'h00;
					Next_Dx 					= 8'h00;
					Next_Dy 					= 8'h00;
					Next_Dz					= 8'h00;
					Next_SendInterrupt 	= 1'b0;
				end
			endcase
		end
	
	///////////////////////////////////////////////////
	//Tie the SM signals to the IO
	//Transmitter
	assign SEND_BYTE 			= Curr_SendByte;
	assign BYTE_TO_SEND 		= Curr_ByteToSend;
	
	//Receiver
	assign READ_ENABLE 		= Curr_ReadEnable;
	
	//Output Mouse Data
	assign MOUSE_DX 			= Curr_Dx;
	assign MOUSE_DY 			= Curr_Dy;
	assign MOUSE_STATUS 		= Curr_Status;
	assign SEND_INTERRUPT 	= Curr_SendInterrupt;
	assign MOUSE_DZ			= Curr_Dz;

endmodule