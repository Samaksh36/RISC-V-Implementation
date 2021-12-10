`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.11.2021 21:51:05
// Design Name: 
// Module Name: opcode
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
`define opcode_and          7'b0110011
`define opcode_or           7'b0110011
`define opcode_add          7'b0110011
`define opcode_sub          7'b0110011
`define opcode_sll          7'b0110011
`define opcode_sra          7'b0110011

`define opcode_rtype        7'b0110011


`define opcode_addi         7'b0010011

`define opcode_sw           7'b0100011

`define opcode_beq          7'b1100011

`define opcode_lw           7'b0000011

`define opcode_mac          7'b1111111