module RX_tb();

reg             clk, reset, i_rxd;
wire  [7:0]     o_rx_data;

UART_RX_TOP     RX(
    .clk(clk),
    .reset(reset),
    .i_rxd(i_rxd),
    .o_rx_data(o_rx_data)
);

initial begin
    clk = 0;
    reset = 1;
    i_rxd = 0;
    #10
    reset = 0;
    #10
    reset = 1;
end

always begin
    #380
    i_rxd = ~i_rxd; 
end

always begin
    #50
    clk = ~clk;
end

endmodule