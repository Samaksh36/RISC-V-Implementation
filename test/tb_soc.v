`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.11.2021 11:04:11
// Design Name: 
// Module Name: tb_soc
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

module tb_soc();
    reg clk;
    reg go;
    reg reset;
        
    wire [31:0] IF_inst;
    wire [31:0] ID_inst;
    wire [31:0] EX_inst;
    wire [31:0] MEM_inst;
    wire [31:0] WB_inst;
    
    riscv_cpu cpu(
        .clk(clk),
        .reset(reset),
        .go(go),
        
        .IF_inst(IF_inst),
        .ID_inst(ID_inst),
        .EX_inst_tb(EX_inst),
        .MEM_inst_tb(MEM_inst),
        .wb_inst(WB_inst)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        go = 0;
        reset = 1;
    end
    
    initial begin 
        #100
        go = 1;
        #5 reset = 0;
    end    
    
endmodule
