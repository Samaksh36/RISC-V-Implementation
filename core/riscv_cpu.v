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

    wire [31:0] rd_data_ex;
    wire [4:0] rd_addr_wb;
    wire rd_we_data;
    wire [3:0] alu_op_mem;
    wire [31:0] op_2_mem;
    wire [31:0] mem_addr_mem;

    EX_stage ex(
        .reset(reset),
    
        .op_1(op1_ex), // From ID input from Reg1
        .op_2(op2_ex), // From ID input from Reg1
        .alu_op(alu_op), // Operating to do

        .rd_addr(rd_addr_ex), // Location to write the data gotten from ID  
        .rd_we(rd_we_ex), // write enable 1 or 0
        .mem_offset(mem_offset_ex), // RAM location to write 

        .rd_addr_wb(rd_addr_wb), // output = input for WB 
        .rd_we_wb(rd_we_wb), // output = input for WB
        .rd_data(rd_data_ex), // Calculated Data for WB (ACTUAL DATA CALCULATED)
        .mem_addr_mem(mem_addr_mem), // Calculated addr to write to or load from 

        .alu_op_mem(alu_op_mem), // Used to check if LW or SW is done in the MEM stage 
        .op_2_mem(op_2_mem) // This is used to send to the mem stage, as we have to STORE r2 in memory for SW
    );

    wire [31:0] ram_data;
    wire ram_we;
    wire [31:0] ram_addr_mem;
    wire [31:0] ram_data_mem;
    wire ram_read_enable;
    // Make RAM/Memory!!!
    ram mem(
        .clk(clk),
        .write_enable(ram_we), // Input from MEM
        .mem_addr(ram_addr_mem), // From MEM
        .mem_data(ram_data_mem), // from MEM
        .read_enable(ram_read_enable), // from MEM

        .mem_output_data(ram_data) // output from MEM will only be needed for LW hence it will be input for the MEM stage 
    );

    // TODO Connect RAM TO MEM and WB 
    mem_stage M_stage(
        .reset(reset),

        .rd_addr_mem(rd_addr_wb), // input = output
        .rd_we_mem(rd_we_wb), // input = output 
        .rd_data_mem(rd_data_ex), // data to write in register in WB stage two main functions only sent to the output reg is SW or LW is not the alu_op
        .mem_addr_mem(mem_addr_mem), // LW/SW addr for write or read 

        .alu_op_mem(alu_op_mem), // SW or LW 
        .sw_data(op_2_mem), // Input from EX stage for the SW operation

        .ram_data(ram_data), // Input from RAM 

        .reg_data_mem(wb_w_data), // If LW or SW not done then =rd_data_mama, else will be assigned the LW data which is ram_data
        .reg_addr_mem(wb_w_addr), // input output thing as we need the addr to either lw or for the Wb
        .reg_we_mem(wb_write_enable), // Outout is inoptu,
        
        .ram_addr_mem(ram_addr_mem), // input is the calculated addr from the EX will be used for either read or write 
        .ram_data_mem(ram_data_mem), // used for RAM data inputm
        .ram_read_enable(ram_read_enable),
        .ram_write_enable(ram_we)
    );

endmodule
