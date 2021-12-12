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
	input go, // Start after the ROM is loaded
	
	output [31:0] IF_inst,
	output [31:0] ID_inst,
	output [31:0] EX_inst_tb,
	output [31:0] MEM_inst_tb,
	output [31:0] wb_inst
	);
	
	wire read_enable_cpu;
	wire [31:0] next_inst_addr;
	wire [31:0] inst;
	
	wire branch;
	wire [31:0] branch_addr;

	wire [5:0] do_stall;
	wire stall_IF;

	wire [31:0] pc_if;

	pc_register pc(
		.go(go),

		.clk(clk),
		.reset(reset),
		
		.branch(br),
		.branch_addr(branch_addr),
		
		.do_stall(stall_stage),
		
		// .pc(next_inst_addr),
		.pc_cpu(pc_if) // Carry over till ID
	);

	inst_rom rom(
		.clk(clk),
		.read_enable_cpu(read_enable_cpu),
		.cpu_addr(next_inst_addr),
		
		.cpu_inst(inst)
	);

	wire [31:0] inst_o;
	wire [31:0] pc_id;
	wire [4:0] stall_stage;
	stall_ctrl ctrl(
		.reset(reset),
		.stall_decode(stall_decode_stage),
		.stall_stage(stall_stage)
	);


	IF_stage IF(
		.reset(reset),
		.go(go),
		
		.inst(inst),
		.pc_if(pc_if),
		
		.branch(branch),
		.branch_addr(branch_addr),
		
		.inst_o(inst_o),
		.pc_id(pc_id),
		.pc_rom(next_inst_addr),
		.read_enable_cpu(read_enable_cpu),

		.do_stall(stall_IF),
		
		.IF_inst(IF_inst)
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
	
	wire id_r3_read_enable;
	wire [4:0] id_r3_addr;  
	wire [31:0] id_r3_data;

	regfile regfile_in(
		.clk(clk),
		.reset(reset),

		.write_enable(reg_we_mem), // WB Stage Only
		.w_addr(reg_addr_mem), // Addr from WB stage to write data, 32==>5 bits
		.w_data(reg_data_mem), // Data from WB stage to write data, 32 bits 
		
		.r1_read_enable(id_r1_read_enable), // From ID to read register R1
		.r1_addr(id_r1_addr), // Addr to Read from r1 register(ROM Logic)

		.r2_read_enable(id_r2_read_enable), // From ID to read register R1
		.r2_addr(id_r2_addr), // Addr to Read from r1 register(ROM Logic)

		.r3_read_enable(id_r3_read_enable), // From ID to read register R1
		.r3_addr(id_r3_addr), // Addr to Read from r1 register(ROM Logic)

		.r1_data(id_r1_data), // Data stored in r1-addr 
		.r2_data(id_r2_data), // Data stored in r2-addr both are outputs to the ID stage
		.r3_data(id_r3_data) // Data stored in r2-addr both are outputs to the ID stage
	);

	wire [31:0] pc_id_reg;
	wire [31:0] inst_id_reg;

	reg_IF_ID pipeline_reg_FD(
		.clk(clk),
		.reset(reset),
		.stall(stall_stage),
		.inst_if(inst_o),
		.pc_if(pc_id),
		.do_stall(stall_IF),
		.br(br),

		.pc_id(pc_id_reg),
		.inst_id(inst_id_reg)
	);

	wire [31:0] op1_ex;
	wire [31:0] op2_ex;
	wire [31:0] op3_ex;
	wire [4:0] rd_addr_ex;
	wire rd_we_ex;
	wire [31:0] mem_offset_ex; // go to ex to calc final mem addr
	wire [3:0] alu_op; // EX Input to perform the instruction
	wire [31:0] pc_out_id; // Carry forward the PC 
	wire [31:0] rd_data_ex;
	wire [4:0] rd_addr_wb;
	wire rd_we_data;
	wire [3:0] reg_alu_op; // EX Input to perform the instruction

	wire stall_decode_stage;
	ID_stage id( // ADD BEQ Functionality 
		.reset(reset),
		.pc(pc_id_reg),
		.inst(inst_id_reg),
		
		.prev_rd_addr(rd_addr_wb),
		.prev_rd_data(rd_data_ex),
		.prev_rd_we(rd_we_wb),

		.i_alu_op_ex(reg_alu_op),

		.r1_data(id_r1_data),
		.r2_data(id_r2_data), // Givne the addr get the data from the reg file
		.r3_data(id_r3_data), // Givne the addr get the data from the reg file

		.r1_read_enable(id_r1_read_enable), // output to regfile
		.r2_read_enable(id_r2_read_enable), // output to regfile
		.r3_read_enable(id_r3_read_enable), // output to regfile
		
		.r1_addr(id_r1_addr), // output to regfile
		.r2_addr(id_r2_addr), // output to regfile
		.r3_addr(id_r3_addr), // output to regfile
		
		.op_1(op1_ex), // output to ALU rs1
		.op_2(op2_ex), // output to ALU rs2
		.op_3(op3_ex), // output to ALU rs2
		.rd_addr(rd_addr_ex), // Only passes through EX for WB stage
		.mem_offset(mem_offset_ex),
		.rd_we(rd_we_ex),

		.br(br), // PC 
		.branch_addr(branch_addr),
		
		.alu_op(alu_op),

		.pc_out(pc_out_id), // carrying over the PC
		.ID_inst(ID_inst),

		.StallCheck(stall_decode_stage)
	);
	
	wire [31:0] reg_op1_ex;
	wire [31:0] reg_op2_ex;
	wire [31:0] reg_op3_ex;
	wire [4:0] reg_rd_addr_ex;
	wire reg_rd_we_ex;
	wire [31:0] reg_mem_offset_ex; // go to ex to calc final mem addr
	wire [31:0] EX_inst;

	// INSERT PIPELINE REGISTER
	reg_ID_EX pipeline_reg_DE(
		.clk(clk),
		.reset(reset),
		
		.inst_DE(ID_inst),
		.stall(stall_stage),
		.id_op_1(op1_ex), // output to ALU rs1
		.id_op_2(op2_ex), // output to ALU rs2
		.id_op_3(op3_ex), // output to ALU rs2
		.id_alu_op(alu_op),

		.id_rd_addr(rd_addr_ex), // Only passes through EX for WB stage
		.id_rd_we(rd_we_ex),
		.id_mem_offset(mem_offset_ex),


		.ex_op_1(reg_op1_ex), // output to ALU rs1
		.ex_op_2(reg_op2_ex), // output to ALU rs2
		.ex_op_3(reg_op3_ex), // output to ALU rs2
		.ex_alu_op(reg_alu_op),

		.ex_rd_addr(reg_rd_addr_ex), // Only passes through EX for WB stage
		.ex_rd_we(reg_rd_we_ex),
		.ex_mem_offset(reg_mem_offset_ex),
		
		.inst_EX(EX_inst)        
	); 
	
	
	wire [3:0] alu_op_mem;
	wire [31:0] op_2_mem;
	wire [31:0] mem_addr_mem;

	EX_stage ex(
		.reset(reset),
		
		.inst_EX(EX_inst),
		
		.op_1(reg_op1_ex), // From ID input from Reg1
		.op_2(reg_op2_ex), // From ID input from Reg1
		.op_3(reg_op3_ex), // From ID input from Reg1
		.alu_op(reg_alu_op), // Operating to do

		.rd_addr(reg_rd_addr_ex), // Location to write the data gotten from ID  
		.rd_we(reg_rd_we_ex), // write enable 1 or 0
		.mem_offset(reg_mem_offset_ex), // RAM location to write 

		.rd_addr_wb(rd_addr_wb), // output = input for WB 
		.rd_we_wb(rd_we_wb), // output = input for WB
		.rd_data(rd_data_ex), // Calculated Data for WB (ACTUAL DATA CALCULATED)
		.mem_addr_mem(mem_addr_mem), // Calculated addr to write to or load from 

		.alu_op_mem(alu_op_mem), // Used to check if LW or SW is done in the MEM stage 
		.op_2_mem(op_2_mem), // This is used to send to the mem stage, as we have to STORE r2 in memory for SW
		.EX_inst(EX_inst_tb)
	);

	wire [31:0] ram_data;
	wire ram_we;
	wire [31:0] ram_addr_mem;
	wire [31:0] ram_data_mem;
	wire ram_read_enable;
	// Make RAM/Memory!!!
	ram mem(
		.clk(clk),
		.reset(reset),
		.write_enable(ram_we), // Input from MEM
		.mem_addr(ram_addr_mem), // From MEM
		.mem_data(ram_data_mem), // from MEM
		.read_enable(ram_read_enable), // from MEM

		.mem_output_data(ram_data) // output from MEM will only be needed for LW hence it will be input for the MEM stage 
	);

	wire [4:0] mem_rd_addr;
	wire mem_rd_we;
	wire [31:0] mem_rd_data;
	wire [31:0] mem_mem_addr;

	wire [3:0] mem_alu_op;
	wire [31:0] mem_sw_data;
	wire [31:0] ex_mem_inst_tb;
	// INSERT PIPELINE REGISTER
	reg_EX_MEM pipeline_reg_EM(
		.clk(clk),
		.reset(reset),
		.inst_ex_mem(EX_inst_tb),
		.ex_rd_addr(rd_addr_wb), // output = for WB 
		.ex_rd_we(rd_we_wb), // output = for WB
		.ex_rd_data(rd_data_ex), // Calculated Data for WB 
		.ex_mem_addr(mem_addr_mem), // Calculated addr to write to or load from 

		.ex_alu_op(alu_op_mem), // Used to check if LW or SW is done in the MEM stage 
		.ex_op_2(op_2_mem), // This is used to send to the mem stage, as we have to STORE r2 in memory for SW

		.mem_rd_addr(mem_rd_addr), // output reg = output
		.mem_rd_we(mem_rd_we), // output reg = output 
		.mem_rd_data(mem_rd_data), // data to write in register in WB stage two main functions only sent to the output reg is SW or LW is not the alu_op
		.mem_mem_addr(mem_mem_addr), // LW/SW addr for write or read 

		.mem_alu_op(mem_alu_op), // SW or LW 
		.mem_op_2(mem_sw_data), // Input from EX stage for the SW operation
		.ex_mem_inst(ex_mem_inst_tb)
	);
 
	// TODO Connect RAM TO MEM and WB 
	mem_stage M_stage(
		.reset(reset),

		.inst_mem(ex_mem_inst_tb),

		.rd_addr_mem(mem_rd_addr), // input = output
		.rd_we_mem(mem_rd_we), // input = output 
		.rd_data_mem(mem_rd_data), // data to write in register in WB stage two main functions only sent to the output reg is SW or LW is not the alu_op
		.mem_addr_mem(mem_mem_addr), // LW/SW addr for write or read 

		.alu_op_mem(mem_alu_op), // SW or LW 
		.sw_data(mem_sw_data), // Input from EX stage for the SW operation

		.ram_data(ram_data), // Input from RAM 

		.reg_data_mem(wb_w_data), // If LW or SW not done then =rd_data_mama, else will be assigned the LW data which is ram_data
		.reg_addr_mem(wb_w_addr), // input output thing as we need the addr to either lw or for the Wb
		.reg_we_mem(wb_write_enable), // Outout is inoptu,
		
		.ram_addr_mem(ram_addr_mem), // input is the calculated addr from the EX will be used for either read or write 
		.ram_data_mem(ram_data_mem), // used for RAM data inputm
		.ram_read_enable(ram_read_enable),
		.ram_write_enable(ram_we),
		.tb_inst_mem(MEM_inst_tb)
	);
	// Add Final Register For pipelining 

	wire [31:0] reg_data_mem; // If LW or SW not done then =rd_data_mama, else will be assigned the LW data which is ram_data
	wire [4:0] reg_addr_mem; // wire output thing as we need the addr to either lw or for the Wb
	wire reg_we_mem; // Outout is inoptu,

	reg_MEM_WB MW(
		.clk(clk),
		.reset(reset),
		.inst_mem_wb(MEM_inst_tb),
		.mem_data_mem(wb_w_data),
		.mem_addr_mem(wb_w_addr),
		.mem_we_mem(wb_write_enable),

		.reg_data_mem(reg_data_mem),
		.reg_addr_mem(reg_addr_mem),
		.reg_we_mem(reg_we_mem),
		.wb_inst(wb_inst)
	);


endmodule
