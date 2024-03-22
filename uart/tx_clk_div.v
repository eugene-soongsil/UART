module tx_clk_div(i_clk, i_reset, o_clk_out);

input        i_clk, i_reset;
output       o_clk_out;

reg [9:0] r_cnt;
reg r_clk_out;

always@(posedge i_clk or negedge i_reset)begin
    if(!i_reset)begin
        r_cnt <= 10'd0;
        r_clk_out <= 1'b0;
    end
    else if(r_cnt == 10'd651)begin
        r_cnt <= 10'd0;
        r_clk_out <= 1'b1;
    end
    else begin
        r_cnt <= r_cnt + 10'd1;
        r_clk_out <= 1'b0;
    end
end

assign o_clk_out = r_clk_out;

endmodule