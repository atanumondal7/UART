`ifndef UART_TEST_SV
`define UART_TEST_SV

class uart_test extends uvm_test;

`uvm_component_utils(uart_test)

uart_env env;

function new(string name, uvm_component parent);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
env = uart_env::type_id::create("env", this);
uvm_config_db#(bit)::set(this, "env.agent.driver", "bit_bang_mode", 0);
endfunction

task run_phase(uvm_phase phase);
uart_sequence seq = uart_sequence::type_id::create("seq", this);
phase.raise_objection(this);
seq.num_item = 20;
seq.use_corners = 1;
seq.start(env.agent.sequencer);
#200;
phase.drop_objection(this);
endtask

endclass

`endif