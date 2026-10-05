`timescale 1ns/1ps

module program_counter_tb;
    reg clk = 0;
    reg reset = 1;
    wire [15:0] pc;

    program_counter dut (
        .clk(clk),
        .reset(reset),
        .pc(pc)
    );

    always #5 clk = ~clk;
    always @(posedge clk)
        $strobe("pc = %0d", pc);

    initial begin
        #12 reset = 0;
        #40 $finish;
    end
endmodule