`ifndef UART_SEQUENCE_SV
`define UART_SEQUENCE_SV

class uart_sequence extends uvm_sequence #(uart_item);
`uvm_object_utils(uart_sequence)

function new(string name = "uart_sequence");
super.new(name);
endfunction

task body();

uart_item item;
repeat(20) begin
item = uart_item::type_id::create("item");
start_item(item);
item.data = $urandom_range(0, 255);
item.inject_error = 0;
item.bit_scale = 1.0;
finish_item(item);
end
endtask

endclass

`endif