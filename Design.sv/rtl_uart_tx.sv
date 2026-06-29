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
