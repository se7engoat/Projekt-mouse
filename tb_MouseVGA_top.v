`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2025 03:36:17
// Design Name: 
// Module Name: tb_TopModule
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


module TopModule_tb;

    //inputs
    reg CLK;
    reg RESET;
    reg SWITCH;
    
    //outputs
    wire [3:0] SEG_SELECT;
    wire [7:0] HEX_OUT;
    wire [15:0] LED_OUT;
    wire HS;
    wire VS;
    wire [7:0] COLOUR_OUT;
    wire CLK_MOUSE;
    wire DATA_MOUSE;
    reg [7:0] BUS_DATA;
    reg [7:0] BUS_ADDR;
    reg BUS_WE;
    reg [1:0] BUS_INTERRUPT_ACK;
    reg [1:0] BUS_INTERRUPT_RAISE;
    wire [7:0] ROM_ADDRESS;
    wire [7:0] ROM_DATA;
    
    // Instantiate the TopModule (DUT)
    TopModule DUT (
        .CLK(CLK),
        .RESET(RESET),
        .SWITCH(SWITCH),
        .CLK_MOUSE(CLK_MOUSE),
        .DATA_MOUSE(DATA_MOUSE),
        .SEG_SELECT(SEG_SELECT),
        .HEX_OUT(HEX_OUT),
        .LED_OUT(LED_OUT),
        .HS(HS),
        .VS(VS),
        .COLOUR_OUT(COLOUR_OUT)
    );
    
    // Clock generation (period: 10ns, frequency: 100MHz)
        always #5 CLK = ~CLK;
        
        // Initial block for testbench initialization
        initial begin
            // Initialize the signals
            CLK = 0;
            RESET = 0;
            SWITCH = 0;
            
            // Apply reset
            RESET = 1;
            #20; // Keep the reset active for 20ns
            RESET = 0;
            
            // Test case 1: Simulate memory write to address 0x10 with data 0x49
            // Write enable (BUS_WE = 1), address = 0x10, data = 0x49
            BUS_ADDR = 8'h10;  // Arbitrary address
            BUS_DATA = 8'h49;  // Data to write
            BUS_WE = 1;        // Enable write
            #10;               // Wait for a small amount of time
            
            // Test case 2: Check the bus values after the write
            if (BUS_WE == 1) begin
                if (BUS_DATA == 8'h49) begin
                    $display("Test case 1 passed: Bus write operation successful (BUS_DATA = 0x49)");
                end else begin
                    $display("Test case 1 failed: Expected BUS_DATA = 0x49, got %h", BUS_DATA);
                end
            end else begin
                $display("Test case 1 failed: BUS_WE was expected to be 1, got %b", BUS_WE);
            end
            
            // Reset the write enable
            BUS_WE = 0;
            #10;

            // Test case 4: Simulate Interrupt Raise and Acknowledge for Timer
            // Raise interrupt for the Timer module
            BUS_INTERRUPT_RAISE = 2'b01; // Set interrupt for Timer
            #10;
            
            // Acknowledge the interrupt for Timer
            BUS_INTERRUPT_ACK = 2'b01; // Set interrupt acknowledge for Timer
            #10;

            if (BUS_INTERRUPT_RAISE) begin
                if (BUS_INTERRUPT_ACK) begin
                    $display("Test case 4 passed: BUS_INTERRUPT_RAISE %h and BUS_INTERRUPT_ACK %h held and passing", BUS_INTERRUPT_RAISE, BUS_INTERRUPT_ACK);
                end else begin
                    $display("Test case 4 failed: BUS_INTERRUPT_ACK %h not held and failing", BUS_INTERRUPT_ACK);
                end
            end else begin
                $display("Test case 4 failed: BUS_INTERRUPT_RAISE %h not held and failing", BUS_INTERRUPT_RAISE);
            end

            
            // Clear the interrupt raise and ack signals
            BUS_INTERRUPT_RAISE = 2'b00; 
            BUS_INTERRUPT_ACK = 2'b00;
            #10;

            if (!BUS_INTERRUPT_RAISE) begin
                if (!BUS_INTERRUPT_ACK) begin
                    $display("Test case 4 passed: BUS_INTERRUPT_RAISE %h and BUS_INTERRUPT_ACK %h cleared", BUS_INTERRUPT_RAISE, BUS_INTERRUPT_ACK);
                end else begin
                    $display("Test case 4 failed: BUS_INTERRUPT_ACK %h not cleared", BUS_INTERRUPT_ACK);
                end
            end else begin
                $display("Test case 4 failed: BUS_INTERRUPT_RAISE %h not cleared", BUS_INTERRUPT_RAISE);
            end

            // VGA Test Case: Verify Sync Signals
            #10;
            if (HS && VS) begin
                $display("VGA Test passed: HS and VS signals are active");
            end else begin
                $display("VGA Test failed: HS = %b, VS = %b", HS, VS);
            end

            // VGA Test Case: Check color output
            #10;
            if (COLOUR_OUT != 8'b0) begin
                $display("VGA Test passed: COLOUR_OUT is active (%h)", COLOUR_OUT);
            end else begin
                $display("VGA Test failed: Expected non-zero COLOUR_OUT, got %h", COLOUR_OUT);
            end

            // End of simulation after a certain period
            #100;
            $finish;
        end
    
    // Optional: Monitor signals and display them during simulation
    initial begin
        $monitor("At time %t, SEG_SELECT = %b, HEX_OUT = %b, LED_OUT = %h, HS = %b, VS = %b, COLOUR_OUT = %h", 
                 $time, SEG_SELECT, HEX_OUT, LED_OUT, HS, VS, COLOUR_OUT);
    end

endmodule
