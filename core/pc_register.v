`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.11.2021 23:55:39
// Design Name: 
// Module Name: pc_register
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


module pc_register(
    input go,

    input clk,
    input reset,
    
    input branch,
    input [31:0] branch_addr,
    
    input [4:0] do_stall,
    
    // output reg [31:0] pc,
    output reg [31:0] pc_cpu
    );

    reg [31:0] pc_local;
    // always @(posedge clk) begin
    //     if(go == 1)begin
    //         if(reset == 1) begin
    //             pc <= 0;
    //             pc_local <= 4;
    //             read_enable_cpu <= 1;
    //         end
    //         else 
    //             if (branch == 1) begin
    //                 pc_local <= branch_addr;
    //                 read_enable_cpu <= 1;
    //             end
    //             if (do_stall[0] == 0) begin
    //                 pc_local <= pc_local + 4;
    //                 pc <= pc_local;
    //                 read_enable_cpu <= 1;
    //         end    
    //     end
    // end
    // always @(posedge clk) begin
    //     if(go == 1) begin
    //         if (branch == 1) begin
    //             pc <= branch_addr;           
    //             pc_cpu <= branch_addr;           
    //             read_enable_cpu <= 1;
    //         end
    //         read_enable_cpu <= 1;
    //         pc <= prev_pc; 
    //         pc_cpu <= prev_pc; 
    //     end
    // end

    always @(posedge clk) begin
        if(reset == 1) begin
            pc_local <= -4;
        end
        else if (go == 1) begin
            if (branch == 1) begin
                pc_local <= branch_addr;
            end
            else if(do_stall[2] == 1) begin
                pc_local <= pc_local;
            end
            else begin
                pc_local <= pc_local + 4;
            end
        end
    end

    always @(*) begin
        // pc = pc_local;
        pc_cpu = pc_local;
    end
endmodule
