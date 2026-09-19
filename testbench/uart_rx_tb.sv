`timescale 1ns/1ps

package uart_rx_tb_pkg;

parameter int CLK_FREQ = 100000000;
parameter int BAUD_RATE = 115200;
parameter int OVERSAMPLE = 16;

endpackage

import uart_rx_tb_pkg::*;

module uart_rx_tb;

logic clk;
logic rst_n;
logic rx_in;
logic [7:0] rx_data;
logic rx_ready;
logic rx_error;

always #10 clk = ~clk;

uart_rx_tb #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE), .OVERSAMPLE(OVERSAMPLE)) dut (
.clk(clk),
.rst_n(rst_n),
.rx_in(rx_in),
.rx_data(rx_data),
.rx_ready(rx_ready),
.rx_error(rx_error)
);

initial begin

$monitor("rst_n=%0b, rx_in=%0b, rx_data=%b, rx_ready=%0b, rx_error=%0", rst_n, rx_in, rx_data, rx_ready, rx_error);

rst_n = 0; #11;
rst_n = 1; rx_in = 0; #10;
rx_in = 1; #10;

#50;

$finish;

end

endmodule