// arm_single.v
// David_Harris@hmc.edu and Sarah_Harris@hmc.edu 25 June 2013
// Single-cycle implementation of a subset of ARMv4
// 
// run 210
// Expect simulator to print "Simulation succeeded"
// when the value 7 is written to address 100 (0x64)

// 16 32-bit registers
// Data-processing instructions
//   ADD, SUB, AND, ORR
//   INSTR<cond><S> rd, rn, #immediate
//   INSTR<cond><S> rd, rn, rm
//    rd <- rn INSTR rm	      if (S) Update Status Flags
//    rd <- rn INSTR immediate	if (S) Update Status Flags
//   Instr[31:28] = cond
//   Instr[27:26] = op = 00
//   Instr[25:20] = funct
//                  [25]:    1 for immediate, 0 for register
//                  [24:21]: 0100 (ADD) / 0010 (SUB) /
//                           0000 (AND) / 1100 (ORR)
//                  [20]:    S (1 = update CPSR status Flags)
//   Instr[19:16] = rn
//   Instr[15:12] = rd
//   Instr[11:8]  = 0000
//   Instr[7:0]   = imm8      (for #immediate type) / 
//                  {0000,rm} (for register type)
//   
// Load/Store instructions
//   LDR, STR
//   INSTR rd, [rn, #offset]
//    LDR: rd <- Mem[rn+offset]
//    STR: Mem[rn+offset] <- rd
//   Instr[31:28] = cond
//   Instr[27:26] = op = 01 
//   Instr[25:20] = funct
//                  [25]:    0 (A)
//                  [24:21]: 1100 (P/U/B/W)
//                  [20]:    L (1 for LDR, 0 for STR)
//   Instr[19:16] = rn
//   Instr[15:12] = rd
//   Instr[11:0]  = imm12 (zero extended)
//
// Branch instruction (PC <= PC + offset, PC holds 8 bytes past Branch Instr)
//   B
//   B target
//    PC <- PC + 8 + imm24 << 2
//   Instr[31:28] = cond
//   Instr[27:25] = op = 10
//   Instr[25:24] = funct
//                  [25]: 1 (Branch)
//                  [24]: 0 (link)
//   Instr[23:0]  = imm24 (sign extend, shift left 2)
//   Note: no Branch delay slot on ARM
//
// Other:
//   R15 reads as PC+8
//   Conditional Encoding
//    cond  Meaning                       Flag
//    0000  Equal                         Z = 1
//    0001  Not Equal                     Z = 0
//    0010  Carry Set                     C = 1w
//    0011  Carry Clear                   C = 0
//    0100  Minus                         N = 1
//    0101  Plus                          N = 0
//    0110  Overflow                      V = 1
//    0111  No Overflow                   V = 0
//    1000  Unsigned Higher               C = 1 & Z = 0
//    1001  Unsigned Lower/Same           C = 0 | Z = 1
//    1010  Signed greater/equal          N = V
//    1011  Signed less                   N != V
//    1100  Signed greater                N = V & Z = 0
//    1101  Signed less/equal             N != V | Z = 1
//    1110  Always                        any

module testbench();

  logic        clk, reset;
  logic [31:0] PC;
  logic [31:0] Instr;
  logic        MemWrite;
  logic [31:0] ALUResult, WriteData;
  logic [31:0] ReadData;
  
  // instantiate device to be tested
    top dut(clk, reset, PC, Instr, ALUResult, MemWrite, WriteData, ReadData, DataAdr);

  
  // initialize test
  initial
    begin
      reset <= 1; # 22; reset <= 0;
    end

  // generate clock to sequence tests
  always
    begin
      clk <= 1; # 5; clk <= 0; # 5;
    end

  // check results
  always @(negedge clk)
    begin
      if(MemWrite) begin
	      if(DataAdr === 100 & WriteData === 254) begin
          $display("Simulation succeeded");
          $stop;
        end else if (DataAdr !== 96) begin
          $display("Simulation failed");
          $stop;
        end
      end
    end
endmodule

module top(input  logic        clk, reset,
           output logic [31:0] PC,
           input  logic [31:0] Instr,
           output logic        MemWrite,
           output logic [31:0] ALUResult, WriteData,
           input  logic [31:0] ReadData);

  logic [31:0] PC, Instr, ReadData;
  logic MemByte; 
	
  arm arm(clk, reset, PC, Instr, MemWrite, MemByte, 
          DataAdr, WriteData, ReadData);
  imem imem(PC, Instr);
  dmem dmem(clk, MemWrite, MemByte, DataAdr, WriteData, ReadData);
endmodule

module dmem(input  logic        clk, we, MemByte,
            input  logic [31:0] a, wd,
            output logic [31:0] rd);

  logic [31:0] RAM[63:0];

  assign rd = RAM[a[31:2]]; // word aligned

always_ff @(posedge clk)
  begin
    if (we)
    begin
      if (~MemByte)
        RAM[a[31:2]] <= {23'b0,wd[7:0]}; // One Byte
      else
         RAM[a[31:2]] <= wd;  // Full Register
    end
  end
endmodule

module imem(input  logic [31:0] a,
            output logic [31:0] rd);

  logic [31:0] RAM[63:0];

  initial
      $readmemh("memfile2.dat",RAM);

  assign rd = RAM[a[31:2]]; // word aligned
endmodule

module arm(input  logic        clk, reset,
           output logic [31:0] PC,
           input  logic [31:0] Instr,
           output logic        MemWrite,
           output logic [31:0] ALUResult, WriteData,
           input  logic [31:0] ReadData);

  logic [3:0] ALUFlags;
  logic       RegWrite, 
              ALUSrc, MemtoReg, PCSrc, Reverse;
  logic [1:0] RegSrc, ImmSrc, ALUControl;

  controller c(clk, reset, Instr[31:12], ALUFlags, 
               RegSrc, RegWrite, ImmSrc, 
               ALUSrc, Reverse, MemByte, ALUControl,
               MemWrite, MemtoReg, PCSrc);
  datapath dp(clk, reset, 
              RegSrc, RegWrite, ImmSrc,
              ALUSrc, Reverse, ALUControl,
              MemtoReg, PCSrc,
              ALUFlags, PC, Instr,
              ALUResult, WriteData, ReadData);
endmodule

module controller(input  logic         clk, reset,
	              input  logic [31:12] Instr,
                  input  logic [3:0]   ALUFlags,
                  output logic [1:0]   RegSrc,
                  output logic         RegWrite,
                  output logic [1:0]   ImmSrc,
                  output logic         ALUSrc, Reverse, MemByte,
                  output logic [1:0]   ALUControl,
                  output logic         MemWrite, MemtoReg,
                  output logic         PCSrc);

  logic [1:0] FlagW;
  logic       PCS, RegW, MemW;
  
  decode dec(Instr[27:26], Instr[25:20], Instr[15:12],
             FlagW, PCS, RegW, MemW,
             MemtoReg, ALUSrc, Reverse, MemByte, ImmSrc, RegSrc, ALUControl);
  condlogic cl(clk, reset, Instr[31:28], ALUFlags,
               FlagW, PCS, RegW, MemW,
               PCSrc, RegWrite, MemWrite);
endmodule

module decode(input  logic [1:0] Op,
              input  logic [5:0] Funct,
              input  logic [3:0] Rd,
              output logic [1:0] FlagW,
              output logic       PCS, RegW, MemW,
              output logic       MemtoReg, ALUSrc, Reverse, MemByte,
              output logic [1:0] ImmSrc, RegSrc, ALUControl);

	logic [10:0] controls;
  logic       Branch, ALUOp;

  // Main Decoder
  
  always_comb
  	casex(Op)
  	                        // Data processing immediate
  	  2'b00:   // Data-Processing Instructions
		   if (Funct[5])
		      controls = 11'b00001010010; // Data processing immediate
  	           else
		      controls = 11'b00000010010; // Data processing register
  	  2'b01:   // Memory Instructions
		   if (Funct[0])
		      controls = 11'b00011110000; // LDR
  	           else
		   begin
		      if (Funct[2])
		         controls = 11'b10011101001; // STRB
		      else
		         controls = 11'b10011101000; // STR
		   end
  	  2'b10:   // Branch Instructions
		   controls = 11'b01101000100; // B
  	  default: // Unimplemented
		   controls = 11'bx;         
  	endcase

  assign {RegSrc, ImmSrc, ALUSrc, MemtoReg, 
          RegW, MemW, Branch, ALUOp, MemByte} = controls; 
          
  // ALU Decoder             
  always_comb
    if (ALUOp) begin                 // which DP Instr?
      case(Funct[4:1]) 
  	    4'b0100: // ADD
		     begin
			Reverse = 1'b0;
		        ALUControl = 2'b00;
		     end
  	    4'b0010: // SUB
		     begin
			Reverse = 1'b0;
		        ALUControl = 2'b01;
		     end
  	    4'b0011: // RSB
		     begin
			Reverse = 1'b1;
		        ALUControl = 2'b01;
		     end
            4'b0000: // AND
		     begin
			Reverse = 1'b0;
		        ALUControl = 2'b10;
		     end
  	    4'b1100: // ORR
		     begin
			Reverse = 1'b0;
		        ALUControl = 2'b11;
		     end
  	    default: // unimplemented
		     begin
			Reverse = 1'bx;
		        ALUControl = 2'bx;
		     end
      endcase
      // update flags if S bit is set 
	// (C & V only updated for arith instructions)
      FlagW[1]      = Funct[0]; // FlagW[1] = S-bit
	// FlagW[0] = S-bit & (ADD | SUB)
      FlagW[0]      = Funct[0] & 
        (ALUControl == 2'b00 | ALUControl == 2'b01); 
    end else begin
      ALUControl = 2'b00; // add for non-DP instructions
      FlagW      = 2'b00; // don't update Flags
    end
	
  // PC Logic
  assign PCS  = ((Rd == 4'b1111) & RegW) | Branch; 
endmodule

module condlogic(input  logic       clk, reset,
                 input  logic [3:0] Cond,
                 input  logic [3:0] ALUFlags,
                 input  logic [1:0] FlagW,
                 input  logic       PCS, RegW, MemW,
                 output logic       PCSrc, RegWrite, MemWrite);
                 
  logic [1:0] FlagWrite;
  logic [3:0] Flags;
  logic       CondEx;

  flopenr #(2)flagreg1(clk, reset, FlagWrite[1], 
                       ALUFlags[3:2], Flags[3:2]);
  flopenr #(2)flagreg0(clk, reset, FlagWrite[0], 
                       ALUFlags[1:0], Flags[1:0]);

  // write controls are conditional
  condcheck cc(Cond, Flags, CondEx);
  assign FlagWrite = FlagW & {2{CondEx}};
  assign RegWrite  = RegW  & CondEx;
  assign MemWrite  = MemW  & CondEx;
  assign PCSrc     = PCS   & CondEx;
endmodule    

module condcheck(input  logic [3:0] Cond,
                 input  logic [3:0] Flags,
                 output logic       CondEx);
  
  logic neg, zero, carry, overflow, ge;
  
  assign {neg, zero, carry, overflow} = Flags;
  assign ge = (neg == overflow);
                  
  always_comb
    case(Cond)
      4'b0000: CondEx = zero;             // EQ
      4'b0001: CondEx = ~zero;            // NE
      4'b0010: CondEx = carry;            // CS
      4'b0011: CondEx = ~carry;           // CC
      4'b0100: CondEx = neg;              // MI
      4'b0101: CondEx = ~neg;             // PL
      4'b0110: CondEx = overflow;         // VS
      4'b0111: CondEx = ~overflow;        // VC
      4'b1000: CondEx = carry & ~zero;    // HI
      4'b1001: CondEx = ~(carry & ~zero); // LS
      4'b1010: CondEx = ge;               // GE
      4'b1011: CondEx = ~ge;              // LT
      4'b1100: CondEx = ~zero & ge;       // GT
      4'b1101: CondEx = ~(~zero & ge);    // LE
      4'b1110: CondEx = 1'b1;             // Always
      default: CondEx = 1'bx;             // undefined
    endcase
endmodule

module datapath(input  logic        clk, reset,
                input  logic [1:0]  RegSrc,
                input  logic        RegWrite,
                input  logic [1:0]  ImmSrc,
                input  logic        ALUSrc, Reverse,
                input  logic [1:0]  ALUControl,
                input  logic        MemtoReg,
                input  logic        PCSrc,
                output logic [3:0]  ALUFlags,
                output logic [31:0] PC,
                input  logic [31:0] Instr,
                output logic [31:0] ALUResult, WriteData,
                input  logic [31:0] ReadData);

  logic [31:0] PCNext, PCPlus4, PCPlus8;
  logic [31:0] ExtImm, SrcA, SrcB, Result;
  logic [3:0]  RA1, RA2;
  logic [31:0] RD1, RD2;

  // next PC logic
  mux2 #(32)  pcmux(PCPlus4, Result, PCSrc, PCNext);
  flopr #(32) pcreg(clk, reset, PCNext, PC);
  adder #(32) pcadd1(PC, 32'b100, PCPlus4);
  adder #(32) pcadd2(PCPlus4, 32'b100, PCPlus8);

  // register file logic
  mux2 #(4)   ra1mux(Instr[19:16], 4'b1111, RegSrc[0], RA1);
  mux2 #(4)   ra2mux(Instr[3:0], Instr[15:12], RegSrc[1], RA2);
  regfile     rf(clk, RegWrite, RA1, RA2,
                 Instr[15:12], Result, PCPlus8, 
                 RD1, RD2);
  mux2 #(32)  resmux(ALUResult, ReadData, MemtoReg, Result);
  extend      ext(Instr[23:0], ImmSrc, ExtImm);

	
  // ALU logic
  // ALU logic
  mux2 #(32)  srcamux(RD1, RD2, Reverse, SrcA);         // Mux to determine SrcA
  mux2 #(32)  Wdmux(RD2, RD1, Reverse, WriteData);      // Mux to determine WriteData
  mux2 #(32)  srcbmux(WriteData, ExtImm, ALUSrc, SrcB); // Mux to determine SrcB
  alu         alu(SrcA, SrcB, ALUControl, 
                  ALUResult, ALUFlags);
endmodule


//----------------------------------------------------------


module adderalu #(parameter N = 8)
	         (input logic [N-1:0] a, b,
	          input logic cin,
	          output logic [N-1:0] s,
	          output logic cout);
   assign {cout, s} = a + b + cin;
endmodule

module alu #(parameter N = 32)
	    (input  logic [N-1:0] a, b,
	     input  logic [1:0]   ALUControl,
	     output logic [N-1:0] Result,
	     output logic [3:0]   ALUFlags);

   logic [N-1:0] resultADD, resultSUB, resultAND, resultOR;
   logic	 cout, coutADD, coutSUB;

   adderalu #(32) adder_inst(a, b, 1'b0, resultADD, coutADD);
   adderalu #(32) subtractor_inst(a, ~b, 1'b1, resultSUB, coutSUB);
   assign resultAND = a & b;
   assign resultOR = a | b;

   always_comb
   begin
      case (ALUControl)
         2'b00:	// Add
		begin
		assign Result = resultADD;
		assign cout = coutADD;
		end
         2'b01:	// Subtract
		begin
		assign Result = resultSUB;
		assign cout = coutSUB;
		end
         2'b10:	// AND
		assign Result = resultAND;
         2'b11:	// OR
		assign Result = resultOR;
      endcase
   end
   // ALUFlags: [3] = Negative     [2] = Zero     [1] = Carry out     [0] = oVerflow
   assign ALUFlags[3] = Result[N-1];
   assign ALUFlags[2] = ~Result;
   assign ALUFlags[1] = ~ALUControl[1] & cout;
   assign ALUFlags[0] = ~(a[N-1]^b[N-1]^ALUControl[0]) & (a[N-1]^Result[N-1])&~ALUControl[1];
endmodule








//----------------------------------------------------------

module regfile(input  logic        clk, 
               input  logic        we3, 
               input  logic [3:0]  ra1, ra2, wa3, 
               input  logic [31:0] wd3, r15,
               output logic [31:0] rd1, rd2);

  logic [31:0] rf[14:0];

  // three ported register file
  // read two ports combinationally
  // write third port on rising edge of clock
  // register 15 reads PC+8 instead

  always_ff @(posedge clk)
    if (we3) rf[wa3] <= wd3;	

  assign rd1 = (ra1 == 4'b1111) ? r15 : rf[ra1];
  assign rd2 = (ra2 == 4'b1111) ? r15 : rf[ra2];
endmodule

module extend(input  logic [23:0] Instr,
              input  logic [1:0]  ImmSrc,
              output logic [31:0] ExtImm);
 
  always_comb
    case(ImmSrc) 
               // 8-bit unsigned immediate
      2'b00:   ExtImm = {24'b0, Instr[7:0]};  
               // 12-bit unsigned immediate 
      2'b01:   ExtImm = {20'b0, Instr[11:0]}; 
               // 24-bit two's complement shifted branch 
      2'b10:   ExtImm = {{6{Instr[23]}}, Instr[23:0], 2'b00}; 
      default: ExtImm = 32'bx; // undefined
    endcase             
endmodule

module adder #(parameter WIDTH=8)
              (input  logic [WIDTH-1:0] a, b,
               output logic [WIDTH-1:0] y);
             
  assign y = a + b;
endmodule

module flopenr #(parameter WIDTH = 8)
                (input  logic             clk, reset, en,
                 input  logic [WIDTH-1:0] d, 
                 output logic [WIDTH-1:0] q);

  always_ff @(posedge clk, posedge reset)
    if (reset)   q <= 0;
    else if (en) q <= d;
endmodule

module flopr #(parameter WIDTH = 8)
              (input  logic             clk, reset,
               input  logic [WIDTH-1:0] d, 
               output logic [WIDTH-1:0] q);

  always_ff @(posedge clk, posedge reset)
    if (reset) q <= 0;
    else       q <= d;
endmodule

module mux2 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, 
              input  logic             s, 
              output logic [WIDTH-1:0] y);

  assign y = s ? d1 : d0; 
endmodule
