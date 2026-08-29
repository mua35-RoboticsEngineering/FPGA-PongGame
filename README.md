# FPGA Pong Game

A hardware implementation of the classic two-player Pong game developed in **SystemVerilog** and deployed onto a **Terasic DE1-SoC FPGA** using **Intel Quartus Prime**.

The project implements the game logic directly in digital hardware, including VGA video generation, two-player paddle control, ball movement and collision detection, score tracking, and seven-segment display output.

---

## Demonstration

A demonstration of the completed FPGA implementation can be viewed below:

### ▶️ [Watch the FPGA Pong Demonstration](./FPGA-PongGame/media/HDL%20pong%20game%20video.mp4)

---

## Project Overview

The aim of this project was to design and implement a playable version of **Pong entirely using digital hardware logic** rather than conventional software.

The system was written in SystemVerilog and synthesised using Intel Quartus Prime for the **Cyclone V FPGA** on the DE1-SoC development board.

The FPGA is responsible for:

- generating the VGA display timing;
- rendering the paddles and ball;
- processing physical push-button inputs;
- controlling paddle movement;
- updating the position and direction of the ball;
- detecting paddle and screen-boundary collisions;
- detecting scoring events;
- maintaining player scores; and
- displaying the scores using the board's seven-segment displays.

The final system provides a complete two-player hardware implementation of Pong with an **800 × 600 VGA output**.

---

## Key Features

- Two-player real-time Pong gameplay
- SystemVerilog RTL implementation
- VGA video output at **800 × 600**
- Independent paddle control for both players
- Ball movement in horizontal and vertical directions
- Paddle collision detection
- Top and bottom wall collision detection
- Automatic ball reset following a score
- Independent score tracking for both players
- Scores displayed on the DE1-SoC seven-segment displays
- Reset control using an on-board switch
- Modular HDL architecture
- Physical implementation on a Cyclone V FPGA

---

## Hardware

The project was implemented using:

| Component | Purpose |
|---|---|
| **Terasic DE1-SoC** | FPGA development platform |
| **Cyclone V FPGA – 5CSEMA5F31C6** | Target programmable logic device |
| **50 MHz on-board clock** | Main system clock |
| **DE1-SoC push buttons** | Player paddle controls |
| **DE1-SoC switches** | System reset |
| **Seven-segment displays** | Player score output |
| **VGA output** | Game display |
| **External VGA-compatible display** | Visualisation of the game |

---

## Technologies

- **SystemVerilog**
- **FPGA development**
- **Digital logic design**
- **RTL design**
- **Intel Quartus Prime**
- **Cyclone V FPGA**
- **VGA timing and video generation**
- **Hardware input/output interfacing**
