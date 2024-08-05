module UART_board(
    input               clk,
    input               reset,
    input               button,
    input               RxD,
    output              TxD
);

wire                    w_clk_div, w_button_edge;
wire    [7:0]           i_switch;

UART_TX             Tx(
    .clk(clk),
    .reset(reset),
    .i_clk_tx(w_clk_div),
    .i_button_edge(w_button_edge),
    .i_switch(i_switch),
    .o_txd(TxD) //out
);

UART_RX             Rx(
    .clk(clk),
    .reset(reset),
    .i_clk_rx(w_clk_div),
    .i_rxd(RxD),
    .RxDone(), //out
    .o_rx_data(i_switch)
);

clk_div             clk_gen(
    .clk(clk),
    .reset(reset),
    .o_clk_div(w_clk_div) //out
);

button_edge         edge_detector(
    .clk(clk),
    .reset(reset),
    .i_button(button),
    .o_button_edge(w_button_edge) //out
);

endmodule