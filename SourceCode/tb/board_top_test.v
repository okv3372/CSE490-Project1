`timescale 1ns/1ps
module board_top_tb;
    reg clk = 0;
    reg btnC = 0;
    reg btnU = 1;
    reg [0:0] sw = 0;
    wire [15:0] led;
    wire [3:0] an;
    wire [6:0] seg;
    board_top dut (.clk(clk), .btnC(btnC), .btnU(btnU),
                   .sw(sw), .led(led), .an(an), .seg(seg));
    always #5 clk = ~clk;

    initial begin
        repeat (3) @(posedge clk);
        @(negedge clk);
        btnU = 0;
        #1;
        if (an !== 4'b1110 || seg !== 7'b0110000)
            $fatal(1, "Display should start with rightmost digit 3 of 3103");
        if (led !== 16'd3)
            $fatal(1, "LEDs should show ALU result 3 for first addi");
        sw[0] = 1;
        #1;
        if (led !== 16'd0) $fatal(1, "Board reset failed");

        btnC = 1;
        repeat (65550) @(posedge clk);
        #1;
        if (led !== 16'd2) $fatal(1, "First button press did not step once");
        if (seg !== 7'b0010010)
            $fatal(1, "Display should show next instruction 3205");
        repeat (65550) @(posedge clk);
        #1;
        if (led !== 16'd2) $fatal(1, "Held button caused another step");
        btnC = 0;
        repeat (65550) @(posedge clk);
        #1;
        btnC = 1;
        repeat (65550) @(posedge clk);
        #1;
        if (led !== 16'd4) $fatal(1, "Second button press failed");
        sw[0] = 0;
        #1;
        if (led !== 16'd8) $fatal(1, "ALU output for add s2,s1 should be 8");
        $display("ALL BOARD TOP TESTS PASSED");
        $finish;
    end
endmodule
