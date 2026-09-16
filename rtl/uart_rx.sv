`timescale 1ns/1ps

module uart_rx #(parameter int CLK_FREQ = 100000000, parameter int BAUD_RATE = 115200, parameter int OVERSAMPLE = 16)(
input logic clk,
input logic rst_n,
input logic rx_in,
output logic [7:0] rx_data,
output logic rx_ready,
output logic rx_error
);

localparam int CLKS_PER_SAMPLE = CLK_FREQ / (BAUD_RATE * OVERSAMPLE);
localparam int CTR_WIDTH = $clog2(CLKS_PER_SAMPLE);
logic [CTR_WIDTH-1:0] oversample_counter;
logic oversample_tick;
logic [3:0] os_tick_count;
logic [2:0] bit_idx;
logic [7:0] rx_shift_reg;

typedef enum logic [1:0] {
IDLE = 2'b00,
START = 2'b01,
DATA = 2'b10,
STOP = 2'b11
} state_t;

state_t current_state, next_state;

logic rx_sync_0, rx_sync_1;

always_ff @(posedge clk or negedge rst_n) begin

if(!rst_n) begin
rx_sync_0 <= 1'b1;
rx_sync_1 <= 1'b0;
end

else begin
rx_sync_0 <= rx_in;
rx_sync_1 <= rx_sync_0;
end

end

always_ff @(posedge clk or negedge rst_n) begin

if(!rst_n || current_state == IDLE) begin
oversample_counter <= '0;
oversample_tick <= '0;
end
else begin

if(oversample_counter == CLKS_PER_SAMPLE - 1) begin
oversample_counter <= '0;
oversample_tick <= 1'b1;
os_tick_count <= os_tick_count + 1'b1;
end
else begin
oversample_counter <= oversample_counter + 1'b1;
oversample_tick <= 1'b0;
end

end
end

always_ff @(posedge clk or negedge rst_n) begin
if(!rst_n || current_state == IDLE) begin
os_tick_count <= '0;
end
else if(oversample_tick) begin
os_tick_count <= os_tick_count + 1'b1;
end
end


always_ff @(posedge clk or negedge rst_n) begin
if(!rst_n) begin
bit_idx <= '0;
rx_data <= '0;
rx_shift_reg <= '0;
end
else begin
if(current_state == IDLE) begin
bit_idx <= '0;
end
else if(current_state == DATA && oversample_tick && os_tick_count == 4'd15) begin
rx_shift_reg[bit_idx] <= rx_sync_1;
if(bit_idx == 3'd7) begin
bit_idx <= '0;
end
else begin
bit_idx <= bit_idx + 1'b1;
end
end

if(current_state == STOP && oversample_tick && os_tick_count == 4'15 && rx_sync_1) begin
rx_data <= rx_shift_reg;
end
end

end

end

always_ff @(posedge clk) begin

if(!rst_n) begin
current_state <= IDLE;
end

else begin
current_state <= next_state;
end

end

always_comb begin

case (current_state)

IDLE: begin
if(!rx_sync_1) begin
next_state = START;
end
end

START: begin
if(oversample_tick && os_tick_count == 4'd7) begin
if(!rx_sync_1) begin
next_state = DATA;
end
else begin
next_state = IDLE;
end
end
end

DATA: begin
if(oversample_tick && bit_idx == 3'd7 && os_tick_count == 4'd15) begin
next_state = STOP;
end
end

STOP: begin
if( oversample_tick && os_tick_count == 4'd15) begin
next_state = IDLE;
end
end

default: next_state = IDLE;
endcase

always_comb begin
rx_ready = '0;
rx_error = '0;

if(current_state == STOP && oversample_tick && os_tick_count == 4'd15) begin
if(rx_sync_1) begin
rx_ready = 1'b1;
end 
else begin
rx_error = 1'b1;
end
end

endmodule