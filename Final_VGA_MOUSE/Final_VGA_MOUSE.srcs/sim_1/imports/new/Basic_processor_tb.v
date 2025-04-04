`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/10 18:19:39
// Design Name: 
// Module Name: Basic_processor_tb
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

`timescale 1ns / 1ps

module Basic_processor_tb;
    
    reg CLK;
    reg RESET;
    wire [7:0] BUS_DATA;
    wire [7:0] BUS_ADDR;
    wire BUS_WE;
    wire [7:0] ROM_ADDRESS;
    wire [7:0] ROM_DATA;
    wire [1:0] BUS_INTERRUPTS_RAISE;
    wire [1:0] BUS_INTERRUPTS_ACK;
    wire [7:0] STATE;
    
    // Clock signal
    always #5 CLK = ~CLK;

    // Initialize RAM
    RAM ram_inst (
        .CLK(CLK),
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE)
    );

    // Initialize ROM
    ROM rom_inst (
        .CLK(CLK),
        .DATA(ROM_DATA),
        .ADDR(ROM_ADDRESS)
    );

    // Processor instance
    Processor processor_inst (
        .CLK(CLK),
        .RESET(RESET),
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        .ROM_ADDRESS(ROM_ADDRESS),
        .ROM_DATA(ROM_DATA),
        .BUS_INTERRUPTS_RAISE(BUS_INTERRUPTS_RAISE),
        .BUS_INTERRUPTS_ACK(BUS_INTERRUPTS_ACK),
        .STATE(STATE)
    );

    initial begin
        // Initialize signals
        CLK = 0;
        RESET = 1;
        #10 RESET = 0;

        // Run for a period of time
        #500 $stop;
    end

endmodule
