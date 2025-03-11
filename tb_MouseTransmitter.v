`timescale 1ns/1ps

module tb_MouseTransmitter;

    // Testbench signals;
    reg RESET;
    reg CLK;
    reg CLK_MOUSE_IN;
    wire CLK_MOUSE_OUT_EN;
    reg DATA_MOUSE_IN;
    wire DATA_MOUSE_OUT;
    wire DATA_MOUSE_OUT_EN;
    reg SEND_BYTE;
    reg [7:0] BYTE_TO_SEND;
    wire BYTE_SENT;

    // Instantiate the MouseTransmitter Module under test
    MouseTransmitter uut (
        .RESET(RESET),
        .CLK(CLK),
        .CLK_MOUSE_IN(CLK_MOUSE_IN),
        .CLK_MOUSE_OUT_EN(CLK_MOUSE_OUT_EN),
        .DATA_MOUSE_IN(DATA_MOUSE_IN),
        .DATA_MOUSE_OUT(DATA_MOUSE_OUT),
        .DATA_MOUSE_OUT_EN(DATA_MOUSE_OUT_EN),
        .SEND_BYTE(SEND_BYTE),
        .BYTE_TO_SEND(BYTE_TO_SEND),
        .BYTE_SENT(BYTE_SENT)
    );

    // Clock Generation (50MHz - tp 20ns)
    always #10 CLK = ~CLK;

    // Task to simulate the falling edge of CLK_MOUSE_IN (PS2 Clock attribute)
    task sendMouseClockPulse;
        begin
            #40 CLK_MOUSE_IN = 0; // falling edge
            #40 CLK_MOUSE_IN = 1; // rising edge
        end
    endtask

    // Task to simulate mouse ACK data transmission
    task mouseACK;
        begin
            // Mouse pulls data low, then releases clock and data - ACK sequence
            #50 DATA_MOUSE_IN = 0; 
            #50 CLK_MOUSE_IN = 0;
            #50 CLK_MOUSE_IN = 1;
            #50 DATA_MOUSE_IN = 1; 
        end
    endtask

    // Initiate Test sequence
    initial begin
        // init signals
        CLK = 0;
        RESET = 1;
        CLK_MOUSE_IN = 1;
        DATA_MOUSE_IN = 1;
        SEND_BYTE = 0;
        BYTE_TO_SEND = 8'b00000000;

        // Apply RESET
        #100 RESET = 0;
        $display("Reset Deasserted");

        // Case 1 - Valid Byte Transmission
        #100;
        BYTE_TO_SEND = 8'b10101010;
        SEND_BYTE = 1;
        #20 SEND_BYTE = 0; // send signal stopped
        $display("Sending Valid byte: 0xAA");

        // Simulate clock pulses for transmission
        repeat (10) sendMouseClockPulse();

        // Simulate Mouse ACK
        mouseACK();

        #200;
        if (BYTE_SENT)
            $display("BYTE_SENT is HIGH, Transmission Successful.");
        else
            $display("ERROR: BYTE_SENT not set!");

        // Case 2 - Data line contention (Nouse holding Data Low)
        #200;
        DATA_MOUSE_IN = 0; // Simulate mouse not releasing data line
        BYTE_TO_SEND = 8'b11001100;
        SEND_BYTE = 1;
        #20 SEND_BYTE = 0;
        $display("Sending Byte with data line contention: 0xCC");

        repeat (10) sendMouseClockPulse();

        if (!BYTE_SENT)
            $display("Data contention detected: Transmission blocked");
        else 
            $display("ERROR: Data Contention not detected");

        // Release data line
        DATA_MOUSE_IN = 1;

        // Case 3 - Bit Underflow (Early Stop)
        #200;
        BYTE_TO_SEND = 8'b11110000;
        SEND_BYTE = 1;
        #20 SEND_BYTE = 0;
        $display("Sending Byte with Bit Underflow: 0xF0");

        repeat (5) send_mouse_clock_pulse(); // Send only 5 bits

        #200;
        if (!BYTE_SENT)
            $display("Bit Underflow Detected: Transmission Incomplete.");
        else
            $display("Error: Underflow Condition Not Detected!");

        // Case 4 - Bit Overflow (Extra Bits Sent)
        #200;
        BYTE_TO_SEND = 8'b01010101;
        SEND_BYTE = 1;
        #20 SEND_BYTE = 0;
        $display("Sending Byte with Bit Overflow: 0x55");

        repeat (12) send_mouse_clock_pulse(); // Send 12 bits instead of 10

        #200;
        if (!BYTE_SENT)
            $display("Bit Overflow Detected: Extra Bits Ignored.");
        else
            $display("Error: Overflow Condition Not Detected!");
        

        // Case 5 - Clock Synchronization Issue (Glitches in CLK_MOUSE_IN)
        #200;
        BYTE_TO_SEND = 8'b00110011;
        SEND_BYTE = 1;
        #20 SEND_BYTE = 0;
        $display("Sending Byte with Clock Glitches: 0x33");

        sendMouseClockPulse();
        #5 CLK_MOUSE_IN = ~CLK_MOUSE_IN; // Introduce an unexpected glitch
        sendMouseClockPulse();
        #5 CLK_MOUSE_IN = ~CLK_MOUSE_IN; // Another glitch

        repeat (8) sendMouseClockPulse();

        #200;
        if (!BYTE_SENT)
            $display("Clock Synchronization Issue Detected.");
        else
            $display("Error: Synchronization Issue Not Detected!");

        // Case 6 - Multiple rapid transmissions
        #200;
        $display("Sending Rapid Consecutive Bytes: 0xA5, 0x5A");

        BYTE_TO_SEND = 8'b10100101;
        SEND_BYTE = 1;
        #20 SEND_BYTE = 0;
        repeat (10) sendMouseClockPulse();
        mouseACK();

        BYTE_TO_SEND = 8'b01011010;
        SEND_BYTE = 1;
        #20 SEND_BYTE = 0;
        repeat (10) sendMouseClockPulse();
        mouseACK();

        #200;
        if (BYTE_SENT)
            $display("Rapid Byte Transmission Successful.");
        else
            $display("Error: Missed Rapid Bytes");

        // Case 7 - Minimum and Maximum Values
        #200;
        $display("Sending Minimum Value (0x00)");
        BYTE_TO_SEND = 8'b00000000;
        SEND_BYTE = 1;
        #20 SEND_BYTE = 0;
        repeat (10) sendMouseClockPulse();
        mouseACK();

        #200;
        $display("Sending Maximum Value (0xFF)");
        BYTE_TO_SEND = 8'b11111111;
        SEND_BYTE = 1;
        #20 SEND_BYTE = 0;
        repeat (10) sendMouseClockPulse();
        mouseACK();

        // End of Simulation
        #500;
        $display("Testbench Complete.");
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0t | BYTE_SENT=%b | BYTE_TO_SEND=0x%h | DATA_MOUSE_OUT=%b | DATA_MOUSE_OUT_EN=%b | CLK_MOUSE_OUT_EN=%b", 
                $time, BYTE_SENT, BYTE_TO_SEND, DATA_MOUSE_OUT, DATA_MOUSE_OUT_EN, CLK_MOUSE_OUT_EN);
    end

endmodule