`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.11.2021 20:39:27
// Design Name: 
// Module Name: ID_stage
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
// Given the inst, decode the addrs needed for the given operation, 
// load the data here and output the data to the ALU directly, 
`include "riscv_define_all.v"

module ID_stage(
	input reset,
	input [31:0] pc,
	input [31:0] inst,
	
	input [4:0] prev_rd_addr,
	input [31:0] prev_rd_data,
	input prev_rd_we, 
	input [3:0] i_alu_op_ex,

	input [31:0] r1_data,
	input [31:0] r2_data, // Givne the addr get the data from the reg file
	input [31:0] r3_data, // Givne the addr get the data from the reg file

	output reg r1_read_enable, // output to regfile
	output reg r2_read_enable, // output to regfile
	output reg r3_read_enable, // output to regfile
	
	output reg [4:0] r1_addr, // output to regfile
	output reg [4:0] r2_addr, // output to regfile
	output reg [4:0] r3_addr, // output to regfile
	
	output reg [31:0] op_1, // output to ALU rs1
	output reg [31:0] op_2, // output to ALU rs2
	output reg [31:0] op_3, // output to ALU rs2
	
	output reg [4:0] rd_addr, // Only passes through EX for WB stage
	output reg [31:0] mem_offset,
	output reg rd_we,

	output reg br, // PC output
	output reg [31:0] branch_addr,
	
	output reg [3:0] alu_op,

	output reg [31:0] pc_out, // carrying over the PC 
	
	output reg [31:0] ID_inst,

	output wire StallCheck
	);

	wire [6:0] opcode = inst[6:0];
	wire [2:0] funct3 = inst[14:12];
	wire [6:0] funct7 = inst[31:25];
	
	wire [11:0] Itype_imm = inst[31:20];
	wire [11:0] Stype_imm = {inst[31:25], inst[11:7]};

	reg [31:0] imm1_reg;

	wire [4:0] rd = inst[11:7];
	wire [4:0] rs1 = inst[19:15];
	wire [4:0] rs2 = inst[24:20];
	wire [4:0] rs3 = inst[11:7];
	
	wire [31:0] pc_plus_Btype; // Only used for BEQ
	wire [31:0] Btype = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
	assign pc_plus_Btype = pc + {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};

	wire reg1_reg2_eq; // only used for BEQ
	assign reg1_reg2_eq = op_1==op_2?1:0;
	
	wire alu_is_load;
	assign alu_is_load = (i_alu_op_ex == `LW_ALU)? 1:0;

	assign StallCheck = (alu_is_load == 1 && (rs1 == prev_rd_addr || rs2 == prev_rd_addr))? 1:0; 
	// This always block sets the rs1 rs2 rd addrs, then sets the ALU operation to be done in the EX stage
	
	always @(*) begin
		if(reset == 1)begin
			alu_op = 0;
			br = 0;
			branch_addr = 0;
			r1_read_enable = 0;
			r2_read_enable = 0;
			r3_read_enable = 0;
			r1_addr = 0;
			r2_addr = 0;
			r3_addr = 0;
			rd_addr = 0;
			mem_offset = 0;
			rd_we = 0;
		end
		else begin
			br = 0;
			branch_addr = 0;
			r3_addr = 0;
			r3_read_enable = 0;
			case (opcode)
				`opcode_rtype: begin
					case (funct3)
						`funct3_and : begin
							alu_op = `AND_ALU;
							r1_read_enable = 1;
							r2_read_enable = 1;
							
							r1_addr = rs1;
							r2_addr = rs2;
													
							rd_addr = rd;
							rd_we = 1;

							imm1_reg = 0;

							mem_offset = 0;
						end

						`funct3_or : begin
							alu_op = `OR_ALU;
							r1_read_enable = 1;
							r2_read_enable = 1;
							
							r1_addr = rs1;
							r2_addr = rs2;
													
							rd_addr = rd;
							rd_we = 1;

							imm1_reg = 0;

							mem_offset = 0;
						end

						`funct3_add : begin
							case (funct7)
								`funct7_add: begin
									alu_op = `ADD_ALU;
									r1_read_enable = 1;
									r2_read_enable = 1;
									
									r1_addr = rs1;
									r2_addr = rs2;
															
									rd_addr = rd;
									rd_we = 1;

									imm1_reg = 0;

									mem_offset = 0;        
								end
								`funct7_sub: begin
									alu_op = `SUB_ALU;
									r1_read_enable = 1;
									r2_read_enable = 1;
									
									r1_addr = rs1;
									r2_addr = rs2;
															
									rd_addr = rd;
									rd_we = 1;

									imm1_reg = 0;

									mem_offset = 0;        
								end
								default: begin // END OF ADD SUB
								end 
							endcase
						end

						`funct3_sll : begin
							alu_op = `SLL_ALU;
							r1_read_enable = 1;
							r2_read_enable = 1;
							
							r1_addr = rs1;
							r2_addr = rs2;
													
							rd_addr = rd;
							rd_we = 1;

							imm1_reg = 0;

							mem_offset = 0;
						end
						
						`funct3_sra : begin
							alu_op = `SRA_ALU;
							r1_read_enable = 1;
							r2_read_enable = 1;
							
							r1_addr = rs1;
							r2_addr = rs2;
													
							rd_addr = rd;
							rd_we = 1;

							imm1_reg = 0;

							mem_offset = 0;
						end
						default: begin
						end
					endcase
				end                                                 // END OF R-TYPE OPCODES
				`opcode_addi : begin
					alu_op = `ADD_ALU;

					r1_read_enable = 1;
					r2_read_enable = 0;

					r1_addr = rs1;
					r2_addr = 0;
						
					rd_addr = rd;
					rd_we = 1;

					imm1_reg = {{20{Itype_imm[11]}}, Itype_imm};

					mem_offset = 0;
				end
				`opcode_sw: begin
					alu_op = `SW_ALU;

					r1_read_enable = 1;
					r2_read_enable = 1;

					r1_addr = rs1;
					r2_addr = rs2;
						
					rd_addr = 0;
					rd_we = 0;

					imm1_reg = 0;

					mem_offset = {{20{Stype_imm[11]}}, Stype_imm};
				end
				`opcode_lw: begin
					alu_op = `LW_ALU;

					r1_read_enable = 1;
					r2_read_enable = 0;

					r1_addr = rs1;
					r2_addr = 0;
						
					rd_addr = rd;
					rd_we = 1;

					imm1_reg = 0;

					mem_offset = {{20{Itype_imm[11]}}, Itype_imm};
				end
				// ADD BRANCH
				
				`opcode_beq: begin
					alu_op = `BEQ_ALU;
					
					r1_read_enable = 1;
					r2_read_enable = 1;

					r1_addr = rs1;
					r2_addr = rs2;
						
					rd_addr = rd;
					rd_we = 0;

					imm1_reg = 0;

					mem_offset = 0;
					if (reg1_reg2_eq == 1) begin
						br = 1;
						branch_addr = pc_plus_Btype;
					end
				end

				`opcode_mac: begin
					alu_op = `MAC_ALU;

					r1_read_enable = 1;
					r2_read_enable = 1;
					r3_read_enable = 1;

					r1_addr = rs1;
					r2_addr = rs2; 
					r3_addr = rs3;

					rd_addr = rd;
					rd_we = 1;

					imm1_reg = 0;

					mem_offset = 0;
				end
				default: begin
					$display("");
				end
			endcase // END OF OPCODE 
		end
	end

	// Assigning R1 Value, in turn OP1
	always @(*) begin
		if(reset == 1) begin
			op_1 = 0;
		end
		else if(alu_is_load == 0 && r1_read_enable == 1 && (rs1 == prev_rd_addr)) begin
			if (prev_rd_addr == 5'b0) begin
				op_1 = 0; 
            end            
			else begin
				op_1 = prev_rd_data;
			end
		end
		else if(r1_read_enable == 1) begin
			op_1 = r1_data; // reason for weird functions
		end
		else
			op_1 = 0;
	end

	// always @(*) begin
	// 	if(reset == 1) begin
	// 		op_1 = 0;
	// 	end
	// 	else if(alu_is_load == 0 && r1_read_enable == 1 && (rs1 == prev_rd_addr)) begin
	// 		op_1 = prev_rd_data;
	// 	end
	// 	else if(r1_read_enable == 1) begin
	// 		op_1 = r1_data; // reason for weird functions
	// 	end
	// 	else
	// 		op_1 = 0;
	// end

	// Assigning R2 Value to OP2
	always @(*) begin
		if(reset == 1) begin
			op_2 = 0;
		end
		else if(alu_is_load == 0 && r2_read_enable == 1 && (rs2 == prev_rd_addr)) begin
			op_2 = prev_rd_data; 
		end
		else if (r2_read_enable == 0) begin
			op_2 = imm1_reg; // ADDI Exclusive
		end
		else if(r2_read_enable == 1) begin
			op_2 = r2_data;
		end
	end
	
	// Assigning R2 Value to OP2
	always @(*) begin
		if(reset == 1) begin
			op_3 = 0;
		end
		// else if(r3_read_enable == 1 && (rs3 == prev_rd_addr)) begin
		// 	op_3 = prev_rd_data;
		// end
		else if(r3_read_enable == 1) begin
			op_3 = r3_data;
		end
		else if (r3_read_enable == 0) begin
		end
	end
	
	always @(*) begin
		pc_out = pc;
	end
	
	always @(*) begin
		ID_inst = inst;
	end

	// always @(*) begin
	// 	stall_is_needed = 0;
	// 	if(alu_is_load == 1 && (rs1 == prev_rd_addr || rs2 == prev_rd_addr)) begin
	// 		stall_is_needed = 1;
	// 	end
	// end

endmodule
