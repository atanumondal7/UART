`timescale 1ns/1ps

module uart_top #(parameter int CLK_FREQ = 100000000, parameter int BAUD_RATE = 115200, parameter int OVERSAMPLE = 16) (
input logic clk,
input logic rst_n,

input logic [7:0] tx_data,
input logic tx_start,
output logic tx_out,
output logic tx_busy,

input logic rx_in,
output logic [7:0] rx_data,
output logic rx_ready,
output logic rx_error
);

uart_tx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) dut_tx (
.clk(clk),
.rst_n(rst_n),
.tx_start(tx_start),
.tx_data(tx_data),
.tx_out(tx_out),
.tx_busy(tx_busy),
.tx_done(tx_done)
);

uart_rx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE), .OVERSAMPLE(OVERSAMPLE)) dut_rx (
.clk(clk),
.rst_n(rst_n),
.rx_in(rx_in),
.rx_data(rx_data),
.rx_ready(rx_ready),
.rx_error(rx_error)
);

endmodule