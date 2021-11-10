`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.11.2021 22:31:10
// Design Name: 
// Module Name: tb_inst_rom
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
`define TEST_FILE "SampleBinary.txt"

module tb_inst_rom();

    reg clk;
    reg write_enable;
    reg read_enable_cpu;

    reg [31:0] tb_inst;
    reg [31:0] tb_addr;
    reg [31:0] cpu_addr;

    wire [31:0] cpu_inst;

    inst_rom rom(
        clk,
        write_enable,
        read_enable_cpu,
        tb_inst,
        tb_addr,
        cpu_addr,
        cpu_inst
    );

    integer data_file;
    integer scan_file;
    integer index_addr;
    reg [31:0] captured_data;

    always #5 clk = ~clk;
    initial begin
        index_addr = 0;
        clk = 0;
        write_enable = 0;
        read_enable_cpu = 0;
        tb_inst = 0;
        tb_addr = 0;
        cpu_addr = 0;
        data_file = $fopen(`TEST_FILE, "r");
        if (data_file == 0) begin
            $display("FILE DIDNT OPEN \nTRY AGAIN");
            $finish;
        end
    end
    // Initialize the ROM
    always @(negedge clk ) begin
        scan_file = $fscanf(data_file, "%b\n", captured_data);
        if($feof(data_file) == 0) begin
            $display("============  Instruction Read:%x - Write to Address: %d ============", captured_data, index_addr);
            write_enable = 1;
            tb_inst = captured_data;
            tb_addr = index_addr;
            index_addr = index_addr + 4;
        end
    end

    initial begin
        #100
        cpu_addr = 4;
        read_enable_cpu = 1;
        $display("Reading From CPU Port for PC:%d - CPU Instruction:%x", cpu_addr, cpu_inst);
        $finish;
    end
endmodule   
