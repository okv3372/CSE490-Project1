`timescale 1ns/1ps

module alu_tb;

    reg [15:0] a;
    reg [15:0] b;
    reg [3:0] alu_op;
    wire [15:0] result;

    integer errors;

    //device under test https://chipverify.com/verilog/verilog-testbench
    alu dut (
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .result(result)
    );

    task check;
        input [3:0] operation;
        input [15:0] value_a;
        input [15:0] value_b;
        input [15:0] expected;

        begin
            alu_op = operation;
            a = value_a;
            b = value_b;

            #1;

            if (result !== expected) begin
                $display(
                    "FAIL: op=%b a=%h b=%h expected=%h got=%h",
                    operation, value_a, value_b, expected, result
                );
                errors = errors + 1;
            end else begin
                $display(
                    "PASS: op=%b a=%h b=%h result=%h",
                    operation, value_a, value_b, result
                );
            end
        end
    endtask

    initial begin
        errors = 0;

        // ADD: 7 + 3 = 10
        check(4'b0000, 16'd7, 16'd3, 16'd10);

        // ADD: the output keeps only 16 bits
        check(4'b0000, 16'hFFFF, 16'd1, 16'h0000);

        // SUB: 7 - 3 = 4
        check(4'b0001, 16'd7, 16'd3, 16'd4);

        // SUB: 3 - 7 = -4
        check(4'b0001, 16'd3, 16'd7, 16'hFFFC);

        // SLL: shift b left by a bits
        check(4'b0010, 16'd4, 16'h005A, 16'h05A0);

        // SLL: shifting all 16 bits out gives zero
        check(4'b0010, 16'd16, 16'hFFFF, 16'h0000);

        // AND: keep bits that are 1 in both operands
        check(4'b0011, 16'hF0F0, 16'h0FF0, 16'h00F0);

        if (errors == 0)
            $display("ALL ALU TESTS PASSED");
        else
            $display("ALU TESTS FAILED: %0d errors", errors);

        $finish;
    end

endmodule