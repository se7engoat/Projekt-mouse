`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/14 12:50:32
// Design Name: 
// Module Name: ROM_tb
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


module ROM_tb;

  // Parameters
  parameter CLK_PERIOD = 10;
  parameter ADDR_WIDTH = 8;
  parameter MEM_DEPTH = 2 ** ADDR_WIDTH;

  // DUT Interface
  reg CLK;
  reg [7:0] ADDR;
  wire [7:0] DATA;

  // DUT Instantiation
  ROM uut (
    .CLK(CLK),
    .ADDR(ADDR),
    .DATA(DATA)
  );

  // Reference memory for checking
  reg [7:0] reference_mem [0:MEM_DEPTH-1];
  
  // Log file
  integer logfile;

  // Clock Generation
  initial CLK = 0;
  always #(CLK_PERIOD/2) CLK = ~CLK;

  // Load reference memory
  initial begin
    $readmemh("C:/Users/s2736992/Desktop/Projekt-mouse/Complete_Demo_ROM.txt", reference_mem);
  end

  // Stimulus and checker
  integer i;
  initial begin
    // Open log file
    logfile = $fopen("ROM_test_log.txt", "w");
    if (logfile == 0) begin
      $display("ERROR: Could not open log file.");
      $finish;
    end

    $display("==== ROM Test Start ====");
    $fwrite(logfile, "==== ROM Test Log ====\n");

    // Wait for ROM to initialize
    #20;

    // Test all possible addresses
    for (i = 0; i < MEM_DEPTH; i = i + 1) begin
      ADDR = i;
      @(posedge CLK); // wait one clock
      #1; // small delay to ensure DATA stable

      // Compare with reference
      if (DATA !== reference_mem[i]) begin
        $display("Mismatch at ADDR %0h: Expected %0h, Got %0h", i, reference_mem[i], DATA);
        $fwrite(logfile, "ERROR at ADDR %0h: Expected %0h, Got %0h\n", i, reference_mem[i], DATA);
      end else begin
        $fwrite(logfile, "ADDR %0h: PASS (DATA = %0h)\n", i, DATA);
      end
    end

    $display("==== ROM Test Finished ====");
    $fclose(logfile);
    $stop;
  end

endmodule
