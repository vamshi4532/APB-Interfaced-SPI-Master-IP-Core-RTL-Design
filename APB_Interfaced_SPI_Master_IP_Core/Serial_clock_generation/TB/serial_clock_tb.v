module serial_clock_tb();
    reg pclk;
	reg PRESET_n;
	reg spiswai_i;
	reg cpol_i;
	reg cpha_i;
	reg ss_i;
	reg [1:0]spi_mode_i;
	reg [2:0]sppr_i;
	reg [2:0]spr_i;
	wire sclk_o;
	wire miso_receive_sclk_o;
	wire miso_receive_sclk0_o;
	wire mosi_send_sclk_o;
	wire mosi_send_sclk0_o;
	wire [11:0]baudratedivisor_o;

serial_clock DUT (pclk,
				  PRESET_n,
				  spiswai_i,
				  cpol_i,
				  cpha_i,
				  ss_i,
				  spi_mode_i,
				  sppr_i,
				  spr_i,
				  sclk_o,
				  miso_receive_sclk_o,
				  miso_receive_sclk0_o,
				  mosi_send_sclk_o,
				  mosi_send_sclk0_o,
				  baudratedivisor_o);

initial 
   begin 
    pclk =1'b0;
    forever 
	#10 pclk = ~pclk;
   end
   
task initialize();
  begin
   spiswai_i=1'b0;
	cpol_i=1'b0;
    cpha_i=1'b0;
	ss_i=1'b0;
	//spi_mode_i=2'b00;
	sppr_i=3'b000;
	spr_i=3'b000;
  end
endtask
task reset();
  begin
    PRESET_n = 1'b0;
    #20;
    PRESET_n = 1'b1;
   end
endtask
task values(input j,input i);
   begin
   spi_mode_i=2'b01;
   spiswai_i= 1'b0;
   sppr_i=3'b000;
   spr_i=3'b010;
   cpol_i=j;
   cpha_i=i;
   ss_i=1'b0;
end
endtask
initial
  begin
     initialize();
	 reset();
	 #10;
	 @(negedge pclk)
	 //values(1'b0,1'b1);
	 //#300;
	 //values(1'b0,1'b0);
	 //#300;
	// @(negedge pclk)
	 //values(1'b1,1'b1);
	// #300;
	 values(1'b0,1'b0);
	 #1000 $finish;
  end
initial
  begin  
 $monitor("baudratedivisor_o=%d",baudratedivisor_o);
  end
endmodule