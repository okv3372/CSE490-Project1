`timescale 1ns/1ps
module instruction_memory_tb;
    reg [15:0] address;
    wire [15:0] instruction;
    integer errors = 0;
    instruction_memory dut (.address(address), .instruction(instruction));

    task check_word;
        input [15:0] addr;
        input [15:0] expected;
        begin
            address = addr;
            #1;
            if (instruction !== expected) begin
                $display("FAIL imem[%0d]=%h expected=%h", addr, instruction, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        check_word(16'd0, 16'h3103);
        check_word(16'd2, 16'h3205);
        check_word(16'd20, 16'h4511);
        check_word(16'd36, 16'h6fff);
        check_word(16'd38, 16'h0000);
        check_word(16'd62, 16'h0000);
        check_word(16'd63, 16'h0000);
        check_word(16'd64, 16'h0000);
        if (errors != 0) $fatal(1, "%0d instruction memory checks failed", errors);
        $display("ALL INSTRUCTION MEMORY TESTS PASSED");
        $finish;
    end
endmodule
