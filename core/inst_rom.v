`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.11.2021 22:14:06
// Design Name: 
// Module Name: inst_rom
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
`define inst_mem_size 256
`define inst_mem_size_two_power 20
`define TEST_FILE "sss.txt"
// Change the name of the Test File

module inst_rom(
    input clk,
    input read_enable_cpu,
    input [31:0] cpu_addr,
    output reg [31:0] cpu_inst 
    );

    reg [31:0] instruction_memory [0:`inst_mem_size-1];
    
    // Read For CPU
    always @(*) begin
        if ((cpu_addr>>2) > 256) begin
            cpu_inst = 32'b00000000000000000000000000010011;
        end
        else if (read_enable_cpu == 1) begin
            cpu_inst = instruction_memory[cpu_addr>>2]; // PC/4, as PC=PC+4
        end
    end
    
    initial begin   
        $readmemb(`TEST_FILE, instruction_memory);
    end

endmodule
