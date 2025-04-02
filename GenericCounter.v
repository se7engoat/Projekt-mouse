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
    input CLK;
    input RESET;
    input ENABLE;
    output reg TRIG_OUT = 0;
    output reg [COUNTER_WIDTH-1:0] COUNT = 0;
    );
    parameter COUNTER_MAX = 9;
    parameter COUNTER_WIDTH = 4;
    
    
    
    //signals that trigger and operate with the TRIG_OUT and COUNT port
    reg [COUNTER_WIDTH-1:0] counter;
    reg trigger_out;
    
    always @(posedge CLK) begin
        if (RESET)
            counter <= 0;
        else if (ENABLE) begin
            if (counter == COUNTER_MAX)
                counter <= 0;
            else
                counter <= counter + 1;
        end
    end
    
    //Synchronous logic for trigger_out
    always @(posedge CLK) begin
        if (RESET)
            trigger_out <= 0;
        else begin
            if (ENABLE && (counter == COUNTER_MAX))
                trigger_out <= 1;
            else
                trigger_out <= 0;
        end
    end
    
    //Tie the registers to the ports
    assign TRIG_OUT = trigger_out;
    assign COUNT = counter;
    
    
    
endmodule
