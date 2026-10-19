// register file hardware component
// the register file has 16 registers, each 16 bits wide
module register_file (
    //clock signal, regs update on rising edge
    input wire clk,
    // when high on rising edge, clear regs
    input wire reset,

    //four bit addresses selecting the registers for rs and rt
    input wire [3:0] rs_addr,
    input wire [3:0] rt_addr,

    // allow reg to write, address is the reg that receieves the data and the data is the value to store
    input wire write_enable,
    input wire [3:0] write_addr,
    input wire [15:0] write_data,

    // current val stored in regs
    output wire [15:0] rs_data,
    output wire [15:0] rt_data
);
    // array w the 16 regs, each 16 bits wide, 16 of them
    reg [15:0] registers [0:15];

    integer i;

    assign rs_data = registers[rs_addr];
    assign rt_data = registers[rt_addr];

    //the writing happens here, if reset is high clear the regs, otherwise if write_enable is high write the data to the register in write_addr
    always @(posedge clk) begin
        //reset has priority over writing
        if (reset) begin
            for (i = 0; i < 16; i = i + 1) begin
                registers[i] <= 16'h0000;
            end
        end else if (write_enable) begin
            registers[write_addr] <= write_data;
        end
    end

endmodule