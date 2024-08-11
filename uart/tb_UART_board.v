module tb_UART_board;

reg         clk, reset, button, RxD;
wire        TxD;

UART_board          board(
    .clk(clk),
    .reset(reset),
    .button(button),
    .RxD(RxD),
    .TxD(TxD)
);

task rx_in(
	input [7:0] i_data
);
begin
	@(posedge clk)
    #104160
	RxD <= 1'b0;
	#104160
	RxD <= i_data[0];
	#104160
	RxD <= i_data[1];
	#104160
	RxD <= i_data[2];
	#104160
	RxD <= i_data[3];
	#104160
	RxD <= i_data[4];
	#104160
	RxD <= i_data[5];
	#104160
	RxD <= i_data[6];
	#104160
	RxD <= i_data[7];
	#104160
	RxD <= 1'b1;
end
endtask

initial begin
    clk = 0; reset = 1;
    #10
    reset = 0;
    #10
    reset = 1;
    RxD = 1'b1;
end

initial begin
    button = 1'b0;
    rx_in(8'b0000_1010);
    button = 1'b1;
    #1200000
    button = 1'b0;
    rx_in(8'd20);
    button = 1'b1;
    #1200000
    button = 1'b0;
    rx_in(8'd30);
    button = 1'b1;
    #1200000
    button = 1'b0;
    rx_in(8'd100);
    button = 1'b1;
    #1200000
    button = 1'b0;
    rx_in(8'd200);
    button = 1'b1;
    #1200000
    button = 1'b0;
    rx_in(8'd255);
    button = 1'b1;
    #1200000
    $finish;
end

always begin
    #5
    clk = ~clk;
end

endmodule