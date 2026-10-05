module program_counter (
    input wire clk,
    input wire reset,
    output reg [15:0] pc
);
    always @(posedge clk) begin
        if (reset)
            pc <= 16'd0;
        else
            pc <= pc + 16'd2;
    end
endmodule