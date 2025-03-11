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