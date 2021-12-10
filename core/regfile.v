`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.11.2021 20:44:13
// Design Name: 
// Module Name: regfile
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


module regfile(
    input clk,
    input reset,

    input write_enable, // WB Stage Only
    input [4:0] w_addr, // Addr from WB stage to write data, 32==>5 bits
    input [31:0] w_data, // Data from WB stage to write data, 32 bits 
    
    input r1_read_enable, // From ID to read register R1
    input [4:0] r1_addr, // Addr to Read from r1 register(ROM Logic)

    input r2_read_enable, // From ID to read register R1
    input [4:0] r2_addr, // Addr to Read from r1 register(ROM Logic)
    
    input r3_read_enable, // From ID to read register R1
    input [4:0] r3_addr, // Addr to Read from r1 register(ROM Logic) // only for MAC operation 

    output reg [31:0] r1_data, // Data stored in r1-addr 
    output reg [31:0] r2_data, // Data stored in r2-addr both are outputs to the ID stage
    output reg [31:0] r3_data // Data stored in r2-addr both are outputs to the ID stage
    );

    reg [31:0] register_file [0:31];
    
    // Write From WB
    always @(*) begin
        if (reset == 0 && write_enable == 1) begin
            if(w_addr != 0) begin
                register_file[w_addr] <= w_data; // Writing data to the register
            end
        end    
    end

    // Read Data for R1
    always @(*) begin
        if(reset == 1 || r1_read_enable == 0 || r1_addr == 0) begin
            r1_data = 0;
        end
        else 
            r1_data = register_file[r1_addr];
    end

    always @(*) begin
        if(reset == 1 || r2_read_enable == 0 || r2_addr == 0) begin
            r2_data = 0;
        end
        else 
            r2_data = register_file[r2_addr];
    end

    always @(*) begin
        if(reset == 1 || r3_read_enable == 0 || r3_addr == 0) begin
            r3_data = 0;
        end
        else 
            r3_data = register_file[r3_addr];
    end

    integer i;
    integer j = 0;
    always @(posedge clk or posedge reset) begin
        if(reset == 1) begin
            for (i = 0; i<32; i = i + 1) begin
                register_file[i] <= 0;
            end
        end
    end

   always @(posedge clk) begin
       $display("\n=============  REGFILE DUMP =============\n");
       for(j = 0; j < 32; j = j + 1) begin
           $display("register[%0d]:\t%0d", j, register_file[j]);
       end
   end
endmodule
