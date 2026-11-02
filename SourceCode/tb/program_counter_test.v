`timescale 1ns/1ps
module program_counter_tb;
    reg clk = 0;
    reg reset = 1;
    reg enable = 0;
    reg [15:0] next_pc = 16'h1234;
    wire [15:0] pc;
    program_counter dut (
        .clk(clk), .reset(reset), .enable(enable),
        .next_pc(next_pc), .pc(pc)
    );
    always #5 clk = ~clk;
    initial begin
        @(posedge clk); #1;
        if (pc !== 16'h0000) $fatal(1, "PC reset failed");
        reset = 0;
        @(posedge clk); #1;
        if (pc !== 16'h0000) $fatal(1, "PC changed while disabled");
        enable = 1;
        @(posedge clk); #1;
        if (pc !== 16'h1234) $fatal(1, "PC failed to load next_pc");
        $display("ALL PROGRAM COUNTER TESTS PASSED");
        $finish;
    end
endmodule
