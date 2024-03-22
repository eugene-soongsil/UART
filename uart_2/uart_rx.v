module uart_rx(
    input           i_clk_rx,
    input           i_reset,
    input           i_rxd,
    output  reg  [7:0]   o_data
);

parameter           idle = 0, start = 1, d0 = 2, d1 = 3, d2 = 4, d3 = 5, d4 = 6,
                    d5 = 7, d6 = 8, d7 = 9, stop = 10;
reg     [3:0]       rx_state, next_rx_state;
reg     [7:0]       r_data;

always@*begin
    case(rx_state)
    idle    : r_data = 0;
    start   : r_data = 0;
    d0      : r_data[0] = i_rxd;
    d1      : r_data[1] = i_rxd;
    d2      : r_data[2] = i_rxd;
    d3      : r_data[3] = i_rxd;
    d4      : r_data[4] = i_rxd;
    d5      : r_data[5] = i_rxd;
    d6      : r_data[6] = i_rxd;
    d7      : r_data[7] = i_rxd;
    stop    : r_data = r_data;
    default : r_data = 0;
    endcase
end

always@(*)begin
    if(rx_state == stop)
        o_data = r_data;
    else
        o_data = 0;
end

always@(posedge i_clk_rx or negedge i_reset)begin
    if(!i_reset)
        rx_state <= idle;
    else
        rx_state <= next_rx_state;
end

always@(*)begin
    next_rx_state = rx_state;
    case(rx_state)
    idle    : begin
        if(i_rxd == 1'b0)
            next_rx_state = start;
        else
            next_rx_state = idle;
    end
    start   : next_rx_state = d0;
    d0      : next_rx_state = d1;
    d1      : next_rx_state = d2;
    d2      : next_rx_state = d3;
    d3      : next_rx_state = d4;
    d4      : next_rx_state = d5;
    d5      : next_rx_state = d6;
    d6      : next_rx_state = d7;
    d7      : next_rx_state = stop;
    stop    : next_rx_state = idle;
    default : next_rx_state = idle;
    endcase
end

endmodule