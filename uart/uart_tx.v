module UART_TX(
    input           clk,
    input           reset,
    input           i_clk_tx,
    input           TxStart, // or TxEn edge ?
    input   [7:0]   i_switch,
    output          TxDone,
    output  reg     o_txd
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
reg     [3:0]       tx_state, next_tx_state, r_tx_cnt;
reg                 r_TxDone;

//state logic
always@(posedge clk or negedge reset)begin
    if(~reset)
        tx_state <= IDLE;
    else if(next_tx_state == START)
        tx_state <= START;
    else if(i_clk_tx && r_tx_cnt == 4'd15)
        tx_state <= next_tx_state;
end

//state output & nextstate logic
always@(*)begin
    o_txd = 1'b1;
    next_tx_state = tx_state;

    case(tx_state)
    IDLE    :   begin
        if(TxStart)begin
            o_txd = 1'b1;
            next_tx_state = START;
        end
        else begin
            o_txd = 1'b1;
            next_tx_state = IDLE;
        end
    end
    START   :   begin
        o_txd = 1'b0;
        next_tx_state = D0;
    end
    D0      :   begin
        o_txd = i_switch[0];
        next_tx_state = D1;
    end
    D1      :   begin
        o_txd = i_switch[1];
        next_tx_state = D2;
    end
    D2      :   begin
        o_txd = i_switch[2];
        next_tx_state = D3;
    end
    D3      :   begin
        o_txd = i_switch[3];
        next_tx_state = D4;
    end
    D4      :   begin
        o_txd = i_switch[4];
        next_tx_state = D5;
    end
    D5      :   begin
        o_txd = i_switch[5];
        next_tx_state = D6;
    end
    D6      :   begin
        o_txd = i_switch[6];
        next_tx_state = D7;
    end
    D7      :   begin
        o_txd = i_switch[7];
        next_tx_state = STOP;
    end
    STOP    :   begin
        o_txd = 1'b1;
        next_tx_state = IDLE;
    end
    endcase
end
//negedge TxDone ????
always@(posedge clk or negedge reset)begin
    if(~reset)
        r_TxDone <= 0;
    else if(tx_state == STOP)
        r_TxDone <= 1;
    else
        r_TxDone <= 0;
end
assign TxDone =  ((tx_state == STOP) != r_TxDone) && r_TxDone;        

//16bit counter
/*always@(posedge clk or negedge reset)begin
    if((~reset) || (r_tx_cnt == 4'd15))
        r_tx_cnt <= 4'd0;
    else if(i_clk_tx)
        r_tx_cnt <= r_tx_cnt + 4'd1;
end
*/
always@(posedge clk or negedge reset)begin
    if(~reset)
        r_tx_cnt <= 4'd0;
    else if(tx_state == IDLE)
        r_tx_cnt <= 4'd0;
    else if(i_clk_tx && (r_tx_cnt == 4'd15))
        r_tx_cnt <= 4'd0;
    else if(i_clk_tx) //조건문 지움
        r_tx_cnt <= r_tx_cnt + 4'd1;
end

endmodule