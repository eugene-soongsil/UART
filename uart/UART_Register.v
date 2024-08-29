module UART_Register(
    input               pClk,
    input               pReset,
    input               pSel,
    input               pEnable,
    input               pWrite, //read or write
    input       [31:0]  pWdata,
    input       [31:0]  pAddr,
    //input               TxStart,
    input               TxDone,
    input               RxStopBit,
    input               RxDone,
    input       [7:0]   RxData,
    output              TxEn,
    output      [7:0]   TxData,
    output      [31:0]  IRQ,
    output      [31:0]  pReadData
);      

//Register
reg [7:0] TxDbuffer;    //0x00
reg [7:0] RxDbuffer;    //0x01
reg [7:0] UBRR;         //0x02
reg [7:0] ControlReg0;  //0x03
reg [7:0] ControlReg1;  //0x04
reg [7:0] StatusReg;    //0x05

//--------------------------Buffer Register------------------------------\\
reg    r_TxBWrite, r_TxEn;


wire   [7:0]     Tx_FIFOtoBuffer;
wire   TxFIFO_write, TxEn_edge;
wire   TxBWrite, RxBWrite, TxBRead, RxBRead;
wire   TxEmpty, TxFull, RxEmpty, RxFull;
//Buffer Signal
assign TxBWrite = pSel && pEnable && pWrite    && (pAddr[7:0] == 8'h00);
assign TxBRead  = pSel && pEnable && (~pWrite) && (pAddr[7:0] == 8'h00);
assign RxBRead  = pSel && pEnable && (~pWrite) && (pAddr[7:0] == 8'h01);

//TxDbuffer
FIFO                TX_FIFO(
    .clk(pClk),
    .reset(pReset),
    .rd(TxEn_edge),
    .wr(TxFIFO_write),
    .wr_data(pWdata[7:0]),
    .empty(TxEmpty), //out
    .full(TxFull),
    .rd_data(Tx_FIFOtoBuffer)
);

always@(posedge pClk or negedge pReset)begin
    if(~pReset)
        TxDbuffer <= 0;
    else if(TxEn_edge || (TxDone && ~TxEmpty)) //after 1clk FIFO output, OK...? or TxBWrite?
        TxDbuffer <= Tx_FIFOtoBuffer;
end

//TxData output
assign TxData = TxDbuffer; //TxEn && TxDbuffer or TxEn is button edge of TX

//TxBWrite Rising edge
always@(posedge pClk or negedge pReset)begin
    if(~pReset)
        r_TxBWrite <= 0;
    else
        r_TxBWrite <= TxBWrite;
end
assign TxFIFO_write = (TxBWrite != r_TxBWrite) && r_TxBWrite;

//TxEn Rising edge
always@(posedge pClk or negedge pReset)begin
    if(~pReset)
        r_TxEn <= 0;
    else
        r_TxEn <= TxEn;
end
assign TxEn_edge = (TxEn != r_TxEn) && r_TxEn;

//RxDbuffer
FIFO                RX_FIFO(
    .clk(pClk),
    .reset(pReset),
    .rd(RxBRead),
    .wr(RxEn),
    .wr_data(RxDbuffer),
    .empty(RxEmpty), //out
    .full(RxFull),
    .rd_data(RxB)
);

always@(posedge pClk or negedge pReset)begin
    if(~pReset)
        RxDbuffer <= 0;
    else if(RxDone_edge && RxEn) //&&RxEn
        RxDbuffer <= RxData;
end

always@(posedge pClk or negedge pReset)begin
    if(~pReset)
        r_RxDone <= 0;
    else
        r_RxDone <= RxDone;
end
assign RxDone_edge = (RxDone != r_RxDone) && r_RxDone;


//-------------------------end Buffer Register----------------------------\\

//---------------------------Control Register------------------------------\\
//ControlReg0
wire   [3:0]      UBRRH;
wire   TxEn, RxEn, TxCIE, RxCIE, CR0_en;

assign TxEn     = pWdata[8];           //Tx enable
assign RxEn     = pWdata[9]; //Rx enable
assign TxCIE    = pWdata[10];          //Tx Complete Interrupt Enable
assign RxCIE    = pWdata[11];          //Rx Complete Interrupt Enable
assign UBRRH    = pWdata[15:12];       //UBRR High

assign CR0_en   = pSel && pEnable && pWrite && (pAddr[7:0] == 8'h03);

always @(posedge pClk or negedge pReset)begin
    if (~pReset)
        ControlReg0 <= 8'd0;
    else if(CR0_en)begin
        ControlReg0[0]      <= TxEn;
        ControlReg0[1]      <= RxEn;
        ControlReg0[2]      <= TxCIE;
        ControlReg0[3]      <= RxCIE;
        ControlReg0[7:4]    <= UBRRH;
    end
end

//ControlReg1
wire [1:0]  DLS; 
wire        STOP, PEN, EPS, CR1_en;

assign DLS      = pWdata[17:16]; //Data Length Select 0x0 : 5bits per  character
assign STOP     = pWdata[18]; //Number of Stop bits
assign PEN      = pWdata[19]; //Parity Enable
assign EPS      = pWdata[20]; //Even Parity Select

assign CR1_en   = pSel && pEnable && pWrite && (pAddr[7:0] == 8'h04);

always@(posedge pClk or negedge pReset)begin
    if(~pReset)
        ControlReg1 <= 0;
    else if(CR1_en)begin
        ControlReg1[1:0] <= DLS;
        ControlReg1[2]   <= STOP;
        ControlReg1[3]   <= PEN;
        ControlReg1[4]   <= EPS;
    end
end
//-------------------------end Control Register---------------------------\\

//---------------------------Status Register------------------------------\\
//StatusReg
wire   RxC, TxC, UDRE, FE, DOR;

assign RxC  = RxDone;              //Rx Complete 
assign TxC  = TxEmpty; //need TxB clear              
assign UDRE = TxEmpty; //???   
assign FE   = RxDone && ~RxStopBit;
assign DOR  = RxFull && RxEn;      //need RxB FIFO mem
//assign UPE  = 

//need enable signal ? remain signal ?
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
//-------------------------end Status Register--------------------------\\
//Read Output Logic
assign pReadData =  //(TxBRead) ? {24'd0, TxDbuffer} :
                    (RxBRead) ? {24'd0, RxB} : 32'd0;
assign IRQ = (TxCIE && ControlReg0[2] || RxCIE && ControlReg0[3]) 
            ? {24'd0, StatusReg} : 32'd0;

endmodule