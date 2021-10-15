`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.10.2021 17:31:08
// Design Name: 
// Module Name: alu
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


module alu(
    input [31:0]    rs1,
    input [31:0]    rs2,
    input [3:0]     opcode,
    output[31:0]    rd  
    );

//
`include "alu_def.v"
//

    reg [31:0] result_alu;
    reg [4:0] rs2_5b;
    
    always @(*)
    begin
        case(opcode)
            `ADD_ALU:
                begin
                    result_alu = rs1 + rs2;
                end
            `SUB_ALU:
                begin
                    result_alu = rs1 - rs2;
                end
            `AND_ALU:
                begin
                    result_alu = rs1 & rs2;
                end
            `OR_ALU:
                begin
                    result_alu = rs1 | rs2;
                end
            `SLL_ALU:
                begin
                    rs2_5b = rs2[4:0];
                    result_alu = rs1 << rs2_5b;
                end
           `SRA_ALU:
                begin
                    rs2_5b = rs2[4:0];
                    result_alu = rs1 >>> rs2_5b;
                end
            default:
                begin
                    result_alu = 32'bx;
                end
        endcase
    end
    
    assign rd = result_alu;
endmodule
