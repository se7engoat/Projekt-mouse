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
    input RESET,
    input CLK,
    input CLK_MOUSE_IN,
    input DATA_MOUSE_IN,
    input READ_ENABLE,
    output [7:0] BYTE_READ,
    output [1:0] BYTE_ERROR_CODE,
    output BYTE_READY,
    output [3:0] STATE
);
    // Clock edge detection
    reg ClkMouseDelayed;
    always @(posedge CLK)
        ClkMouseDelayed <= CLK_MOUSE_IN;

    // State machine registers
    reg [2:0]   CurrState, NextState;
    reg [7:0]   CurrShiftReg, NextShiftReg;
    reg [3:0]   CurrBitCounter, NextBitCounter;
    reg         CurrByteReady, NextByteReady;
    reg [1:0]   CurrErrorCode, NextErrorCode;
    reg [15:0]  CurrTimeout, NextTimeout;

    // Sequential logic
    always @(posedge CLK) begin
        if (RESET) begin
            CurrState       <= 3'b0;
            CurrShiftReg    <= 8'h00;
            CurrBitCounter <= 0;
            CurrByteReady   <= 1'b0;
            CurrErrorCode  <= 2'b00;
            CurrTimeout     <= 0;
        end else begin
            CurrState       <= NextState;
            CurrShiftReg    <= NextShiftReg;
            CurrBitCounter <= NextBitCounter;
            CurrByteReady   <= NextByteReady;
            CurrErrorCode  <= NextErrorCode;
            CurrTimeout    <= NextTimeout;
        end
    end

    parameter IDLE = 3'b000, RECEIVE = 3'b001, PARITY_CHECK = 3'b010, STOP_CHECK = 3'b011, READY = 3'b100;
    // Combinatorial logic
    always @(*) begin
        // Defaults
        NextState        = CurrState;
        NextShiftReg     = CurrShiftReg;
        NextBitCounter   = CurrBitCounter;
        NextByteReady    = 1'b0;
        NextErrorCode    = CurrErrorCode;
        NextTimeout     = CurrTimeout + 1'b1;

        // State transitions
        case (CurrState)
            // IDLE
            IDLE: begin
                if (READ_ENABLE & ClkMouseDelayed & ~CLK_MOUSE_IN & ~DATA_MOUSE_IN) begin
                    NextState     = RECEIVE;
                    NextErrorCode = 2'b00;
                end
                NextBitCounter = 0;
            end

            // RECEIVE BITS
            RECEIVE: begin
                if (CurrTimeout == 50000)
                    NextState = IDLE;
                else if (CurrBitCounter == 8) begin
                    NextState      = PARITY_CHECK;
                    NextBitCounter = 0;
                end else if (ClkMouseDelayed & ~CLK_MOUSE_IN) begin //shift byte in
                    NextShiftReg[6:0] = CurrShiftReg[7:1];
                    NextShiftReg[7]  = DATA_MOUSE_IN;
                    NextBitCounter   = CurrBitCounter + 1;
                    NextTimeout     = 0;
                end
            end

            // PARITY CHECK
            PARITY_CHECK: begin
                if (CurrTimeout == 50000)
                    NextState = IDLE;
                else if (ClkMouseDelayed & ~CLK_MOUSE_IN) begin
                    if (DATA_MOUSE_IN != ~^CurrShiftReg[7:0])
                        NextErrorCode[0] = 1'b1;
                    NextBitCounter = 0;
                    NextState      = STOP_CHECK;
                    NextTimeout    = 0;
                end
            end

            // STOP BIT CHECK
            STOP_CHECK: begin
                if (CurrTimeout == 50000)
                    NextState = IDLE;
                else if (ClkMouseDelayed & ~CLK_MOUSE_IN) begin
                    if (~DATA_MOUSE_IN)
                        NextErrorCode[1] = 1'b1;
                    
                    NextBitCounter = 0;
                    NextState       = READY;
                    NextTimeout     = 0;
                end
            end

            // BYTE READY
            READY: begin
                NextState = IDLE;
                NextByteReady = 1'b1;
            end

            default: begin
                NextState       = IDLE;
                NextShiftReg    = 8'h00;
                NextBitCounter  = 4'h0;
                NextByteReady   = 1'b0;
                NextErrorCode   = 2'b00;
                NextTimeout     = 0;
            end
        endcase
    end

    assign BYTE_READY      = CurrByteReady;
    assign BYTE_READ       = CurrShiftReg;
    assign BYTE_ERROR_CODE = CurrErrorCode;
    assign STATE          = CurrState;

endmodule
