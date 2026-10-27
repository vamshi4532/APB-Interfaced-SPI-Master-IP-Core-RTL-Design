module APB_slave_interface(
input pclk, PRESET_n, pwrite_i, psel_i, penable_i, ss_i, receive_data_i, tip_i,
input [2:0] paddr_i,
input [7:0] pwdata_i, miso_data_i,
output reg [7:0] mosi_data_o,
output reg send_data_o,
output reg [7:0] prdata_o,
output [2:0] sppr_o, spr_o,
output reg [1:0] spi_mode_o,
output mstr_o, cpol_o, cpha_o, lsbfe_o, spiswai_o, pslverr_o, pready_o,
output reg spi_interrupt_request_o
);
reg [7:0] SPI_BR;
reg [7:0] SPI_CR1;
reg [7:0] SPI_CR2;
reg [7:0] SPI_SR;
reg [7:0] SPI_DR;
wire sptef;
wire spif;
wire spe;
wire spi;
wire modfen;
wire modf;
wire ssoe;
wire wr_enb;
wire rd_enb;
wire spie;
wire sptie;
parameter cr2_mask = 8'b0001_1011;
parameter br_mask = 8'b0111_0111;
parameter spi_run = 2'b00;
parameter spi_wait = 2'b01;
parameter spi_stop = 2'b10;
reg [1:0] next_mode;
reg [1:0] STATE, next_state;
parameter IDLE = 2'b00;
parameter SETUP = 2'b01;
parameter ENABLE = 2'b10;
assign pready_o = (STATE == ENABLE) ? 1'b1 : 1'b0;
assign wr_enb = ((STATE == ENABLE) && pwrite_i) ? 1'b1 : 1'b0;
assign rd_enb = ((STATE == ENABLE) && !pwrite_i) ? 1'b1 : 1'b0;
assign pslverr_o = (STATE == ENABLE) ? ~tip_i : 1'b0;
assign sptef = (SPI_DR == 8'b0) ? 1'b0 : 1'b1;
assign spif = (SPI_DR != 8'b0) ? 1'b1 : 1'b0;
assign mstr_o = SPI_CR1[4];
assign cpol_o = SPI_CR1[3];
assign cpha_o = SPI_CR1[2];
assign lsbfe_o = SPI_CR1[0];
assign spie = SPI_CR1[7];
assign spe = SPI_CR1[6];
assign sptie = SPI_CR1[5];
assign modfen = SPI_CR2[4];
assign spiswai_o = SPI_CR2[1];
assign sppr_o = SPI_BR[6:4];
assign spr_o = SPI_BR[2:0];
assign ssoe = SPI_CR1[1];
assign modf = (!ss_i && mstr_o && modfen && !ssoe);
assign spi = spe;
always @(posedge pclk or negedge PRESET_n)
	begin
		if(!PRESET_n)
			STATE <= IDLE;
		else
			STATE <= next_state;
	end
always @(*)
	begin
		case(STATE)
			IDLE:
				begin
					if(psel_i && !penable_i)
						next_state = SETUP;
					else
						next_state = IDLE;
	end
			SETUP:
				begin
					if(psel_i && penable_i)
						next_state = ENABLE;
					else if(!psel_i)
						next_state = IDLE;
					else
						next_state = SETUP;
				end
			ENABLE:
			begin
				if(!psel_i)
					next_state = IDLE;
				else
					next_state = SETUP;
			end
			default:
				next_state = IDLE;
		endcase
	end
always @(posedge pclk or negedge PRESET_n)
	begin
		if(!PRESET_n)
			spi_mode_o <= spi_run;
		else
			spi_mode_o <= next_mode;
	end
always @(*)
	begin
		case(spi_mode_o)
			spi_run:
				begin
					if(!spie)
						next_mode = spi_wait;
					else
						next_mode = spi_run;
	            end
			spi_wait:
			begin
				if(spie)
					next_mode = spi_run;
				else if(spiswai_o)
					next_mode = spi_stop;
				else
					next_mode = spi_wait;
			end
			spi_stop:
				begin
					if(!spiswai_o)
						next_mode = spi_wait;
					else if(spie)
						next_mode = spi_run;
					else
						next_mode = spi_stop;
				end
				default:
					next_mode = spi_run;
		endcase
	end
always @(posedge pclk or negedge PRESET_n)
	begin
		if(!PRESET_n)
			SPI_CR1 <= 8'h04;
		else
		begin
			if(wr_enb && (paddr_i == 3'b000))
			SPI_CR1 <= pwdata_i;
		end
	end
always @(posedge pclk or negedge PRESET_n)
	begin
		if(!PRESET_n)
			SPI_CR2 <= 8'h00;
		else
		begin
			if(wr_enb && (paddr_i == 3'b001))
			SPI_CR2 <= pwdata_i & cr2_mask;
		end
	end
always @(posedge pclk or negedge PRESET_n)
	begin
		if(!PRESET_n)
			SPI_BR <= 8'h00;
		else
		begin
			if(wr_enb && (paddr_i == 3'b010))
			SPI_BR <= pwdata_i & br_mask;
		end
	end
always @(posedge pclk or negedge PRESET_n)
	begin
		if(!PRESET_n)
			SPI_DR <= 8'h00;
		else
		begin
			if(wr_enb && (paddr_i == 3'b101))
				SPI_DR <= pwdata_i;
			else if(!wr_enb)
			begin
				if((SPI_DR == pwdata_i) && (SPI_DR != miso_data_i) && ((spi_mode_o == spi_run) || (spi_mode_o == spi_wait)))
					SPI_DR <= 8'b0;
				else if(receive_data_i && ((spi_mode_o == spi_run) || (spi_mode_o == spi_wait)))
				SPI_DR <= miso_data_i;
			end
	    end
	end
always @(posedge pclk or negedge PRESET_n)
	begin
		if(!PRESET_n)
			send_data_o <= 1'b0;
		else
		begin
			if(wr_enb)
				send_data_o <= 1'b0;
			else if((SPI_DR == pwdata_i) && (SPI_DR != miso_data_i) && ((spi_mode_o == spi_run) || (spi_mode_o == spi_wait)))
				send_data_o <= 1'b1;
			else
			send_data_o <= 1'b0;
		end
	end
always @(posedge pclk or negedge PRESET_n)
	begin
		if(!PRESET_n)
			mosi_data_o <= 8'b0;
		else if((SPI_DR == pwdata_i) && (SPI_DR != miso_data_i) && ((spi_mode_o == spi_run) || (spi_mode_o == spi_wait)))
		mosi_data_o <= SPI_DR;
	end
always @(*)
	begin
		if(!spie && !sptie)
			spi_interrupt_request_o = 1'b0;
		else if(!sptie && spie)
			spi_interrupt_request_o = (spif | modf);
		else if(!spie && sptie)
			spi_interrupt_request_o = sptef;
		else
		spi_interrupt_request_o = (spif | modf | sptef);
	end
always @(*)
	begin
		if(rd_enb)
			begin
			case(paddr_i)
				3'b000: prdata_o = SPI_CR1;
				3'b001: prdata_o = SPI_CR2;
				3'b010: prdata_o = SPI_BR;
				3'b011: prdata_o = SPI_SR;
				3'b101: prdata_o = SPI_DR;
				default: prdata_o = 8'h00;
			endcase
			end
		else
			begin
			prdata_o = 8'b0;
	end
	end
	
always @(*)
	begin
		if(!PRESET_n)
			SPI_SR = 8'b00100000;
		else
		SPI_SR = {spif,1'b0,sptef,modf,4'b0};
	end
endmodule