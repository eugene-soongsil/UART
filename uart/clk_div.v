module clk_div(
    input        clk,
    input        reset,
    input        RxDone,
    input        div_en,
    output reg   o_clk_rx,
    output reg   o_clk_tx
);

reg [9:0] r_cnt;

/*
always@(posedge clk or negedge reset)begin
    if(~reset)begin
        r_cnt <= 20'd0;
        o_clk_div <= 1'b0;
    end
    else if((div_en == 1'b1) && (r_cnt == 20'd10416))begin
        r_cnt <= 20'd0;
        o_clk_div <= 1'b1;
    end
    else if(div_en == 1'b0) begin
    else begin
        r_cnt <= r_cnt + 20'd1;
        o_clk_div <= 1'b0;
    end
end
*/

/*
always@(posedge clk or negedge reset)begin
    if(~reset)
        r_cnt <= 20'd0;
    else if((r_cnt == 20'd10416) || (div_en == 1'b1))
        r_cnt <= 20'd0;
    else
        r_cnt <= r_cnt + 20'd1;
end

always@(posedge clk or negedge reset)begin
    if(~reset)
        o_clk_div <= 1'b0;
    else if((r_cnt == 20'd10416) && (div_en == 1'b1))
        o_clk_div <= 1'b1;
    else if(div_en == 1'b0)
        o_clk_div <= 1'b0;
end
*/

//UBRR 650 counter
always@(posedge clk or negedge reset)begin
    if((~reset) || (r_cnt == 10'd650) || (RxDone))
        r_cnt <= 10'd0;
    else
        r_cnt <= r_cnt + 10'd1;
end

//RX clk or assign ?
always@(posedge clk or negedge reset)begin
    if(~reset)
        o_clk_rx <= 1'b0;
    else if(r_cnt == 10'd650)
        o_clk_rx <= 1'b1;
    else
        o_clk_rx <= 1'b0;
end

//TX clk or assign ?
always@(posedge clk or negedge reset)begin
    if(~reset)
        o_clk_tx <= 1'b0;
    else if(r_cnt == 10'd650)
        o_clk_tx <= 1'b1;
    else
        o_clk_tx <= 1'b0;
end
        
endmodule