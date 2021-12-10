`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.11.2021 19:54:57
// Design Name: 
// Module Name: reg_MEM_WB
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


module reg_MEM_WB(
    input clk,
    input reset,

    input [31:0] inst_mem_wb,

    input [31:0] mem_data_mem, // If LW or SW not done then =rd_data_mama, else will be assigned the LW data which is ram_data
    input [4:0] mem_addr_mem, // input output thing as we need the addr to either lw or for the Wb
    input mem_we_mem, // Outout is inoptu,
    
    output reg [31:0] reg_data_mem, // If LW or SW not done then =rd_data_mama, else will be assigned the LW data which is ram_data
    output reg [4:0] reg_addr_mem, // output reg output thing as we need the addr to either lw or for the Wb
    output reg reg_we_mem, // Outout is inoptu,
    output reg [31:0] wb_inst
    );

    always @(posedge clk) begin
        if(reset == 1) begin
            reg_data_mem <= 0;
            reg_addr_mem <= 0;
            reg_we_mem <= 0;
        end
        else begin
            reg_data_mem <= mem_data_mem;
            reg_addr_mem <= mem_addr_mem;
            reg_we_mem <= mem_we_mem;
        end
    end

    always @(posedge clk) begin
        wb_inst <= inst_mem_wb;
    end

endmodule
