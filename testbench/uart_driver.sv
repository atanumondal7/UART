`ifndef UART_DRIVER_SV
`define UART_DRIVER_SV

class uart_driver extends uvm_driver #(uart_item);
`uvm_component_utils(uart_driver)

bit bit_bang_mode;
int unsigned BIT_CLKS;
virtual uart_if vif;

function new(string name, uvm_component parent);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
if(!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif)) begin
`uvm_fatal("DRV", "Could not find virtual interface handles")
end
void'(uvm_config_db#(bit)::get(this, "", "bit_bang_mode", bit_bang_mode));
BIT_CLKS = CLK_FREQ / BAUD_RATE;
endfunction

task drive_item_loopback(uart_item item);
@(vif.drv_cb);
while (vif.drv_cb.tx_busy !== 1'b0) @(vif.drv_cb);
vif.drv_cb.tx_data  <= item.data;
vif.drv_cb.tx_start <= 1'b1;
@(vif.drv_cb);
vif.drv_cb.tx_start <= 1'b0;
while (vif.drv_cb.tx_busy !== 1'b1) @(vif.drv_cb);
while (vif.drv_cb.tx_busy !== 1'b0) @(vif.drv_cb);
endtask

task send_bit(bit b, int unsigned clks);
vif.drv_cb.rx_drv <= b;
repeat (clks) @(vif.drv_cb);
endtask

task drive_item_bitbang(uart_item item);
int unsigned clks = (item.bit_scale > 0.0) ? int'(BIT_CLKS * item.bit_scale) : BIT_CLKS;

send_bit(1'b0, clks);
for(int i=0;i<8;i++)
send_bit(item.data[i], clks);
send_bit((item.inject_error) ? 1'b0 : 1'b1, clks);
send_bit(1'b0, BIT_CLKS);
endtask 

task run_phase(uvm_phase phase);
uart_item item;

vif.drv_cb.tx_start <= 1'b0;
vif.drv_cb.tx_data <= '0;
vif.drv_cb.rx_drv <= 1'b1;
vif.drv_cb.rx_sel <= bit_bang_mode;

wait(vif.rst_n === 1);
forever begin
seq_item_port.get_next_item(item);
if(bit_bang_mode)
drive_item_bitbang(item);
else 
drive_item_loopback(item);
seq_item_port.item_done();
end
endtask
endclass

`endif