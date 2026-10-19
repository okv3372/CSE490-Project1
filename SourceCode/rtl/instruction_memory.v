// processors program
module instruction_memory (

    //takes 16 bit mem address for input and outputs the instruction
    input wire [15:0] address,
    output wire [15:0] instruction
);

    //64 entries, each is 8 bit, so 64 bytes of storage, 32 instructions
    reg [7:0] memory [0:63];

    integer i;

    // runs once, not a clocked operation and does not run on reset
    initial begin

        // give every byte a known init value
        for (i = 0; i < 64; i = i + 1) begin
            memory[i] = 8'h00;
        end

        //3 hardcoded r type instructions

        // instruction 16'h0210 at byte addresses 0 and 1 in memory
        // R[s2] = R[s1] + R[s2]
        memory[0] = 8'h02;
        memory[1] = 8'h10;

        // R[s2] = R[s1] - R[s2]
        memory[2] = 8'h02;
        memory[3] = 8'h11;

        //R[s2] = R[s2] << R[s1]
        memory[4] = 8'h02;
        memory[5] = 8'h12;

        // R[s2] = R[s1] & R[s2]
        memory[6] = 8'h02;
        memory[7] = 8'h13;

    end

    // keep reading 2 bytes and combine them
    // final valid starting address is 62 because we also need 63, starting at 63 would require missing 64
    assign instruction =
        (address <= 16'd62)
        // combines the 2 bytes to be 16 bit
        ? {memory[address], memory[address + 16'd1]}
        : 16'h0000;

endmodule