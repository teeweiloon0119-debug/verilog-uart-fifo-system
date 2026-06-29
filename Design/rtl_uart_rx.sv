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