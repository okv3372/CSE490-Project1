// a muxer with a choice between two buses: select=0 chooses a, select=1 chooses b.
// simple and made to be reused
module mux_2to1 #(parameter WIDTH = 16) (
    input wire [WIDTH-1:0] a,
    input wire [WIDTH-1:0] b,
    input wire select,
    output wire [WIDTH-1:0] y
);
    assign y = select ? b : a;
endmodule
