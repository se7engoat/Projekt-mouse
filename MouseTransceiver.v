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
    input RESET,  
    input CLK,   
    inout CLK_MOUSE,    
    inout DATA_MOUSE,  
    output reg [3:0] MouseStatus,               
    output reg [7:0] MouseX,               
    output reg [7:0] MouseY,
    output INTR   
);  

    // X, Y Limits of Mouse Position based on VGA screen limits
    parameter [7:0] mouseLimitX = 160;
    parameter [7:0] mouseLimitY = 120;
    // parameter [7:0] mouseLimitZ = 255;
    
    //TriState Signals
    //Clk
    reg ClkMouseIn;
    wire ClkMouseOutEn;
    
    //Data
    wire DataMouseIn;
    wire DataMouseOut;
    wire DataMouseOutEn;

    
    //Clk Output - can be driven by host or device
    assign CLK_MOUSE = ClkMouseOutEn ? 1'b0 : 1'bz;
    
    //Clk Input
    assign DataMouseIn = DATA_MOUSE;
    
    //Data Output - can be driven by host or device
    assign DATA_MOUSE = DataMouseOutEn ? DataMouseOut : 1'bz;

    //This section filters the incoming Mouse clock to make sure that
    //it is stable before data is latched by either transmitter
    //or receiver modules
    reg [7:0] MouseClkFilter;
    
    always@(posedge CLK) begin
        if(RESET)
            ClkMouseIn <= 1'b0;
        else begin
            MouseClkFilter[7:1] <= MouseClkFilter[6:0]; //shift register
            MouseClkFilter[0] <= CLK_MOUSE;
            
            //falling edge
            if(ClkMouseIn & (MouseClkFilter == 8'h00))            
                ClkMouseIn <= 1'b0;
            //rising edge
            else if(~ClkMouseIn & (MouseClkFilter == 8'hFF))
                ClkMouseIn <= 1'b1;
        end
    end
    
    //Instantiate the Transmitter module
    wire SendByte;
    wire ByteSent;
    wire [7:0] ByteToSend;
    MouseTransmitter T(
        .RESET(RESET),
        .CLK(CLK),
        //Mouse IO - CLK
        .CLK_MOUSE_IN(ClkMouseIn),
        .CLK_MOUSE_OUT_EN(ClkMouseOutEn),
        //Mouse IO - DATA
        .DATA_MOUSE_IN(DataMouseIn),
        .DATA_MOUSE_OUT(DataMouseOut),
        .DATA_MOUSE_OUT_EN(DataMouseOutEn),
        //Control
        .SEND_BYTE(SendByte),
        .BYTE_TO_SEND(ByteToSend),
        .BYTE_SENT(ByteSent)
    );
    
    
    //Instantiate the Receiver module
    wire ReadEnable;
    wire [7:0] ByteRead;
    wire [1:0] ByteError;
    wire ByteReady;
    
    MouseReceiver R(
        .RESET(RESET),
        .CLK(CLK),
        .CLK_MOUSE_IN(ClkMouseIn),
        .DATA_MOUSE_IN(DataMouseIn),
        .READ_ENABLE (ReadEnable),
        .BYTE_READ(ByteRead),
        .BYTE_ERROR_CODE(ByteError),
        .BYTE_READY(ByteReady)
    );


    //Instantiate the Master State Machine module
    wire [7:0] MouseStatusRaw;
    wire [7:0] MouseDxRaw;
    wire [7:0] MouseDyRaw;
    wire SendInterrupt;
    
    MouseMasterSM MSM(
        .RESET(RESET),
        .CLK(CLK),
        .SEND_BYTE(SendByte),
        .BYTE_TO_SEND(ByteToSend),
        .BYTE_SENT(ByteSent),
        .READ_ENABLE (ReadEnable),
        .BYTE_READ(ByteRead),
        .BYTE_ERROR_CODE(ByteError),
        .BYTE_READY(ByteReady),
        .MOUSE_STATUS(MouseStatusRaw),
        .MOUSE_DX(MouseDxRaw),
        .MOUSE_DY(MouseDyRaw),
        .SEND_INTERRUPT(SendInterrupt)
    );
    

    //Pre-processing - handling of overflow and signs.
    //More importantly, this keeps tabs on the actual X/Y
    //location of the mouse.
    wire signed [8:0] MouseDx;
    wire signed [8:0] MouseDy;
    wire signed [8:0] MouseNewX;
    wire signed [8:0] MouseNewY;

    assign MouseDX = MouseDxRaw;
    assign MouseDY = MouseDyRaw;
    assign INTERRUPT = SendInterrupt;

    //DX and DY are modified to take account of overflow and direction
    assign MouseDx = (MouseStatusRaw[6]) ? (MouseStatusRaw[4] ? {MouseStatusRaw[4],8'h00} : {MouseStatusRaw[4],8'hFF} ) : {MouseStatusRaw[4],MouseDxRaw[7:0]};
    assign MouseDy = (MouseStatusRaw[7]) ? (MouseStatusRaw[5] ? {MouseStatusRaw[5],8'h00} : {MouseStatusRaw[5],8'hFF} ) : {MouseStatusRaw[5],MouseDyRaw[7:0]};

    assign MouseNewX = {1'b0,MouseX} + MouseDx;
    assign MouseNewY = {1'b0,MouseY} + MouseDy;

    always@(posedge CLK) begin
        if(RESET) begin
            MouseStatus <= 0;
            MouseX <= mouseLimitX/2;
            MouseY <= mouseLimitY/2;
        end
        else if (SendInterrupt) begin
            MouseStatus <= MouseStatusRaw[7:0];
            //X is modified based on DX with limits on max and min
            if(MouseNewX < 0)
                MouseX <= 0;
            else if(MouseNewX > (mouseLimitX-1))
                MouseX <= mouseLimitX-1;
            else
                MouseX <= MouseNewX[7:0];
            
            //Y is modified based on DY with limits on max and min
            if(MouseNewY < 0)
                MouseY <= 0;
            else if(MouseNewY > (mouseLimitY-1))
                MouseY <= mouseLimitY-1;
            else
                MouseY <= MouseNewY[7:0];
        end
    end
endmodule

