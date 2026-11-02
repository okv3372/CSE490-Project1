`timescale 1ns/1ps
module processor_tb;
    reg clk = 0;
    reg reset = 1;
    reg step_enable = 0;
    reg [3:0] debug_reg_addr = 0;
    reg [15:0] debug_mem_addr = 0;
    wire [15:0] debug_reg_data;
    wire [15:0] debug_mem_data;
    wire [15:0] pc;
    wire [15:0] instruction;
    integer errors = 0;

    // create processor.
    processor dut (
        .clk(clk), .reset(reset), .step_enable(step_enable),
        .debug_reg_addr(debug_reg_addr), .debug_mem_addr(debug_mem_addr),
        .debug_reg_data(debug_reg_data), .debug_mem_data(debug_mem_data),
        .pc(pc), .instruction(instruction)
    );
    always #5 clk = ~clk;

    task check_step;
        input [15:0] expected_pc;
        input [3:0] reg_addr;
        input [15:0] expected_reg;
        begin
            debug_reg_addr = reg_addr;
            @(posedge clk); #1;
            if (pc !== expected_pc || debug_reg_data !== expected_reg) begin
                $display("FAIL PC=%h expected=%h; s%0d=%h expected=%h",
                         pc, expected_pc, reg_addr, debug_reg_data, expected_reg);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 0;
        // pc should stay at 0 until step_enable is on
        @(posedge clk); #1;
        if (pc !== 16'd0) $fatal(1, "CPU advanced without step_enable");
        @(negedge clk);
        step_enable = 1;

        check_step(16'd2, 4'd1, 16'd3);       // addi
        check_step(16'd4, 4'd2, 16'd5);       // addi
        check_step(16'd6, 4'd2, 16'd8);       // add
        check_step(16'd8, 4'd2, 16'hfffb);   // sub
        check_step(16'd10, 4'd3, 16'hffff);  // negative addi
        check_step(16'd12, 4'd3, 16'hfffb);  // and
        check_step(16'd14, 4'd4, 16'd2);     // addi
        check_step(16'd16, 4'd1, 16'd12);    // sll
        check_step(16'd18, 4'd1, 16'd12);    // sw with negative offset
        if (debug_mem_data !== 16'd12 ||
            dut.dmem_unit.memory[0] !== 8'h00 ||
            dut.dmem_unit.memory[1] !== 8'h0c)
            $fatal(1, "Big-endian store or debug memory read failed");
        check_step(16'd20, 4'd5, 16'd12);    // lw with negative offset
        check_step(16'd24, 4'd6, 16'd0);     // beq taken, skip s6 write
        check_step(16'd28, 4'd6, 16'd0);     // bne taken, skip s6 write
        check_step(16'd32, 4'd6, 16'd0);     // jmp, skip s6 write
        check_step(16'd34, 4'd7, 16'hfff8); // addi -8
        check_step(16'd36, 4'd7, 16'hfff7); // addi -1
        check_step(16'd36, 4'd7, 16'hfff7); // signed jmp -1

        // change the rom for this test to try branches that are not taken
        // and a negative offset, this does not change the board program
        @(negedge clk);
        reset = 1;
        step_enable = 0;
        dut.imem_unit.memory[0] = 8'h31; dut.imem_unit.memory[1] = 8'h01;
        dut.imem_unit.memory[2] = 8'h32; dut.imem_unit.memory[3] = 8'h02;
        dut.imem_unit.memory[4] = 8'h41; dut.imem_unit.memory[5] = 8'h21;
        dut.imem_unit.memory[6] = 8'h51; dut.imem_unit.memory[7] = 8'h11;
        dut.imem_unit.memory[8] = 8'h41; dut.imem_unit.memory[9] = 8'h11;
        dut.imem_unit.memory[10] = 8'h33; dut.imem_unit.memory[11] = 8'h07;
        dut.imem_unit.memory[12] = 8'h51; dut.imem_unit.memory[13] = 8'h2e;
        @(posedge clk); #1;
        @(negedge clk);
        reset = 0;
        step_enable = 1;
        check_step(16'd2, 4'd1, 16'd1);
        check_step(16'd4, 4'd2, 16'd2);
        check_step(16'd6, 4'd3, 16'd0);  // beq not taken
        check_step(16'd8, 4'd3, 16'd0);  // bne not taken
        check_step(16'd12, 4'd3, 16'd0); // beq taken
        check_step(16'd10, 4'd3, 16'd0); // bne -2
        check_step(16'd12, 4'd3, 16'd7);

        if (errors != 0) $fatal(1, "%0d processor checks failed", errors);
        $display("ALL PROCESSOR TESTS PASSED");
        $finish;
    end
endmodule
