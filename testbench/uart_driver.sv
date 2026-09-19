`ifndef UART_DRIVER_SV
`define UART_DRIVER_SV

class uart_driver extends uvm_driver #(uart_item);
`uvm_component_utils(uart_driver)

virtual uart_if vif;

function new(string name, uvm_component parent);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
if(!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif)) begin
`uvm_fatal("DRV", "Could not find virtual interface handles")
end
endfunction

task drive_item(uart_item item);
while(vif.cb.tx_busy) @(vif.cb);

@(vif.cb);
vif.cb.tx_data <= item.data;
vif.cb.tx_start <= 1'b1;
@(vif.cb);
vif.cb.tx_start <= 1'b0;
endtask

task run_phase(uvm_phase phase);
uart_item item;

vif.cb.tx_start <= 1'b0;
vif.cb.tx_data <= '0;

wait(vif.rst_n === 1);

forever begin
seq_item_port.get_next_item(item);
drive_item(item);
seq_item_port.item_done();
end
endtask
endclass

`endif