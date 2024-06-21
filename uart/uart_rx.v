module UART_RX(
    input               clk,
    input               reset,
    input               i_clk_rx,
    input               i_rxd,
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
reg     [3:0]       rx_state, next_rx_state;
reg     [7:0]       r_data;

//state logic
always@(posedge clk or negedge reset)begin
    if(~reset)
        rx_state <= IDLE;
    else if(clk)
        rx_state <= next_rx_state;
end

//state output & next state logic
always@(*)begin
    next_rx_state = rx_state;

    case(rx_state)
    IDLE    :   begin
        if(~i_rxd && reset)begin
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
    else
        r_data[rx_state-2] <= i_rxd;
end

//o_data
always@(posedge clk or negedge reset)begin
    if(~reset)
        o_rx_data <= 8'd0;
    else if(rx_state == STOP)
        o_rx_data <= r_data;
end

/* combination...?
always@(*)begin
    if(rx_state == STOP)
        o_rx_data = r_data;
    else
        o_rx_data = o_data;
end
*/

endmodule