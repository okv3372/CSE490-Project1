`timescale 1ns/1ps
module data_memory_tb;
    reg clk = 0;
    reg enable = 1;
    reg read_enable = 1;
    reg write_enable = 0;
    reg [15:0] address = 0;
    reg [15:0] write_data = 0;
    reg [15:0] debug_address = 0;
    wire [15:0] read_data, debug_data;
    data_memory dut (
        .clk(clk), .enable(enable), .read_enable(read_enable),
        .write_enable(write_enable), .address(address),
        .write_data(write_data), .read_data(read_data),
        .debug_address(debug_address), .debug_data(debug_data)
    );
    always #5 clk = ~clk;
    initial begin
        #1;
        address = 16'd1;
        debug_address = 16'd1;
        write_data = 16'habcd;
        write_enable = 1;
        @(posedge clk); #1;
        if (read_data !== 16'habcd || debug_data !== 16'habcd ||
            dut.memory[1] !== 8'hab || dut.memory[2] !== 8'hcd)
            $fatal(1, "Unaligned big-endian store/read failed");
        enable = 0;
        write_data = 16'h1234;
        @(posedge clk); #1;
        if (read_data !== 16'habcd) $fatal(1, "Disabled write changed memory");
        enable = 1;
        address = 16'd62;
        debug_address = 16'd62;
        write_data = 16'hef12;
        @(posedge clk); #1;
        if (read_data !== 16'hef12 || dut.memory[63] !== 8'h12)
            $fatal(1, "Last valid word failed");
        address = 16'd63;
        debug_address = 16'd63;
        write_data = 16'hffff;
        @(posedge clk); #1;
        if (read_data !== 16'h0000 || debug_data !== 16'h0000 ||
            dut.memory[63] !== 8'h12)
            $fatal(1, "Out-of-range access failed");
        read_enable = 0;
        address = 16'd1;
        #1;
        if (read_data !== 16'h0000) $fatal(1, "Read enable failed");
        $display("ALL DATA MEMORY TESTS PASSED");
        $finish;
    end
endmodule
