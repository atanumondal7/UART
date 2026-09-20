`ifndef UART_SCOREBOARD_SV
`define UART_SCOREBOARD_SV

`uvm_analysis_imp_decl(_exp)
`uvm_analysis_imp_decl(_act)

class uart_scoreboard extends uvm_scoreboard;

`uvm_component_utils(uart_scoreboard)

uvm_analysis_imp_exp #(uart_item, uart_scoreboard) exp_imp;
uvm_analysis_imp_act #(uart_item, uart_scoreboard) act_imp;

uart_item exp_q[$];
int pass_count, fail_count;

function new(string name, uvm_component parent);
super.new(name, parent);
exp_imp = new("exp_imp", this);
act_imp = new("act_imp", this);
endfunction

function uart_item predict(uart_item sent);
uart_item exp = uart_item::type_id::create("exp");
exp.data = sent.data;
exp.error = 0;
return exp;
endfunction

function void write_exp(uart_item t);
exp_q.push_back(predict(t));
endfunction

function void write_act(uart_item act);
uart_item exp;
if(exp_q.size() == 0) begin
`uvm_error("SB", $sformatf("Received 0x%02h but nothing expected", act.data))
fail_count++;
return;
end
exp = exp_q.pop_front();
if(act.error !== exp.error || act.data !== exp.data) begin
`uvm_error("SB", $sformatf("MISMATCH exp=0x%02h/err=%0b act=0x%02h/err=%0b", exp.data, exp.error, act.data, act.error))
fail_count++;
end
else begin
`uvm_info("SB", $sformatf("MATCH 0x%02h", act.data), UVM_MEDIUM)
pass_count++;
end
endfunction

function void check_phase(uvm_phase phase);
super.check_phase(phase);
if(exp_q.size() != 0) begin
`uvm_error("SB", $sformatf("%0d expected items were never received", exp_q.size()))
fail_count++;
end
endfunction

function void report_phase(uvm_phase phase);
super.report_phase(phase);
`uvm_info("SB", $sformatf("PASS=%0d  FAIL=%0d", pass_count, fail_count), UVM_MEDIUM)
endfunction

endclass

`endif