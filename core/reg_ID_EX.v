`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.11.2021 15:55:39
// Design Name: 
// Module Name: reg_ID_EX
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


module reg_ID_EX(
    input clk,
    input reset,
    
    input [31:0] inst_DE,
    
    input [4:0] stall,

    input [31:0] id_op_1, // output to ALU rs1
    input [31:0] id_op_2, // output to ALU rs2
    input [31:0] id_op_3, // output to ALU rs2
    input [3:0] id_alu_op,

    input [4:0] id_rd_addr, // Only passes through EX for WB stage
    input id_rd_we,
    input [31:0] id_mem_offset,


    output reg [31:0] ex_op_1, // output to ALU rs1
    output reg [31:0] ex_op_2, // output to ALU rs2
    output reg [31:0] ex_op_3, // output to ALU rs2
    output reg [3:0] ex_alu_op,

    output reg [4:0] ex_rd_addr, // Only passes through EX for WB stage
    output reg ex_rd_we,
    output reg [31:0] ex_mem_offset,
    
    output reg [31:0] inst_EX
    );

    always @(posedge clk) begin
        if(reset == 1)begin
            ex_alu_op <= 0;
            ex_op_1 <= 0;
            ex_op_2 <= 0;
            ex_op_3 <= 0;
            
            ex_rd_addr <= 0;
            ex_rd_we <= 0;
            ex_mem_offset <= 0;
        end
        else if(stall[2] == 1) begin
            ex_alu_op <= 0;
            ex_op_1 <= 0;
            ex_op_2 <= 0;
            ex_op_3 <= 0;
            
            ex_rd_addr <= 0;
            ex_rd_we <= 0;
            ex_mem_offset <= 0;
        end
        else begin // Introduce stalling 
            ex_op_1 <= id_op_1;
            ex_op_2 <= id_op_2;
            ex_op_3 <= id_op_3;
            ex_alu_op <= id_alu_op;

            ex_rd_addr <= id_rd_addr;
            ex_rd_we <= id_rd_we;
            ex_mem_offset <= id_mem_offset;
        end
    end
    
    always @(posedge clk) begin
        if(stall[2] == 1) begin
            inst_EX <= 32'bx;
        end
        else begin
            inst_EX <= inst_DE; 
        end
    end

endmodule
