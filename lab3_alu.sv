`timescale 1ns / 1ps                                                                                     
                                                                                                                       
                                                                                                         
module lab3_alu(                                                                                         
                                                                                                         
input logic [31:0] a, b,                                                                                 
input logic [1:0] ALUControl,                                                                            
output logic [31:0] Result,                                                                              
output logic [3:0] ALUFlags);                                                                            
                                                                                                         
logic [32:0] Sum;                                                                                        
logic [31:0] N;                                                                                          
logic Carry, Overflow, Zero, Negative;                                                                   
                                                                                                         
assign Carry = ~ALUControl[1] & Sum[32];                                                                 
assign Overflow = ~ALUControl[1] & (a[31] ^ Sum[31]) & (a[31] ^ b[31] ^ ~ALUControl[0]);                 
assign Negative = Result[31];                                                                            
assign Zero = ~(&Result);                                                                                
assign ALUFlags = {Negative, Zero, Carry, Overflow};                                                     
                                                                                                         
                                                                                                         
always_comb                                                                                              
                                                                                                         
if (ALUControl[0])                                                                                       
    Sum = a + ~b + ALUControl[0];                                                                        
    else                                                                                                 
    Sum = a + b + ALUControl[0];                                                                         
                                                                                                         
always_comb                                                                                              
                                                                                                         
if (ALUControl == 2'b00)                                                                                 
    Result = Sum[31:0];                                                                                  
    else if (ALUControl == 2'b01)                                                                        
    Result = Sum[31:0];                                                                                  
    else if (ALUControl == 2'b10)                                                                        
    Result = a & b;                                                                                      
    else if (ALUControl == 2'b11)                                                                        
    Result = a | b;                                                                                      
                                                                                                         
                                                                                                         
endmodule                                                                                                
                                                                                                         
