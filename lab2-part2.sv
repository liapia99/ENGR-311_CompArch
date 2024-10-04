`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/17/2024 01:29:47 PM
// Design Name: 
// Module Name: segment
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


module segment(
    input logic [3:0] D,
    output logic [6:0] S

    );
    
    assign S[0] = D[3] | D[1] | ~D[2] & ~D[0] | D[2] & D[0];
    assign S[1] = ~D[2] | ~D[1] & ~D[0] | D[1] & D[0];
    assign S[2] = ~D[1] | D[0] | D[2];
    assign S[3] = D[3] | ~D[2] & ~D[0] | D[1] & ~D[0] | ~D[2] & D[1] | D[2] & ~D[1] & D[0];
    assign S[4] = ~D[2] & ~D[0] | D[1] & ~D[0];
    assign S[5] = D[3] | D[2] & ~D[1] | D[2]  & ~D[0] | ~D[1] & ~D[0];
    assign S[6] = D[3] | D[2] & ~D[1] | D[2]  & ~D[0] | ~D[2] & D[1];
    
endmodule
