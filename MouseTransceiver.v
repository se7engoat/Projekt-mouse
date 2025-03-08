`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.02.2025 19:17:55
// Design Name: 
// Module Name: MouseTransceiver
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
module MouseTransceiver(  
      //Standard Inputs  
      input RESET,  
      input CLK,  
      //IO - Mouse side  
      inout CLK_MOUSE,    
      inout DATA_MOUSE,  
      // Mouse data information  
      output [3:0] MouseStatus,               
      output [7:0] MouseX,               
      output [7:0] MouseY,
      output [7:0] MouseZ,  
      output SendInterrupt   
 );  

// X, Y Limits of Mouse Position based on VGA screen limits
parameter [7:0] mouseLimitX = 160;
parameter [7:0] mouseLimitY = 120;
parameter [7:0] mouseLimitZ = 255;
  
//TriState Signals
//Clk
reg clkMouseIn;
wire clkMouseOutEnTrans;
  
//Data
wire     dataMouseIn;
wire     dataMouseOutTrans;
wire     dataMouseOutEnTrans;
  
reg[3:0] tempMouseStatus;
reg[7:0] tempMouseX;
reg[7:0] tempMouseY;
reg[7:0] tempMouseZ;

  
//Clk Output - can be driven by host or device
assign CLK_MOUSE = clkMouseOutEnTrans ? 1'b0 : 1'bz;
  
//Clk Input
assign dataMouseIn = DATA_MOUSE;
  
//Data Output - can be driven by host or device
assign DATA_MOUSE = dataMouseOutEnTrans ? dataMouseOutTrans : 1'bz;

//This section filters the incoming Mouse clock to make sure that
//it is stable before data is latched by either transmitter
//or receiver modules
reg [7:0] mouseClkFilter;
  
always@(posedge CLK) begin
    if(RESET)
        clkMouseIn <= 1'b0;
    else 
        begin
            //A simple shift register
            mouseClkFilter[7:1] <= mouseClkFilter[6:0];
            mouseClkFilter[0] <= CLK_MOUSE;
              
            //falling edge
            if(clkMouseIn & (mouseClkFilter == 8'h00))            
                clkMouseIn <= 1'b0;
              
            //rising edge
            else if(~clkMouseIn & (mouseClkFilter == 8'hFF))
                clkMouseIn <= 1'b1;
        end
end
  
  //Instantiate the Transmitter module
  wire             sendByteToMouse;
  wire             byteSentToMouse;
  wire [7:0]         byteToSendToMouse;
  MouseTransmitter T(
                  //Standard Inputs
                  .RESET(RESET),
                  .CLK(CLK),
                  //Mouse IO - CLK
                  .CLK_MOUSE_IN(clkMouseIn),
                  .CLK_MOUSE_OUT_EN(clkMouseOutEnTrans),
                  //Mouse IO - DATA
                  .DATA_MOUSE_IN(dataMouseIn),
                  .DATA_MOUSE_OUT(dataMouseOutTrans),
                  .DATA_MOUSE_OUT_EN(dataMouseOutEnTrans),
                  //Control
                  .SEND_BYTE(sendByteToMouse),
                  .BYTE_TO_SEND(byteToSendToMouse),
                  .BYTE_SENT(byteSentToMouse)
  );
  
  
  //Instantiate the Receiver module
  wire                     readEnable;
  wire [7:0]                 byteRead;
  wire [1:0]                 byteErrorCode;
  wire                     byteReady;
  MouseReceiver R(
                          //Standard Inputs
                          .RESET(RESET),
                          .CLK(CLK),
                          //Mouse IO - CLK
                          .CLK_MOUSE_IN(clkMouseIn),
                          //Mouse IO - DATA
                          .DATA_MOUSE_IN(dataMouseIn),
                          //Control
                          .READ_ENABLE (readEnable),
                          .BYTE_READ(byteRead),
                          .BYTE_ERROR_CODE(byteErrorCode),
                          .BYTE_READY(byteReady)
  );

  //Instantiate the Master State Machine module
  wire [7:0]                 mouseStatusRaw;
  wire [7:0]                 mouseDxRaw;
  wire [7:0]                 mouseDyRaw;
  wire [7:0]                 mouseDzRaw;
  MouseMasterSM MSM(
                              //Standard Inputs
                              .RESET(RESET),
                              .CLK(CLK),
                              //Transmitter Interface
                              .SEND_BYTE(sendByteToMouse),
                              .BYTE_TO_SEND(byteToSendToMouse),
                              .BYTE_SENT(byteSentToMouse),
                              //Receiver Interface
                              .READ_ENABLE (readEnable),
                              .BYTE_READ(byteRead),
                              .BYTE_ERROR_CODE(byteErrorCode),
                              .BYTE_READY(byteReady),
                              //Data Registers
                              .MOUSE_STATUS(mouseStatusRaw),
                              .MOUSE_DX(mouseDxRaw),
                              .MOUSE_DY(mouseDyRaw),
                              .MOUSE_DZ(mouseDzRaw),
                              .SEND_INTERRUPT(SendInterrupt)
  );
 
/* 4th march commenting 
    //for DOT_IN functionality
    reg dot_toggle;
	reg [7:0] prev_MouseZ;

	always @(posedge CLK or posedge RESET) begin
		if (RESET) begin
			dot_toggle <= 0;
			prev_MouseZ <= MouseZ;
		end
		else begin
			// If MouseZ changes (scroll wheel moved), toggle the decimal point
			if (MouseZ != prev_MouseZ) begin
				dot_toggle <= ~dot_toggle;
				prev_MouseZ <= MouseZ;  // Update previous MouseZ value
			end
		end
	end

	// Signals for Seven-Segment Display
	wire [3:0] bin_to_display;
	wire [3:0] seg_select_out;
	wire [7:0] hex_out;
	reg [1:0] seg_select_counter;

	// Display switching to alternate between MouseX and MouseY
	always @(posedge CLK or posedge RESET) begin
    if (RESET)
        seg_select_counter <= 2'b00;
    else
        seg_select_counter <= seg_select_counter + 1'b1;
	end

	// Seven segment switches between MouseX and MouseY every cycle
	assign bin_to_display = (seg_select_counter[0] == 0) ? MouseX[3:0] : MouseY[3:0];

	// Instantiate the Seven-Segment Decoder
	SevenSegment seg_display (
		.SEG_SELECT_IN(seg_select_counter),  // Cycles through display digits
		.BIN_IN(bin_to_display),             // Switches between MouseX and MouseY
		.DOT_IN(dot_toggle),             	 // DOT_IN toggles when the MouseZ, Scrollwheel is spun
    	.SEG_SELECT_OUT(seg_select_out),     // Selected digit
    	.HEX_OUT(hex_out)                    // 7-segment encoded output
	);

	// Connect outputs to module outputs
	assign SEG_SELECT = seg_select_out; //selects which segment to be lit
	assign HEX_OUT = hex_out; //pattern to be displayed on each segment

*/

	//Pre-processing - handling of overflow and signs.
	//More importantly, this keeps tabs on the actual X/Y
	//location of the mouse.
	wire signed [8:0] MouseDx;
	wire signed [8:0] MouseDy;
	wire signed [8:0] MouseDz;
	wire signed [8:0] MouseNewX;
	wire signed [8:0] MouseNewY;
	wire signed [8:0] MouseNewZ;
	
	//DX and DY are modified to take account of overflow and direction
	assign MouseDx = (mouseStatusRaw[6]) ? (mouseStatusRaw[4] ? {mouseStatusRaw[4],8'h00} : {mouseStatusRaw[4],8'hFF} ) : {mouseStatusRaw[4],mouseDxRaw[7:0]};
	
	// assign the proper expression to MouseDy
	assign MouseDy = (mouseStatusRaw[7]) ? (mouseStatusRaw[5] ? {mouseStatusRaw[5],8'h00} : {mouseStatusRaw[5],8'hFF} ) : {mouseStatusRaw[5],mouseDyRaw[7:0]};
	
    // calculate new mouse position
    assign MouseDz = {mouseDzRaw[7],mouseDzRaw[7:0]};
  
    assign MouseNewX = {1'b0,MouseX} + MouseDx;
    assign MouseNewY = {1'b0,MouseY} + MouseDy;
    assign MouseNewZ = {1'b0,MouseZ} + MouseDz;

  always@(posedge CLK)
      begin
          if(RESET) 
              begin
                  tempMouseStatus     <= 4'b0;
                  tempMouseX          <= mouseLimitX/2;
                  tempMouseY          <= mouseLimitY/2;
                  tempMouseZ          <= mouseLimitZ/2;
              end 
          else if (SendInterrupt) 
              begin
              
                  //Status is stripped of all unnecessary info
                  tempMouseStatus     <= mouseStatusRaw[3:0];
              
                  //X is modified based on DX with limits on max and min
                  if(MouseNewX < 0)
                      tempMouseX         <= 0;
                  else if(MouseNewX > (mouseLimitX-1))
                      tempMouseX         <= mouseLimitX-1;
                  else
                      tempMouseX         <= MouseNewX[7:0];
                  
                  //Y is modified based on DY with limits on max and min
                  if(MouseNewY < 0)
                      tempMouseY         <= 0;
                  else if(MouseNewY > (mouseLimitY-1))
                      tempMouseY         <= mouseLimitY-1;
                  else
                      tempMouseY         <= MouseNewY[7:0];
                      
                  //Z is modified based on DZ with limits on max and min
                  //Z wraps around, as this is a scroll wheel
                  if(MouseNewZ < 0)
                      tempMouseY         <= mouseLimitZ;
                  else if(MouseNewZ > mouseLimitZ)
                      tempMouseZ         <= 0;
                  else
                      tempMouseZ         <= MouseNewZ[7:0];                
              end
      end
assign MouseStatus = tempMouseStatus;
assign MouseX = tempMouseX;
assign MouseY = tempMouseY;
assign MouseZ = tempMouseZ;      
endmodule

