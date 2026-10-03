`ifndef UART_COVERAGE_SV
`define UART_COVERAGE_SV

class uart_coverage extends uvm_subscriber #(uart_item);

`uvm_component_utils(uart_coverage)

uart_item item;

bit c_data;
logic [7:0] corner_vals [6] = '{8'h00, 8'hFF, 8'h55, 8'hAA, 8'h01, 8'h80};
bit seen_corner [6];
bit seen_no_error;
bit seen_error;
int corners=0;
int t_cover;

function new(string name, uvm_component parent);
super.new(name, parent);
endfunction

function void write(uart_item t);
c_data = |t.data;

foreach (corner_vals[i]) begin
if(corner_vals[i] == t.data) begin
seen_corner[i] = 1;
end
end

if(t.error) begin
seen_error = 1;
end
else begin
seen_no_error = 1;
end

endfunction

function void check_phase(uvm_phase phase);
super.check_phase(phase);
foreach(seen_corner[i]) begin
if(seen_corner[i] == 1) begin
corners++;
end
end

t_cover = corners + c_data;
endfunction

function void report_phase(uvm_phase phase);
super.report_phase(phase);

`uvm_info("COV", "---- Coverage Report ----", UVM_LOW)
`uvm_info("COV", $sformatf("Data Cover: %s", (c_data) ? "Covered" : "Not Covered"), UVM_LOW)
`uvm_info("COV", $sformatf("Corner Values: %0d/%0d", corners, 6), UVM_LOW)
`uvm_info("COV", $sformatf("Error: %s", (seen_error) ? "Found" : "Not Found"), UVM_LOW)
`uvm_info("COV", $sformatf("Total Coverage: %0.2f%%", (real'(t_cover)/7)*100), UVM_LOW)
endfunction

endclass

`endif