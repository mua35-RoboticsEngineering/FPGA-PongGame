// Username: mua35

module Ball
#(
    parameter BALL_SIZE   = 10,
    parameter INIT_X      = 400,
    parameter INIT_Y      = 300,
    parameter SCREEN_W    = 800,
    parameter SCREEN_H    = 600
)
(
    input  logic        Clock,
    input  logic        Reset,
    input  logic [10:0] pixelX,   // current VGA scan X
    input  logic [ 9:0] pixelY,   // current VGA scan Y
    // paddle edges for collision
    input  logic [10:0] p1Right,  // right edge of player 1 paddle
    input  logic [ 9:0] p1Top,
    input  logic [ 9:0] p1Bottom,
    input  logic [10:0] p2Left,   // left edge of player 2 paddle
    input  logic [ 9:0] p2Top,
    input  logic [ 9:0] p2Bottom,
    // scoring outputs
    output logic        p1Score,  // pulse when P1 scores (ball past right edge)
    output logic        p2Score,  // pulse when P2 scores (ball past left edge)
    output logic        draw_ball // 1 when current pixel is inside ball
);

    // Ball position (top-left corner)
    logic [10:0] ballX;
    logic [ 9:0] ballY;

    // Direction: 1 = positive (right/down), 0 = negative (left/up)
    logic xDir, yDir;

    // Slow clock counter - move ball every ~500k cycles (~100Hz at 50MHz)
    logic [19:0] clkDiv;
    logic        movePulse;

    always_ff @(posedge Clock) begin
        if (Reset) begin
            clkDiv <= 0;
        end else begin
            clkDiv <= clkDiv + 1;
        end
    end
    assign movePulse = (clkDiv == 20'd0);

    // Score pulses (single cycle)
    logic p1ScoreReg, p2ScoreReg;
    assign p1Score = p1ScoreReg;
    assign p2Score = p2ScoreReg;

    always_ff @(posedge Clock) begin
        if (Reset) begin
            ballX      <= INIT_X;
            ballY      <= INIT_Y;
            xDir       <= 1;
            yDir       <= 1;
            p1ScoreReg <= 0;
            p2ScoreReg <= 0;
        end else begin
            p1ScoreReg <= 0;
            p2ScoreReg <= 0;

            if (movePulse) begin
                // --- X movement ---
                if (xDir == 1) begin
                    // Moving right
                    if (ballX + BALL_SIZE >= SCREEN_W - 1) begin
                        // Hit right wall -> P1 scores, reset ball
                        p1ScoreReg <= 1;
                        ballX      <= INIT_X;
                        ballY      <= INIT_Y;
                        xDir       <= 0;
                    end else if ((ballX + BALL_SIZE >= p2Left) &&
                                 (ballY + BALL_SIZE >= p2Top)  &&
                                 (ballY             <= p2Bottom)) begin
                        // Hit P2 paddle
                        xDir <= 0;
                    end else begin
                        ballX <= ballX + 1;
                    end
                end else begin
                    // Moving left
                    if (ballX == 0) begin
                        // Hit left wall -> P2 scores, reset ball
                        p2ScoreReg <= 1;
                        ballX      <= INIT_X;
                        ballY      <= INIT_Y;
                        xDir       <= 1;
                    end else if ((ballX             <= p1Right) &&
                                 (ballY + BALL_SIZE >= p1Top)   &&
                                 (ballY             <= p1Bottom)) begin
                        // Hit P1 paddle
                        xDir <= 1;
                    end else begin
                        ballX <= ballX - 1;
                    end
                end

                // --- Y movement ---
                if (yDir == 1) begin
                    if (ballY + BALL_SIZE >= SCREEN_H - 1)
                        yDir <= 0;
                    else
                        ballY <= ballY + 1;
                end else begin
                    if (ballY == 0)
                        yDir <= 1;
                    else
                        ballY <= ballY - 1;
                end
            end
        end
    end

    // Draw ball: current pixel inside ball area
    assign draw_ball = (pixelX >= ballX) && (pixelX < ballX + BALL_SIZE) &&
                       (pixelY >= ballY) && (pixelY < ballY + BALL_SIZE);

endmodule
