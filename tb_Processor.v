// `timescale 1ns / 1ps


// module tb_Processor;
//     reg CLK;
//     reg RESET;
//     wire [7:0] BUS_DATA;
//     wire [7:0] BUS_ADDR;
//     wire BUS_WE;
//     wire [7:0] ROM_ADDRESS;
//     reg [7:0] ROM_DATA;
//     reg [1:0] BUS_INTERRUPTS_RAISE;
//     wire [1:0] BUS_INTERRUPTS_ACK;


//     reg [7:0] registerA;
//     reg [7:0] registerB;
//     Processor uut (
//         .RESET(RESET),
//         .CLK(CLK),
//         .BUS_DATA(BUS_DATA);
//         .BUS_ADDR(BUS_ADDR);
//         .BUS_WE(BUS_WE);
//         .ROM_ADDRESS(ROM_ADDRESS);
//         .ROM_DATA(ROM_DATA);
//         .BUS_INTERRUPTS_RAISE(BUS_INTERRUPTS_RAISE);
//         .BUS_INTERRUPTS_ACK(BUS_INTERRUPTS_ACK);
//     );
    

//     //20ns for each clock cycle

//     //this can be a task that can be used for maybe a load and store function
//     //LOAD instruction
//     task readFromMemory();
//     begin
//         BUS_WE = 0;
//         if (!BUS_WE) begin
//             #40 BUS_DATA = 8'hC0;
//             registerA = BUS_DATA;
//             $display("Read Value from Memory and sent to registerA: 0xC0"); 
//         end else 
//             $display("BUS WRITE not Enabled!")
        


//         #40 BUS_DATA = 8'hC1;
//         registerB = BUS_DATA;
//         $display("Read Value from Memory and sent to registerB: 0xC0");


//     end

//     //STORE instruction
//     task writeToMemory();
//     begin

//         #40 registerA
        
//     end

//     //Arithmetic instruction
//     task mathOP(int A. int B, int opCode);
//     begin
        
//     end

//     //Jump Instruction
//     task jumpInstruction(int Addr, int returnContext);
//     begin
        
//     end

//     //Branch Instruction
//     task branchInstr(int Addr, int Context);
//     begin
        
//     end

//     //Dereference
//     task Dereference(int A, int B);
//     begin
        
//     end

    
//     always #10 CLK = ~CLK;
    
//     initial begin
        
//         CLK = 0;
//         RESET = 1;
    
//         #50 RESET = 0;
//         $display("RESET seems to work");
    
    
//         //Reading ROM ADDR and DATA
//         #20
//         force uut.ROM_DATA = 8'hE5;
//         force uut.ROM_ADDRESS = 8'h0F;
//         $display("At time %0t, ROM Data read = %b, ROM Address fetched = %b" , $time, ROM_DATA, ROM_ADDRESS);
    
//         //Edge cases for the ROM address space
//         #20 
//         force uut.ROM_ADDRESS = 8'FF;
//         $display("At time %0t, highest ROM address space read = %b", $time, ROM_DATA);
//         #20
//         force uut.ROM_ADDRESS = 8'00;
//         $display("At time %0t, lowest ROM address space read = %b", $time, ROM_DATA);
        
      
//         #20
//         //Instruction READ
//         readFromMemory();

//         #20
//         //Instruction WRITE
//         writeToMemory();

//         #20 
//         //Instruction MATH
//     end

// endmodule




`timescale 1ns / 1ps

module Processor_tb;

    // Inputs
    reg CLK;
    reg RESET;
    reg [1:0] BUS_INTERRUPTS_RAISE;

    // Outputs
    wire [7:0] BUS_ADDR;
    wire BUS_WE;
    wire [7:0] ROM_ADDRESS;
    wire [7:0] BUS_DATA; // Tristate output
    wire [1:0] BUS_INTERRUPTS_ACK;

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
        .BUS_INTERRUPTS_RAISE(BUS_INTERRUPTS_RAISE),
        .BUS_INTERRUPTS_ACK(BUS_INTERRUPTS_ACK)
    );

    // Clock generation
    always begin
        #5 CLK = ~CLK;  // Clock period is 10ns (100MHz)
    end

    // Initial block for stimulus
    initial begin
        // Initialize inputs
        CLK = 0;
        RESET = 0;
        BUS_INTERRUPTS_RAISE = 2'b00;
        ROM_DATA = 8'hFF;  // Placeholder value for ROM data
        //It is also the init state of the processor SM after a reset.

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
        BUS_INTERRUPTS_RAISE = 2'b01;  // Raise interrupt A
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
        BUS_INTERRUPTS_RAISE = 2'b10;  // Raise interrupt B
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
