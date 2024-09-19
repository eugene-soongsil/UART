module UART_Register(
    input               PCLK,
    input               PRESETn,
    input               PSEL,
    input               PENABLE,
    input               PWRITE, //read or write
    input       [31:0]  PWDATA,
    input       [31:0]  PADDR,
    //input               TxStart,
    input               TxDone,
    input               RxStopBit,
    input               RxDone,
    input       [7:0]   RxData,
    output              TxStart,
    output      [7:0]   TxData,
    output              irqreq,
    output      [31:0]  PRDATA
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
reg    r_RxDone, r_RxBRead;

wire   [7:0]     Tx_FIFOtoBuffer;
wire   TxFIFO_write;
wire   TxBWrite, RxBWrite, TxBRead, RxBRead;
wire   TxEmpty, TxFull, RxEmpty, RxFull;
//Buffer Signal
assign TxBWrite = PSEL && PENABLE && PWRITE    && (PADDR[7:0] == 8'h00);
assign TxBRead  = PSEL && PENABLE && (~PWRITE) && (PADDR[7:0] == 8'h00);
assign RxBRead  = PSEL && PENABLE && (~PWRITE) && (PADDR[7:0] == 8'h01);

//TxDbuffer
FIFO                TX_FIFO(
    .clk(PCLK),
    .reset(PRESETn),
    .rd(TxStart),
    .wr(TxBWrite),
    .wr_data(PWDATA[7:0]),
    .empty(TxEmpty), //out
    .full(TxFull),
    .rd_data(Tx_FIFOtoBuffer)
);

always@(posedge PCLK or negedge PRESETn)begin
    if(~PRESETn)
        TxDbuffer <= 0;
    else if(TxStart) //after 1clk FIFO output, OK...? or TxBWrite?
        TxDbuffer <= Tx_FIFOtoBuffer;
end

assign TxStart = TxEn_edge || (TxDone && ~TxEmpty);

//TxData output
assign TxData = TxDbuffer; //TxEn && TxDbuffer or TxEn is button edge of TX

//TxBWrite Rising edge
always@(posedge PCLK or negedge PRESETn)begin
    if(~PRESETn)
        r_TxBWrite <= 0;
    else
        r_TxBWrite <= TxBWrite;
end
assign TxFIFO_write = (TxBWrite != r_TxBWrite) && TxBWrite;
//TxEn Rising edge
always@(posedge PCLK or negedge PRESETn)begin
    if(~PRESETn)
        r_TxEn <= 0;
    else
        r_TxEn <= TxEn;
end
assign TxEn_edge = (TxEn != r_TxEn) && TxEn;

//RxDbuffer
FIFO                RX_FIFO(
    .clk(PCLK),
    .reset(PRESETn),
    .rd(RxBRead_edge),
    .wr(RxStart), //timing ok?
    .wr_data(RxDbuffer),
    .empty(RxEmpty), //out
    .full(RxFull),
    .rd_data(RxB)
);

always@(posedge PCLK or negedge PRESETn)begin
    if(~PRESETn)
        RxDbuffer <= 0;
    else if(RxDone) //&&RxEn
        RxDbuffer <= RxData;
end

assign RxStart = RxDone_edge && ControlReg0[1];

//RxDone delete?
always@(posedge PCLK or negedge PRESETn)begin
    if(~PRESETn)
        r_RxDone <= 0;
    else
        r_RxDone <= RxDone;
end
assign RxDone_edge = (RxDone != r_RxDone) && r_RxDone;

always@(posedge PCLK or negedge PRESETn)begin
    if(~PRESETn)
        r_RxBRead <= 0;
    else
        r_RxBRead <= RxBRead;
end
assign RxBRead_edge = (RxBRead != r_RxBRead) && RxBRead;
//-------------------------end Buffer Register----------------------------\\

//---------------------------Control Register------------------------------\\
//ControlReg0
wire   [3:0]       UBRRH;
wire   TxEn, RxEn, TxCIE, RxCIE, CR0_en;

assign TxEn     = PWDATA[0] && CR0_en;           //Tx enable
assign RxEn     = PWDATA[1] && CR0_en;           //Rx enable
assign TxCIE    = PWDATA[2];          //Tx Complete Interrupt Enable
assign RxCIE    = PWDATA[3];          //Rx Complete Interrupt Enable
assign UBRRH    = PWDATA[7:4];        //UBRR High

assign CR0_en   = PSEL && PENABLE && PWRITE && (PADDR[7:0] == 8'h03);

always @(posedge PCLK or negedge PRESETn)begin
    if (~PRESETn)
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

assign DLS      = PWDATA[1:0]; //Data Length Select 0x0 : 5bits per  character
assign STOP     = PWDATA[2];    //Number of Stop bits
assign PEN      = PWDATA[3];    //Parity Enable
assign EPS      = PWDATA[4];    //Even Parity Select

assign CR1_en   = PSEL && PENABLE && PWRITE && (PADDR[7:0] == 8'h04);

always@(posedge PCLK or negedge PRESETn)begin
    if(~PRESETn)
        ControlReg1 <= 8'd0;
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
assign TxC  = TxEmpty;             //need TxB clear              
assign UDRE = TxEmpty;             //???   
assign FE   = RxDone && ~RxStopBit;
assign DOR  = RxFull && RxEn;      //need RxB FIFO mem
//assign UPE  = 

//need enable signal ? remain signal ?
always@(posedge PCLK or negedge PRESETn)begin
    if(~PRESETn)
        StatusReg <= 8'd0;
    else begin
        StatusReg[0] <= RxC;
        StatusReg[1] <= TxC;
        StatusReg[2] <= UDRE;
        StatusReg[3] <= FE;
        StatusReg[4] <= DOR;
    end
end
//-------------------------end Status Register--------------------------\\
//Read irqreq Output Logic
wire   UBRR_Read, ControlReg0_Read, ControlReg1_Read, StatusReg_Read;

assign UBRR_Read         = PSEL && PENABLE && (~PWRITE) && (PADDR[7:0] == 8'h02);
assign ControlReg0_Read  = PSEL && PENABLE && (~PWRITE) && (PADDR[7:0] == 8'h03);
assign ControlReg1_Read  = PSEL && PENABLE && (~PWRITE) && (PADDR[7:0] == 8'h04);
assign StatusReg_Read    = PSEL && PENABLE && (~PWRITE) && (PADDR[7:0] == 8'h05);

assign PRDATA =     (TxBRead)          ? {24'd0, TxDbuffer} :
                    (RxBRead)          ? {24'd0, RxDbuffer} :
                    (UBRR_Read)        ? {24'd0, UBRR} :
                    (ControlReg0_Read) ? {24'd0, ControlReg0} :
                    (ControlReg1_Read) ? {24'd0, ControlReg1} :
                    (StatusReg_Read)   ? {24'd0, StatusReg} : 32'd0;

assign irqreq = (RxDone) ? 1'b1 : 1'b0;

endmodule