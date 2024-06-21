module  UART_TX_TOP(
    input               clk,
    input               reset,
    input               i_button,
    input   [7:0]       i_switch,
    output              o_txd
);

wire                    w_clk_tx,
                        w_button_edge;

UART_TX         TX(
    .clk(clk),
    .reset(reset),
    .i_clk_tx(w_clk_tx),
    .i_button_edge(w_button_edge),
    .i_switch(i_switch),
    .o_txd(o_txd)
);

button_edge     inst_button(
    .clk(clk),
    .reset(reset),
    .i_button(i_button),
    .o_button_edge(w_button_edge)
);

clk_div         inst_clk_div(
    .clk(clk),
    .reset(reset),
    .o_clk_div(w_clk_tx)
);

endmodule