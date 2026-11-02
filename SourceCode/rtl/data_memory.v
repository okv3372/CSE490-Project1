// data memory has 64 bytes, each 16 bit value takes 2 bytes
// high byte goes first, low byte goes at the next address
module data_memory (
    input wire clk,
    input wire enable,
    input wire read_enable,
    input wire write_enable,
    input wire [15:0] address,
    input wire [15:0] write_data,
    output wire [15:0] read_data,
    input wire [15:0] debug_address,
    output wire [15:0] debug_data
);
    reg [7:0] memory [0:63];
    integer i;

    // start with zeroes, pressing btnU does not clear this memory
    initial begin
        for (i = 0; i < 64; i = i + 1)
            memory[i] = 8'h00;
    end

    // reading combines the byte at this address with the next byte
    // 62 is the last starting address, since 63 needs byte 64 which is missing
    assign read_data = (read_enable && address <= 16'd62)
                     ? {memory[address], memory[address + 16'd1]} : 16'h0000;
    // lets the testbench read memory without doing a lw instruction
    assign debug_data = (debug_address <= 16'd62)
                      ? {memory[debug_address], memory[debug_address + 16'd1]} : 16'h0000;

    // sw writes both bytes when the cpu takes a step
    always @(posedge clk) begin
        if (enable && write_enable && address <= 16'd62) begin
            memory[address] <= write_data[15:8];
            memory[address + 16'd1] <= write_data[7:0];
        end
    end
endmodule
