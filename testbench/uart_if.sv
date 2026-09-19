`ifndef UART_INTERFACE_SV
`define UART_INTERFACE_SV

import uart_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

interface uart_if (input logic clk);

logic clk;
logic rst_n;

logic [7:0] tx_data;
logic tx_start;
logic tx_out;
logic tx_busy;

logic rx_in;
logic [7:0] rx_data;
logic rx_ready;
logic rx_error;

clocking cb @(posedge clk);
default input #1 output #1;
output rst_n;
output tx_data;
output tx_start;
output rx_in;
input tx_out;
input tx_busy;
input rx_data;
input rx_ready;
input rx_error;
endclocking

endinterface

`endif