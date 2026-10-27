module shift_register_tb();

reg pclk;
reg PRESET_n;
reg ss_i;
reg send_data_i;
reg lsbfe_i;
reg cpha_i;
reg cpol_i;

reg miso_receive_sclk;
reg miso_receive_sclk0;
reg mosi_send_sclk;
reg mosi_send_sclk0;

reg miso_i;
reg receive_data_i;
reg [7:0] data_mosi_i;

wire mosi_o;
wire [7:0] data_miso_o;

reg [2:0] sppr_i;
reg [2:0] spr_i;
reg sclk_n;
reg spiswai_i;
reg [1:0] spi_mode_i;

integer i;


// DUT

Shift_register DUT(
    .pclk(pclk),
    .PRESET_n(PRESET_n),
    .ss_i(ss_i),
    .send_data_i(send_data_i),
    .lsbfe_i(lsbfe_i),
    .cpha_i(cpha_i),
    .cpol_i(cpol_i),

    .miso_receive_sclk(miso_receive_sclk),
    .miso_receive_sclk0(miso_receive_sclk0),

    .mosi_send_sclk(mosi_send_sclk),
    .mosi_send_sclk0(mosi_send_sclk0),

    .miso_i(miso_i),
    .receive_data_i(receive_data_i),

    .data_mosi_i(data_mosi_i),

    .mosi_o(mosi_o),
    .data_miso_o(data_miso_o)
);


// Baud-rate divisor
// sppr = 3'b000
// spr  = 3'b000
// divisor = (0+1) * 2^0 = 1

	wire pre_sclk_s;
	reg [11:0] count_s;
	wire [11:0] baudratedivisor;
	
	assign baudratedivisor=((sppr_i+1)*(2**(spr_i)));
	assign pre_sclk_s=(cpol_i)?1:0;
	
	//count and sclk gen
	
	always@(posedge pclk or negedge PRESET_n)
		begin
			if(!PRESET_n)
				begin	
					count_s<=12'b0;
					sclk_n<=pre_sclk_s;
				end
			else if(!ss_i&&!spiswai_i&&((spi_mode_i==2'b00)||(spi_mode_i==2'b01)))
				begin	
					if(count_s==(baudratedivisor/2)-2'b01)
						begin
							count_s<=12'b0;
							sclk_n<=~sclk_n;
						end
					else
						begin
							sclk_n<=sclk_n;
							count_s<=count_s+1;
						end
				end
			else
				begin
					sclk_n<=sclk_n;
					count_s<=12'b0;
				end
		end
		
	// flag generation miso receive
	
	always@(posedge pclk or negedge PRESET_n)
		begin
			if(!PRESET_n)
				begin
					miso_receive_sclk<=0;
					miso_receive_sclk0<=0;
				end
			else 
				begin	
					if((!cpha_i&&cpol_i)||(cpha_i&&!cpol_i))
						begin
							if(sclk_n)
								begin
									if(count_s==(baudratedivisor/2)-2'b01)
										miso_receive_sclk0<=1;
									else
										miso_receive_sclk0<=0;
								end
							else
								miso_receive_sclk0<=0;
						end
					else if((!cpha_i&&!cpol_i)||(cpha_i&&cpol_i))
						begin	
							if(!sclk_n)
								begin
									if(count_s==(baudratedivisor/2)-2'b01)
										miso_receive_sclk<=1;
									else
										miso_receive_sclk<=0;
								end
							else
								miso_receive_sclk<=0;
						end
				end
		end
		
	// flag for mosi send
	
	always@(posedge pclk or negedge PRESET_n)
		begin
			if(!PRESET_n)
				begin
					mosi_send_sclk<=0;
					mosi_send_sclk0<=0;
				end
			else
				begin
					if((!cpha_i&&cpol_i)||(cpha_i&&!cpol_i))
						begin
							if(sclk_n)
								begin
									if(count_s==(baudratedivisor/2)-2'b10)
										mosi_send_sclk0<=1;
									else
										mosi_send_sclk0<=0;
								end
							else
								mosi_send_sclk0<=0;
						end
					else if((!cpha_i&&!cpol_i)||(cpha_i&&cpol_i))
						begin	
							if(!sclk_n)
								begin
									if(count_s==(baudratedivisor/2)-2'b10)
										mosi_send_sclk<=1;
									else
										mosi_send_sclk<=0;
								end
							else
								mosi_send_sclk<=0;
						end
				end
		end
	
	initial
		pclk = 0;

		always #5
				pclk = ~pclk;
				
				
	task initilise;
		begin
			{
			PRESET_n,
			ss_i,
			send_data_i,
			lsbfe_i,
			cpha_i,
			cpol_i,

			miso_receive_sclk,
			miso_receive_sclk0,
			mosi_send_sclk,
			mosi_send_sclk0,

			miso_i,
			receive_data_i,
			data_mosi_i,
			sppr_i,
			spr_i,sclk_n,
			spiswai_i,
			spi_mode_i}=0;
		end
	endtask

	task reset;
		begin
			PRESET_n=0;
			#10;
			PRESET_n=1;
		end
	endtask
	
	task stim(input [7:0]a);
		begin
			send_data_i=1;
			lsbfe_i=0;
			cpha_i=0;
			cpol_i=0;
			sppr_i=3'b000;
			spr_i=3'b010;
			spiswai_i=0;
			spi_mode_i=2'b00;
			@(negedge pclk)
			data_mosi_i=a;
		end
	endtask
	
	task miso_stim;
		begin
			miso_i=1'b1;
		for(i=0;i<8;i=i+1)
				begin	
				@(negedge sclk_n)
					miso_i=~miso_i;
				end
		end
	endtask
	
	initial
		begin
			initilise;
			reset;
			fork
			
			stim(8'b11010110);
			#100;
			miso_stim;
			join
			
			receive_data_i=1;
			
			#2000 $finish;
		end
endmodule