// Design Name:    BasicProcessor
// Module Name:    TopLevel 
// CSE141L
// partial only										   
module TopLevel(		   // you will have the same 3 ports
    input     start,	   // init/reset, active high
	input     CLK,		   // clock -- posedge used inside design
    output    halt		   // done flag from DUT
    );

wire [ 9:0] PC;            // program count
wire [ 8:0] Instruction;   // our 9-bit opcode
wire [ 7:0] ReadA, ReadB;  // reg_file outputs
wire [ 7:0] In,	   // ALU operand inputs
            ALU_out;       // ALU result
wire [ 7:0] regWriteValue, // data in to reg file
            memWriteValue, // data in to data_memory
	   	    Mem_Out;	   // data out from data_memory
wire        MEM_READ,	   // data_memory read enable
		    MEM_WRITE,	   // data_memory write enable
			sc_clr,        // carry reg clear
			sc_en,	       // carry reg enable
		    SC_OUT,	       // to carry register
			ZERO,		   // ALU output = 0 flag
			BEVEN,		   // ALU input B is even flag
            jump_en,	   // to program counter: jump enable
            branch_en;	   // to program counter: branch enable
logic[15:0] cycle_ct;	   // standalone; NOT PC!
logic       SC_IN;         // carry register (loop with ALU)

// Fetch = Program Counter + Instruction ROM
// Program Counter
  PC PC1 (
	.init       (start), 
	.halt              ,  // SystemVerilg shorthand for .halt(halt), 
	.jump_en           ,  // jump enable
	.branch_en	       ,  // branch enable
	.CLK        (CLK)  ,  // (CLK) is required in Verilog, optional in SystemVerilog
	.PC             	  // program count = index to instruction memory
	);					  

// Control decoder
  Ctrl Ctrl1 (
	.Instruction,    // from instr_ROM
	.ZERO,			 // from ALU: result = 0
	.BEVEN,			 // from ALU: input B is even (LSB=0)
	.EQ				 // from ALU: compare result
	.jump_en,		 // to PC
	.branch_en		 // to PC
  );
// instruction ROM
  InstROM instr_ROM1(
	.InstAddress   (PC), 
	.InstOut       (Instruction)
	);

  assign load_inst = Instruction[8:6]==3'b110;  // calls out load specially

// reg file
	reg_file #(.W(8),.D(4)) reg_file1 (
		.CLK    				  ,
		.write_en  (reg_wr_en)    , 
		.addr      (Instruction[3:0]),         
		.data_in   (WriteValue) , 
		.data_out  (Readdata)
	);


    assign In = (Instruction[7:4] == 4'b0100)? Mem_Out : Readdata;		// connect RFandDataMem out to ALU in 
	assign MEM_WRITE = (Instruction[7:4] == 4'b0101);       	  // load command
	assign reg_wr_en = (Instruction[7:4] == 4'b0001);			  // assign command
	assign SET = Instruction[8];
	assign SETNUM = Instruction[7:0];
	assign WriteValue = ALU_out;  
	
    ALU ALU1  (
	  .INPUT  (In),
	  .SET					  ,
	  .SETNUM				  ,
	  .OP     (Instruction[7:4]),
	  .OUT    (ALU_out), //regWriteValue
	  .SC_IN   , //(SC_IN),
	  .SC_OUT  ,
	  .ZERO ,
	  .EQ,
	  .BEVEN
	  );
  
	data_mem data_mem1(
		.DataAddress  (Instruction[3:0])    , 
		.ReadMem      (1'b1),          //(MEM_READ) ,   temporarily unabled 
		.WriteMem     (MEM_WRITE), 
		.DataIn       (WriteValue), 
		.DataOut      (Mem_Out)  , 
		.CLK 		  		     ,
		.reset		  (start)
	);
	
// count number of instructions executed
always_ff @(posedge CLK)
  if (start == 1)	   // if(start)
  	cycle_ct <= 0;
  else if(halt == 0)   // if(!halt)
  	cycle_ct <= cycle_ct+16'b1;

always_ff @(posedge CLK)    // carry/shift in/out register
  if(sc_clr)				// tie sc_clr low if this function not needed
    SC_IN <= 0;             // clear/reset the carry (optional)
  else if(sc_en)			// tie sc_en high if carry always updates on every clock cycle (no holdovers)
    SC_IN <= SC_OUT;        // update the carry  

endmodule
