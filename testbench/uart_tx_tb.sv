`timescale 1ns/1ps

package uart_tx_pkg;

parameter int CLK_FREQ = 100000000;
parameter int BAUD_RATE = 115200;

endpackage

import uart_tx_pkg::*;

module uart_tx_tb;

logic clk = 0;
logic rst_n;
logic tx_start;
logic [7:0] tx_data;
logic tx_out;
logic tx_busy;
logic tx_done;

always #10 clk = ~clk;

uart_tx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) dut (
.clk(clk),
.rst_n(rst_n),
.tx_start(tx_start),
.tx_data(tx_data),
.tx_out(tx_out),
.tx_busy(tx_busy),
.tx_done(tx_done)
);

initial begin

$monitor("rst_n=%0b, tx_start=%0b, tx_data=%b, tx_out=%0b, tx_busy=%0b, tx_done=%0b", rst_n, tx_start, tx_data, tx_out, tx_busy, tx_done);

rst_n = 0; #11;
rst_n = 1; tx_start = 1; tx_data = 8'b01010101; #16000;
tx_data = 8'b10101010; #20000;

$finish;

end

endmodule