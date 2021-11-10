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
`define inst_mem_size 16
`define inst_mem_size_two_power 20

module inst_rom(
    input clk,
    input write_enable,
    input read_enable_cpu,
    input [31:0] tb_inst,
    input [31:0] tb_addr, // Essentially PC
    input [31:0] cpu_addr,
    output reg [31:0] cpu_inst 
    );

    reg [31:0] instruction_memory [0:`inst_mem_size-1];

    // Initial Write all data from Binary File
    // STRICTLY FOR TEST-BENCH
    always @(posedge clk ) begin
        if (write_enable == 1) begin
            instruction_memory[tb_addr>>2] <= tb_inst; 
        end            
    end

    // Read For CPU
    always @(*) begin
        if (cpu_addr > `inst_mem_size) begin
            cpu_inst = 32'b00000000000000000000000000010011;
        end
        if (read_enable_cpu == 1) begin
            cpu_inst = instruction_memory[cpu_addr>>2]; // PC/4, as PC=PC+4
        end
    end
    
endmodule
