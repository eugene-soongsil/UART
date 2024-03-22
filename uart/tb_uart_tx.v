`timescale 1ns/1ps
module tb_uart;

reg         i_start, i_reset, i_clk_tx;
reg [7:0]   i_data;
wire [7:0]       o_data;
wire         o_txd;

uart_tx     tx(
    .i_start(i_start),
    .i_reset(i_reset),
    .i_data(i_data),
    .i_clk_tx(i_clk_tx),
    .o_txd(o_txd)
);

uart_rx     rx(
    .i_clk_rx(i_clk_tx),
    .i_reset(i_reset),
    .i_rxd(o_txd),
    .o_data(o_data)
);

initial begin
    i_clk_tx = 0;
    i_reset = 1;
    #3 i_reset = 0;
    #3 i_reset = 1; i_start = 1;
    i_data = 8'b01010110;
end

always begin
    #3 i_clk_tx = ~i_clk_tx;
end


endmodule