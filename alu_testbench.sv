`timescale 1ns / 1ps

module alu_testbench();

 logic [31:0] a, b;
 logic [1:0] ALUControl;
 logic [31:0] Result;
 logic [3:0] ALUFlags;


lab3_alu uut(.*);

initial
begin 

ALUControl=2'b00;
a=32'h00000000;
b=32'h00000000;
#100;


a=32'h00000000;
b=32'hFFFFFFFF;
#100;

a=32'h00000001;
b=32'hFFFFFFFF;
#100;

a=32'h000000FF;
b=32'h00000001;
#100;

ALUControl=2'b01;
a=32'h00000000;
b=32'h00000000;
#100;

a=32'h00000000;
b=32'hFFFFFFFF;
#100;


a=32'h00000001;
b=32'h00000001;
#100;

a=32'h00000100;
b=32'h00000001;
#100;

ALUControl=2'b10;
a=32'hFFFFFFFF;
b=32'hFFFFFFFF;
#100;

a=32'hFFFFFFFF;
b=32'h12345678;
#100;

a=32'h12345678;
b=32'h87654321;
#100;

a=32'h00000000;
b=32'hFFFFFFFF;
#100;


ALUControl=2'b11;
a=32'hFFFFFFFF;
b=32'hFFFFFFFF;
#100;

a=32'h12345678;
b=32'h87654321;
#100;


a=32'h00000000;
b=32'hFFFFFFFF;
#100;


a=32'h00000000;
b=32'h00000000;
#100;


$stop;
end


endmodule
