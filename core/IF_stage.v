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
    input [31:0] pc_if,
    
    input branch,
    input [31:0] branch_addr,
    
    output reg [31:0] inst_o,
    output reg [31:0] pc_id,
    
    output reg [31:0] pc_rom, // Mostly needed for ROm
    
    output reg read_enable_cpu,

    output reg do_stall,
    
    output reg [31:0] IF_inst
    );
    // always @(*) begin
    //     if (go == 1) begin
    //         if (reset == 1) begin
    //             do_stall = 0;
    //             inst_o = 0;
    //             pc_id = 0;
    //         end
    //         else if(branch == 1) begin
    //             inst_o = inst;
    //             pc_id = branch_addr;
    //             do_stall = 0; 
    //         end
    //         else
    //             inst_o = inst;
    //             pc_id = pc_if;
    //             do_stall = 0;
    //     end    
    // end

    always @(*) begin
        if(reset == 1) begin
            inst_o = 0;
            do_stall = 0;
            pc_id = 0;
            read_enable_cpu = 0; 
        end
        else if (go == 1) begin
            if (branch == 1) begin
                inst_o = 0;
                pc_id = 0;
                do_stall = 0;
                read_enable_cpu = 0;
            end
            else begin
                pc_id = pc_if;
                pc_rom = pc_if;
                inst_o = inst;
                read_enable_cpu = 1;
                do_stall = 0;
            end
        end
    end
    
    always @(*) begin
        IF_inst = inst;
    end    
    
endmodule