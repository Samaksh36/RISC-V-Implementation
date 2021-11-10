`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.11.2021 10:50:47
// Design Name: 
// Module Name: IF_stage
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


module IF_stage( // Add Stall Functionality 
    input go,
    input reset,
    input [31:0] inst,
    input branch,
    input [31:0] branch_addr,
    output reg [31:0] inst_o,
    output reg do_stall
    );
    always @(*) begin
        if (go == 1) begin
            if (reset == 1) begin
                do_stall = 0;
                inst_o = 0;
            end
            else if(branch == 1) begin
                inst_o = branch_addr;
                do_stall = 0; 
            end
            else
                inst_o = inst;
                do_stall = 0;
        end    
    end
endmodule