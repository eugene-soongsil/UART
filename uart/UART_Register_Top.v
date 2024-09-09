module UART_Register_Top(
    input               pClk,
    input               pReset,
    //input               button,
    input               pSel,
    input               pEnable,
    input               pWrite,
    input       [31:0]  pWdata,
    input       [31:0]  pAddr,
    input               RxD,
    output              TxD,
    output              IRQ,
    output      [31:0]  pReadData
);

wire                w_TxStart, w_clk_tx, w_clk_rx, w_RxDone, w_RxStopBit, w_TxDone;
wire    [7:0]       w_RxData, w_TxData;

UART_Register       UART_REG(
    .pClk(pClk),
    .pReset(pReset),
    .pSel(pSel),
    .pEnable(pEnable),
    .pWrite(pWrite),
    .pWdata(pWdata),
    .pAddr(pAddr),
    .TxDone(w_TxDone),
    .RxStopBit(w_RxStopBit),
    .RxDone(w_RxDone),
    .RxData(w_RxData),
    .TxData(w_TxData), //out
    .TxStart(w_TxStart),
    .IRQ(IRQ),
    .pReadData(pReadData)
);

UART_TX             UART_TX(
    .clk(pClk),
    .reset(pReset),
    .i_clk_tx(w_clk_tx),
    .TxStart(w_TxStart),
    .i_switch(w_TxData),
    .TxDone(w_TxDone),
    .o_txd(TxD) //out
);

UART_RX             UART_RX(
    .clk(pClk),
    .reset(pReset),
    .i_clk_rx(w_clk_rx),
    .i_rxd(RxD),
    .RxDone(w_RxDone), //out
    .RxStopBit(w_RxStopBit),
    .o_rx_data(w_RxData)
);

clk_div             clk_gen(
    .clk(pClk),
    .reset(pReset),
    .o_clk_rx(w_clk_rx),
    .o_clk_tx(w_clk_tx) //out
);

/*button_edge         edge_detector(
    .clk(pClk),
    .reset(pReset),
    .i_button(button),
    .o_button_edge(w_button_edge) //out
);
*/
endmodule