`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.11.2021 11:04:11
// Design Name: 
// Module Name: tb_soc
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
`define TEST_FILE "sss.txt"
//`define TEST_FILE_BIN "sss.bin"

module tb_soc();

    reg clk;
    reg write_enable;
    reg go;
    reg reset;

    reg [31:0] mem_input_data;
    wire [31:0] inst;
    reg [31:0] start_pc;

    wire [31:0] next_inst_addr;
    wire halt;
    wire [31:0] mem_addr;
    wire [31:0] mem_output_data;
    wire read_enable_cpu;

    reg [31:0] tb_inst;
    reg [31:0] tb_addr;
    reg [31:0] inst_mem [0:31];
    
    inst_rom rom(
        .clk(clk),
        .write_enable(write_enable),
        .read_enable_cpu(read_enable_cpu),
        .tb_inst(tb_inst),
        .tb_addr(tb_addr),
        .cpu_addr(next_inst_addr),
        
        .cpu_inst(inst)
    );

    riscv_cpu cpu(
        .clk(clk),
        .reset(reset),
        .go(go),
        .start_pc(start_pc),
        .mem_input_data(mem_input_data),
        .inst(inst),
        .next_inst_addr(next_inst_addr),
        .halt(halt),
        .mem_addr(mem_addr),
        .mem_output_data(mem_output_data),
        .read_enable_cpu(read_enable_cpu)
    );

    integer data_file;
    integer data_file_1;
    integer scan_file;
    integer scan_file_1;
    
    integer index_addr;
    integer index_cpu;
    reg [31:0] captured_data;

    always #5 clk = ~clk;

    initial begin
        index_addr = 0;
        clk = 0;
        index_cpu = 0;
        write_enable = 1;
        start_pc = 0;
        tb_inst = 0;
        tb_addr = 0;
        go = 0;
        reset = 1;
        data_file_1 = $fopen(`TEST_FILE, "r");
        data_file = $fopen(`TEST_FILE, "r");
        if (data_file == 0) begin
            $display("FILE DIDNT OPEN \nTRY AGAIN");
            $finish;
        end
    end
    reg end_of_rom;
    
    initial begin   
        $readmemb(`TEST_FILE, inst_mem);
    end
    
    always @(negedge clk ) begin // At every posedge read via index_addr
        scan_file = $fscanf(data_file, "%b\n", captured_data);
        if($feof(data_file) == 0) begin
            $display("============  Instruction Read:%x - Write to Address: %d ============", captured_data, index_addr);
            tb_inst = captured_data;
            tb_addr = index_addr;
            index_addr = index_addr + 4;
        end
        else begin
            tb_inst = 0;
            tb_addr = index_addr;
            index_addr = index_addr + 4;
            end_of_rom = index_addr;
            // $display("============  Instruction Read:%x - Write to Address: %d ============", captured_data, index_addr);
            // tb_inst = captured_data;
            // tb_addr = index_addr;
            // index_addr = index_addr + 4;
            go = 1;
            #10 reset = 0;
            // if(index_cpu == 0) begin
            //     start_pc = 0;
            // end
            // else begin
            //     start_pc = next_inst_addr;
            //     index_cpu = index_cpu + 4;
            // end
            if(go == 1) begin
                start_pc = index_cpu;
                index_cpu = index_cpu + 4;
            end
        end
    end
    
    // always @(posedge clk) begin
    //     if(inst_mem[index_addr+4] == 32'd0) begin
    //         tb_inst = 0;
    //         tb_addr = index_addr + 4;
    //         go = 1;
    //         #10 reset = 0;
    //     end else begin
    //         $display("============  Instruction Read:%x - Write to Address: %d ============", inst_mem[index_addr], index_addr);
    //         tb_inst = inst_mem[index_addr];
    //         tb_addr = index_addr;
    //         index_addr = index_addr + 4;
    //     end
    // end
    
    // always @(posedge clk) begin
    //     if(go == 1) begin
    //         start_pc = index_cpu;
    //         index_cpu = index_cpu + 4;
    //     end
    // end

endmodule
