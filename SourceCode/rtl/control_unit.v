// decode instruction and produce control signals
//ONLY R TYPE
module control_unit (
    input wire [3:0] opcode,
    input wire [3:0] function_code,

    output reg [3:0] alu_op,

    output reg reg_write
);

    //reevaluate outputs whenever input changes
    always @(*) begin

        // default to ADD
        // result will not be saved unless reg_write becomes 1
        alu_op = 4'b0000;

        // disable writing unless theres a supported instruction
        reg_write = 1'b0;

        //check for R type
        if (opcode == 4'b0000) begin

            case (function_code)

                // ADD: R[rt/rd] = R[rs] + R[rt/rd]
                4'b0000: begin
                    alu_op = 4'b0000;
                    reg_write = 1'b1;
                end

                // SUB: R[rt/rd] = R[rs] - R[rt/rd]
                4'b0001: begin
                    alu_op = 4'b0001;
                    reg_write = 1'b1;
                end

                // SLL: R[rt/rd] = R[rt/rd] << R[rs]
                4'b0010: begin
                    alu_op = 4'b0010;
                    reg_write = 1'b1;
                end

                // AND: R[rt/rd] = R[rs] & R[rt/rd]
                4'b0011: begin
                    alu_op = 4'b0011;
                    reg_write = 1'b1;
                end

                // invalid r type
                // disable writing
                default: begin
                    alu_op = 4'b0000;
                    reg_write = 1'b0;
                end

            endcase

        end

        // need to add other types still

    end

endmodule