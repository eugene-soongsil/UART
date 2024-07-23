module tb_UART_Register;

reg             pClk, pReset, switch, button, pSel, pEnable, pWrite;
reg     [31:0]  pWdata, pAddr;
reg     [7:0]   RxD;
wire    [7:0]   TxD;
wire    [31:0]  pReadData;

UART_Register_Top   top(
    .pClk(pClk),
    .pReset(pReset),
    .switch(switch),
    .button(button),
    .pSel(pSel),
    .pEnable(pEnable),
    .pWrite(pWrite),
    .pWdata(pWdata),
    .pAddr(pAddr),
    .RxD(RxD),
    .TxD(TxD),
    .pReadData(pReadData)    
);

initial begin
    pClk = 0; pReset = 1;
    #10
    pReset = 0;
    #10
    pReset = 1;
end

initial begin
    #50
    
end

always begin
    #50
    pClk = ~pClk;
end


endmodule