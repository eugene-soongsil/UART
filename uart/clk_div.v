module clk_div(
    input        clk,
    input        reset,
    output reg   o_clk_div
);

reg [19:0] r_cnt;

always@(posedge clk or negedge reset)begin
    if(~reset)begin
        r_cnt <= 20'd0;
        o_clk_div <= 1'b0;
    end
    else if(r_cnt == 20'd10416)begin
        r_cnt <= 20'd0;
        o_clk_div <= 1'b1;
    end
    else begin
        r_cnt <= r_cnt + 20'd1;
        o_clk_div <= 1'b0;
    end
end

endmodule