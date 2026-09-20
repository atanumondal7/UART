`timescale 1ns/1ps

import uvm_pkg::*;
import uart_pkg::*;
`include "uvm_macros.svh"

module uart_tb_top;

logic clk = 0;

always #5 clk = ~clk;

uart_if vif(clk);

assign vif.rx_in = vif.tx_out;

uart_top #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE), .OVERSAMPLE(OVERSAMPLE)) dut (
.clk(clk),
.rst_n(vif.rst_n),
.tx_data(vif.tx_data),
.tx_start(vif.tx_start),
.tx_out(vif.tx_out),
.tx_busy(vif.tx_busy),
.rx_in(vif.rx_in),
.rx_data(vif.rx_data),
.rx_ready(vif.rx_ready),
.rx_error(vif.rx_error)
);

initial begin
vif.rst_n = 0;
#100;
vif.rst_n = 1;
end

initial begin
uvm_config_db#(virtual uart_if)::set(null, "*", "vif", vif);
run_test("uart_test");
end

endmodule 