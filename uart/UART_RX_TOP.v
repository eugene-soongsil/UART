module  UART_RX_TOP(
    input               clk,
    input               reset,
    input               i_rxd,
    output [7:0]        o_rx_data
);

wire                    w_clk_rx;

UART_RX         RX(
    .clk(clk),
    .reset(reset),
    .i_clk_rx(w_clk_rx),
    .i_rxd(i_rxd),
    .o_rx_data(o_rx_data)
);

clk_div         inst_clk_div(
    .clk(clk),
    .reset(reset),
    .o_clk_div(w_clk_rx)
);

endmodule