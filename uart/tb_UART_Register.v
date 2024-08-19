module tb_UART_Register;

reg             pClk, pReset, button, pSel, pEnable, pWrite;
reg     [31:0]  pWdata, pAddr;
reg             RxD;
wire            TxD;
wire    [31:0]  pReadData;

UART_Register_Top   top(
    .pClk(pClk),
    .pReset(pReset),
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

task Ureg(
    input        write,
    input [31:0] Txdata,
    input [31:0] RegAddr
);
begin
    @(posedge pClk)
    button <= 1'b1;
    pSel <= 1'b1;
    pWrite <= write;
    pAddr <= RegAddr;
    @(posedge pClk)
    pEnable <= 1'b1;
    pWdata <= Txdata;
    @(posedge pClk)
    button <= 1'b0;
end
endtask

task rx_in(
	input [7:0] i_data
);
begin
	@(posedge pClk)
	RxD <= 1'b0;
	#104160
	RxD <= i_data[0];
	#104160
	RxD <= i_data[1];
	#104160
	RxD <= i_data[2];
	#104160
	RxD <= i_data[3];
	#104160
	RxD <= i_data[4];
	#104160
	RxD <= i_data[5];
	#104160
	RxD <= i_data[6];
	#104160
	RxD <= i_data[7];
	#104160
	RxD <= 1'b1;
end
endtask

initial begin
    pClk = 0; pReset = 1;
    #10
    pReset = 0;
    #10
    pReset = 1;
    RxD = 1'b1;
end

initial begin
    #25
    Ureg(1'b1, 32'd10, 32'd0); //Tx data 10 transmit
    #(104160*10);
    Ureg(1'b0, 32'd0, 32'd0); //Tx buffer read
    #(104160*10);
    rx_in(8'd20);
    #(104160*10);
    Ureg(1'b0, 32'd0, 32'd1); //Rx data read
    #(104160*10);
    $finish;
end

always begin
    #5
    pClk = ~pClk;
end


endmodule