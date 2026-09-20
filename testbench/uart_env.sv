`ifndef UART_ENV_SV
`define UART_ENV_SV

class uart_env extends uvm_env;

`uvm_component_utils(uart_env)

uart_agent agent;
uart_scoreboard scoreboard;
uart_coverage coverage;

function new(string name, uvm_component parent);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
agent = uart_agent::type_id::create("agent", this);
scoreboard = uart_scoreboard::type_id::create("scoreboard", this);
coverage = uart_coverage::type_id::create("coverage", this);
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
agent.tx_mon.item_collected_port.connect(scoreboard.exp_imp);
agent.rx_mon.item_collected_port.connect(scoreboard.act_imp);
agent.rx_mon.item_collected_port.connect(coverage.analysis_export);
endfunction

endclass

`endif