`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.11.2021 21:14:35
// Design Name: 
// Module Name: EX_stage
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
`include "riscv_define_all.v"

module EX_stage(
    input reset,
    
    input [31:0] op_1, // From ID input from Reg1
    input [31:0] op_2, // From ID input from Reg1
    input [31:0] op_3, // From ID input from Reg1
    input [3:0] alu_op, // Operating to do

    input [4:0] rd_addr, // Location to write the data gotten from ID  
    input rd_we, // write enable 1 or 0
    input [31:0] mem_offset, // RAM location to write 
    
    input [31:0] inst_EX,
    
    output reg [4:0] rd_addr_wb, // output = input for WB 
    output reg rd_we_wb, // output = input for WB
    output reg [31:0] rd_data, // Calculated Data for WB 
    output reg [31:0] mem_addr_mem, // Calculated addr to write to or load from 

    output wire [3:0] alu_op_mem, // Used to check if LW or SW is done in the MEM stage 
    output wire [31:0] op_2_mem, // This is used to send to the mem stage, as we have to STORE r2 in memory for SW
    output reg [31:0] EX_inst
    );

    assign op_2_mem = op_2; // For memory store/load
    assign alu_op_mem = alu_op; // For Store load in mem stage
    wire [31:0] alu_register;
    reg [31:0] rs1_alu;
    reg [31:0] rs2_alu;
    reg [31:0] rs3_alu;
    reg [3:0] opcode_alu;

    alu alu_ex(
        .rs1(rs1_alu),
        .rs2(rs2_alu),
        .rs3(rs3_alu),
        .reset(reset),
        .opcode(opcode_alu),
        .rd(alu_register) // Connect ALU REGISTER To ThE rd_data or mem_addr_mem
    );
    

    always @(*) begin
        if(reset == 1) begin
            rs1_alu = 0;
            rs2_alu = 0;
            rs3_alu = 0;
            opcode_alu = 0;      
            rd_addr_wb = 0;
            rd_data = 0;  
        end
        else begin // Perform the ALU operations 
            case (alu_op)
                `ADD_ALU: begin
                    rs1_alu = op_1;
                    rs2_alu = op_2;
                    opcode_alu = `ADD_ALU;
                end 
                `SUB_ALU: begin
                    rs1_alu = op_1;
                    rs2_alu = op_2;
                    opcode_alu = `SUB_ALU;
                end 
                `AND_ALU: begin
                    rs1_alu = op_1;
                    rs2_alu = op_2;
                    opcode_alu = `AND_ALU;
                end 
                `OR_ALU: begin
                    rs1_alu = op_1;
                    rs2_alu = op_2;
                    opcode_alu = `OR_ALU;
                end 
                `SLL_ALU: begin
                    rs1_alu = op_1;
                    rs2_alu = op_2;
                    opcode_alu = `SLL_ALU;
                end 
                `SRA_ALU: begin
                    rs1_alu = op_1;
                    rs2_alu = op_2;
                    opcode_alu = `SRA_ALU;
                end 
                `SW_ALU: begin
                    rs1_alu = op_1;
                    rs2_alu = mem_offset;
                    opcode_alu = `ADD_ALU;
                end 
                `LW_ALU: begin
                    rs1_alu = op_1;
                    rs2_alu = mem_offset;
                    opcode_alu = `ADD_ALU;
                end
                `MAC_ALU: begin
                    rs1_alu = op_1;
                    rs2_alu = op_2;
                    rs3_alu = op_3;
                    opcode_alu = `MAC_ALU;
                end
                default: begin
                end
            endcase
        end
    end

    always @(*) begin
        rd_addr_wb = rd_addr;
        rd_we_wb = rd_we;
        mem_addr_mem = 0; // Initialize mem_addr
        // rd_data logic 
        // initialize mem_addr
        case (alu_op)
            `ADD_ALU: begin
                rd_data = alu_register;
            end 
            `SUB_ALU: begin
                rd_data = alu_register;
            end 
            `AND_ALU: begin
                rd_data = alu_register;
            end
            `OR_ALU: begin
                rd_data = alu_register;
            end 
            `SLL_ALU: begin
                rd_data = alu_register;
            end 
            `SRA_ALU: begin
                rd_data = alu_register;
            end 
            `SW_ALU: begin
                rd_data = 0;
                mem_addr_mem = alu_register;
            end 
            `LW_ALU: begin
                rd_data = 0;
                mem_addr_mem = alu_register;
            end
            `MAC_ALU: begin
                rd_data = alu_register;
            end 
            default: begin
            end
        endcase
    end
    
    always @(*) begin
        EX_inst = inst_EX;
    end
endmodule
