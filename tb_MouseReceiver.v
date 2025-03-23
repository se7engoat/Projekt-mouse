`timescale 1ns/1ps

module tb_MouseReceiver;

    // Testbench signals
    reg RESET;
    reg CLK;
    reg CLK_MOUSE_IN;
    reg DATA_MOUSE_IN;
    reg READ_ENABLE;
    wire [7:0] BYTE_READ;
    wire [1:0] BYTE_ERROR_CODE;
    wire BYTE_READY;

    // Instantiate the MouseReciever Module
    MouseReceiver uut (
        .RESET(RESET),
        .CLK(CLK),
        .CLK_MOUSE_IN(CLK_MOUSE_IN),
        .DATA_MOUSE_IN(DATA_MOUSE_IN),
        .READ_ENABLE(READ_ENABLE),
        .BYTE_READ(BYTE_READ),
        .BYTE_ERROR_CODE(BYTE_ERROR_CODE),
        .BYTE_READY(BYTE_READY)
    );

    // Clock generation (50MHz - tp 20ns)
    always #10 CLK = ~CLK;

    // Task for sending a single PS2 bit
    task sendPS2Bit(input data);
        begin
            #40 CLK_MOUSE_IN = 0; // Falling edge
            DATA_MOUSE_IN = data;
            #40 CLK_MOUSE_IN = 1; // Rising edge
        end
    endtask

    // Task for sending a full PS2 byte (includes start, parity and stop bits)
    task sendPS2Byte(input [7:0] dataByte, input forcedParityError, input forcedStopError);
        integer i;
        reg parityBit;
        begin
            // Parity logic - compute odd parity
            parityBit = ~^dataByte;
            if (forcedParityError) begin
                parityBit = ~parityBit; // introducing error in parity
            end

            // send start bit
            sendPS2Bit(0); // always 0

            // send Data Byte (LSB first in)
            for (i = 0; i < 8; i = i + 1 ) begin
                sendPS2Bit(dataByte[i]);
            end

            // Parity bit
            sendPS2Bit(parityBit);

            // send stop bit (always 1, unless forced error)
            if (forcedStopError)
                sendPS2Bit(0); // Force incorrect stop bit
            else
                sendPS2Bit(1);
        end 
    endtask

    // Test sequence 
    initial begin
        // Signals init
        CLK = 0;
        RESET = 1;
        CLK_MOUSE_IN = 1;
        DATA_MOUSE_IN = 1;
        READ_ENABLE = 0;

        // Apply RESET
        #100 RESET = 0;
        $display("Reset Deasserted");

        // Enable reading
        #50 READ_ENABLE = 1;
        $display("Read Enable set");

        // Byte Sending - Case 1 - Valid input
        #100;
        $display("Sending Valid PS/2 Byte: 0xAA");
        sendPS2Byte(8'b10101010, 0, 0);

        // Wait for byte reception
        #200;
        if (BYTE_READY) 
            $display("BYTE_READY is HIGH, Receieved: 0x%h", BYTE_READ);
        else
            $display("ERROR: BYTE_READY is not set");

        //  Case 2 - Parity Error
        #200;
        $display("Sending PS/2 Byte with Parity Error: 0x55");
        sendPS2Byte(8'b01010101, 1, 0);

        // Waiting for byte reception
        #200;
        if (BYTE_ERROR_CODE[0]) 
            $display("Parity Error Detected");
        else
            $display("ERROR: Parity bit error is not detected");
        
        // Case 3 - Stop Bit Error 
        #200;
        $display("Sending PS/2 Byte with Stop Bit Error: 0x33");
        sendPS2Byte(8'b00110011, 0, 1);

        // Waiting for byte reception
        #200;
        if (BYTE_ERROR_CODE[1])
            $display("Stop Bit Error detected");
        else
            $display("ERROR: Stop bit error is not detected");

        // Case 4 - Missing Bits (Underflow)
        #200;
        $display("Sending Incomplete PS/2 Byte (Underflow)");
        sendPS2Bit(0); // Start bit
        sendPS2Bit(0); // Only one data bit, then stop
        sendPS2Bit(1); // Stop bit sent too early

        #200;
        if (!BYTE_READY)
            $display("Underflow Detected: BYTE_READY not set.");
        else
            $display("Error: Underflow condition not handled correctly");

        // Case 5 - Extra Bits (Overflow)
        #200;
        $display("Sending Extra Bits (Overflow)");
        sendPS2Byte(8'b11001100, 0, 0);
        sendPS2Bit(1); // Sending an extra stop bit

        #200;
        if (!BYTE_READY)
            $display("Overflow Detected: Extra bit ignored.");
        else
            $display("Error: Overflow condition not handled correctly");

        // Case 6 - Rapid Byte Reception
        #200;
        $display("Sending Rapid Consecutive Bytes: 0xA5, 0x5A");
        sendPS2Byte(8'b10100101, 0, 0);
        sendPS2Byte(8'b01011010, 0, 0);

        #200;
        if (BYTE_READY)
            $display("Rapid Byte Reception Successful: Last Received Byte = 0x%h", BYTE_READ);
        else
            $display("Error: Missed rapid bytes");

        // Case 7: Maximum and Minimum Values
        #200;
        $display("Sending Maximum Value (0xFF)");
        sendPS2Byte(8'b11111111, 0, 0);

        #200;
        $display("Sending Minimum Value (0x00)");
        sendPS2Byte(8'b00000000, 0, 0);

        // End of Simulation
        #500;
        $display("Testbench for MouseReceiver Complete.");
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0t | BYTE_READY=%b | BYTE_READ=0x%h | BYTE_ERROR_CODE=%b", 
                 $time, BYTE_READY, BYTE_READ, BYTE_ERROR_CODE);
    end

endmodule    