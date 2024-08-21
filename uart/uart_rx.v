module UART_RX(
    input               clk,
    input               reset,
    input               i_clk_rx,
    input               i_rxd,
    output              RxDone,
    //output reg          div_en,
    output reg          RxStopBit,
    output reg [7:0]    o_rx_data
);

parameter           IDLE    = 0,
                    START   = 1,
                    D0      = 2,
                    D1      = 3,
                    D2      = 4,
                    D3      = 5,
                    D4      = 6,
                    D5      = 7,
                    D6      = 8,
                    D7      = 9,
                    STOP    = 10;

reg                 r_before_IDLE;
reg     [3:0]       rx_state, next_rx_state, r_rx_cnt, s_data;
reg     [7:0]       r_data;

//state logic
always@(posedge clk or negedge reset)begin
    if(~reset)
        rx_state <= IDLE;
    else if(next_rx_state == START)
        rx_state <= START;
    //else if(rx_state == START) //don't need
    //    rx_state <= D0;
    else if(i_clk_rx && r_rx_cnt == 4'd15)
        rx_state <= next_rx_state;
end

always@(posedge clk or negedge reset)begin
    if(~reset)
        r_before_IDLE <= 1'b0;
    else if(i_clk_rx && (rx_state == IDLE))
        r_before_IDLE <= 1'b1;
    else if(rx_state == STOP)
        r_before_IDLE <= 1'b0;
end

//state output & next state logic
always@(*)begin
    next_rx_state = rx_state;

    case(rx_state)
    IDLE    :   begin
        if(~i_rxd && reset && r_before_IDLE)begin
            next_rx_state = START;
        end
        else begin
            next_rx_state = IDLE;
        end
    end
    START   :   begin
        next_rx_state = D0;
    end
    D0      :   begin
        next_rx_state = D1;
    end
    D1      :   begin
        next_rx_state = D2;
    end
    D2      :   begin
        next_rx_state = D3;
    end
    D3      :   begin
        next_rx_state = D4;
    end
    D4      :   begin
        next_rx_state = D5;
    end
    D5      :   begin
        next_rx_state = D6;
    end
    D6      :   begin
        next_rx_state = D7;
    end
    D7      :   begin
        next_rx_state = STOP;
    end
    STOP    :   begin
        next_rx_state = IDLE;
    end
    endcase
end

//r_data save flipflop
always@(posedge clk or negedge reset)begin
    if(~reset)
        r_data <= 8'd0;
    else if(r_rx_cnt == 4'd15)
        r_data[rx_state-2] <= s_data[3];
    //else if(rx_state == STOP) //for testbench visual
    //   r_data <= 8'd0;
end

//o_data
always@(posedge clk or negedge reset)begin
    if(~reset)
        o_rx_data <= 8'd0;
    else if(rx_state == STOP)
        o_rx_data <= r_data;
    //else
    //    o_rx_data <= 8'd0;
end

//RxDone -> assign ???
assign RxDone    = (rx_state == STOP) ? 1'b1 : 1'b0;

//FF ? Combination?
always@(posedge clk or negedge reset)begin
    if(~reset)
        RxStopBit = 1'b0;
    else if(RxDone)
        RxStopBit = i_rxd;
end

/*
always@(posedge clk or negedge reset)begin
    if(~reset)
        RxDone <= 0;
    else if(rx_state == STOP)
        RxDone <= 1;
    else
        RxDone <= 0;
end
*/

//16bit sampling counter
always@(posedge clk or negedge reset)begin
    if(~reset)// && i_rxd == 0))
        r_rx_cnt <= 4'd0;
    else if(rx_state == IDLE)
        r_rx_cnt <= 4'd0;
    else if(i_clk_rx && (r_rx_cnt == 4'd15))
        r_rx_cnt <= 4'd0;
    else if(i_clk_rx) //조건문 지움
        r_rx_cnt <= r_rx_cnt + 4'd1;
end

//sampling data set
always@(*)begin
    if(~reset)
        s_data = 4'd0;
    else if(r_rx_cnt == 4'd0)
        s_data = 4'd0;
    else if(r_rx_cnt == 4'd7)
        s_data[0] = i_rxd;
    else if(r_rx_cnt == 4'd8)
        s_data[1] = i_rxd;
    else if(r_rx_cnt == 4'd9)
        s_data[2] = i_rxd;
    else if(r_rx_cnt == 4'd10)
        s_data[3] = (s_data[2] & s_data[1]) | (s_data[1] & s_data[0]);
end

//assign div_en = (rx_state == D0) ? 1'b1 : 1'b0;

/*
always@(posedge clk or negedge reset)begin
    if(~reset)
        div_en <= 1'b0;
    else if(rx_state == D0)
        div_en <= 1'b1;
    else if(rx_state == STOP)
        div_en <= 1'b0;
end
*/

/* combination...?
always@(*)begin
    if(rx_state == STOP)
        o_rx_data = r_data;
    else
        o_rx_data = o_data;
end
*/

endmodule