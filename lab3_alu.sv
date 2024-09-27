`timescale 1ns / 1ps                                                                                       
//////////////////////////////////////////////////////////////////////////////////                         
// Company:                                                                                                
// Engineer:                                                                                               
//                                                                                                         
// Create Date: 09/23/2024 06:02:44 PM                                                                     
// Design Name:                                                                                            
// Module Name: lab3_alu                                                                                   
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
                                                                                                           
                                                                                                           
module lab3_alu(                                                                                           
                                                                                                           
input logic [31:0] a, b,                                                                                   
input logic [1:0] ALUControl,                                                                              
output logic [31:0] Result,                                                                                
output logic [3:0] ALUFlags);                                                                              
                                                                                                           
logic [31:0] Sum;                                                                                          
logic [31:0] N;                                                                                            
logic cout;                                                                                                
logic v1, v2, v3;                                                                                          
                                                                                                           
                                                                                                           
always_comb begin                                                                                          
                                                                                                           
if (~ALUControl[0])                                                                                        
    N = b;                                                                                                 
    else                                                                                                   
    N = ~b;                                                                                                
end                                                                                                        
                                                                                                           
assign {cout, Sum} = a + N + ALUControl[0];                                                                
                                                                                                           
always_comb begin                                                                                          
                                                                                                           
if (ALUControl == 2'b00)                                                                                   
    Result = Sum;                                                                                          
    else if (ALUControl == 2'b01)                                                                          
    Result = Sum;                                                                                          
    else if (ALUControl == 2'b10)                                                                          
    Result = a & b;                                                                                        
    else if (ALUControl == 2'b11)                                                                          
    Result = a | b;                                                                                        
end                                                                                                        
                                                                                                           
assign v1 = ~(ALUControl[0] ^ a[31] ^ b[31]);                                                              
assign v2 = a[31] ^ Sum[31];                                                                               
assign v3 = ~Result;                                                                                       
assign ALUFlags[0] = ~ALUControl[1] & v1 & v2;                                                             
assign ALUFlags[1] = ~ALUControl[1] & cout;                                                                
assign ALUFlags[2] = &v3;                                                                                  
assign ALUFlags[3] = Result[31];                                                                           
                                                                                                           
endmodule                                                                                                  
                                                                                                           
