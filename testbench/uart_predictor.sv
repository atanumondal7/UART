class uart_predictor extends uvm_component;
`uvm_component_utils(uart_predictor)

uvm_analysis_port #(uart_item) exp_port;

function new(string name = "uart_predictor", uvm_component parent);
super.new(name, parent);
mon_imp  = new("mon_imp", this);
exp_port = new("exp_port", this);
endfunction

virtual function void write(uart_item sent);
uart_item exp = uart_item::type_id::create("exp");

exp.data = sent.data;
exp.error = sent.inject_error;

exp_port.write(exp);
endfunction
endclass