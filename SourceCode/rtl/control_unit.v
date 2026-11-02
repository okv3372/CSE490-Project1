// decode instruction and produce control signals
// r type also uses the function code
module control_unit (
    input wire [3:0] opcode,
    input wire [3:0] function_code,
    output reg [3:0] alu_op,
    output reg reg_write,
    output reg alu_src_imm,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg branch_eq,
    output reg branch_ne,
    output reg jump
);
    //reevaluate outputs whenever input changes
    always @(*) begin
        // default to ADD
        // result will not be saved unless reg_write becomes 1
        alu_op = 4'b0000;
        // disable writing unless theres a supported instruction
        reg_write = 1'b0;
        alu_src_imm = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        mem_to_reg = 1'b0;
        branch_eq = 1'b0;
        branch_ne = 1'b0;
        jump = 1'b0;

        case (opcode)
            4'b0000: begin //check for R type
                case (function_code)
                    // ADD: R[rt/rd] = R[rs] + R[rt/rd]
                    4'b0000: begin alu_op = 4'b0000; reg_write = 1'b1; end
                    // SUB: R[rt/rd] = R[rs] - R[rt/rd]
                    4'b0001: begin alu_op = 4'b0001; reg_write = 1'b1; end
                    // SLL: R[rt/rd] = R[rt/rd] << R[rs]
                    4'b0010: begin alu_op = 4'b0010; reg_write = 1'b1; end
                    // AND: R[rt/rd] = R[rs] & R[rt/rd]
                    4'b0011: begin alu_op = 4'b0011; reg_write = 1'b1; end
                    default: begin end
                endcase
            end
            4'b0001: begin // lw reads memory at rs + offset and puts the value in rt
                alu_src_imm = 1'b1;
                mem_read = 1'b1;
                mem_to_reg = 1'b1;
                reg_write = 1'b1;
            end
            4'b0010: begin // sw writes rt to memory at rs + offset
                alu_src_imm = 1'b1;
                mem_write = 1'b1;
            end
            4'b0011: begin // addi puts rs + signed immediate in rt
                alu_src_imm = 1'b1;
                reg_write = 1'b1;
            end
            4'b0100: branch_eq = 1'b1; // beq branches if the registers match
            4'b0101: branch_ne = 1'b1; // bne branches if they don't match
            4'b0110: jump = 1'b1;      // jmp uses the jump address
            default: begin end
        endcase
    end
endmodule
