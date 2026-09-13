`timescale 1ns/1ps

module uart_tx #(parameter int CLK_FREQ = 100000000, parameter int BAUD_RATE = 115200)(
input logic clk,
input logic rst_n,
input logic tx_start,
input logic [7:0] tx_data,
output logic tx_out,
output logic tx_busy,
output logic tx_done
);

localparam int CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
localparam int CTR_WIDTH    = $clog2(CLKS_PER_BIT);

logic baud_tick;
logic [7:0] tx_data_latch;
logic [2:0] bit_idx = '0;
logic [CTR_WIDTH-1:0] baud_counter;

typedef enum logic [1:0] {
IDLE = 2'b00,
START = 2'b01,
DATA = 2'b10,
STOP = 2'b11
} state_t;

state_t current_state, next_state;

always_ff @(posedge clk or negedge rst_n) begin

if(!rst_n)
current_state <= IDLE;

else
current_state <= next_state;

end

always_ff @(posedge clk) begin

if(!rst_n || current_state == IDLE) begin
baud_counter <= '0;
baud_tick <= '0;
end
else begin
if(baud_counter == CLKS_PER_BIT - 1) begin
baud_counter <= '0;
baud_tick <= 1'b1;
end
else begin
baud_counter <= baud_counter + 1'b1;
baud_tick <= 1'b0;
end
end
end

always_ff @(posedge clk or negedge rst_n) begin
if (!rst_n) begin
tx_data_latch <= '0;
bit_idx <= '0;
end else begin
if (current_state == IDLE && tx_start) begin
tx_data_latch <= tx_data;
bit_idx <= '0;
end else if (current_state == DATA && baud_tick) begin
bit_idx <= bit_idx + 1'b1;
end
end
end

always_comb begin

case(current_state)

IDLE: begin
if(tx_start) begin
next_state = START;
end
end

START: begin
if(baud_tick) 
next_state = DATA;
end

DATA: begin

if(baud_tick && bit_idx == 3'd7) begin
next_state = STOP;
end

end

STOP: begin 

if(baud_tick) begin
next_state = IDLE;
end
end
default: next_state = current_state;

endcase
end

always_comb begin
tx_out  = 1'b1;
tx_busy = 1'b1;
tx_done = 1'b0;

case (current_state)
IDLE: begin
tx_out  = 1'b1;
tx_busy = 1'b0;
end
START: begin
tx_out  = 1'b0;
tx_busy = 1'b1;
end
DATA: begin
tx_out  = tx_data_latch[bit_idx];
end
STOP: begin
tx_out  = 1'b1;
if (baud_tick)
tx_done = 1'b1;
end
default: ;
endcase

end

endmodule