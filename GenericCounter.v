`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.03.2025 18:48:53
// Design Name: 
// Module Name: GenericCounter
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


module GenericCounter(
    input CLK,
    input RESET,
    input ENABLE,
    output reg TRIG_OUT = 0,
    output reg [COUNTER_WIDTH-1:0] COUNT = 0
    );
    parameter COUNTER_MAX = 9;
    parameter COUNTER_WIDTH = 4;
    
    always @(posedge CLK) begin
        if (RESET)
            COUNT <= 0;
        else if (ENABLE) begin
            if (COUNT == COUNTER_MAX)
                COUNT <= 0;
            else
                COUNT <= COUNT + 1;
        end
    end
    
    //Synchronous logic for trigger_out
    always @(posedge CLK) begin
        if (RESET)
            TRIG_OUT <= 0;
        else begin
            if (ENABLE && (COUNT == COUNTER_MAX))
                TRIG_OUT <= 1;
            else
                TRIG_OUT <= 0;
        end
    end
    
endmodule
