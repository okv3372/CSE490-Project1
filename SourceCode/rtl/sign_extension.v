// make the immediate 16 bits while keeping its sign
// for example F is -1 and becomes FFFF
module sign_extension #(parameter INPUT_WIDTH = 4) (
    input wire [INPUT_WIDTH-1:0] value,
    output wire [15:0] extended
);
    assign extended = {{(16-INPUT_WIDTH){value[INPUT_WIDTH-1]}}, value};
endmodule
