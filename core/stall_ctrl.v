`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.12.2021 18:48:58
// Design Name: 
// Module Name: stall_ctrl
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


module stall_ctrl(
    input reset,
    input stall_decode,
    output reg [4:0] stall_stage
    );

    always @(*) begin
        if(reset == 1) begin
            stall_stage = 5'b00000;
        end
        if(stall_decode == 1) begin
            stall_stage = 5'b00111;
        end
        else begin
            stall_stage = 5'b00000;
        end
    end

endmodule
