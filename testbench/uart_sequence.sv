`ifndef UART_SEQUENCE_SV
`define UART_SEQUENCE_SV

class uart_sequence extends uvm_sequence #(uart_item);
`uvm_object_utils(uart_sequence)

int num_item = 0;
bit use_corners = 0;

function new(string name = "uart_sequence");
super.new(name);
endfunction

task body();

uart_item item;
logic [7:0] corners[6] = '{8'h00, 8'hFF, 8'h55, 8'hAA, 8'h01, 8'h80};

if(use_corners) begin
foreach(corners[i]) begin
item = uart_item::type_id::create("item");
start_item(item);
item.data = corners[i];
finish_item(item);
end
end

repeat(num_item) begin
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