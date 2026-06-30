module topmodule();

    reg clk;
    reg reset;

    reg wr_en;
    reg [7:0] din;

    reg rd_en;
    wire [7:0] dout;

    wire full;
    wire empty;

    fifo_sync inst (
        .clk(clk),
        .reset(reset),
        .wr_en(wr_en),
        .din(din),
        .rd_en(rd_en),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task write_byte;
        input [7:0] data;
        begin
            @(negedge clk);
            din = data;
            wr_en = 1;

            @(negedge clk);
            wr_en = 0;
        end
    endtask

    task read_byte;
        begin
            @(negedge clk);
            rd_en = 1;

            @(negedge clk);
            rd_en = 0;
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, topmodule);

        reset = 1;
        wr_en = 0;
        rd_en = 0;
        din = 8'd0;

        #12 reset = 0;

        write_byte(8'hA5);
        write_byte(8'd39);
        write_byte(8'h10C);
        write_byte(8'b11011011);

        read_byte();
        #1 $display("Read 1: %h", dout);

        read_byte();
        #1 $display("Read 2: %h", dout);

        read_byte();
        #1 $display("Read 3: %h", dout);

        read_byte();
        #1 $display("Read 4: %h", dout);

        #50 $finish;
    end

endmodule