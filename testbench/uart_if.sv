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

localparam CLK_BITS_SAMPLE = CLK_FREQ/BAUD_RATE;

localparam clks = 9 * CLK_BITS_SAMPLE;

property p_tx_idle_on_reset;
@(posedge clk) !rst_n |-> (tx_start == 1'b1);
endproperty

assert property (p_tx_idle_on_reset)
else $error("[SVA] TX Start line is not high during reset");

property p_start_bit_check;
@(posedge clk) disable iff (!rst_n)
$fell(tx_out) |-> (tx_out == 1'b0);
endproperty

assert property (p_start_bit_check)
else $error("[SVA] Invalid start bit transition on TX!");

property p_stop_bit_check;
@(posedge clk) disable iff (!rst_n)
$rose(tx_start) |-> ##clks (tx_out == 1'b1);
endproperty

assert property (p_stop_bit_check)
else $error("[SVA] Invalid stop bit transition at the end of DATA phase!");

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