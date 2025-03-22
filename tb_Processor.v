`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.03.2025 11:23:10
// Design Name: 
// Module Name: tb_Processor
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

module Processor_tb;

    // Inputs
    reg CLK;
    reg RESET;
    reg [1:0] BUS_INTERRUPT_RAISE;

    // Outputs
    wire [7:0] BUS_ADDR;
    wire BUS_WE;
    wire [7:0] ROM_ADDRESS;
    wire [7:0] BUS_DATA; // Tristate output
    wire [1:0] BUS_INTERRUPT_ACK;

    // ROM Data
    reg [7:0] ROM_DATA;

    // Instantiate the Processor
    Processor uut (
        .CLK(CLK),
        .RESET(RESET),
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        .ROM_ADDRESS(ROM_ADDRESS),
        .ROM_DATA(ROM_DATA),
        .BUS_INTERRUPT_RAISE(BUS_INTERRUPT_RAISE),
        .BUS_INTERRUPT_ACK(BUS_INTERRUPT_ACK)
    );

    // Clock generation
    always #5 CLK = ~CLK;  // Clock period is 10ns (100MHz)
    

<<<<<<< HEAD
    //clk timeperiod is 50Hz so that should be 20ns. 
    //ONE CLK CYCLE - 20ns. For most of the operations here were are waiting for 2 clock cycles for the instructions to get implemented
    //thus the wait period should be #40 for two full clocks
    
    //this can be a task that can be used for maybe a load and store function
    //LOAD instruction
    task readFromMemory(int A, int B);
    begin
        #20 BUS_DATA = 8'h01;
        #20 BUS
    end

    //STORE instruction
    task writeToMemory(int A, int B);
    begin
        
    end

    //Arithmetic instruction
    task mathOP(int A. int B, int opCode);
    begin
        
    end

    //Jump Instruction
    task jumpInstruction(int Addr, int returnContext);
    begin
        
    end

    //Branch Instruction
    task branchInstr(int Addr, int Context);
    begin
        
    end

    //Dereference
    task Dereference(int A, int B);
    begin
        
    end

    
    always #10 CLK = ~CLK;
    
=======
    // Initial block for stimulus
>>>>>>> ff548a73f3f01a96e05affc9b52558173adb69ee
    initial begin
        // Initialize inputs
        CLK = 0;
        RESET = 0;
        BUS_INTERRUPT_RAISE = 2'b00;
        // Placeholder value for ROM data
        //It is also the init state of the processor SM after a reset.
        ROM_DATA = 8'hFF;  

        // Apply reset
        RESET = 1;
        #10;
        RESET = 0;

        // Test 1: Check if the processor starts in IDLE state after a RESET.
        // BUS_ADDR to be set to INIT_INSTRUCTION_POST_RESET state (8'hFF) after reset.
        #10;
        if (uut.CurrState != 8'hFF) begin
            $display("Test 1 Failed: Expected state 8'hFF (IDLE), got %h", uut.CurrState);
        end else begin
            $display("Test 1 Passed: Processor is in IDLE state after reset");
        end

        // Test 2: Raise an interrupt and check for thread start address
        BUS_INTERRUPT_RAISE = 2'b01;  // Raise interrupt A
        #10;
        if (uut.CurrState != 8'hF1) begin
            $display("Test 2 Failed: Expected state 8'hF1 (GET_THREAD_START_ADDR_0), got %h", uut.CurrState);
        end else begin
            $display("Test 2 Passed: Interrupt raised and processor moved to GET_THREAD_START_ADDR_0");
        end
        
        // Test 3: Provide a program counter value and check if state changes accordingly
        ROM_DATA = 8'h10;  // Set ROM_DATA to 0x10 (instruction for READ_FROM_MEM_TO_A)
        #10;
        if (uut.CurrState != 8'h10) begin
            $display("Test 3 Failed: Expected state 8'h10 (READ_FROM_MEM_TO_A), got %h", uut.CurrState);
        end else begin
            $display("Test 3 Passed: Processor moved to READ_FROM_MEM_TO_A state");
        end

        // Test 4: Simulate another interrupt to check if the processor responds accordingly
        BUS_INTERRUPT_RAISE = 2'b10;  // Raise interrupt B
        #10;
        if (uut.CurrState != 8'hF1) begin
            $display("Test 4 Failed: Expected state 8'hF1 (GET_THREAD_START_ADDR_0), got %h", uut.CurrState);
        end else begin
            $display("Test 4 Passed: Interrupt raised and processor moved to GET_THREAD_START_ADDR_0");
        end

        // Test 5: Check if processor handles memory read/write
        ROM_DATA = 8'h02;  // Simulate instruction 0x02 (WRITE_TO_MEM_FROM_A)
        #10;
        if (uut.CurrState != 8'h20) begin
            $display("Test 5 Failed: Expected state 8'h20 (WRITE_TO_MEM_FROM_A), got %h", uut.CurrState);
        end else begin
            $display("Test 5 Passed: Processor handled WRITE_TO_MEM_FROM_A correctly");
        end

        // Test 6: Check if processor handles memory read/write
        ROM_DATA = 8 'h00; // Simulate instruction 0x00 (READ_FROM_MEM_TO_A)
        #10;
        if (uut.CurrState != 8'h10) begin
            $display("Test 6 Failed: Expected state 8'h10 (READ_FROM_MEM_TO_A), got %h", uut.CurrState);
        end else begin
            $display("Test 6 Passed: Processor handled READ_FROM_MEM_TO_A correctly");
        end

        // Test 7: Test ALU operations
        ROM_DATA = 8'h04;  // Simulate instruction 0x04 (DO_MATHS_OPP_SAVE_IN_A)
        #10;
        if (uut.CurrState != 8'h30) begin
            $display("Test 7 Failed: Expected state 8'h30 (DO_MATHS_OPP_SAVE_IN_A), got %h", uut.CurrState);
        end else begin
            $display("Test 7 Passed: Processor handled DO_MATHS_OPP_SAVE_IN_A correctly");
        end

        // Test 8: Test branching operation
        ROM_DATA = 8'h60;  // Simulate instruction 0x60 (FUNCTION_START)
        #10;
        if (uut.CurrState != 8'h60) begin
            $display("Test 8 Failed: Expected state 8'h60 (FUNCTION_START), got %h", uut.CurrState);
        end else begin
            $display("Test 8 Passed: Processor handled FUNCTION_START correctly");
        end

        // End of Testbench
        $finish;
    end

endmodule
