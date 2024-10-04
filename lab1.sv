`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/16/2024 06:19:38 PM
// Design Name: 
// Module Name: subt
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


module subt(
    input logic [3:0] a,
    input logic [3:0] b,
    input logic bin,
    output bout,
    output logic [3:0] d
    );
    
    logic [2:0] d_bout; // dummy borrow out
    assign bin = 1'b0; //it is 0 here because we are subtracting unsigned numbers and not

    assign d_bout[0]= ~a[0] & bin | ~a[0] & b[0] | b[0] & bin;
    assign d_bout[1]= ~a[1] & d_bout[0] | ~a[1] & b[1] | b[1] & d_bout[0];
    assign d_bout[2]=  ~a[2] & d_bout[1] | ~a[2] & b[2] | b[2] & d_bout[1];
    assign bout =  ~a[3] & d_bout[2] | ~a[3] & b[3] | b[3] & d_bout[2];
    
    assign d[0] = a[0] ^ b[0] ^ bin;
    assign d[3:1] = a[3:1] ^ b[3:1] ^ d_bout[2:0];
    
endmodule
