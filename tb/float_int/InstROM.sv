// Create Date:    15:50:22 10/02/2016 
// Design Name: 
// Module Name:    InstROM 
// Project Name:   CSE141L
// Tool versions: 
// Description: Verilog module -- instruction ROM template	
//	 preprogrammed with instruction values (see case statement)
// DW = machine code width (9 bits for class; 32 for ARM/MIPS)
// IW = program counter width, determines instruction memory depth
// Revision: 
//
module InstROM #(parameter IW=9, DW=9) (
  input       [IW-1:0] InstAddress,
  output logic[DW-1:0] InstOut);
	 

  logic[DW-1:0] inst_rom[2**(IW)];
  always_comb InstOut = inst_rom[InstAddress];
 
  initial begin		                  // load from external text file
  	$readmemb("flt2int_machine_code.txt",inst_rom); // add a full 0 code in the txt
  end 
  
endmodule
