module UART_Register(
    input               pClk,
    input               pReset,
    input               pSel,
    input               pEnable,
    input               pWrite, //read or write
    input       [31:0]  pWdata,
    input       [31:0]  pAddr,
    //input               TxStart,
    input               RxDone,
    input       [7:0]   RxData,
    output      [7:0]   TxData,
    output  reg [31:0]  pReadData
);

reg [7:0] TxDbuffer;    //0x00
reg [7:0] RxDbuffer;    //0x01
//reg [7:0] UBRR;       //0x02
//reg [7:0] ControlReg0 //0x03
//reg [7:0] ControlReg1 //0x04
reg [7:0] StateReg      //0x05

wire   TxBWrite, RxBWrite, TxBRead, RxBRead;

assign TxBWrite = pSel && pEnable && pWrite && (pAddr[7:0] == 8'h0);
//assign RxBWrite = pSel && pEnable && pWrite && (pAddr[7:0] == 8'h1);
assign TxBRead = pSel && pEnable && (~pWrite) && (pAddr[7:0] == 8'h0);
assign RxBRead = pSel && pEnable && (~pWrite) && (pAddr[7:0] == 8'h1);

//TxDbuffer
always@(posedge pClk or negedge pReset)begin
    if(~pReset)
        TxDbuffer <= 0;
    else if(TxBWrite)
        TxDbuffer <= pWdata[7:0];
end

//TxData output
assign TxData = TxDbuffer;

//RxDbuffer
always@(posedge pClk or negedge pReset)begin
    if(~pReset)
        RxDbuffer <= 0;
    else if(RxDone)
        RxDbuffer <= RxData;
end

//ControlReg0

//StatusReg
assign StateReg[0] = (RxDbuffer != 8'd0) || (RxBWrite); //RXC
assign StateReg[1] = (TxDbuffer == 8'd0);               //TXC
assign StateReg[2] = (TxDbuffer == 8'd0);               //UDRE ??   

//Read logic
always@(posedge pClk or negedge pReset)begin
    if(~pReset)
        pReadData <= 0;
    else if(TxBRead)
        pReadData <= {24'd0, TxDbuffer};
    else if(RxBRead)
        pReadData <= {24'd0, RxDbuffer};
end//output for one clk? or maintain output
//assign 으로 뽑아줘야한다 APB에서는 core로 넘겨주는 건 combination
//요청신호를 보내고 바로 데이터를 가져가기때문에 clk에 물리면 안댐

endmodule