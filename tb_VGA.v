`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/13 13:25:40
// Design Name: 
// Module Name: tb_VGA
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


module tb_VGA(

    );
       // ======================
       // Testbench Signals
       // ======================
       reg CLK;                    // Clock signal
       reg RESET;                  // Reset signal
       reg [7:0] BUS_ADDR;         // Address bus
       reg BUS_WE;                 // Write Enable
       reg [7:0] bus_data_out;     // Data to be written
       reg bus_data_enable;        // Control tri-state bus
       wire [7:0] BUS_DATA;        // Data bus (tri-state)
       wire [7:0] COLOUR_OUT;      // VGA Colour Output
       wire HS;                    // Horizontal Sync
       wire VS;                    // Vertical Sync
       
       // Tri-state bus handling
       assign BUS_DATA = bus_data_enable ? bus_data_out : 8'hZZ;
       
       // Instantiate the VGA Driver module
       VGA_Driver uut (
           .CLK(CLK),
           .RESET(RESET),
           .BUS_ADDR(BUS_ADDR),
           .BUS_DATA(BUS_DATA),
           .BUS_WE(BUS_WE),
           .COLOUR_OUT(COLOUR_OUT),
           .HS(HS),
           .VS(VS)
       );
       
       // ======================
       // Clock Generation (100MHz -> 10ns period, toggles every 5ns)
       // ======================
       always #5 CLK = ~CLK; 
       
       // ======================
       // Test Sequence
       // ======================
       initial begin
           // Initialize signals
           CLK = 0;
           RESET = 1;
           BUS_ADDR = 8'h00;
           BUS_WE = 0;
           bus_data_out = 8'h00;
           bus_data_enable = 0;
           
           // Hold reset for a few cycles
           #20 RESET = 0;
           
           // ======================
           // Write X Coordinate to VGA
           // ======================
           #10 BUS_ADDR = 8'hB0; // VGABaseAddress
           bus_data_out = 8'h50; // X Coordinate
           bus_data_enable = 1;
           BUS_WE = 1;
           #10 BUS_WE = 0;
           bus_data_enable = 0;
           
           // ======================
           // Write Y Coordinate to VGA
           // ======================
           #10 BUS_ADDR = 8'hB1; // VGABaseAddress + 1
           bus_data_out = 8'h40; // Y Coordinate
           bus_data_enable = 1;
           BUS_WE = 1;
           #10 BUS_WE = 0;
           bus_data_enable = 0;
           
           // ======================
           // Write Pixel Data to Frame Buffer
           // ======================
           #10 BUS_ADDR = 8'hB2; // VGABaseAddress + 2
           bus_data_out = 8'h01; // Pixel ON
           bus_data_enable = 1;
           BUS_WE = 1;
           #10 BUS_WE = 0;
           bus_data_enable = 0;
           
           // ======================
           // Check VGA Output Signals
           // ======================
           #50 $display("Time: %t | COLOUR_OUT: %h | HS: %b | VS: %b", $time, COLOUR_OUT, HS, VS);
           
           // ======================
           // Finish Simulation
           // ======================
           #100 $finish;
       end
   endmodule
