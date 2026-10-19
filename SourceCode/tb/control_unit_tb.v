`timescale 1ns/1ps

module control_unit_tb;

    reg [3:0] opcode;
    reg [3:0] function_code;

    wire [3:0] alu_op;
    wire reg_write;

    integer errors;

    control_unit dut (
        .opcode(opcode),
        .function_code(function_code),
        .alu_op(alu_op),
        .reg_write(reg_write)
    );

    task check_decode;

        input [3:0] test_opcode;
        input [3:0] test_function;

        input [3:0] expected_alu_op;
        input expected_reg_write;

        begin
            opcode = test_opcode;
            function_code = test_function;

            #1;

            if ((alu_op !== expected_alu_op) ||
                (reg_write !== expected_reg_write)) begin

                $display(
                    "FAIL: opcode=%b function=%b",
                    test_opcode, test_function
                );

                $display(
                    "  alu_op=%b expected=%b; reg_write=%b expected=%b",
                    alu_op, expected_alu_op,
                    reg_write, expected_reg_write
                );

                errors = errors + 1;

            end else begin

                $display(
                    "PASS: opcode=%b function=%b alu_op=%b reg_write=%b",
                    test_opcode, test_function, alu_op, reg_write
                );

            end
        end

    endtask

    // run all checks one time
    initial begin

        errors = 0;
        opcode = 4'b0000;
        function_code = 4'b0000;

        // ADD
        check_decode(4'b0000, 4'b0000, 4'b0000, 1'b1);

        // SUB
        check_decode(4'b0000, 4'b0001, 4'b0001, 1'b1);

        // SLL
        check_decode(4'b0000, 4'b0010, 4'b0010, 1'b1);

        // AND
        check_decode(4'b0000, 4'b0011, 4'b0011, 1'b1);

        // invalid
        check_decode(4'b0000, 4'b0100, 4'b0000, 1'b0);
        check_decode(4'b0000, 4'b1111, 4'b0000, 1'b0);

        //INVALID RIGHT NOW, need to implement
        // load-word opcode.
        check_decode(4'b0001, 4'b0000, 4'b0000, 1'b0);

        // store-word opcode.
        check_decode(4'b0010, 4'b0001, 4'b0000, 1'b0);

        // add-immediate opcode.
        check_decode(4'b0011, 4'b0010, 4'b0000, 1'b0);

        // jump opcode.
        check_decode(4'b0110, 4'b0011, 4'b0000, 1'b0);

        // valid operation should work after invalid ones
        check_decode(4'b0000, 4'b0001, 4'b0001, 1'b1);

        if (errors == 0)
            $display("ALL CONTROL UNIT TESTS PASSED");
        else
            $display("CONTROL UNIT TESTS FAILED: %0d errors", errors);

        $finish;

    end

endmodule