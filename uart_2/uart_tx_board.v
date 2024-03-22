module uart_tx(
    input           i_clk,
    input           i_start,
    input           i_reset,
    input           i_clk_tx,
    input   [7:0]   sw,
    output          o_txd
);

parameter           idle = 0, start = 1, d0 = 2, d1 = 3, d2 = 4, d3 = 5, d4 = 6,
                    d5 = 7, d6 = 8, d7 = 9, stop = 10;
reg [3:0]           tx_state, next_tx_state;
reg                 r_txd;
reg [3:0] clk_div_c;

reg rs;

wire clk_div;


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

always @(posedge i_clk or negedge i_reset)begin
    if(!i_reset || rs) clk_div_c <= 0;
    else clk_div_c <= clk_div_c + 1;
end

assign clk_div = clk_div_c == 4'b1111;

//state logic 
always@(posedge i_clk or negedge i_reset)begin
    if(!i_reset)
        tx_state <= idle;
    else
        tx_state <= next_tx_state;
end

always@(*)begin
    next_tx_state = tx_state;
    rs = 0;
    case(tx_state)
        idle : begin
            if(i_start == 1'b1 )begin
                next_tx_state = start;
                rs = 1;
            end
            else
                next_tx_state = idle;
        end
        start : if (clk_div) next_tx_state = d0;
        d0    : if (clk_div) next_tx_state = d1;
        d1    : if (clk_div) next_tx_state = d2;
        d2    : if (clk_div) next_tx_state = d3;
        d3    : if (clk_div) next_tx_state = d4;
        d4    : if (clk_div) next_tx_state = d5;
        d5    : if (clk_div) next_tx_state = d6;
        d6    : if (clk_div) next_tx_state = d7;
        d7    : if (clk_div) next_tx_state = stop;
        stop  : if (clk_div) next_tx_state = idle;
        default : next_tx_state = idle;
    endcase
end

assign o_txd = r_txd;



endmodule

