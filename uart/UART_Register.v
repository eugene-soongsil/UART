module UART_Register(
    input               pClk,
    input               pReset,
    input               pSel,
    input               pEnable,
    input               pWrite, //read or write
    input       [31:0]  pWdata,
    input       [31:0]  pAddr,
    //input               TxStart,
    //input               TxDone,
    //input               RxStopBit,
    input               RxDone,
    input       [7:0]   RxData,
    output      [7:0]   TxData,
    output      [31:0]  IRQ,
    output      [31:0]  pReadData
);      

//Register
reg [7:0] TxDbuffer;    //0x00
reg [7:0] RxDbuffer;    //0x01
reg [7:0] UBRR;       //0x02
reg [7:0] ControlReg0; //0x03
reg [7:0] ControlReg1; //0x04
reg [7:0] StatusReg;   //0x05

wire   TxBWrite, RxBWrite, TxBRead, RxBRead;

//Buffer Signal
assign TxBWrite = pSel && pEnable && pWrite && (pAddr[7:0] == 8'h0);
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
assign TxData = TxDbuffer; //TxEn && TxDbuffer or TxEn is button edge of TX

//RxDbuffer
always@(posedge pClk or negedge pReset)begin
    if(~pReset)
        RxDbuffer <= 0;
    else if(RxDone)
        RxDbuffer <= RxData;
end
//-------------------------end Buffer Register----------------------------
//ControlReg0
wire   [3:0]      UBRRH;
wire   TxEn, RxEn, TxCIE, RxCIE;

assign TxEn     = i_TxEn;
assign RxEn     = i_RxEn;
assign TxCIE    = i_TxCIE;
assign RxCIE    = i_RxCIE;
assign UBRRH    = ControlReg0[7:4];

always @(posedge pClk or negedge pReset) begin
    if (~pReset)
        ControlReg0 <= 8'd0;
    else begin
        ControlReg0[0] <= TxEn;
        ControlReg0[1] <= RxEn;
        ControlReg0[2] <= TxCIE;
        ControlReg0[3] <= RxCIE;
    end
end

//ControlReg1


//StatusReg
wire   RxC, TxC, UDRE, FE, DOR;

assign RxC  = RxDone;
assign TxC  = (TxDbuffer == 8'd0);               
assign UDRE = (TxDbuffer == 8'd0); //???   
assign FE   = RxDone && RxStopBit;
assign DOR  = RxDbuffer == 1;
//assign UPE  = 

always@(posedge pClk or negedge pReset)begin
    if(~pReset)
        StatusReg <= 0;
    else begin
        StatusReg[0] <= RxC;
        StatusReg[1] <= TxC;
        StatusReg[2] <= UDRE;
        StatusReg[3] <= FE;
        StatusReg[4] <= DOR;
    end
end

//Read logic
assign pReadData =  (TxBRead)? {24'd0, TxDbuffer} :
                    (RxBRead)? {24'd0, RxDbuffer} : 32'd0;
assign IRQ = (TxCIE || RxCIE) ? {24'd0, StatusReg} : 32'd0;

endmodule