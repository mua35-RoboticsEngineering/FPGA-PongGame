// Username: mua35

module Paddle
#(
    parameter PADDLE_W = 10,
    parameter PADDLE_H = 80,
    parameter INIT_Y   = 260,
    parameter SCREEN_H = 600,
    parameter PADDLE_X = 10,
    parameter ACTIVE_LOW = 1   // 1 = buttons (active low), 0 = switches (active high)
)
(
    input  logic        Clock,
    input  logic        Reset,
    input  logic        MoveUp,
    input  logic        MoveDown,
    input  logic [10:0] pixelX,
    input  logic [ 9:0] pixelY,
    output logic [10:0] paddleRight,
    output logic [ 9:0] paddleTop,
    output logic [ 9:0] paddleBottom,
    output logic        draw_paddle
);

    logic [ 9:0] posY;
    logic [19:0] clkDiv;
    logic        movePulse;

    // Normalise input: pressed = 1 regardless of active level
    logic up, down;
    assign up   = ACTIVE_LOW ? ~MoveUp   : MoveUp;
    assign down = ACTIVE_LOW ? ~MoveDown : MoveDown;

    always_ff @(posedge Clock) begin
        if (Reset) clkDiv <= 0;
        else       clkDiv <= clkDiv + 1;
    end
    assign movePulse = (clkDiv == 20'd0);

    always_ff @(posedge Clock) begin
        if (Reset) begin
            posY <= INIT_Y;
        end else if (movePulse) begin
            if (up && posY > 0)
                posY <= posY - 2;
            else if (down && (posY + PADDLE_H < SCREEN_H - 1))
                posY <= posY + 2;
        end
    end

    assign paddleRight  = PADDLE_X + PADDLE_W;
    assign paddleTop    = posY;
    assign paddleBottom = posY + PADDLE_H;

    assign draw_paddle = (pixelX >= PADDLE_X)             &&
                         (pixelX <  PADDLE_X + PADDLE_W)  &&
                         (pixelY >= posY)                  &&
                         (pixelY <  posY + PADDLE_H);

endmodule
