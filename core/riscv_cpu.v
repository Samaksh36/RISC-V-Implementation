`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.11.2021 22:15:23
// Design Name: 
// Module Name: riscv_cpu
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


module riscv_cpu(
    input clk,
    input reset,
    input [31:0] start_pc,
    input go, // Start after the ROM is loaded
    input [31:0] mem_input_data, // load and Store
    input [31:0] inst, // Connect to ROM
    output [31:0] next_inst_addr, // Connect to ROM
    output halt, // Stop once all instructions are completed
    output [31:0] mem_addr, // Connect to RAM
    output [31:0] mem_output_data, // Connect to RAM
    output read_enable_cpu // Connect to ROM
    );

    wire branch;
    wire [31:0] branch_addr;

    wire [5:0] do_stall;
    wire stall_IF;

    pc_register pc(
        .go(go),
        .clk(clk),
        .reset(reset),
        .branch(br),
        .prev_pc(start_pc),
        .do_stall(do_stall),
        .branch_addr(branch_addr),
        
        .pc(next_inst_addr),
        .read_enable_cpu(read_enable_cpu)
    );
    
    wire [31:0] inst_o;

    IF_stage IF(
        .reset(reset),
        .go(go),
        .inst(inst),
        .branch(branch),
        .branch_addr(branch_addr),
        .inst_o(inst_o),
        .do_stall(stall_IF)
    );
    
    wire wb_write_enable;
    wire [4:0] wb_w_addr;
    wire [31:0] wb_w_data;
    
    wire id_r1_read_enable;
    wire [4:0] id_r1_addr;
    wire [31:0] id_r1_data;
    
    wire id_r2_read_enable;
    wire [4:0] id_r2_addr;  
    wire [31:0] id_r2_data;

    regfile regfile_in(
        .clk(clk),
        .reset(reset),

        .write_enable(wb_write_enable), // WB Stage Only
        .w_addr(wb_w_addr), // Addr from WB stage to write data, 32==>5 bits
        .w_data(wb_w_data), // Data from WB stage to write data, 32 bits 
        
        .r1_read_enable(id_r1_read_enable), // From ID to read register R1
        .r1_addr(id_r1_addr), // Addr to Read from r1 register(ROM Logic)

        .r2_read_enable(id_r2_read_enable), // From ID to read register R1
        .r2_addr(id_r2_addr), // Addr to Read from r1 register(ROM Logic)

        .r1_data(id_r1_data), // Data stored in r1-addr 
        .r2_data(id_r2_data) // Data stored in r2-addr both are outputs to the ID stage
    );

    // Add ID Stage
    // Make Premil Test bench
    wire [31:0] op1_ex;
    wire [31:0] op2_ex;
    wire [4:0] rd_addr_ex;
    wire rd_we_ex;
    wire [31:0] mem_offset_ex; // go to ex to calc final mem addr
    wire [3:0] alu_op; // EX Input to perform the instruction
    wire [31:0] pc_out_id; // Carry forward the PC 

    ID_stage id(
        .reset(reset),
        .pc(prev_is_load),
        .inst(inst_o),
        
        .r1_data(id_r1_data),
        .r2_data(id_r2_data), // Givne the addr get the data from the reg file

        .r1_read_enable(id_r1_read_enable), // output to regfile
        .r2_read_enable(id_r2_read_enable), // output to regfile
        
        .r1_addr(id_r1_addr), // output to regfile
        .r2_addr(id_r2_addr), // output to regfile
        
        .op_1(op1_ex), // output to ALU rs1
        .op_2(op2_ex), // output to ALU rs2
        .rd_addr(rd_addr_ex), // Only passes through EX for WB stage
        .mem_offset(mem_offset_ex),
        .rd_we(rd_we_ex),

        .br(br), // PC 
        .branch_addr(branch_addr),
        
        .alu_op(alu_op),

        .pc_out(pc_out_id) // carrying over the PC 
    );
    
endmodule
