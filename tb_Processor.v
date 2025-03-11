`timescale 1ns / 1ps


module tb_Processor;
    reg CLK;
    reg RESET;
    wire [7:0] BUS_DATA;
    wire [7:0] BUS_ADDR;
    wire BUS_WE;
    wire [7:0] ROM_ADDRESS;
    reg [7:0] ROM_DATA;
    reg [1:0] BUS_INTERRUPTS_RAISE;
    wire [1:0] BUS_INTERRUPTS_ACK;


    ALU uut (
        .RESET(RESET),
        .CLK(CLK),
        .BUS_DATA(BUS_DATA),
        .BUS_ADDR(BUS_ADDR),
        .BUS_WE(BUS_WE),
        .ROM_ADDRESS(ROM_ADDRESS),
        .ROM_DATA(ROM_DATA),
        .BUS_INTERRUPTS_RAISE(BUS_INTERRUPTS_RAISE),
        .BUS_INTERRUPTS_ACK(BUS_INTERRUPTS_ACK)
    );
    
    
    always #10 CLK = ~CLK;
    
    initial begin
        
        CLK = 0;
        RESET = 1;
    
        #50 RESET = 0;
        $display("RESET seems to work");
    
    
        //Reading ROM ADDR and DATA
        #20
        force uut.ROM_DATA = 8'hE5;
        force uut.ROM_ADDRESS = 8'h0F;
        $display("At time %0t, ROM Data read = %b, ROM Address fetched = %b" , $time, ROM_DATA, ROM_ADDRESS);
    
        //Edge cases for the ROM address space
        #20 
        force uut.ROM_ADDRESS = 8'FF;
        $display("At time %0t, highest ROM address space read = %b", $time, ROM_DATA);
        #20
        force uut.ROM_ADDRESS = 8'00;
        $display("At time %0t, lowest ROM address space read = %b", $time, ROM_DATA);
        
      
    end

endmodule