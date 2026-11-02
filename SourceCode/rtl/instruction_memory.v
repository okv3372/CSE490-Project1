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

        // hardcoded demo program, two bytes per instruction
        // first byte is the high half, last jump keeps the pc at address 36
        memory[0] = 8'h31; memory[1] = 8'h03;   // addi s1, s0, 3
        memory[2] = 8'h32; memory[3] = 8'h05;   // addi s2, s0, 5
        memory[4] = 8'h02; memory[5] = 8'h10;   // add  s2, s1 => 8
        memory[6] = 8'h02; memory[7] = 8'h11;   // sub  s2, s1 => -5
        memory[8] = 8'h33; memory[9] = 8'h0f;   // addi s3, s0, -1
        memory[10] = 8'h03; memory[11] = 8'h23; // and  s3, s2 => -5
        memory[12] = 8'h34; memory[13] = 8'h02; // addi s4, s0, 2
        memory[14] = 8'h01; memory[15] = 8'h42; // sll  s1, s4 => 12
        memory[16] = 8'h21; memory[17] = 8'h4e; // sw   s1, -2(s4), address 0
        memory[18] = 8'h15; memory[19] = 8'h4e; // lw   s5, -2(s4) => 12
        memory[20] = 8'h45; memory[21] = 8'h11; // beq  s5, s1, +1
        memory[22] = 8'h36; memory[23] = 8'h07; // skipped
        memory[24] = 8'h55; memory[25] = 8'h21; // bne  s5, s2, +1
        memory[26] = 8'h36; memory[27] = 8'h07; // skipped
        memory[28] = 8'h60; memory[29] = 8'h01; // jmp  +1
        memory[30] = 8'h36; memory[31] = 8'h07; // skipped
        memory[32] = 8'h37; memory[33] = 8'h08; // addi s7, s0, -8
        memory[34] = 8'h37; memory[35] = 8'h7f; // addi s7, s7, -1
        memory[36] = 8'h6f; memory[37] = 8'hff; // jmp -1 (self-loop)

    end

    // keep reading 2 bytes and combine them
    // final valid starting address is 62 because we also need 63, starting at 63 would require missing 64
    assign instruction =
        (address <= 16'd62)
        // combines the 2 bytes to be 16 bit
        ? {memory[address], memory[address + 16'd1]}
        : 16'h0000;

endmodule
