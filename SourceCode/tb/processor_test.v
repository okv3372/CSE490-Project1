`timescale 1ns/1ps

module processor_tb;

    reg clk;
    reg reset;

    wire [15:0] pc;
    wire [15:0] instruction;

    integer errors;

    // create processor.
    processor dut (
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .instruction(instruction)
    );

    always #5 clk = ~clk;

    task check_step;

        input [15:0] expected_pc;

        input [15:0] expected_s2;

        begin
            @(posedge clk);

            #1;

            // check PC advanced correctly
            // s2 received the expected result
            // s1 remained unchanged
            if ((pc !== expected_pc) ||
                (dut.regfile_unit.registers[2] !== expected_s2) ||
                (dut.regfile_unit.registers[1] !== 16'd3)) begin

                $display(
                    "FAIL: PC=%0d expected=%0d",
                    pc, expected_pc
                );

                $display(
                    "  s2=%h expected=%h; s1=%h expected=0003",
                    dut.regfile_unit.registers[2],
                    expected_s2,
                    dut.regfile_unit.registers[1]
                );

                errors = errors + 1;

            end else begin

                $display(
                    "PASS: PC=%0d s2=%h",
                    pc, dut.regfile_unit.registers[2]
                );

            end
        end

    endtask

    initial begin

        clk = 0;
        reset = 1;
        errors = 0;

        repeat (2) @(posedge clk);

        @(negedge clk);
        reset = 0;

        dut.regfile_unit.registers[1] = 16'd3;
        dut.regfile_unit.registers[2] = 16'd5;

        check_step(16'd2, 16'h0008);

        check_step(16'd4, 16'hFFFB);

        check_step(16'd6, 16'hFFD8);

        check_step(16'd8, 16'h0000);

        if (errors == 0)
            $display("ALL PROCESSOR TESTS PASSED");
        else
            $display("PROCESSOR TESTS FAILED: %0d errors", errors);

        $finish;

    end

endmodule