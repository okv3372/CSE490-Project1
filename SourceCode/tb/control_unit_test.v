`timescale 1ns/1ps
module control_unit_tb;
    reg [3:0] opcode;
    reg [3:0] function_code;
    wire [3:0] alu_op;
    wire reg_write, alu_src_imm, mem_read, mem_write, mem_to_reg;
    wire branch_eq, branch_ne, jump;
    wire [11:0] controls;
    integer errors = 0;

    assign controls = {alu_op, reg_write, alu_src_imm, mem_read,
                       mem_write, mem_to_reg, branch_eq, branch_ne, jump};
    control_unit dut (
        .opcode(opcode), .function_code(function_code), .alu_op(alu_op),
        .reg_write(reg_write), .alu_src_imm(alu_src_imm),
        .mem_read(mem_read), .mem_write(mem_write), .mem_to_reg(mem_to_reg),
        .branch_eq(branch_eq), .branch_ne(branch_ne), .jump(jump)
    );

    task check_decode;
        input [3:0] op;
        input [3:0] fn;
        input [11:0] expected;
        begin
            opcode = op;
            function_code = fn;
            #1;
            if (controls !== expected) begin
                $display("FAIL decode op=%h fn=%h got=%h expected=%h",
                         op, fn, controls, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        check_decode(4'h0, 4'h0, 12'h080); // add
        check_decode(4'h0, 4'h1, 12'h180); // sub
        check_decode(4'h0, 4'h2, 12'h280); // sll
        check_decode(4'h0, 4'h3, 12'h380); // and
        check_decode(4'h0, 4'h4, 12'h000); // invalid function
        check_decode(4'h1, 4'h0, 12'h0e8); // lw
        check_decode(4'h2, 4'h0, 12'h050); // sw
        check_decode(4'h3, 4'h0, 12'h0c0); // addi
        check_decode(4'h4, 4'h0, 12'h004); // beq
        check_decode(4'h5, 4'h0, 12'h002); // bne
        check_decode(4'h6, 4'h0, 12'h001); // jmp
        check_decode(4'h7, 4'h0, 12'h000); // invalid opcode
        if (errors != 0) $fatal(1, "%0d control-unit checks failed", errors);
        $display("ALL CONTROL UNIT TESTS PASSED");
        $finish;
    end
endmodule
