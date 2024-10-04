`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2024 06:36:47 PM
// Design Name: 
// Module Name: lab4_fsm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lab4_fsm(
input logic clk,
input logic reset,
input logic left, right,
output logic la, lb, lc, ra, rb, rc
    );
    
    
parameter S0 = 6'b000000;

parameter S1 = 6'b001000; // turns the first left light on.
parameter S2 = 6'b011000; // turns the first and second left lights on.
parameter S3 = 6'b111000;

parameter S4 = 6'b000100; // turns the first left light on.
parameter S5 = 6'b000110; // turns the first and second left lights on.
parameter S6 = 6'b000111;

// state variables
logic [5:0] state, nextstate;
// state register
always_ff @(posedge clk, posedge reset)
if (reset) state <= 6'b0; // if reset is high, go to state0
else state <= nextstate; // if reset is not high, then transition to the next state logic
// next state logic
always_comb

case (state)
S0: if (left) nextstate = S1;
else if (right) nextstate = S4;
else nextstate = S0;
S1: nextstate = S2; //Indicate which state is next after state1;
S2: nextstate = S3; // Indicate which state is next after state2;
S3: nextstate = S4; // Indicate which state is next after state3;
S4: nextstate = S5; // Indicate which state is next after state4;
S5: nextstate = S6; // Indicate which state is next after state5;
S6: nextstate = S0; // Indicate which state is next after state6;

default: nextstate = S0; //Indicate which state should be your default state;
endcase

// output logic
assign {lc, lb, la, ra, rb, rc} = state[5:0]; //Output light display
endmodule
