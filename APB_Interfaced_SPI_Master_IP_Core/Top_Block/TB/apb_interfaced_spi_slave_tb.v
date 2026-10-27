module apb_interfaced_spi_slave_tb;
 reg pclk,PRESET_n,pwrite_i,penable_i,psel_i,miso_i;
 reg [2:0] paddr_i;
 reg [7:0] pwdata_i;
 wire ss_o,sclk_o,spi_interrupt_request_o,pready_o,pslverr_o,mosi_o;
 wire [7:0] prdata_o;
 integer i;
 apb_interfaced_spi_slave DUT(.pclk(pclk),.PRESET_n(PRESET_n),.pwrite_i(pwrite_i),.penable_i(penable_i),.psel_i(psel_i),.miso_i(miso_i),.paddr_i(paddr_i),.pwdata_i(pwdata_i),
                                    .ss_o(ss_o),.sclk_o(sclk_o),.spi_interrupt_request_o(spi_interrupt_request_o),.pready_o(pready_o),.pslverr_o(pslverr_o),.mosi_o(mosi_o),.prdata_o(prdata_o));
			
	
	initial
	 begin
	  pclk=0;
	  forever #20 pclk=~pclk;
	 end
	
	task initialize;
	 begin
	  {pwrite_i,penable_i,psel_i,miso_i,paddr_i,pwdata_i}=0;
	 end
	endtask
	
	task reset;
	 begin
	  PRESET_n=1'b0;
	  #20;
	  PRESET_n=1'b1;
	  
	 end
	endtask
	
	
	task write_stimulus(input [2:0] paddr,input [7:0] pwdata);
	 begin
	 @(negedge pclk)
	  pwrite_i=1'b1;
	  psel_i=1'b1;
	  penable_i=1'b0;
	  paddr_i=paddr;
	  pwdata_i=pwdata;
	 // miso_i=miso;
	 @(negedge pclk)
	  psel_i=1'b1;
	  penable_i=1'b1;
	 @(negedge pclk)
	  psel_i=1'b0;
	  penable_i=1'b0;
	  
	 end
	endtask
	
	task miso_values;
		 begin
		  miso_i=0;
		  for(i=0;i<8;i=i+1)
		   begin
		    @(negedge sclk_o)
			  miso_i=~miso_i;
		   end
		 end
	endtask
	
	task read_stimulus(input [2:0] paddr1);
	 begin
	  @(negedge pclk)
	     pwrite_i=1'b0;
		 psel_i=1'b1;
		 penable_i=1'b0;
	   @(negedge pclk)
	   paddr_i=paddr1;
	    psel_i=1'b1;
	    penable_i=1'b1;
	  @(negedge pclk)
	    psel_i=1'b0;
	    penable_i=1'b0;
		 
	 end
	endtask
	
	
	initial
	 begin
	  initialize;
	  reset;
	  write_stimulus(3'b000,8'b1111_0111);//cr1
	  //miso_values;
	 // read_stimulus(3'b000);
	  #20;
	  write_stimulus(3'b001,8'b1111_1101);//cr2
	  //miso_values;
	 // read_stimulus(3'b001);
	  #20
	  write_stimulus(3'b010,8'b1001_1001);//br-->24
	  //miso_values;
	  ///read_stimulus(3'b010);
	  #20;
	  write_stimulus(3'b101,8'd57);//dr
	  miso_values;
	  wait(ss_o);
	  read_stimulus(3'b101);
	  #4000 $finish;
	  
	 end
endmodule