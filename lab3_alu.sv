`timescale 1ns / 1ps                                                                                       
                                                                                                
module lab3_alu(                                                                                           
                                                                                                           
input logic [31:0] a, b,                                                                                   
input logic [1:0] ALUControl,                                                                              
output logic [31:0] Result,                                                                                
output logic [3:0] ALUFlags);                                                                              
                                                                                                           
logic [31:0] Sum;                                                                                          
logic [31:0] N;                                                                                            
logic cout;                                                                                                
logic v1, v2;                                                                                          
                                                                                                           
                                                                                                           
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
                                                                                                           
assign v1 = ~(a[31] ^ b[31]);                                                            
assign v2 = a[31] ^ Sum[31];                                                                               
                                                                                    
assign ALUFlags[0] = v1 & v2;                                                             
assign ALUFlags[1] = cout;                                                                
assign ALUFlags[2] = (Result == 32'b0);                                                                                 
assign ALUFlags[3] = Result[31];                                                                           
                                                                                                           
endmodule                                                                                                  
                                                                                                           
