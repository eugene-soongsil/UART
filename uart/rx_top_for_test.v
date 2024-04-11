module rx_top_for_test(
    input i_clk,
    input i_reset,
    input i_rxd,
    output  [7:0] o_data
);

wire i_clk_rx;

uart_rx inst_test(
    .i_clk(i_clk),
    .i_clk_rx(i_clk_rx),
    .i_reset(i_reset),
    .i_rxd(i_rxd),
    .o_data(o_data)
);

tx_clk_div      tx_clk(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .o_clk_out(i_clk_rx)
);

endmodule