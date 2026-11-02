// pc stores the address of the current instruction
module program_counter (
    input wire clk,
    input wire reset,
    input wire enable,
    input wire [15:0] next_pc,
    output reg [15:0] pc
);
    // reset goes to 0, otherwise a step updates the pc
    always @(posedge clk) begin
        if (reset)
            pc <= 16'd0;
        else if (enable)
            pc <= next_pc;
    end
endmodule
