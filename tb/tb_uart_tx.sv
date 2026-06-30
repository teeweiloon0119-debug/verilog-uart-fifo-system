module topmodule();
  reg clk, reset, start;
  reg[7:0] in;
  wire tx, busy, done;
  
  uart_tx inst(clk, reset, start, in, tx, busy, done);
  
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, topmodule);
    reset = 1;
    start = 0;
    in = 0;
    
    #10 reset = 0;
    #10 start =1; in=8'hA5;
    #10 start = 0;
    wait(done);
    
    #30 start=1; in=8'h3c;
    #10 start=0;
    wait(done);
    
    #30 $finish;
  end

endmodule