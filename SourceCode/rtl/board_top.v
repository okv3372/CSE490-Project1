// board_top connects the processor to the basys 3 board
// based on the board_top example from piazza
module board_top (
    input wire clk, // 100 MHz clock on the board
    input wire btnC, // center button runs one instruction
    input wire btnU, // up button resets pc and registers
    input wire [0:0] sw, // sw0 chooses what the leds show
    output wire [15:0] led, // leds above the switches
    output wire [3:0] an, // chooses one of the four display digits
    output wire [6:0] seg // chooses which parts of that digit light up
);
    wire [15:0] cpu_pc;
    wire [15:0] cpu_inst;
    wire [15:0] cpu_alu;
    wire step_enable;

    // use the board clock for the processor, step_enable lets it run only
    // when the center button is pressed
    processor my_cpu (
        .clk(clk), .reset(btnU), .step_enable(step_enable),
        .debug_reg_addr(4'd0), .debug_mem_addr(16'd0),
        .debug_reg_data(), .debug_mem_data(),
        .pc(cpu_pc), .instruction(cpu_inst),
        .alu_result_debug(cpu_alu)
    );

    // sw0 up shows the pc, down shows the alu result
    assign led = sw[0] ? cpu_pc : cpu_alu;

    // the button can bounce when pressed and make more than one pulse
    // first sync it to the clock, then wait until it stays steady
    reg btn_sync_0;
    reg btn_sync_1;
    reg [15:0] debounce_counter;
    reg btn_state;
    reg btn_prev;
    always @(posedge clk) begin
        if (btnU) begin
            btn_sync_0 <= 1'b0;
            btn_sync_1 <= 1'b0;
            debounce_counter <= 16'd0;
            btn_state <= 1'b0;
            btn_prev <= 1'b0;
        end else begin
            btn_sync_0 <= btnC;
            btn_sync_1 <= btn_sync_0;
            btn_prev <= btn_state;
            if (btn_sync_1 == btn_state)
                debounce_counter <= 16'd0;
            else if (debounce_counter == 16'hffff) begin
                debounce_counter <= 16'd0;
                btn_state <= btn_sync_1;
            end else
                debounce_counter <= debounce_counter + 16'd1;
        end
    end
    // one pulse when the press is accepted, so the pc only moves once
    assign step_enable = btn_state && !btn_prev;

    // light one digit at a time very quickly so all four look lit
    // the display shows the instruction at the current pc
    reg [19:0] refresh_counter = 20'd0;
    wire [1:0] digit_sel = refresh_counter[19:18];
    reg [3:0] hex_digit;
    always @(posedge clk)
        refresh_counter <= refresh_counter + 20'd1;

    always @(*) begin
        case (digit_sel)
            2'b00: hex_digit = cpu_inst[3:0];   // right digit
            2'b01: hex_digit = cpu_inst[7:4];
            2'b10: hex_digit = cpu_inst[11:8];
            2'b11: hex_digit = cpu_inst[15:12]; // left digit
        endcase
    end

    assign an = (digit_sel == 2'b00) ? 4'b1110 :
                (digit_sel == 2'b01) ? 4'b1101 :
                (digit_sel == 2'b10) ? 4'b1011 : 4'b0111;

    // change one hex digit into the pattern for the display
    // a 0 turns a segment on for this board
    reg [6:0] seg_out;
    always @(*) begin
        case (hex_digit)
            4'h0: seg_out = 7'b1000000;
            4'h1: seg_out = 7'b1111001;
            4'h2: seg_out = 7'b0100100;
            4'h3: seg_out = 7'b0110000;
            4'h4: seg_out = 7'b0011001;
            4'h5: seg_out = 7'b0010010;
            4'h6: seg_out = 7'b0000010;
            4'h7: seg_out = 7'b1111000;
            4'h8: seg_out = 7'b0000000;
            4'h9: seg_out = 7'b0010000;
            4'hA: seg_out = 7'b0001000;
            4'hB: seg_out = 7'b0000011;
            4'hC: seg_out = 7'b1000110;
            4'hD: seg_out = 7'b0100001;
            4'hE: seg_out = 7'b0000110;
            4'hF: seg_out = 7'b0001110;
            default: seg_out = 7'b1111111;
        endcase
    end
    assign seg = seg_out;
endmodule
