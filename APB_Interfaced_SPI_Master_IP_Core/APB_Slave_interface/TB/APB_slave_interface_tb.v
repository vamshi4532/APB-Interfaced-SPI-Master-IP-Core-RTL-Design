module APB_slave_interface_tb;

reg pclk;
reg PRESET_n;
reg pwrite_i;
reg psel_i;
reg penable_i;
reg ss_i;
reg receive_data_i;
reg tip_i;
reg [2:0] paddr_i;
reg [7:0] pwdata_i;
reg [7:0] miso_data_i;

wire [7:0] mosi_data_o;
wire send_data_o;
wire [7:0] prdata_o;
wire [2:0] sppr_o;
wire [2:0] spr_o;
wire [1:0] spi_mode_o;
wire mstr_o;
wire cpol_o;
wire cpha_o;
wire lsbfe_o;
wire spiswai_o;
wire spi_interrupt_request_o;
wire pready_o;
wire pslverr_o;

APB_slave_interface DUT(.pclk(pclk),.PRESET_n(PRESET_n),.pwrite_i(pwrite_i),.psel_i(psel_i),.penable_i(penable_i),.ss_i(ss_i),.receive_data_i(receive_data_i),.tip_i(tip_i),.paddr_i(paddr_i),
                        .pwdata_i(pwdata_i),.miso_data_i(miso_data_i),.mosi_data_o(mosi_data_o),.send_data_o(send_data_o),.prdata_o(prdata_o),.sppr_o(sppr_o),.spr_o(spr_o),.spi_mode_o(spi_mode_o),
                        .mstr_o(mstr_o),.cpol_o(cpol_o),.cpha_o(cpha_o),.lsbfe_o(lsbfe_o),.spiswai_o(spiswai_o),.spi_interrupt_request_o(spi_interrupt_request_o),.pready_o(pready_o),
						.pslverr_o(pslverr_o));
initial 
	begin
		pclk = 1'b0;
		forever #5 pclk = ~pclk;
	end

	task apb_write;
		input [2:0] addr;
		input [7:0] data;
		begin
			@(posedge pclk);
			psel_i = 1'b1;
			penable_i = 1'b0;
			pwrite_i = 1'b1;
			paddr_i = addr;
			pwdata_i = data;

			@(posedge pclk);
			penable_i = 1'b1;

			wait(pready_o == 1'b1);

			@(posedge pclk);
			psel_i = 1'b0;
			penable_i = 1'b0;
			pwrite_i = 1'b0;
		end
	endtask

task apb_read;
	input [2:0] addr;
	begin
		@(posedge pclk);
		psel_i = 1'b1;
		penable_i = 1'b0;
		pwrite_i = 1'b0;
		paddr_i = addr;

		@(posedge pclk);
		penable_i = 1'b1;

		wait(pready_o == 1'b1);

		@(posedge pclk);
		psel_i = 1'b0;
		penable_i = 1'b0;
	end
endtask

initial
	begin
		PRESET_n = 1'b0;
		pwrite_i = 1'b0;
		psel_i = 1'b0;
		penable_i = 1'b0;
		ss_i = 1'b1;
		receive_data_i = 1'b0;
		tip_i = 1'b0;
		paddr_i = 3'b000;
		pwdata_i = 8'h00;
		miso_data_i = 8'h00;
		#20;
		PRESET_n = 1'b1;
		#20;
		apb_write(3'b000,8'hDD);
		#20;
		apb_read(3'b000);
		#10;
		apb_write(3'b001,8'h1B);
		apb_read(3'b001);
		apb_write(3'b010,8'h77);
		apb_read(3'b010);
		#100;
		apb_write(3'b101,8'hA5);
		apb_read(3'b101);
		miso_data_i = 8'h5A;
		receive_data_i = 1'b1;
		#20;
		receive_data_i = 1'b0;
		#20;
		ss_i = 1'b0;
		#20;
		ss_i = 1'b1;
		#20;
		$finish;
	end

endmodule