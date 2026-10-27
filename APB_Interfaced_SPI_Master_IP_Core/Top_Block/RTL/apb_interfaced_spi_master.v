module apb_interfaced_spi_master(
    input pclk,
    input PRESET_n,
    input pwrite_i,
    input psel_i,
    input penable_i,
    input [2:0] paddr_i,
    input [7:0] pwdata_i,
    input miso_i,
    output [7:0] prdata_o,
    output pready_o,
    output pslverr_o,
    output spi_interrupt_request_o,
    output sclk_o,
    output mosi_o,
    output ss_o
);

wire ss_s;
wire receive_data_s;
wire send_data_s;
wire tip_s;
wire [7:0] mosi_data_s;
wire [7:0] miso_data_s;
wire [7:0] data_miso_s;
wire [2:0] sppr_s;
wire [2:0] spr_s;
wire [1:0] spi_mode_s;
wire mstr_s;
wire cpol_s;
wire cpha_s;
wire lsbfe_s;
wire spiswai_s;
wire [11:0] baudratedivisor_s;
wire miso_receive_sclk_s;
wire miso_receive_sclk0_s;
wire mosi_send_sclk_s;
wire mosi_send_sclk0_s;

APB_slave_interface U1(
    .pclk(pclk),
    .PRESET_n(PRESET_n),
    .pwrite_i(pwrite_i),
    .psel_i(psel_i),
    .penable_i(penable_i),
    .ss_i(ss_s),
    .receive_data_i(receive_data_s),
    .tip_i(tip_s),
    .paddr_i(paddr_i),
    .pwdata_i(pwdata_i),
    .miso_data_i(data_miso_s),
    .mosi_data_o(mosi_data_s),
    .send_data_o(send_data_s),
    .prdata_o(prdata_o),
    .sppr_o(sppr_s),
    .spr_o(spr_s),
    .spi_mode_o(spi_mode_s),
    .mstr_o(mstr_s),
    .cpol_o(cpol_s),
    .cpha_o(cpha_s),
    .lsbfe_o(lsbfe_s),
    .spiswai_o(spiswai_s),
    .spi_interrupt_request_o(spi_interrupt_request_o),
    .pready_o(pready_o),
    .pslverr_o(pslverr_o)
);

serial_clock U2(
    .pclk(pclk),
    .PRESET_n(PRESET_n),
    .spiswai_i(spiswai_s),
    .cpol_i(cpol_s),
    .cpha_i(cpha_s),
    .ss_i(ss_s),
    .spi_mode_i(spi_mode_s),
    .sppr_i(sppr_s),
    .spr_i(spr_s),
    .sclk_o(sclk_o),
    .miso_receive_sclk_o(miso_receive_sclk_s),
    .miso_receive_sclk0_o(miso_receive_sclk0_s),
    .mosi_send_sclk_o(mosi_send_sclk_s),
    .mosi_send_sclk0_o(mosi_send_sclk0_s),
    .baudratedivisor_o(baudratedivisor_s)
);

Shift_register U3(
    .pclk(pclk),
    .PRESET_n(PRESET_n),
    .ss_i(ss_s),
    .send_data_i(send_data_s),
    .lsbfe_i(lsbfe_s),
    .cpha_i(cpha_s),
    .cpol_i(cpol_s),
    .miso_receive_sclk(miso_receive_sclk_s),
    .miso_receive_sclk0(miso_receive_sclk0_s),
    .mosi_send_sclk(mosi_send_sclk_s),
    .mosi_send_sclk0(mosi_send_sclk0_s),
    .miso_i(miso_i),
    .receive_data_i(receive_data_s),
    .data_mosi_i(mosi_data_s),
    .mosi_o(mosi_o),
    .data_miso_o(data_miso_s)
);

spi_slave_control_select U4(
    .pclk(pclk),
    .PRESET_n(PRESET_n),
    .mstr_i(mstr_s),
    .spiswai_i(spiswai_s),
    .send_data_i(send_data_s),
    .spi_mode_i(spi_mode_s),
    .baudratedivisor_i(baudratedivisor_s),
    .receive_data_o(receive_data_s),
    .ss_o(ss_s),
    .tip_o(tip_s)
);

assign ss_o = ss_s;

endmodule
