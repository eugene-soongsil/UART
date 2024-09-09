module tb_FIFO;

    // Parameters
    parameter B = 8;  // Data width
    parameter W = 4;  // Address width

    // Signals
    reg               clk;
    reg               reset;
    reg               rd;
    reg               wr;
    reg  [B-1:0]      wr_data;
    wire              empty;
    wire              full;
    wire [B-1:0]      rd_data;

    // Instantiate the FIFO module
    FIFO #(.B(B), .W(W)) uut (
        .clk(clk),
        .reset(reset),
        .rd(rd),
        .wr(wr),
        .wr_data(wr_data),
        .empty(empty),
        .full(full),
        .rd_data(rd_data)
    );

    // Clock generation
    always #5 clk = ~clk;  // 10ns clock period

    // Initial block to drive the test cases
    initial begin
        // Initialize inputs
        clk = 0;
        reset = 1;
        rd = 0;
        wr = 0;
        wr_data = 0;

        // Apply reset
        reset = 0;
        #10;
        reset = 1;
        #10;
        
        // Test 1: Write data to the FIFO
        wr_data = 8'hAA;  // Write data 0xAA
        wr = 1;
        #10;
        wr = 0;           // Stop writing
        #10;
        
        // Test 2: Read data from the FIFO
        rd = 1;           // Read the data
        #10;
        rd = 0;
        #10;
        
        // Test 3: Fill the FIFO to check full condition
        for (integer i = 0; i < (2**W); i = i + 1) begin
            wr_data = i;  // Write increasing data values
            wr = 1;
            #10;
            wr = 0;
            #10;
        end
        
        // Test 4: Empty the FIFO to check empty condition
        for (integer i = 0; i < (2**W); i = i + 1) begin
            rd = 1;
            #10;
            rd = 0;
            #10;
        end

        // Test 5: Simultaneous read and write
        wr_data = 8'hBB;  // Write data 0xBB
        wr = 1;
        rd = 1;
        #10;
        wr = 0;
        rd = 0;
        #10;

        // Stop simulation
        $stop;
    end

    // Monitor signals
    initial begin
        $monitor("Time=%0d | wr=%b, rd=%b, wr_data=0x%h, rd_data=0x%h, empty=%b, full=%b", 
                  $time, wr, rd, wr_data, rd_data, empty, full);
    end

endmodule