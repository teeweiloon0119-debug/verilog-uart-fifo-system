module fifo_sync (
    input clk,
    input reset,

    input wr_en,
    input [7:0] din,

    input rd_en,
    output reg [7:0] dout,

    output full,
    output empty
);

    reg [7:0] mem [0:15];
    reg [3:0] wr_ptr;
    reg [3:0] rd_ptr;
    reg [4:0] count;

    assign full  = (count == 5'd16);
    assign empty = (count == 5'd0);

    always @(posedge clk) begin
        if (reset) begin
            wr_ptr <= 4'd0;
            rd_ptr <= 4'd0;
            count  <= 5'd0;
            dout   <= 8'd0;
        end else begin

            // Write only when not full
            if (wr_en && !full) begin
                mem[wr_ptr] <= din;
                wr_ptr <= wr_ptr + 4'd1;
            end

            // Read only when not empty
            if (rd_en && !empty) begin
                dout <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 4'd1;
            end

            // Update count
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 5'd1; // write only
                2'b01: count <= count - 5'd1; // read only
                2'b11: count <= count;        // write and read same time
                2'b00: count <= count;        // no operation
            endcase
        end
    end

endmodule