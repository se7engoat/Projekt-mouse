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
        #100;
        $display("Test Case 1: Initialization and Basic Functionality");
        assert(MOUSE_DX === 8'b0);
        assert(MOUSE_DY === 8'b0);
        assert(MOUSE_DZ === 8'b0);
        assert(MOUSE_STATUS === 1'b0);
        assert(SEND_BYTE === 1'b0);
        assert(BYTE_TO_SEND === 8'b0);
        assert(BYTE_SENT === 1'b0);
        assert(READ_ENABLE === 1'b0);
        assert(BYTE_READ === 8'b0);
        assert(BYTE_ERROR_CODE === 2'b00);
        assert(BYTE_READY === 1'b0);
        assert(SEND_INTERRUPT === 1'b0);

        // Case 2 - Test state transitions and edge cases
        // Reset state
        RESET = 1;
        // Wait for reset to stabilize
        #100 RESET = 0;

        // Edge Case: Test BYTE_READY handling
        #100;
        $display("Test Case 2: BYTE_READY Edge Case");
        READ_ENABLE = 1; // Enable reading
        BYTE_READY = 0; // Byte not ready
        // Wait for some cycles
        #100;
        assert(READ_ENABLE === 1'b1);
        assert(BYTE_READY === 1'b0);
        // Simulate byte becoming ready
        BYTE_READY = 1;
        // Wait for some cycles
        #100;
        assert(BYTE_READ === 8'b0); // Ensure no byte read until BYTE_READY is high
        assert(READ_ENABLE === 1'b1);
        assert(BYTE_READY === 1'b1);
        // Simulate byte read
        BYTE_READ = 8'hFF;
        // Wait for some cycles
        #100;
        assert(BYTE_READ === 8'hFF); // Ensure byte read correctly
        assert(BYTE_READY === 1'b1);
        assert(SEND_INTERRUPT === 1'b0);

        // Case 3 - Test error handling (BYTE_ERROR_CODE)
        #100;
        $display("Test Case 3: Error Handling (BYTE_ERROR_CODE)");
        BYTE_ERROR_CODE = 2'b01; // Set error code to '01'
        // Wait for some cycles
        #100;
        assert(BYTE_ERROR_CODE === 2'b01); // Ensure error code set correctly
        assert(SEND_INTERRUPT === 1'b1); // Interrupt triggered on error

        // Case 4 - Test multiple state transitions
        #100;
        $display("Test Case 4: Multiple State Transitions");
        nextState = 4'b0001;
        // Wait for a few clock cycles to observe state transition
        #100;
        assert(currentState === 4'b0000); // Check if state transition occurred correctly
        assert(nextState === 4'b0001); // Check if next state is correctly updated


        // Case 5 - Test state transition on BYTE_SENT signal
        #100;
        $display("Test Case 5: State Transition on BYTE_SENT Signal");
        // Simulate BYTE_SENT signal high
        BYTE_SENT = 1'b1;
        // Wait for some cycles
        #100;
        assert(BYTE_SENT === 1'b1); // Ensure BYTE_SENT signal is high
        assert(currentState === nextState); // Ensure no state change until next clock cycle
        // Wait for another clock cycle to observe state change
        #10;
        assert(currentState !== nextState); // Ensure state transition occurred on next clock cycle

        // Case 6 - Test state transition on RESET signal
        #100;
        $display("Test Case 6: State Transition on RESET Signal");
        RESET = 1; // Activate RESET
        // Wait for some cycles
        #100;
        assert(RESET === 1); // Ensure RESET is active
        assert(currentState === 4'b0000); // Ensure FSM is reset to initial state
        RESET = 0; // Deactivate RESET
        // Wait for another clock cycle to observe state transition after RESET
        #10;
        assert(currentState !== 4'b0000); // Ensure state transition occurred after RESET

        // End simulation
        #100 $finish;
    end

    // Monitor outputs
    always @(posedge CLK) begin
        $monitor("Time=%0t | MOUSE_DX=%h, MOUSE_DY=%h, MOUSE_DZ=%h, MOUSE_STATUS=%b, BYTE_READ=%h, BYTE_ERROR_CODE=%b, BYTE_READY=%b",
                 $time, MOUSE_DX, MOUSE_DY, MOUSE_DZ, MOUSE_STATUS, BYTE_READ, BYTE_ERROR_CODE, BYTE_READY);
    end

endmodule
