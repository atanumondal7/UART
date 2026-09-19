`ifndef UART_ITEM_SV
`define UART_ITEM_SV

class uart_item extends uvm_sequence_item;

logic [7:0] data;
logic error;
bit inject_error;
real bit_scale;

function new(string name = "uart_item");
super.new(name);
endfunction

`uvm_object_utils_begin(uart_item)
`uvm_field_int(data, UVM_ALL_ON)
`uvm_field_int(inject_error, UVM_ALL_ON)
`uvm_field_int(error, UVM_ALL_ON)
`uvm_object_utils_end

endclass

`endif