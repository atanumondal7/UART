`timescale 1ns/1ps

package uart_tx_pkg;
parameter int CLK_FREQ = 100000000;
parameter int BAUD_RATE = 115200;
endpackage

module uart_tx_tb;
import uart_tx_pkg::*;

logic clk = 0;
logic rst_n = 0;
logic tx_start = 0;
logic [7:0] tx_data = '0;
logic tx_out;
logic tx_busy;
logic tx_done;

always #5 clk = ~clk;

uart_tx #(
.CLK_FREQ(CLK_FREQ), 
.BAUD_RATE(BAUD_RATE)
) dut (
.clk(clk),
.rst_n(rst_n),
.tx_start(tx_start),
.tx_data(tx_data),
.tx_out(tx_out),
.tx_busy(tx_busy),
.tx_done(tx_done)
);

initial begin
$monitor("Time=%0t | rst_n=%b | tx_start=%b | tx_data=%h | tx_out=%b | tx_busy=%b | tx_done=%b", 
$time, rst_n, tx_start, tx_data, tx_out, tx_busy, tx_done);

#100;
rst_n = 1;
#100;

@(posedge clk);
tx_data  = 8'h55;
tx_start = 1;
@(posedge clk);
tx_start = 0;

@(posedge tx_done);
#500

@(posedge clk);
tx_data  = 8'hAA;
tx_start = 1;
@(posedge clk);
tx_start = 0;

@(posedge tx_done);
#1000;

$finish;
end

endmodule