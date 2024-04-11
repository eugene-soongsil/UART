module uart_top(
    input       i_clk,
    //input       i_start,
    input       i_reset,
    input [7:0] sw,
    input       i_rxd,
    input       i_bo,
    output      o_txd,
    output [7:0]  o_data
);

wire            w_clk_tx;

uart_tx         tx(
    .i_clk(i_clk),
    //.i_start(i_start),
    .i_reset(i_reset),
    .i_clk_tx(w_clk_tx),
    .sw(sw),
    .i_bo(i_bo),
    .o_txd(o_txd)
);

uart_rx         rx(
    .i_clk(i_clk),
    .i_clk_rx(w_clk_tx),
    .i_reset(i_reset),
    .i_rxd(i_rxd),
    .o_data(o_data)
);

tx_clk_div      tx_clk(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .o_clk_out(w_clk_tx)
);

endmodule
