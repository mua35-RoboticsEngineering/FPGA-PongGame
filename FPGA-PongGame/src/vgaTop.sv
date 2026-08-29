// Username: mua35

module vgaTop
(
    input  logic        CLOCK_50,
    input  logic [ 3:0] KEY,    // active LOW: KEY[0]=P1up, KEY[1]=P1down, KEY[2]=P2up, KEY[3]=P2down
    input  logic [ 9:0] SW,     // SW[9]=reset (active HIGH)

    // VGA outputs
    output logic        VGA_HS,
    output logic        VGA_VS,
    output logic        VGA_BLANK_N,
    output logic        VGA_SYNC_N,
    output logic        VGA_CLK,
    output logic [ 7:0] VGA_R,
    output logic [ 7:0] VGA_G,
    output logic [ 7:0] VGA_B,

    // 7-segment displays (active low segments)
    output logic [ 6:0] HEX0,   // P1 score units
    output logic [ 6:0] HEX1,   // P1 score tens
    output logic [ 6:0] HEX4,   // P2 score units
    output logic [ 6:0] HEX5    // P2 score tens
);

    // ----------------------------------------------------------------
    // Internal signals
    // ----------------------------------------------------------------
    logic        blank_n, sync_n, hSync_n, vSync_n;
    logic [10:0] nextX;
    logic [ 9:0] nextY;

    logic        draw_ball, draw_p1, draw_p2;

    logic [10:0] p1Right, p2Left;
    logic [ 9:0] p1Top, p1Bottom;
    logic [ 9:0] p2Top, p2Bottom;

    logic        p1ScorePulse, p2ScorePulse;
    logic [ 6:0] p1Score, p2Score;

    // SW[9] active high = reset
    logic reset;
    assign reset   = SW[9];
    assign VGA_CLK = CLOCK_50;

    // ----------------------------------------------------------------
    // VGA Controller
    // ----------------------------------------------------------------
    VgaController vga_inst (
        .Clock   (CLOCK_50),
        .Reset   (reset),
        .blank_n (blank_n),
        .sync_n  (sync_n),
        .hSync_n (hSync_n),
        .vSync_n (vSync_n),
        .nextX   (nextX),
        .nextY   (nextY)
    );

    assign VGA_HS      = hSync_n;
    assign VGA_VS      = vSync_n;
    assign VGA_BLANK_N = blank_n;
    assign VGA_SYNC_N  = sync_n;

    // ----------------------------------------------------------------
    // Player 1 Paddle (left, X=10) — KEY[0]=up, KEY[1]=down (active low)
    // ----------------------------------------------------------------
    Paddle #(
        .PADDLE_X   (10),
        .INIT_Y     (260),
        .ACTIVE_LOW (1)
    ) p1_inst (
        .Clock        (CLOCK_50),
        .Reset        (reset),
        .MoveUp       (KEY[0]),
        .MoveDown     (KEY[1]),
        .pixelX       (nextX),
        .pixelY       (nextY),
        .paddleRight  (p1Right),
        .paddleTop    (p1Top),
        .paddleBottom (p1Bottom),
        .draw_paddle  (draw_p1)
    );

    // ----------------------------------------------------------------
    // Player 2 Paddle (right, X=780) — KEY[2]=up, KEY[3]=down (active low)
    // ----------------------------------------------------------------
    Paddle #(
        .PADDLE_X   (780),
        .INIT_Y     (260),
        .ACTIVE_LOW (1)
    ) p2_inst (
        .Clock        (CLOCK_50),
        .Reset        (reset),
        .MoveUp       (KEY[2]),
        .MoveDown     (KEY[3]),
        .pixelX       (nextX),
        .pixelY       (nextY),
        .paddleRight  (),
        .paddleTop    (p2Top),
        .paddleBottom (p2Bottom),
        .draw_paddle  (draw_p2)
    );
    assign p2Left = 11'd780;

    // ----------------------------------------------------------------
    // Ball
    // ----------------------------------------------------------------
    Ball #(
        .INIT_X (400),
        .INIT_Y (300)
    ) ball_inst (
        .Clock      (CLOCK_50),
        .Reset      (reset),
        .pixelX     (nextX),
        .pixelY     (nextY),
        .p1Right    (p1Right),
        .p1Top      (p1Top),
        .p1Bottom   (p1Bottom),
        .p2Left     (p2Left),
        .p2Top      (p2Top),
        .p2Bottom   (p2Bottom),
        .p1Score    (p1ScorePulse),
        .p2Score    (p2ScorePulse),
        .draw_ball  (draw_ball)
    );

    // ----------------------------------------------------------------
    // Score counters (max 99)
    // ----------------------------------------------------------------
    always_ff @(posedge CLOCK_50) begin
        if (reset) begin
            p1Score <= 0;
            p2Score <= 0;
        end else begin
            if (p1ScorePulse && p1Score < 7'd99) p1Score <= p1Score + 1;
            if (p2ScorePulse && p2Score < 7'd99) p2Score <= p2Score + 1;
        end
    end

    // ----------------------------------------------------------------
    // 7-segment decoder (active low)
    // ----------------------------------------------------------------
    function automatic logic [6:0] seg7(input logic [3:0] digit);
        case (digit)
            4'd0: seg7 = 7'b1000000;
            4'd1: seg7 = 7'b1111001;
            4'd2: seg7 = 7'b0100100;
            4'd3: seg7 = 7'b0110000;
            4'd4: seg7 = 7'b0011001;
            4'd5: seg7 = 7'b0010010;
            4'd6: seg7 = 7'b0000010;
            4'd7: seg7 = 7'b1111000;
            4'd8: seg7 = 7'b0000000;
            4'd9: seg7 = 7'b0010000;
            default: seg7 = 7'b1111111;
        endcase
    endfunction

    assign HEX0 = seg7(p1Score % 10);
    assign HEX1 = seg7(p1Score / 10);
    assign HEX4 = seg7(p2Score % 10);
    assign HEX5 = seg7(p2Score / 10);

    // ----------------------------------------------------------------
    // Pixel colour generation
    // ----------------------------------------------------------------
    always_ff @(posedge CLOCK_50) begin
        if (draw_ball || draw_p1 || draw_p2) begin
            VGA_R <= 8'hFF;
            VGA_G <= 8'hFF;
            VGA_B <= 8'hFF;
        end else begin
            VGA_R <= 8'h00;
            VGA_G <= 8'h00;
            VGA_B <= 8'h00;
        end
    end

endmodule
