module topmodule();
  
  reg clk, reset, in;
  wire[7:0] data_out;
  wire valid;
  
  uart_rx inst(clk, reset, in, data_out, valid);
  
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  task send_byte;
        input [7:0] data;
        integer i;
        begin
          @(negedge clk);
            in = 0;

          @(negedge clk);  // extra cycle because our FSM has START state
            in = 0;

          for (i = 0; i < 8; i = i + 1) begin
            @(negedge clk);
            	in = data[i];                
          end
            // stop bit
          @(negedge clk);
            in = 1;
        end
   endtask
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    
    reset =1;
    in = 1;
    #10 reset = 0;
    send_byte(8'hA5);
    #20;

    send_byte(8'h3C);
    #20;

    send_byte(8'h00);
    #20;

    send_byte(8'hFF);
    #30;
    
    $finish;
  end
endmodule
