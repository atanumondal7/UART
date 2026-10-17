`timescale 1ns/1ps

`ifndef UART_INTERFACE_SV
`define UART_INTERFACE_SV

import uart_pkg::*;

interface uart_if (input logic clk);

logic rst_n;

logic [7:0] tx_data;
logic tx_start;
logic tx_out;
logic tx_busy;

logic rx_in;
logic [7:0] rx_data;
logic rx_ready;
logic rx_error;

logic rx_sel = 1'b0;
logic rx_drv = 1'b1;

localparam int CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
localparam int FRAME_CLKS   = 10 * CLKS_PER_BIT;
localparam int START_LAT_MAX = 2;

property p_tx_idle_on_reset;
  @(posedge clk) (!rst_n)[*2] |-> (tx_out === 1'b1 && tx_busy === 1'b0);
endproperty
assert property (p_tx_idle_on_reset)
  else $error("[SVA] TX not idle (tx_out high, tx_busy low) during reset");

property p_no_fall_when_idle;
  @(posedge clk) disable iff (!rst_n)
  $fell(tx_out) |-> tx_busy;
endproperty
assert property (p_no_fall_when_idle)
  else $error("[SVA] tx_out fell while tx_busy was low");

property p_start_bit_width;
  @(posedge clk) disable iff (!rst_n)
  $rose(tx_busy) |-> ##[0:START_LAT_MAX] ($fell(tx_out) ##0 (!tx_out)[*CLKS_PER_BIT]);
endproperty
assert property (p_start_bit_width)
  else $error("[SVA] Start bit missing or not one bit-time wide after tx_busy rose");

property p_frame_length;
  @(posedge clk) disable iff (!rst_n)
  $rose(tx_busy) |-> tx_busy[*FRAME_CLKS+1] ##1 !tx_busy;
endproperty
assert property (p_frame_length)
  else $error("[SVA] tx_busy duration is not 10 bit-times");

property p_stop_bit_check;
  @(posedge clk) disable iff (!rst_n)
  $fell(tx_busy) |-> tx_out;
endproperty
assert property (p_stop_bit_check)
  else $error("[SVA] tx_out not high when tx_busy fell (bad stop bit)");

property p_start_causes_busy;
  @(posedge clk) disable iff (!rst_n)
  (tx_start && !tx_busy) |-> ##[1:2] tx_busy;
endproperty
assert property (p_start_causes_busy)
  else $error("[SVA] tx_start did not cause tx_busy");

cover property (@(posedge clk) disable iff (!rst_n) $rose(tx_busy));
cover property (@(posedge clk) disable iff (!rst_n) $fell(tx_busy) ##0 tx_out);
cover property (@(posedge clk) disable iff (!rst_n) tx_start && tx_busy);

clocking drv_cb @(posedge clk);
default input #1step output #1;
output tx_data;
output tx_start;
output rx_sel;
output rx_drv;
input  tx_busy;
endclocking

clocking mon_cb @(posedge clk);
default input #1step;
input tx_data;
input tx_start;
input tx_busy;
input rx_data;
input rx_ready;
input rx_error;
endclocking

endinterface

`endif