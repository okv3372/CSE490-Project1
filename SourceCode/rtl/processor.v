// top-level processor to create componenets and connect them
//JUST R TYPE
module processor (
    input wire clk,
    input wire reset,

    output wire [15:0] pc,
    output wire [15:0] instruction
);

    wire [15:0] rs_value;
    wire [15:0] rt_value;

    wire [15:0] alu_result;

    wire [3:0] alu_operation;

    wire reg_write;

    // create program counter
    program_counter pc_unit (
        .clk(clk),
        .reset(reset),
        .pc(pc)
    );

    // PC selects which instruction
    instruction_memory imem_unit (
        .address(pc),
        .instruction(instruction)
    );

    // decode the instruction
    control_unit control_unit_instance (
        .opcode(instruction[15:12]),
        .function_code(instruction[3:0]),
        .alu_op(alu_operation),
        .reg_write(reg_write)
    );

    // read  source registers and provide destination for result
    register_file regfile_unit (
        .clk(clk),
        .reset(reset),

        .rs_addr(instruction[7:4]),

        .rt_addr(instruction[11:8]),

        .write_enable(reg_write),

        .write_addr(instruction[11:8]),

        .write_data(alu_result),

        .rs_data(rs_value),
        .rt_data(rt_value)
    );

    // perform the operation.
    alu alu_unit (
        .a(rs_value),
        .b(rt_value),
        .alu_op(alu_operation),
        .result(alu_result)
    );

endmodule