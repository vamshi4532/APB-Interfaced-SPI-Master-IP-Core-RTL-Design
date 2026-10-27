module spi_slave_control_select(
	input pclk,PRESET_n,mstr_i,spiswai_i,send_data_i,
	input [1:0]spi_mode_i,
	input [11:0]baudratedivisor_i,
	output reg receive_data_o,ss_o,
	output tip_o);
	
	reg [15:0]count;
	wire [15:0]target;
	reg rcv;
	
	assign tip_o=~ss_o;
	assign target=(baudratedivisor_i/2)*16;
	
	parameter 	spi_run=2'b00,
				spi_wait=2'b01;	
	
	always@(posedge pclk or negedge PRESET_n) 
		begin
			if(!PRESET_n)
				receive_data_o<=1'b0;
			else
				receive_data_o<=rcv;
		end
		
	always@(posedge pclk or negedge PRESET_n)
		begin
			if(!PRESET_n)
				begin
					count<=16'hffff;
					ss_o<=1'b1;
					rcv<=1'b0;
				end
			else if(mstr_i&&((spi_mode_i==spi_run)||(spi_mode_i==spi_wait))&&!spiswai_i)
				begin
					if(send_data_i)
						begin
							count<=16'b0;
							ss_o<=1'b0;
							rcv<=1'b0;
						end
					else if(count<=target-1'b1)
							begin
								count<=count+1'b1;
								ss_o<=1'b0;
					        if(count==target-1)
								begin
								rcv<=1;
								end
							end
					else
					 begin
					  rcv<=0;
					  ss_o<=1;
					  count<=16'hffff;
					 end
				end
			else
				begin	
					count<=16'hffff;
					ss_o<=1'b1;
					rcv<=1'b0;
				end
		end
endmodule