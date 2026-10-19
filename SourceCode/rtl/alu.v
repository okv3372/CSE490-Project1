//alu hardware component
// a and b are the two 16 bit inputs, for r type you connect a to R[rs] and b to R[rt/rd], the alu_op is 4 bit signal selecting the operation
//result is output
// r type is opcode 4 bit, rt/rd 4 bit, rs 4 bit func 4 bit for 16 bits
module alu (
    input wire [15:0] a,
    input wire [15:0] b,
    input wire [3:0] alu_op,
    output reg [15:0] result
);

    //check when something changes and choose what operation needs to be done
    always @(*) begin
        case (alu_op)
            4'b0000: result = a + b;
            4'b0001: result = a - b;
            4'b0010: result = b << a;
            4'b0011: result = a & b;
            default: result = 16'h0000;
        endcase
    end

endmodule