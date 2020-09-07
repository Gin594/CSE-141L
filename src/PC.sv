// Design Name:    basic_proc
// Module Name:    PC 
// Project Name:   CSE141L
// Description:    instruction fetch (pgm ctr) for processor
//
// Revision:  2019.01.27
//
module PC(
  input branch_en,		      // store Target value
  input jump_en, 		  	  // jump ... "how high?"
  input Init,				  // reset, start, etc. 
  input Halt,				  // 1: freeze PC; 0: run PC
  input CLK,				  // PC can change on pos. edges only
  input EQ,
  input	[8:0] Target,
  output logic[8:0] PC		  // program counter
  );
	 
  reg EQ_delay;
  
  always_ff @(posedge CLK)
	EQ_delay <= EQ;
	
  always_ff @(posedge CLK)	  // or just always; always_ff is a linting construct
	if(!Init)
	  PC <= 0;				  // for first program; want different value for 2nd or 3rd
	else if(Halt)
	  PC <= PC;
	else if(jump_en)	      // unconditional absolute jump
	  PC <= Target;
	else if(branch_en & EQ_delay)	      // unconditional absolute jump
	  PC <= Target;
	else
	  PC <= PC+1;		      // default increment ()

endmodule
