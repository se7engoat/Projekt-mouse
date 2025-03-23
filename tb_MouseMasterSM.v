`timescale 1ns / 1ps

module tb_MouseMasterSM;

    // Testbench signals
    reg CLK;
    reg RESET;
    
    // Transmitter Control
    wire SEND_BYTE;
    wire [7:0] BYTE_TO_SEND;
    reg BYTE_SENT;
    
    // Receiver Control
    reg READ_ENABLE;
    wire [7:0] BYTE_READ;
    wire [1:0] BYTE_ERROR_CODE;
    wire BYTE_READY;
    
    // Data Registers
    wire [7:0] MOUSE_DX;
    wire [7:0] MOUSE_DY;
    wire [7:0] MOUSE_DZ;
    wire [7:0] MOUSE_STATUS;
    wire SEND_INTERRUPT;

    // Instantiate the module
    MouseMasterSM uut (
        .CLK(CLK),
        .RESET(RESET),
        .SEND_BYTE(SEND_BYTE),
        .BYTE_TO_SEND(BYTE_TO_SEND),
        .BYTE_SENT(BYTE_SENT),
        .READ_ENABLE(READ_ENABLE),
        .BYTE_READ(BYTE_READ),
        .BYTE_ERROR_CODE(BYTE_ERROR_CODE),
        .BYTE_READY(BYTE_READY),
        .MOUSE_DX(MOUSE_DX),
        .MOUSE_DY(MOUSE_DY),
        .MOUSE_DZ(MOUSE_DZ),
        .MOUSE_STATUS(MOUSE_STATUS),
        .SEND_INTERRUPT(SEND_INTERRUPT)
    );

    // Clock generation (50 MHz - tp 20ns)
    always #10 CLK = ~CLK;

    // Initial values
    initial begin
        CLK = 0;
        RESET = 1;
        #100 RESET = 0;
    end

    // Test sequence
    initial begin
        // Case 1 - Test initialization and basic functionality
        initial begin
        #100;  // Wait for initialization
        $display("Test Case 1: Initialization and Basic Functionality");
        // Check all signals
        if (MOUSE_DX !== 8'b0) 
            $display("Error: MOUSE_DX should be 0, got %b", MOUSE_DX);
        if (MOUSE_DY !== 8'b0) 
            $display("Error: MOUSE_DY should be 0, got %b", MOUSE_DY);
        if (MOUSE_DZ !== 8'b0) 
            $display("Error: MOUSE_DZ should be 0, got %b", MOUSE_DZ);
        if (MOUSE_STATUS !== 1'b0) 
            $display("Error: MOUSE_STATUS should be 0, got %b", MOUSE_STATUS);
        if (SEND_BYTE !== 1'b0) 
            $display("Error: SEND_BYTE should be 0, got %b", SEND_BYTE);
        if (BYTE_TO_SEND !== 8'b0) 
            $display("Error: BYTE_TO_SEND should be 0, got %b", BYTE_TO_SEND);
        if (BYTE_SENT !== 1'b0) 
            $display("Error: BYTE_SENT should be 0, got %b", BYTE_SENT);
        if (READ_ENABLE !== 1'b0) 
            $display("Error: READ_ENABLE should be 0, got %b", READ_ENABLE);
        if (BYTE_READ !== 8'b0) 
            $display("Error: BYTE_READ should be 0, got %b", BYTE_READ);
        if (BYTE_ERROR_CODE !== 2'b00) 
            $display("Error: BYTE_ERROR_CODE should be 00, got %b", BYTE_ERROR_CODE);
        if (BYTE_READY !== 1'b0) 
            $display("Error: BYTE_READY should be 0, got %b", BYTE_READY);
        if (SEND_INTERRUPT !== 1'b0) 
            $display("Error: SEND_INTERRUPT should be 0, got %b", SEND_INTERRUPT);

        // Adding $finish to stop simulation on failure
        if ((MOUSE_DX !== 8'b0) || (MOUSE_DY !== 8'b0) || (MOUSE_DZ !== 8'b0) ||
            (MOUSE_STATUS !== 1'b0) || (SEND_BYTE !== 1'b0) || (BYTE_TO_SEND !== 8'b0) ||
            (BYTE_SENT !== 1'b0) || (READ_ENABLE !== 1'b0) || (BYTE_READ !== 8'b0) ||
            (BYTE_ERROR_CODE !== 2'b00) || (BYTE_READY !== 1'b0) || (SEND_INTERRUPT !== 1'b0)) 
        begin
            $display("Test Case 1 Failed");
            $finish;
        end
        else begin
            $display("Test Case 1 Passed");
        end
    end
    // Case 2 - Test state transitions and edge cases
    initial begin
        // Reset sequence
        RESET = 1;
        #100 RESET = 0;

        // Edge Case: Test BYTE_READY handling
        #100;
        $display("Test Case 2: BYTE_READY Edge Case");
        READ_ENABLE = 1;
        BYTE_READY = 0;
        #100;
        
        // Check initial conditions
        if (READ_ENABLE !== 1'b1)
            $display("Error: READ_ENABLE should be 1, got %b", READ_ENABLE);
        if (BYTE_READY !== 1'b0)
            $display("Error: BYTE_READY should be 0, got %b", BYTE_READY);

        // Simulate byte becoming ready
        BYTE_READY = 1;
        #100;
        if (BYTE_READ !== 8'b0)
            $display("Error: BYTE_READ should be 0, got %b", BYTE_READ);
        if (READ_ENABLE !== 1'b1)
            $display("Error: READ_ENABLE should remain 1, got %b", READ_ENABLE);
        if (BYTE_READY !== 1'b1)
            $display("Error: BYTE_READY should be 1, got %b", BYTE_READY);

        // Simulate byte read
        BYTE_READ = 8'hFF;
        #100;
        if (BYTE_READ !== 8'hFF)
            $display("Error: BYTE_READ should be FF, got %b", BYTE_READ);
        if (BYTE_READY !== 1'b1)
            $display("Error: BYTE_READY should stay 1, got %b", BYTE_READY);
        if (SEND_INTERRUPT !== 1'b0)
            $display("Error: SEND_INTERRUPT should be 0, got %b", SEND_INTERRUPT);

        // Final check for Case 2
        if ((BYTE_READ !== 8'hFF) || (SEND_INTERRUPT !== 1'b0)) begin
            $display("Test Case 2 Failed");
            $finish;
        end
        else begin
            $display("Test Case 2 Passed");
        end
    end

    // Case 3 - Test error handling (BYTE_ERROR_CODE)
    initial begin
        #100;
        $display("Test Case 3: Error Handling (BYTE_ERROR_CODE)");
        BYTE_ERROR_CODE = 2'b01;
        #100;
        
        if (BYTE_ERROR_CODE !== 2'b01)
            $display("Error: BYTE_ERROR_CODE should be 01, got %b", BYTE_ERROR_CODE);
        if (SEND_INTERRUPT !== 1'b1)
            $display("Error: SEND_INTERRUPT should be 1, got %b", SEND_INTERRUPT);

        if ((BYTE_ERROR_CODE !== 2'b01) || (SEND_INTERRUPT !== 1'b1)) begin
            $display("Test Case 3 Failed");
            $finish;
        end
        else begin
            $display("Test Case 3 Passed");
        end
    end

    // Case 4 - Test multiple state transitions
    initial begin
        #100;
        $display("Test Case 4: Multiple State Transitions");
        uut.nextState = 4'b0001;
        #100;
        
        if (uut.currentState !== 4'b0000)
            $display("Error: currentState should be 0000, got %b", uut.currentState);
        if (uut.nextState !== 4'b0001)
            $display("Error: nextState should be 0001, got %b", uut.nextState);

        // Wait for clock edge
        #10;
        if (uut.currentState !== 4'b0001)
            $display("Error: State didn't transition to 0001, current: %b", uut.currentState);

        if ((uut.currentState !== 4'b0001) || (uut.nextState !== 4'b0001)) begin
            $display("Test Case 4 Failed");
            $finish;
        end
        else begin
            $display("Test Case 4 Passed");
        end
    end
        

       // Case 5 - Test state transition on BYTE_SENT signal
    initial begin
        #100;
        $display("Test Case 5: State Transition on BYTE_SENT Signal");
        
        // Simulate BYTE_SENT signal high
        BYTE_SENT = 1'b1;
        
        // Wait for some cycles
        #100;
        
        // Check BYTE_SENT signal is high
        if (BYTE_SENT !== 1'b1) 
            $display("Error: BYTE_SENT should be 1, got %b", BYTE_SENT);
        
        // Check no state change before clock edge
        if (uut.currentState !== uut.nextState)
            $display("Error: State changed before clock cycle. Current: %h, Next: %h", 
            uut.currentState, uut.nextState);
        
        // Wait for clock cycle
        #10;
        
        // Check state transition after clock edge
        if (uut.currentState === uut.nextState)
            $display("Error: No state transition after clock cycle. Current: %h", 
            uut.currentState);
        
        // Final test result
        if ((BYTE_SENT !== 1'b1) || 
            (uut.currentState === uut.nextState)) begin
            $display("Test Case 5 Failed");
            $finish;
        end
        else begin
            $display("Test Case 5 Passed");
        end
    end
        
    
    // Case 6 - Test state transition on RESET signal
    initial begin
        #100;
        $display("Test Case 6: State Transition on RESET Signal");
        
        // Activate RESET
        RESET = 1'b1;
        #100;
        
        // Check RESET status and FSM state
        if (RESET !== 1'b1)
            $display("Error: RESET should be 1, got %b", RESET);
        if (uut.currentState !== 4'b0000)
            $display("Error: FSM should be in state 0000 during reset, got %b", uut.currentState);

        // Deactivate RESET
        RESET = 1'b0;
        #10;  // Wait for one clock cycle
        
        // Check post-RESET behavior
        if (uut.currentState === 4'b0000)
            $display("Error: FSM didn't transition from reset state, still in 0000");

        // Final verification
        if ((RESET !== 1'b0) || 
            (uut.currentState === 4'b0000)) begin
            $display("Test Case 6 Failed");
            $finish;
        end
        else begin
            $display("Test Case 6 Passed");
        end

        // End simulation
        #100 $display("All tests completed successfully");
        $finish;
    end
    
    // Monitor outputs
    always @(posedge CLK) begin
        $monitor("Time=%0t | MOUSE_DX=%h, MOUSE_DY=%h, MOUSE_DZ=%h, MOUSE_STATUS=%b, BYTE_READ=%h, BYTE_ERROR_CODE=%b, BYTE_READY=%b",
                 $time, MOUSE_DX, MOUSE_DY, MOUSE_DZ, MOUSE_STATUS, BYTE_READ, BYTE_ERROR_CODE, BYTE_READY);
    end

endmodule
