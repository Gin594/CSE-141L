///// Create Date:    2018.04.05
// Design Name:    BasicProcessor
// Module Name:    TopLevel 
// CSE141L
// partial only	
import definitions::*;
									   
module TopLevel(		   // you will have the same 3 ports
    input     start,	   // init/reset, active high
	input     CLK,		   // clock -- posedge used inside design
    output    program_done // done flag from DUT
    );

wire [ 8:0] PC;            // program count
wire [ 8:0] Target;
wire [ 8:0] Instruction;   // our 9-bit opcode
wire [ 7:0] Readdata,      // reg_file outputs
            ALU_out;       // ALU result
wire [ 7:0] Mem_Out,	   // data out from data_memory
			SETNUM,
			accum_out;
wire        ram_write,	   // data_memory write enable
			ac_ena,
		    SC_OUT,	       // to carry register
			EQ,
			SET,
			Halt,
			write_reg,
            jump_en,	   // to program counter: jump enable
			branch_en;
reg	 [ 7:0]	accum_in;
logic[15:0] cycle_ct;	   // standalone; NOT PC!
logic       SC_IN;         // carry register (loop with ALU)


assign SETNUM = Instruction[7:0];

// Fetch = Program Counter + Instruction ROM
// Program Counter
  PC PC1 (
	.Init       (start), 
	.Halt              ,  // SystemVerilg shorthand for .halt(halt), 
	.jump_en           ,  // jump enable
	.branch_en		   ,
	.CLK        	   ,  // (CLK) is required in Verilog, optional in SystemVerilog
	.EQ				   ,
	.Target			   ,
	.PC             	  // program count = index to instruction memory
	);					  

// Control decoder
  Ctrl Ctrl1 (
	.Instruction,    // from instr_ROM
	.CLK,
	.RST(start),
	.EQ,
	.write_reg,			 // from ALU: result = 0
	.ram_write,			 // from ALU: input B is even (LSB=0)
	.ac_ena,			 // from ALU: compare result
	.branch_en,
	.jump_en,		 // to PC
	.Target,
	.Halt,
	.SET,
	.program_done
  );
  
 
// instruction ROM
  InstROM instr_ROM1(
	.InstAddress   (PC), 
	.InstOut       (Instruction)
	);


// reg file
  reg_file #(.W(8),.D(4)) reg_file1 (
  	.CLK    				  ,
  	.write_en  (write_reg)    , 
  	.addr      (Instruction[3:0]),         
  	.data_in   (ALU_out), 
  	.data_out  (Readdata)
  );

	accum accum1 (
	.CLK,
	.RST(start),
	.ena(ac_ena),
	.in(accum_in),
	.out(accum_out)	
	);
	
    ALU ALU1  (
	  .INPUT  (Readdata), //input from register
	  .ACCUM  (accum_out), //input from accumulator
	  .SET, //for set instruction 
	  .OP     (Instruction[7:4]), // input instruction
	  .OUT    (ALU_out), // output to accumulator
	  .SC_IN   , //(SC_IN),loop from SC_OUT
	  .SC_OUT  , // loop to SC_IN
	  .EQ // Show conditional branch results
	  );
  
	data_mem #(.AW(4)) data_mem1 (
		.DataAddress  (Instruction[3:0]), 
		.ReadMem      (1'b1),          //(MEM_READ) ,   temporarily unabled 
		.WriteMem     (ram_write), 
		.DataIn       (ALU_out), 
		.DataOut      (Mem_Out)  , 
		.CLK 		  		     
	);
	
always_comb     // A multiplexer,It should have been made into a module, but it's convenient to put it here.
	if (Instruction[8])
		accum_in = SETNUM;
	else if (Instruction[7:4] == kmove)
		accum_in = Readdata;
	else if (Instruction[7:4] == kload)
		accum_in = Mem_Out;
	else
		accum_in = ALU_out; 
	
// count number of instructions executed
always_ff @(posedge CLK)
  if (start == 0)	   // if(start)
  	cycle_ct <= 0;
  else if(program_done == 0)   // if(!halt)
  	cycle_ct <= cycle_ct+16'b1;

always_ff @(posedge CLK)    
    SC_IN <= SC_OUT;        // update the carry  

endmodule
