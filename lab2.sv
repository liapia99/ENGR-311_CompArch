`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/16/2024 07:10:40 PM
// Design Name: 
// Module Name: lab2_JP
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


module lab2_JP(

input logic [3:0] x, 
input logic [3:0] y,
input cin,
output logic cout,
output logic [3:0] z
    );
    logic [3:0] p; 
    logic [3:0] g;
    
    assign p = x | y;
    assign g = x & y;
    
    assign cin = 1'b0;
    
    logic [4:1] c;
    
    assign c[1] = g[0] | p[0] & cin;
    
    assign c[2] = g[1] | g[0] & p[1] | cin & p[0] & p[1];
    
    assign c[3] = g[2] | g[1] & p[2] | g[0] & p[1] & p[2] | cin & p[0] & p[1] & p[2];
    
    assign c[4] = g[3] | g[2] & p[3] | g[1] & p[2] & p[3] | g[0] & p[1] & p[2] & p[3] | c[0] & p[0] & p[1] & p[2] & p[3];
    
    logic [3:0] z;
    
    assign z[0] = cin ^ p[0] ^ g[0];
    assign z[1] = c[1] ^ p[1] ^ g[1];
    assign z[2] = c[2] ^ p[2] ^ g[2];
    assign z[3] = c[3] ^ p[3] ^ g[3];
    
    assign cout = c[4];

endmodule
