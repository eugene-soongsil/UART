`timescale 1ns/1ps
module rx_tb();

reg         i_clk, i_reset, i_rxd;
wire [7:0]  o_data;


rx_top_for_test inst_rx(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_rxd(i_rxd),
    .o_data(o_data)
);


initial begin
    i_clk = 0; i_reset = 1; i_rxd = 1;
    #10
    i_reset = 0;
    #10
    i_reset = 1;
    #1000000
    i_rxd = 0;
end

always begin
    #30
    i_clk = ~i_clk;
end

endmodule
