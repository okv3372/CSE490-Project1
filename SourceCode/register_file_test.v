`timescale 1ns/1ps

module register_file_tb;

    reg clk;
    reg reset;

    reg [3:0] rs_addr;
    reg [3:0] rt_addr;

    reg write_enable;
    reg [3:0] write_addr;
    reg [15:0] write_data;

    wire [15:0] rs_data;
    wire [15:0] rt_data;

    integer errors;
    integer i;

    register_file dut (
        .clk(clk),
        .reset(reset),
        .rs_addr(rs_addr),
        .rt_addr(rt_addr),
        .write_enable(write_enable),
        .write_addr(write_addr),
        .write_data(write_data),
        .rs_data(rs_data),
        .rt_data(rt_data)
    );

    always #5 clk = ~clk;

    task write_register;
        input enable;
        input [3:0] address;
        input [15:0] value;

        begin
            @(negedge clk);
            write_enable = enable;
            write_addr = address;
            write_data = value;

            @(posedge clk);
            #1;
            write_enable = 0;
        end
    endtask

    task check_reads;
        input [3:0] address_a;
        input [3:0] address_b;
        input [15:0] expected_a;
        input [15:0] expected_b;

        begin
            rs_addr = address_a;
            rt_addr = address_b;
            #1;

            if ((rs_data !== expected_a) ||
                (rt_data !== expected_b)) begin
                $display(
                    "FAIL: s%0d=%h expected=%h; s%0d=%h expected=%h",
                    address_a, rs_data, expected_a,
                    address_b, rt_data, expected_b
                );
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        rs_addr = 0;
        rt_addr = 0;
        write_enable = 0;
        write_addr = 0;
        write_data = 0;
        errors = 0;

        // Hold reset through two rising clock edges.
        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 0;

        // Every register should start at zero.
        for (i = 0; i < 16; i = i + 1) begin
            check_reads(i, i, 16'h0000, 16'h0000);
        end

        // Write different values and read both simultaneously.
        write_register(1'b1, 4'd1, 16'd3);
        write_register(1'b1, 4'd2, 16'd5);
        check_reads(4'd1, 4'd2, 16'd3, 16'd5);

        // A disabled write must leave the old value intact.
        write_register(1'b0, 4'd1, 16'd99);
        check_reads(4'd1, 4'd2, 16'd3, 16'd5);

        // Overwrite s2 without changing s1.
        write_register(1'b1, 4'd2, 16'hFFFC);
        check_reads(4'd1, 4'd2, 16'd3, 16'hFFFC);

        // Both read ports can select the same register.
        check_reads(4'd2, 4'd2, 16'hFFFC, 16'hFFFC);

        // s0 must be writable; s15 must also work.
        write_register(1'b1, 4'd0, 16'd9);
        write_register(1'b1, 4'd15, 16'hABCD);
        check_reads(4'd0, 4'd15, 16'd9, 16'hABCD);

        // Reset must take priority over a simultaneous write.
        @(negedge clk);
        reset = 1;
        write_register(1'b1, 4'd1, 16'd99);

        @(negedge clk);
        reset = 0;

        for (i = 0; i < 16; i = i + 1) begin
            check_reads(i, i, 16'h0000, 16'h0000);
        end

        if (errors == 0)
            $display("ALL REGISTER FILE TESTS PASSED");
        else
            $display("REGISTER FILE TESTS FAILED: %0d errors", errors);

        $finish;
    end

endmodule