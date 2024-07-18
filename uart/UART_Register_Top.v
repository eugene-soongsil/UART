module UART_Register_Top(
    input               pClk,
    input               pReset,
    input               switch,
    input               button,
    input               pSel,
    input               pEnable,
    input               pWrite,
    input       [31:0]  pWdata,
    input       [31:0]  pAddr,
    input       [7:0]   RxD,
    output      [7:0]   TxD,
    output      [31:0]  pReadData
);

wire                w_button_edge, w_clk_div, w_RxDone;
wire    [7:0]       w_RxData, w_TxData;

UART_Register       UART_REG(
    .pClk(pClk),
    .pReset(pReset),
    .pSel(pSel),
    .pEnable(pEnable),
    .pWrite(pWrite),
    .pWdata(pWdata),
    .pAddr(pAddr),
    .RxDone(w_RxDone),
    .RxData(w_RxData),
    .TxData(w_TxData), //out
    .pReadData(pReadData)
);

UART_TX             UART_TX(
    .clk(pClk),
    .reset(pReset),
    .i_clk_tx(w_clk_div),
    .i_button_edge(w_button_edge),
    .i_switch(switch),
    .o_txd(TxD) //out
);

UART_RX             UART_RX(
    .clk(pClk),
    .reset(pReset),
    .i_clk_rx(w_clk_div),
    .i_rxd(RxD),
    .RxDone(w_RxDone), //out
    .o_rx_data(w_RxData)
);

clk_div             clk_gen(
    .clk(pClk),
    .reset(pReset),
    .o_clk_div(w_clk_div) //out
);

button_edge         edge_detector(
    .clk(pClk),
    .reset(pReset),
    .i_button(button),
    .o_button_edge(w_button_edge) //out
);

endmodule