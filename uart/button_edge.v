module button_edge(
    input       clk,
    input       reset,
    input       i_button,
    output reg  o_button_edge
);

reg             buff_bo;

always@(posedge clk or negedge reset)begin
    if(~reset)
        buff_bo <= 0;
    else
        buff_bo <= i_button;
end

always@(posedge clk or negedge reset)begin
    if(~reset)
            o_button_edge <= 0;
    else begin
        if(~buff_bo && i_button)
            o_button_edge <= 1;
        else
            o_button_edge <= 0;
    end
end

endmodule