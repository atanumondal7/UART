`timescale 1ns/1ps

package uart_rx_tb_pkg;
parameter int CLK_FREQ = 100_000_000;
parameter int BAUD_RATE = 115200;
parameter int OVERSAMPLE = 16;
endpackage

module uart_rx_tb;
import uart_rx_tb_pkg::*;

localparam real CLK_PERIOD = 1.0e9 / CLK_FREQ;
localparam real BIT_PERIOD = 1.0e9 / BAUD_RATE;

logic clk = 0;
logic rst_n;
logic rx_in;
logic [7:0] rx_data;
logic rx_ready, rx_error;

always #(CLK_PERIOD/2) clk = ~clk;

uart_rx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE), .OVERSAMPLE(OVERSAMPLE)) dut (
.clk, .rst_n, .rx_in, .rx_data, .rx_ready, .rx_error
);

logic [7:0] exp_q[$];
int errors = 0;

always @(posedge clk) if (rx_ready) begin
if (exp_q.size() == 0) begin
$error("Unexpected rx_ready, data=%h", rx_data); errors++;
end else begin
logic [7:0] exp = exp_q.pop_front();
if (rx_data !== exp) begin
$error("Mismatch: got %h, expected %h", rx_data, exp); errors++;
end else
$display("[%0t] PASS: %h", $time, rx_data);
end
end

task automatic send_byte(input logic [7:0] data, input bit good_stop = 1);
if (good_stop) exp_q.push_back(data);
rx_in = 0; #(BIT_PERIOD);
for (int i = 0; i < 8; i++) begin
rx_in = data[i]; #(BIT_PERIOD);
end
rx_in = good_stop; #(BIT_PERIOD);
rx_in = 1;
endtask

initial begin
$dumpfile("uart_rx_tb.vcd");
$dumpvars(0, uart_rx_tb);

rst_n = 0; rx_in = 1; #100;
rst_n = 1; #(BIT_PERIOD*2);

send_byte(8'h9D); #(BIT_PERIOD*2);
send_byte(8'h55, 0); #(BIT_PERIOD*2);
send_byte(8'hA3);
send_byte(8'h00); #(BIT_PERIOD*2);

if (errors == 0 && exp_q.size() == 0) $display("TEST PASSED");
else $display("TEST FAILED: errors=%0d, pending=%0d", errors, exp_q.size());
$finish;
end
endmodule