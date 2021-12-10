`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.11.2021 19:57:25
// Design Name: 
// Module Name: mem_stage
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

module mem_stage(
    input reset,

    input [4:0] rd_addr_mem, // input = output
    input rd_we_mem, // input = output 
    input [31:0] rd_data_mem, // data to write in register in WB stage two main functions only sent to the output reg is SW or LW is not the alu_op
    input [31:0] mem_addr_mem, // LW/SW addr for write or read 

    input [31:0] inst_mem,

    input [3:0] alu_op_mem, // SW or LW 
    input [31:0] sw_data, // Input from EX stage for the SW operation

    input [31:0] ram_data, // Input from RAM 

    output reg [31:0] reg_data_mem, // If LW or SW not done then =rd_data_mama, else will be assigned the LW data which is ram_data
    output reg [4:0] reg_addr_mem, // input output thing as we need the addr to either lw or for the Wb
    output reg reg_we_mem, // Outout is inoptu,
    
    output reg [31:0] ram_addr_mem, // input is the calculated addr from the EX will be used for either read or write 
    output reg [31:0] ram_data_mem, // used for RAM data inputm
    output reg ram_read_enable,
    output reg ram_write_enable,

    output reg [31:0] tb_inst_mem
    );

    always @(*) begin
        if(reset == 1) begin
            reg_data_mem = 0;   // If LW or SW not done then =rd_data_mama, else will be assigned the LW data which is ram_data
            reg_addr_mem = 0;   // input output thing as we need the addr to either lw or for the Wb
            reg_we_mem = 0;      // Outout is inoptu,
        
            ram_addr_mem = 0; // input is the calculated addr from the EX will be used for either read or write 
            ram_data_mem = 0;// used for RAM data inputm
            ram_read_enable = 0;
            ram_write_enable = 0;
        end
        else begin // add additional stall functionality
            case (alu_op_mem)
               `LW_ALU : begin
                    reg_addr_mem = rd_addr_mem;
                    reg_data_mem = ram_data;
                    reg_we_mem = rd_we_mem;

                    ram_addr_mem = mem_addr_mem;
                    ram_data_mem = 0;
                    ram_read_enable = 1;
                    ram_write_enable = 0;

               end 
               `SW_ALU : begin
                    reg_data_mem = 0;
                    reg_we_mem = rd_we_mem;
                    reg_addr_mem = rd_addr_mem;

                    ram_addr_mem = mem_addr_mem;
                    ram_data_mem = sw_data;
                    ram_read_enable = 0;
                    ram_write_enable = 1;
               end
                default: begin
                    // This case would be any other instruction that does register based operations
                    reg_we_mem = rd_we_mem;
                    reg_data_mem = rd_data_mem;
                    reg_addr_mem = rd_addr_mem;
                end 
            endcase
        end
    end

    always @(*) begin
        tb_inst_mem = inst_mem;
    end

endmodule
