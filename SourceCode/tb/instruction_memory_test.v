`timescale 1ns/1ps

module instruction_memory_tb;

    // address input to the instruction memory component, and instruction produced by the component
    reg [15:0] address;
    wire [15:0] instruction;

    integer errors;

    instruction_memory dut (
        .address(address),
        .instruction(instruction)
    );

    task check_instruction;

        // byte address we want to read
        input [15:0] test_address;

        input [15:0] expected;

        begin
            // apply the address
            address = test_address;

            #1;

            // check for wrong value
            if (instruction !== expected) begin

                $display(
                    "FAIL: address=%0d expected=%h got=%h",
                    test_address, expected, instruction
                );

                errors = errors + 1;

            end else begin

                $display(
                    "PASS: address=%0d instruction=%h",
                    test_address, instruction
                );

            end
        end

    endtask

    initial begin

        address = 16'd0;
        errors = 0;

        check_instruction(16'd0, 16'h0210);
        check_instruction(16'd2, 16'h0211);
        check_instruction(16'd4, 16'h0212);
        check_instruction(16'd6, 16'h0213);

        check_instruction(16'd8, 16'h0000);

        check_instruction(16'd62, 16'h0000);

        check_instruction(16'd63, 16'h0000);
        check_instruction(16'd64, 16'h0000);

        if (errors == 0)
            $display("ALL INSTRUCTION MEMORY TESTS PASSED");
        else
            $display(
                "INSTRUCTION MEMORY TESTS FAILED: %0d errors",
                errors
            );

        $finish;

    end

endmodule