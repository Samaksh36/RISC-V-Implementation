`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.11.2021 22:14:28
// Design Name: 
// Module Name: ram
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
`define mem_size 4096 // 2^20 memory size


module ram( 
    input clk,
    input reset,
    input write_enable,
    input [31:0] mem_addr,
    input [31:0] mem_data,
    input read_enable,

    output reg [31:0] mem_output_data
    );

    reg [31:0] main_memory [0:4096-1];
    wire [11:0] actual_addr = mem_addr[11:0];

    integer i;

    always @(posedge clk or posedge reset) begin
        if(reset == 1) begin
            for (i = 0; i < 4096; i = i + 1) begin
                main_memory[i] <= 0; 
            end
        end
    end

    // Writing Data 
    always @(posedge clk) begin
        if (write_enable == 1) begin
            main_memory[actual_addr>>2] <= mem_data;
        end
    end

    // Read Data 
    always @(*) begin
        if(read_enable == 1 && write_enable == 0) begin
            mem_output_data = main_memory[actual_addr>>2];
        end
        else begin
            mem_output_data = 0;
        end
    end

endmodule