`timescale 1ns/1ps

package uart_rx_tb_pkg;

parameter int CLK_FREQ = 100000000;
parameter int BAUD_RATE = 115200;
parameter int OVERSAMPLE = 16;

endpackage

import uart_rx_tb_pkg::*;

module uart_rx_tb;

localparam real BIT_PERIOD = 1.0e9 / 115200; 

logic clk;
logic rst_n;
logic rx_in;
logic [7:0] rx_data;
logic rx_ready;
logic rx_error;

always #10 clk = ~clk;

uart_rx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE), .OVERSAMPLE(OVERSAMPLE)) dut (
.clk(clk),
.rst_n(rst_n),
.rx_in(rx_in),
.rx_data(rx_data),
.rx_ready(rx_ready),
.rx_error(rx_error)
);

task automatic send_byte(input logic [7:0] data, input bit good_stop = 1);
rx_in = 0;  #(BIT_PERIOD);               
for (int i = 0; i < 8; i++) begin       
rx_in = data[i];  #(BIT_PERIOD);
end
rx_in = good_stop;  #(BIT_PERIOD);       
rx_in = 1;                               
endtask

initial begin
$monitor("rst_n=%0b, rx_in=%0b, rx_data=%b, rx_ready=%0b, rx_error=%0b", rst_n, rx_in, rx_data, rx_ready, rx_error);
rst_n = 0; rx_in = 1; #100;
rst_n = 1; #(BIT_PERIOD*2);
send_byte(8'h9D);          
#(BIT_PERIOD*2);
send_byte(8'h55, 0);      
#(BIT_PERIOD*2);
$finish;
end

endmodule