`timescale 1ns/1ps

`ifndef UART_PACKAGE_SV
`define UART_PACKAGE_SV

package uart_pkg;

parameter int CLK_FREQ = 100000000;
parameter int BAUD_RATE = 115200;
parameter int OVERSAMPLE = 16;

`include "uart_item.sv"
`include "uart_sequence.sv"
`include "uart_driver.sv"
`include "uart_monitor.sv"
`include "uart_scoreboard.sv"
`include "uart_coverage.sv"
`include "uart_agent.sv"
`include "uart_env.sv"
`include "uart_tb_top.sv"

endpackage

`endif