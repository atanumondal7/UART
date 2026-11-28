`ifndef UART_PREDICTOR_SV
`define UART_PREDICTOR_SV

class uart_predictor extends uvm_subscriber #(uart_item);
`uvm_component_utils(uart_predictor)

uvm_analysis_port #(uart_item) exp_port;

function new(string name, uvm_component parent);
super.new(name, parent);
exp_port = new("exp_port", this);
endfunction

function void write(uart_item t);
uart_item exp = uart_item::type_id::create("exp");

exp.data = t.data;
exp.error = t.inject_error;

exp_port.write(exp);
endfunction
endclass

`endif