module spi_slave_control_select_tb();
	reg pclk,PRESET_n,mstr_i,spiswai_i,send_data_i;
	reg [1:0]spi_mode_i;
	reg [11:0]baudratedivisor_i;
	wire receive_data_o,ss_o,tip_o;
	
	spi_slave_control_select dut(pclk,PRESET_n,mstr_i,spiswai_i,send_data_i,spi_mode_i,baudratedivisor_i,receive_data_o,ss_o,tip_o);
	
	
	always
		begin
			pclk=1;
			#5;
			pclk=~pclk;
			#5;
		end
		
	task initilise;
		begin
			{mstr_i,spiswai_i,send_data_i,spi_mode_i,baudratedivisor_i}=0;
		end
	endtask
	
	task reset;
		begin
			@(negedge pclk)
			PRESET_n=0;
			@(negedge pclk)
			PRESET_n=1;
		end
	endtask
	
	task stim;
		begin
			@(negedge pclk);
			spiswai_i = 0;
			send_data_i = 1;
			mstr_i = 1;
			spi_mode_i = 2'b00;

			repeat(2)
				@(negedge pclk);

			send_data_i = 0;

			repeat(50)
				@(negedge pclk);
		end
	endtask
	
	initial
	begin
		initilise;
		baudratedivisor_i = 4;
		reset;
		stim;
		$finish;
	end
endmodule