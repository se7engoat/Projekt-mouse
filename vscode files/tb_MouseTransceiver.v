`timescale 1ns/1ps  

module tb_MouseTransceiver;
    // Testbench signals
    reg RESET;
    reg CLK;
    wire CLK_MOUSE;
    wire DATA_MOUSE;
    wire [3:0] MouseStatus;
    wire [7:0] MouseX;
    wire [7:0] MouseY;
    wire [7:0] MouseZ;
    wire [3:0] SEG_SELECT;
    wire [7:0] HEX_OUT;

    // Module instantiation for MouseTransceiver
    MouseTransceiver uut (
        .RESET(RESET),
        .CLK(CLK),
        .CLK_MOUSE(CLK_MOUSE),
        .DATA_MOUSE(DATA_MOUSE),
        .MouseStatus(MouseStatus),
        .MouseX(MouseX),
        .MouseY(MouseY),
        .MouseZ(MouseZ)
    );

    // Clock generation (50MHz - tp 20ns)
    always #10 CLK = ~CLK;

    // Test sequence
    initial begin
        // init signals
        CLK = 0;
        RESET = 1;

        #50 RESET = 0;
        $display("RESET Deasserted");

        // Simulate mouse movement
        #20;
        force uut.tempMouseX = 8'd30;
        force uut.tempMouseY = 8'd45;
        force uut.tempMouseZ = 8'd7;
        $display("Simulating Mouse Movement: MouseX = 30, MouseY = 45, MouseZ = 7");

        //edge case tests for MouseX and MouseY
        #20;
        force uut.tempMouseX = 8'd159;
        force uut.tempMouseY = 8'd119;
        $display("Simulating Mouse Movement: MouseX = 160, MouseY = 120");

        #20 
        force uut.tempMouseX = 8'd170;
        force uut.tempMouseY = 8'd140;
        $display("Simulating Mouse Movement: MouseX and MouseY exceed VGA dimensions, overflow detected");
        
        // Simulating Mouse Scroll movement;
        #20;
        force uut.MouseZ = 8'd50;
        $display("Scrolling Mouse Wheel: MouseZ = 50 (Expect DOT_IN Toggle)");

        #20;
        force uut.tempMouseZ = 8'd254;
        $display("Scrolling Mouse Wheel: MouseZ = 254 (Expect DOT_IN Toggle)");

        #20;
        force uut.tempMouseZ = 8'd255;
        $display("Scrolling Mouse Wheel: MouseZ = 255, overflow detected (DOT_IN does not Toggle)");

        #20;
        force uut.tempMouseZ = 8'sd-1;
        $display("Scrolling Mouse Wheel: MouseZ = 255, overflow detected (DOT_IN does not Toggle)");
        
        // Test different MouseStatus states (Simulate button press)
        #20;
        force uut.tempMouseStatus = 4'b0001;  // Simulating left click
        $display("Testing Mouse Button Press: MouseStatus = 0001 (Left Click)");

        #20;
        force uut.tempMouseStatus = 4'b0010;  // Simulating right click
        $display("Testing Mouse Button Press: MouseStatus = 0010 (Right Click)");

        // End Simulation
        #100;
        $display("Testbench complete.");
        $finish;
    // Monitor outputs
    initial begin
        $monitor("Time=%0t | MouseStatus=%b | MouseX=%d | MouseY=%d | MouseZ=%d | SEG_SELECT=%b | HEX_OUT=%b", 
                 $time, MouseStatus, MouseX, MouseY, MouseZ, SEG_SELECT, HEX_OUT);
    end
endmodule