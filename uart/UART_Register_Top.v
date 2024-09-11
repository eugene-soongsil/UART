module UART_Register_Top(
    //signal
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 PCLK CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_RESET PRESETn FREQ_HZ 50000000" *)
    input               PCLK,
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 PRESETn RST" *)
    (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_LOW" *)
    input               PRESETn,
    (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 irqreq INTERRUPT" *)
    (* X_INTERFACE_PARAMETER = "SENSITIVITY EDGE_RISING" *)
    output              irqreq,
    //interface
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PADDR" *)
    input       [31:0]  PADDR,
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PSEL" *)
    input               PSEL,
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PENABLE" *)
    input               PENABLE,
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PWRITE" *)
    input               PWRITE,
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PWDATA" *)
    input       [31:0]  PWDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PREADY" *)
    output              PREADY, // Slave Ready (required)
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PRDATA" *)
    output      [31:0]  PRDATA,
    (* X_INTERFACE_INFO = "xilinx.com:interface:apb:1.0 S_APB PSLVERR" *)
    output              PSLVERR, // Slave Error Response (required)
// aditional ports
    input               RxD,
    output              TxD
);

assign  PREADY  = 1'b1;
assign  PSLVERR = 1'b0;

wire                w_TxStart, w_clk_tx, w_clk_rx, w_RxDone, w_RxStopBit, w_TxDone;
wire    [7:0]       w_RxData, w_TxData;

UART_Register       UART_REG(
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PWDATA(PWDATA),
    .PADDR(PADDR),
    .TxDone(w_TxDone),
    .RxStopBit(w_RxStopBit),
    .RxDone(w_RxDone),
    .RxData(w_RxData),
    .TxData(w_TxData), //out
    .TxStart(w_TxStart),
    .irqreq(irqreq),
    .PRDATA(PRDATA)
);

UART_TX             UART_TX(
    .clk(PCLK),
    .reset(PRESETn),
    .i_clk_tx(w_clk_tx),
    .TxStart(w_TxStart),
    .i_switch(w_TxData),
    .TxDone(w_TxDone),
    .o_txd(TxD) //out
);

UART_RX             UART_RX(
    .clk(PCLK),
    .reset(PRESETn),
    .i_clk_rx(w_clk_rx),
    .i_rxd(RxD),
    .RxDone(w_RxDone), //out
    .RxStopBit(w_RxStopBit),
    .o_rx_data(w_RxData)
);

clk_div             clk_gen(
    .clk(PCLK),
    .reset(PRESETn),
    .o_clk_rx(w_clk_rx),
    .o_clk_tx(w_clk_tx) //out
);

endmodule