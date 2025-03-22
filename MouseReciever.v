`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.01.2025 12:46:27
// Design Name: 
// Module Name: MouseReciever
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

module MouseReceiver(
    // Standard Inputs
    input           RESET,
    input           CLK,
    input           CLK_MOUSE_IN,
    input           DATA_MOUSE_IN,
    input           READ_ENABLE,
    output [7:0]    BYTE_READ,
    output [1:0]    BYTE_ERROR_CODE,
    output          BYTE_READY
);
    // Clock edge detection
    reg clkMouseDelayed;
    always @(posedge CLK)
        clkMouseDelayed <= CLK_MOUSE_IN;

    // State machine registers
    reg [2:0]   currentState, nextState;
    reg [7:0]   currentShiftReg, nextShiftReg;
    reg [3:0]   currentBitCounter, nextBitCounter;
    reg         currentByteReady, nextByteReady;
    reg [1:0]   currentErrorCode, nextErrorCode;
    reg [15:0]  currentTimeout, nextTimeout;

    // Sequential logic
    always @(posedge CLK) begin
        if (RESET) begin
            currentState       <= 3'b0;
            currentShiftReg    <= 8'h00;
            currentBitCounter <= 0;
            currentByteReady   <= 1'b0;
            currentErrorCode  <= 2'b00;
            currentTimeout     <= 0;
        end else begin
            currentState       <= nextState;
            currentShiftReg    <= nextShiftReg;
            currentBitCounter <= nextBitCounter;
            currentByteReady   <= nextByteReady;
            currentErrorCode  <= nextErrorCode;
            currentTimeout    <= nextTimeout;
        end
    end

    parameter IDLE = 3'b000, RECEIVE = 3'b001, PARITY_CHECK = 3'b010, STOP_CHECK = 3'b011, READY = 3'b100;
    // Combinatorial logic
    always @(*) begin
        // Defaults
        nextState        = currentState;
        nextShiftReg     = currentShiftReg;
        nextBitCounter   = currentBitCounter;
        nextByteReady    = 1'b0;
        nextErrorCode    = currentErrorCode;
        nextTimeout     = currentTimeout + 1'b1;

        // State transitions
        case (currentState)
            // IDLE
            IDLE: begin
                if (READ_ENABLE & clkMouseDelayed & ~CLK_MOUSE_IN & ~DATA_MOUSE_IN) begin
                    nextState     = RECEIVE;
                    nextErrorCode = 2'b00;
                end
                nextBitCounter = 0;
            end

            // RECEIVE BITS
            RECEIVE: begin
                if (currentTimeout == 50000)
                    nextState = IDLE;
                else if (currentBitCounter == 8) begin
                    nextState      = PARITY_CHECK;
                    nextBitCounter = 0;
                end else if (clkMouseDelayed & ~CLK_MOUSE_IN) begin //shift byte in
                    nextShiftReg[6:0] = currentShiftReg[7:1];
                    nextShiftReg[7]  = DATA_MOUSE_IN;
                    nextBitCounter   = currentBitCounter + 1;
                    nextTimeout     = 0;
                end
            end

            // PARITY CHECK
            PARITY_CHECK: begin
                if (currentTimeout == 50000)
                    nextState = IDLE;
                else if (clkMouseDelayed & ~CLK_MOUSE_IN) begin
                    if (DATA_MOUSE_IN != ~^currentShiftReg[7:0])
                        nextErrorCode[0] = 1'b1;
                    nextBitCounter = 0;
                    nextState      = STOP_CHECK;
                    nextTimeout    = 0;
                end
            end

            // STOP BIT CHECK
            STOP_CHECK: begin
                if (currentTimeout == 100000)
                    nextState = IDLE;
                else if (clkMouseDelayed & ~CLK_MOUSE_IN) begin
                    if (DATA_MOUSE_IN)
                        nextErrorCode[1] = 1'b0;
                    else
                        nextErrorCode[1] = 1'b0;
                    
                    nextState       = READY;
                    nextTimeout     = 0;
                end
            end

            // BYTE READY
            READY: begin
                if (currentTimeout == 100000) //1ms timeout for 100MHz clock
                    nextState = IDLE;
                if (CLK_MOUSE_IN & DATA_MOUSE_IN) begin
                    nextByteReady = 1'b1;
                    nextState     = IDLE;
                end
            end

            default: begin
                nextState       = IDLE;
                nextShiftReg    = 8'h00;
                nextBitCounter  = 0;
                nextByteReady   = 1'b0;
                nextErrorCode   = 2'b00;
                nextTimeout     = 0;
            end
        endcase
    end

    // Outputs (unchanged ports)
    assign BYTE_READY      = currentByteReady;
    assign BYTE_READ       = currentShiftReg;
    assign BYTE_ERROR_CODE = currentErrorCode;

endmodule
