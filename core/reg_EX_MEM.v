`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.11.2021 16:50:08
// Design Name: 
// Module Name: reg_EX_MEM
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


module reg_EX_MEM(
    input clk,
    input reset,

    input [31:0] inst_ex_mem,

    input [4:0] ex_rd_addr, // output = input for WB 
    input ex_rd_we, // output = input for WB
    input [31:0] ex_rd_data, // Calculated Data for WB 
    input [31:0] ex_mem_addr, // Calculated addr to write to or load from 

    input wire [3:0] ex_alu_op, // Used to check if LW or SW is done in the MEM stage 
    input wire [31:0] ex_op_2, // This is used to send to the mem stage, as we have to STORE r2 in memory for SW

    output reg [4:0] mem_rd_addr, // output reg = output
    output reg mem_rd_we, // output reg = output 
    output reg [31:0] mem_rd_data, // data to write in register in WB stage two main functions only sent to the output reg is SW or LW is not the alu_op
    output reg [31:0] mem_mem_addr, // LW/SW addr for write or read 

    output reg [3:0] mem_alu_op, // SW or LW 
    output reg [31:0] mem_op_2, // Input from EX stage for the SW operation
    
    output reg [31:0] ex_mem_inst
    );

    always @(posedge clk) begin
        if(reset == 1) begin
            mem_rd_addr <= 0; //  = output
            mem_rd_we <= 0; //  = output 
            mem_rd_data <= 0; // data to write in register in WB stage two main functions only sent to the  is SW or LW is not the alu_op
            mem_mem_addr <= 0; // LW/SW addr for write or read 

            mem_alu_op <= 0;// SW or LW 
            mem_op_2 <= 0;// Input from EX stage for the SW operation
        end
        else begin
            mem_rd_addr <= ex_rd_addr; //  = output
            mem_rd_we <= ex_rd_we; //  = output 
            mem_rd_data <= ex_rd_data; // data to write in register in WB stage two main functions only sent to the  is SW or LW is not the alu_op
            mem_mem_addr <= ex_mem_addr; // LW/SW addr for write or read 

            mem_alu_op <= ex_alu_op;// SW or LW 
            mem_op_2 <= ex_op_2;// Input from EX stage for the SW operation
        end
    end
    
    always @(posedge clk) begin
        ex_mem_inst <= inst_ex_mem;
    end

endmodule
