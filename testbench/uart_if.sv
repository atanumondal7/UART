`timescale 1ns/1ps

`ifndef UART_INTERFACE_SV
`define UART_INTERFACE_SV

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

clocking drv_cb @(posedge clk);
default input #1step output #1;
output tx_data;
output tx_start;
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