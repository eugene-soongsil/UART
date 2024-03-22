module uart_top(
    input       i_clk,
    input       i_start,
    input       i_reset,
    input [7:0] sw,
    output      o_txd
);

wire            w_clk_tx;

uart_tx         tx(
    .i_clk(i_clk),
    .i_start(i_start),
    .i_reset(i_reset),
    .i_clk_tx(w_clk_tx),
    .sw(sw),
    .o_txd(o_txd)
);
tx_clk_div      tx_clk(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .o_clk_out(w_clk_tx)
);

endmodule
