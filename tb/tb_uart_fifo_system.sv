module topmodule();
  reg clk, reset, rx_serial;
  wire[7:0] rx_out, tx_in;
  wire rx_valid, tx_serial, tx_busy, tx_done, fifo_full, fifo_empty;
  
  uart_final inst(clk, reset, rx_serial, rx_out, tx_in, rx_valid, tx_serial, tx_busy, tx_done, fifo_full, fifo_empty);
  
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  task send_byte;
    input [7:0] data;
    integer i;
    begin
      
      @(negedge clk)
      rx_serial = 0;
      
      for(i=0; i<8; i++) begin
        @(negedge clk) rx_serial = data[i];
      end
      
      @(negedge clk)
      rx_serial = 1;
    end
  endtask
      
    
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, topmodule);
    
    reset = 1;
    rx_serial = 1;
    
    #10 reset =0;
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