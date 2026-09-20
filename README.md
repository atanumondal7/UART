# UART TX/RX with a UVM Testbench

A UART transmitter and receiver in SystemVerilog (8N1, 115200 baud, 100 MHz clock, parameterized), with a 16x-oversampling receiver, verified in loopback (TX wired to RX) with a UVM environment: driver, sequencer, two monitors, a scoreboard with a reference model, and hand-coded coverage.

The Questa edition I use doesn't support `randomize()` or `covergroup`, so stimulus comes from `$urandom_range` and coverage is tracked with plain counters and bins in a `uvm_subscriber`. It's more manual than the standard flow, but it made me decide what "covered" means for a UART data path instead of letting a covergroup decide.

## Design

**TX.** A four-state FSM (IDLE, START, DATA, STOP). `tx_start` latches `tx_data`, and the frame goes out LSB first: one start bit, eight data bits, one stop bit. `tx_busy` is decoded from the state, so it rises one clock after `tx_start` and falls when the stop bit ends.

**RX.** The input goes through a 2-FF synchronizer. After the falling edge of the start bit, an oversample counter ticks every 54 clocks (16 ticks per bit). The start bit is re-checked at tick 7 (mid-bit) to reject glitches, then each data bit is sampled 16 ticks apart, so every sample lands at bit centre. The stop bit is checked at its centre: high produces a one-cycle `rx_ready` and updates `rx_data`, low produces a one-cycle `rx_error` and leaves `rx_data` untouched.

**Baud error.** 100 MHz / (115200 x 16) = 54.25, truncated to 54, so the receiver runs about 0.5% fast relative to nominal. UART tolerates a few percent, so this is fine, but it's a real approximation and I kept it on purpose rather than adding a fractional divider.

## Architecture

### RTL
![UART UVM Testbench Architecture](docs/architecture_rtl.png)

### Testbench
![UART UVM Testbench Architecture](docs/architecture_tb.png)

The driver pulses `tx_start` with `tx_data`, and the TX serializes it into the RX. One monitor class is instantiated twice: the TX monitor records each byte sent, and the RX monitor records each byte received. The scoreboard's reference model is the transaction-level identity (bytes in equal bytes out, in order); the TX monitor pushes expected bytes into a queue and the RX monitor's bytes are compared against the front of it. Anything left in the queue at the end is reported as lost data.

## What was checked

| Behaviour | How it's checked | Where |
|---|---|---|
| Data integrity, TX to RX | Scoreboard compares every byte, in order | UVM, loopback |
| No lost or spurious bytes | Queue must be empty at the end; unexpected `rx_ready` is an error | UVM, loopback |
| Corner data values | `0x00`, `0xFF`, `0x55`, `0xAA`, `0x01`, `0x80` in a directed sequence | UVM, loopback |
| Every bit position | Per-bit 0 and 1 toggle bins | UVM, loopback |

## Result

```
[paste your final scoreboard and coverage output here]
UVM_INFO ... [SB] PASS=<n> FAIL=0
```

![Waveform](docs/waveform.png)

## Bugs I ran into

**1. `rx_error` had the wrong polarity.** `rx_ready` and `rx_error` were both driven from `rx_sync_1`, so every good frame raised both flags and a bad frame raised neither. Fix: `rx_error <= ~rx_sync_1`.

**2. The RX sampled the first data bit at the wrong point.** `os_tick_count` kept free-running through START, so the first data bit was sampled at the *end* of the bit instead of the middle. Clearing the tick counter on the START-to-DATA transition put every sample at bit centre.

**3. A missing default in the TX's `always_comb` inferred a latch.** Without `next_state = current_state`, the state came out of reset as `x`, and `tx_busy` (which is decoded from state) was high before any `tx_start`.

**4. My first UVM driver returned after 15 ns instead of ~87 us.** It checked `tx_busy` before the TX had raised it (busy rises one clock after `tx_start`), so it assumed the TX was idle and moved on to the next item. The fix was making the driver wait for `tx_busy` to rise, then fall, and treating `x` as "not idle".

## Runtime

A frame at 115200 baud is about 87 us of simulated time, so 106 transactions took over two minutes: roughly a million clock cycles. That's inherent to a serial protocol, not a testbench problem. For quick iteration I scale `BAUD_RATE` up in `uart_tb_top` and keep one run at 115200 for sign-off.

## Limits and next steps

Loopback can't produce framing errors, false start bits, or baud mismatch, because the TX always sends clean frames. I checked those with a plain directed testbench that drives `rx_in` directly ([`directed_tb/`](directed_tb/)), not in the UVM environment.

Next I'd add a direct-drive agent so the error cases run under UVM too, and a back-to-back stress sequence with no idle gap between frames.

## File hierarchy

| File | Role |
|---|---|
| [`uart_tx.sv`](rtl/uart_tx.sv) | RTL: FSM transmitter, 8N1 |
| [`uart_rx.sv`](rtl/uart_rx.sv) | RTL: 16x-oversampling receiver with 2-FF synchronizer |
| [`uart_top.sv`](rtl/uart_top.sv) | Wraps TX and RX |
| [`uart_if.sv`](testbench/uart_if.sv) | Interface with separate driver and monitor clocking blocks |
| [`uart_item.sv`](testbench/uart_item.sv) | Transaction: data byte plus stimulus knobs |
| [`uart_sequence.sv`](testbench/uart_sequence.sv) | Random data bytes, plus directed corner values |
| [`uart_driver.sv`](testbench/uart_driver.sv) | Drives the TX handshake, waits for a full frame |
| [`uart_monitor.sv`](testbench/uart_monitor.sv) | One class, TX or RX role set by config |
| [`uart_scoreboard.sv`](testbench/uart_scoreboard.sv) | Reference model and queue-based checker |
| [`uart_coverage.sv`](testbench/uart_coverage.sv) | Byte values, corner values, per-bit toggles |
| [`uart_agent.sv`](testbench/uart_agent.sv) / [`uart_env.sv`](testbench/uart_env.sv) / [`uart_test.sv`](testbench/uart_test.sv) | UVM structure |
| [`uart_pkg.sv`](testbench/uart_pkg.sv) / [`uart_tb_top.sv`](testbench/uart_tb_top.sv) | Package and top-level testbench |

## Compilation & Simulation

```bash
python run.py
```
