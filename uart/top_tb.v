`timescale 1ns/1ps
module top_tb;

reg         i_clk, i_start, i_reset;
reg [7:0]   sw;
wire        o_txd;

uart_top    top(
    .i_clk(i_clk),
    .i_start(i_start),
    .i_reset(i_reset),
    .sw(sw),
    .o_txd(o_txd)
);

initial begin
    i_clk = 0;
    i_reset = 1;
    sw = 0;
    #3 i_reset = 0;
    #3 i_reset = 1; i_start = 1;
end

always begin
    #1 i_clk = ~i_clk;
end

always  begin
    #10000 sw = sw + 1;
end

endmodule