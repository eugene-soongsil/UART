module FIFO(
    input               clk,
    input               reset,
    input               rd,
    input               wr,
    input   [B-1:0]     wr_data,
    output              empty,
    output              full,
    output  [B-1:0]     rd_data
);

parameter               B = 8;
parameter               W = 4;

reg         [B-1:0]     array_reg[2**W-1:0];
reg         [W-1:0]     wr_ptr_reg, wr_ptr_next;
reg         [W-1:0]     rd_ptr_reg, rd_ptr_next;
reg                     full_reg, full_next;
reg                     empty_reg, empty_next;

//----------------------- 1. State Register -------------------------\\
always@(posedge clk or negedge reset)begin
    if(~reset)begin
        wr_ptr_reg <= 0;
        rd_ptr_reg <= 0;
        full_reg   <= 0;
        empty_reg  <= 1;
    end
    else begin
        wr_ptr_reg <= wr_ptr_next;
        rd_ptr_reg <= rd_ptr_next;
        full_reg   <= full_next;
        empty_reg  <= empty_next;
    end
end
//------------------------ 2. Array Register ---------------------------\\
//Write Operation
always@(posedge clk)
    if(wr & (~full_reg)) //write enable, buffer not full
        array_reg[wr_ptr_reg] <= wr_data;
//Read Operation
assign rd_data = array_reg[rd_ptr_reg];
//------------------------ 3. Next State Logic -------------------------\\
always@(*)begin
    //default values
    rd_ptr_next     = rd_ptr_reg;
    wr_ptr_next     = wr_ptr_reg;
    full_next       = full_reg;
    empty_next      = empty_reg;
    //read or write
    case({wr, rd})
        2'b01: //read
        if(~empty_reg)begin //if buffer not empty
            rd_ptr_next = rd_ptr_reg + 1;
            full_next   = 1'b0; //after read, buffer is not full
            if(rd_ptr_next == wr_ptr_reg) //when 2 pointers equal
                empty_next = 1'b1;
        end
        2'b10: //write
        if(~full_reg)begin //if buffer not full
            wr_ptr_next = wr_ptr_reg + 1;
            empty_next  = 1'b0; //after write, buffer is not empty
            if(wr_ptr_next == rd_ptr_reg)//when 2 pointers equal
                full_next = 1'b1;
        end
        2'b11: begin//read and write
        rd_ptr_next = rd_ptr_reg + 1;
        wr_ptr_next = wr_ptr_reg + 1;
        end
        default: ;
    endcase
end
//---------------------- 4. Output Logic -----------------------------\\
//rd_data is already described in
assign full  = full_reg;
assign empty = empty_reg;

endmodule