`ifndef UART_MONITOR_SV
`define UART_MONITOR_SV

typedef enum {MON_TX, MON_RX} mon_kind_e;

class uart_monitor extends uvm_monitor;

`uvm_component_utils(uart_monitor)
mon_kind_e kind = MON_RX;

virtual uart_if vif;
uvm_analysis_port #(uart_item) item_collected_port;

function new(string name, uvm_component parent);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
item_collected_port = new("item_collected_port", this);
if(!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif)) begin
`uvm_fatal("MON", "Could not find virtual interface handles")
end
void'(uvm_config_db#(mon_kind_e)::get(this, "", "kind", kind));
endfunction

task run_phase(uvm_phase phase);
uart_item item;
wait (vif.mon_cb.rst_n === 1);
forever begin
@(vif.mon_cb);
if(kind == MON_TX) begin
if (vif.mon_cb.tx_start && !vif.mon_cb.tx_busy) begin
item = uart_item::type_id::create("item");
item.data = vif.mon_cb.tx_data;
item_collected_port.write(item);
end
end
else begin
if(vif.mon_cb.rx_ready || vif.mon_cb.rx_error) begin
item = uart_item::type_id::create("item");
item.data = vif.mon_cb.rx_data;
item.error = vif.mon_cb.rx_error;
item_collected_port.write(item);
end
end
end
endtask

endclass

`endif