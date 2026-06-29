# Verilog UART FIFO System

This project implements a UART communication system in Verilog, including a UART transmitter, UART receiver, synchronous FIFO buffer, and a top-level integration module.

## Architecture

serial_rx → UART RX → FIFO → UART TX → serial_tx

## Modules

- `uart_tx.v`: Converts 8-bit parallel data into serial UART output.
- `uart_rx.v`: Converts serial UART input into 8-bit parallel data.
- `fifo_sync.v`: Stores received bytes before transmission.
- `uart_fifo_system.v`: Connects UART RX, FIFO, and UART TX.

## Features

- FSM-based UART transmitter
- FSM-based UART receiver
- 8-bit synchronous FIFO
- Full and empty FIFO flags
- Testbench verification
- Waveform debugging using EPWave

## Tools Used

- Verilog
- EDA Playground
- Icarus Verilog
- EPWave

## What I Learned

- RTL design
- FSM design
- UART protocol basics
- FIFO buffering
- Testbench writing
- Waveform analysis
