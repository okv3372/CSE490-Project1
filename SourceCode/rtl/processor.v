// top-level processor to create componenets and connect them
// each step runs one instruction
module processor (
    input wire clk,
    input wire reset,
    input wire step_enable,
    input wire [3:0] debug_reg_addr,
    input wire [15:0] debug_mem_addr,
    output wire [15:0] debug_reg_data,
    output wire [15:0] debug_mem_data,
    output wire [15:0] pc,
    output wire [15:0] instruction,
    output wire [15:0] alu_result_debug
);
    // values used while the instruction runs
    wire [15:0] rs_value;
    wire [15:0] rt_value;
    wire [15:0] immediate;
    wire [15:0] jump_immediate;
    wire [15:0] alu_b;
    wire [15:0] alu_result;
    wire [15:0] memory_result;
    wire [15:0] writeback_value;
    // places the pc could go next
    wire [15:0] pc_plus_two;
    wire [15:0] branch_target;
    wire [15:0] jump_target;
    wire [15:0] pc_after_branch;
    wire [15:0] next_pc;
    // signals telling the components what to do
    wire [3:0] alu_operation;
    wire reg_write;
    wire alu_src_imm;
    wire mem_read;
    wire mem_write;
    wire mem_to_reg;
    wire branch_eq;
    wire branch_ne;
    wire jump;
    wire equal_registers;
    wire take_branch;

    // instructions are 2 bytes, so normally move the pc by 2
    assign pc_plus_two = pc + 16'd2;
    // beq and bne compare the registers directly
    assign equal_registers = (rs_value == rt_value);
    assign take_branch = (branch_eq && equal_registers) ||
                         (branch_ne && !equal_registers);
    // offsets count instructions, so shift left 1 to convert to bytes
    assign branch_target = pc_plus_two + (immediate << 1);
    assign jump_target = pc_plus_two + (jump_immediate << 1);
    assign alu_result_debug = alu_result;

    // create program counter
    program_counter pc_unit (
        .clk(clk), .reset(reset), .enable(step_enable),
        .next_pc(next_pc), .pc(pc)
    );

    // PC selects which instruction
    instruction_memory imem_unit (
        .address(pc), .instruction(instruction)
    );

    // decode the instruction
    control_unit control_unit_instance (
        .opcode(instruction[15:12]),
        .function_code(instruction[3:0]),
        .alu_op(alu_operation),
        .reg_write(reg_write),
        .alu_src_imm(alu_src_imm),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch_eq(branch_eq),
        .branch_ne(branch_ne),
        .jump(jump)
    );

    // make the immediate 16 bits so negative numbers still work
    sign_extension #(.INPUT_WIDTH(4)) imm_extend (
        .value(instruction[3:0]), .extended(immediate)
    );
    sign_extension #(.INPUT_WIDTH(12)) jump_extend (
        .value(instruction[11:0]), .extended(jump_immediate)
    );

    // read  source registers and provide destination for result
    register_file regfile_unit (
        .clk(clk), .reset(reset), .enable(step_enable),
        .rs_addr(instruction[7:4]),
        .rt_addr(instruction[11:8]),
        .write_enable(reg_write),
        .write_addr(instruction[11:8]),
        .write_data(writeback_value),
        .rs_data(rs_value), .rt_data(rt_value),
        .debug_addr(debug_reg_addr), .debug_data(debug_reg_data)
    );

    // choose register value or immediate for the ALU
    mux_2to1 alu_source_mux (
        .a(rt_value), .b(immediate),
        .select(alu_src_imm), .y(alu_b)
    );
    // perform the operation.
    alu alu_unit (
        .a(rs_value), .b(alu_b),
        .alu_op(alu_operation), .result(alu_result)
    );

    // lw and sw use the ALU result as the memory address
    data_memory dmem_unit (
        .clk(clk), .enable(step_enable),
        .read_enable(mem_read), .write_enable(mem_write),
        .address(alu_result), .write_data(rt_value),
        .read_data(memory_result),
        .debug_address(debug_mem_addr), .debug_data(debug_mem_data)
    );

    // lw writes the memory value, other instructions write the ALU result
    mux_2to1 writeback_mux (
        .a(alu_result), .b(memory_result),
        .select(mem_to_reg), .y(writeback_value)
    );
    // choose the normal next pc, a branch, or a jump
    mux_2to1 branch_pc_mux (
        .a(pc_plus_two), .b(branch_target),
        .select(take_branch), .y(pc_after_branch)
    );
    mux_2to1 jump_pc_mux (
        .a(pc_after_branch), .b(jump_target),
        .select(jump), .y(next_pc)
    );
endmodule
