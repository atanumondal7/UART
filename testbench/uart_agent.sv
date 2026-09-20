`ifndef UART_AGENT_SV
`define UART_AGENT_SV

class uart_agent extends uvm_agent;
`uvm_component_utils(uart_agent)
uart_driver driver;
uart_monitor tx_mon;
uart_monitor rx_mon;
uvm_sequencer #(uart_item) sequencer;

function new(string name, uvm_component parent);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
tx_mon = uart_monitor::type_id::create("tx_mon", this);
rx_mon = uart_monitor::type_id::create("rx_mon", this);
uvm_config_db#(mon_kind_e)::set(this, "tx_mon", "kind", MON_TX);
uvm_config_db#(mon_kind_e)::set(this, "rx_mon", "kind", MON_RX);

if(get_is_active() == UVM_ACTIVE) begin
driver = uart_driver::type_id::create("driver", this);
sequencer = uvm_sequencer#(uart_item)::type_id::create("sequencer", this);
end

endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
if(get_is_active() == UVM_ACTIVE) begin
driver.seq_item_port.connect(sequencer.seq_item_export);
end
endfunction

endclass

`endif