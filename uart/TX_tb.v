module TX_tb();

reg             clk, reset, i_button;
reg [7:0]       i_switch;
wire            o_txd;

UART_TX_TOP     TX(
    .clk(clk),
    .reset(reset),
    .i_button(i_button),
    .i_switch(i_switch),
    .o_txd(o_txd)
);

initial begin
    clk = 0;
    reset = 1;
    i_button = 0;
    i_switch = 8'b0100_1100;
    #10
    reset = 0;
    #10
    reset = 1;
end

always begin
    #350
    i_button = ~i_button; 
end

always begin
    #50
    clk = ~clk;
end

endmodule