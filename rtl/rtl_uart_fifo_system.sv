module uart_tx (
    input clk,
    input reset,
    input start,
    input [7:0] in,
    output reg tx,
    output busy,
    output done
);
  
  reg[2:0] state, next;
  reg[2:0] count;
  reg[7:0] data;
  parameter IDLE=0, START=1, DATA=2, STOP=3, DONE=4;
  
  always@(*) begin
    case(state)
      IDLE: next = start ? START : IDLE;
      START: next = DATA;
      DATA: begin
        if(count==7)
          next = STOP;
        else 
          next = DATA;
      end
      STOP: next = DONE;
      DONE: next = IDLE;
    endcase
  end
  
  always @(posedge clk) begin
    if(reset) begin
      state <= IDLE;
      count <= 0;
      tx <= 1;
      data <= 0;
    end
    else begin
      state <= next;
      case(state)
        IDLE: begin
          count <= 0;
          tx <= 1;
          if(start)
            data <= in;
        end
        START: 
          tx <= 0;

        DATA: begin
          tx <= data[count];
          count <= count+1;
        end
        STOP: 
          tx <= 1;
      endcase
    end
          
  end
      
  assign done = (state==DONE);
  assign busy = (state==START) || (state==DATA) || (state==STOP);
    
endmodule


module uart_rx (
    input clk,
    input reset,
    input in,
    output reg [7:0] data_out,
    output valid
);
  
  reg[2:0] state, next;
  reg[2:0] bit_count;
  reg[7:0] shift_reg;
  parameter IDLE=0,START=1,DATA=2,STOP=3,WAIT=4,DONE=5;
  
  always@(*) begin
    case(state)
      IDLE: next = in ? IDLE : START;
      START: next = DATA;
      DATA: begin
        if(bit_count == 7)
          next = STOP;
        else
          next = DATA;
      end
      STOP: next = in ? DONE : WAIT;
      WAIT: next = in ? IDLE : WAIT;
      DONE: next = IDLE;
    endcase
  end
    
  
  always@(posedge clk) begin
    
    if(reset) begin
      state <= IDLE;
      bit_count <= 0;
      shift_reg <= 0;
      data_out <= 0;
    end
    
    else begin
      state <= next;
      case(state)
        IDLE: bit_count <=0;
        START: begin
          shift_reg[0] <= in;  //add this to make sure receiver is on the 
          bit_count <= 1;      //same pace as transmitter
        end
        DATA: begin
          shift_reg[bit_count] <= in;
          bit_count <= bit_count+1;
        end
        STOP: data_out <= shift_reg;
      endcase
    end
      
  end
  
  assign valid = (state == DONE);
  
endmodule

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

module uart_final(
  input clk,
  input reset,
  
  input rx_serial, 
  output [7:0] rx_out,
  output [7:0] tx_in,
  output rx_valid,
  
  output tx_serial,
  output tx_busy,
  output tx_done,
  
  output fifo_full,
  output fifo_empty
  
);
  reg wr_en, rd_en, tx_start;
  
  assign wr_en = rx_valid && !fifo_full;
   
  uart_rx inst1(clk, reset, rx_serial, rx_out, rx_valid);
  fifo_sync inst2(clk, reset, wr_en, rx_out, rd_en, tx_in, fifo_full, fifo_empty);
  uart_tx inst3(clk, reset, tx_start, tx_in, tx_serial, tx_busy, tx_done);
  
  reg [1:0] ctrl_state, ctrl_next; //to delay tx_start one cycle after rd_en
  								   //or else tx_in updated in fifo won't be 								   //able to update in uart_tx since they 									   //happen in the same cycle

  parameter C_IDLE  = 0,
            C_READ  = 1,
            C_START = 2;

  always @(*) begin
    rd_en = 0;
    tx_start   = 0;
    ctrl_next  = ctrl_state;

    case(ctrl_state)
      C_IDLE: begin
        if(!fifo_empty && !tx_busy)
          ctrl_next = C_READ;
        else
          ctrl_next = C_IDLE;
      end

      C_READ: begin
        rd_en = 1;
        ctrl_next = C_START;
      end

      C_START: begin
        tx_start = 1;
        ctrl_next = C_IDLE;
      end

      default: begin
        ctrl_next = C_IDLE;
      end
    endcase
  end

  always @(posedge clk) begin
    if(reset)
      ctrl_state <= C_IDLE;
    else
      ctrl_state <= ctrl_next;
  end
  
endmodule
                  
