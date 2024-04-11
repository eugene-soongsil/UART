module uart_tx(
    input           i_clk,
//    input           i_start,
    input           i_reset,
    input           i_clk_tx,
    input   [7:0]   sw,
    input           i_bo,
    output  reg     o_txd
);

parameter           idle = 0, start = 1, d0 = 2, d1 = 3, d2 = 4, d3 = 5, d4 = 6,
                    d5 = 7, d6 = 8, d7 = 9, stop = 10;
reg [3:0]           tx_state, next_tx_state;
reg                 r_txd, buff_bo, edge_bo;



//state output
always@*begin
    case(tx_state)
    idle    : r_txd = 1;
    start   : r_txd = 0;
    d0      : r_txd = sw[0];
    d1      : r_txd = sw[1];
    d2      : r_txd = sw[2];
    d3      : r_txd = sw[3];
    d4      : r_txd = sw[4];
    d5      : r_txd = sw[5];
    d6      : r_txd = sw[6];
    d7      : r_txd = sw[7];
    stop    : r_txd = 1;
    default : r_txd = 1;
    endcase
end
/*
always@(posedge i_clk or negedge i_reset)begin
    if(!i_reset)
        o_txd <= 0;
    else if(edge_bo)
        o_txd <= r_txd;
    else
        o_txd <= 0;
end
*/

//button
always@(posedge i_clk or negedge i_reset)begin
    if(!i_reset)
        buff_bo <= 0;
    else
        buff_bo <= i_bo;
end

always@(posedge i_clk or negedge i_reset)begin
    if(!i_reset)
        edge_bo <= 0;
    else begin
        if((buff_bo == 0) && (i_bo == 1))
            edge_bo <= 1;
        else
            edge_bo <= 0;
    end
end

//state logic 
always@(posedge i_clk or negedge i_reset)begin
    if(!i_reset)
        tx_state <= idle;
    else if(i_clk_tx)
        tx_state <= next_tx_state;
end

always@(*)begin
    next_tx_state = tx_state;
        case(tx_state)
        idle : begin
            if(edge_bo == 1'b1)
                next_tx_state = start;
            else
                next_tx_state = idle;
        end
        start : next_tx_state = d0;
        d0    : next_tx_state = d1;
        d1    : next_tx_state = d2;
        d2    : next_tx_state = d3;
        d3    : next_tx_state = d4;
        d4    : next_tx_state = d5;
        d5    : next_tx_state = d6;
        d6    : next_tx_state = d7;
        d7    : next_tx_state = stop;
        stop  : next_tx_state = idle;
        default : next_tx_state = idle;
    endcase
end

assign o_txd = r_txd;

endmodule

//i_bo 만들고 나서 동작이 안댐....i_start 사용할땐 됐는데