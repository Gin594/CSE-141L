// Module Name:    ALU 
// Project Name:   CSE141L
//
// Additional Comments: 
//   combinational (unclocked) ALU
import definitions::*;			  // includes package "definitions"
module ALU(
  input [ 7:0] INPUT,      	  // data inputs
  input [ 8:0] OP,				  // ALU opcode, part of microcode
  input 	   SET,
  input [ 7:0] SETNUM,
  input        SC_IN,             // shift in/carry in 
  output logic [7:0] OUT,		  // or:  output reg [7:0] OUT,
  output logic SC_OUT,			  // shift out/carry out
  output logic ZERO,              // zero out flag
  output logic EQ,				  // compare flag
  output logic BEVEN              // LSB of input B = 0
    );
	 
  op_mne op_mnemonic;			  // type enum: used for convenient waveform viewing
  logic [7:0] R0;
	
  always_comb begin
    {SC_OUT, OUT} = 0;            // default -- clear carry out and result out
// single instruction for both LSW & MSW
  if (SET) begin
	  R0 = SETNUM;
	  end
  else begin
	  case(OP)
		kmove : begin {SC_OUT, OUT} = 0; R0 = INPUT;end
		kassign : {SC_OUT, OUT} = {0,R0};
		kload : begin {SC_OUT, OUT} = 0; R0 = INPUT;end
		kstore : {SC_OUT, OUT} = {0,R0};
		kadd : {SC_OUT, OUT} = {1'b0,INPUT} + R0 + SC_IN;  // add w/ carry-in & out
		klsl : {SC_OUT, OUT} = {INPUT, SC_IN};  	            // shift left 
		klsr : {OUT, SC_OUT} = {SC_IN, INPUT};			        // shift right
		kb	 : begin 
				{SC_OUT, OUT} = 0; 
				assign EQ=(R0 == 0)? 1'b1 : 1'b0;
			   end
		kbeq : begin 
				{SC_OUT, OUT} = 0; 
				assign EQ = (R0 == INPUT)? 1'b1 : 1'b0;
			   end
		kbeq : begin 
				{SC_OUT, OUT} = 0; 
				assign EQ = (R0 == INPUT)? 1'b1 : 1'b0;
			   end
		kblt : begin 
				{SC_OUT, OUT} = 0; 
				assign EQ = (R0 < INPUT)? 1'b1 : 1'b0;
			   end
		kbge : begin 
				{SC_OUT, OUT} = 0; 
				assign EQ = (R0 >= INPUT)? 1'b1 : 1'b0;
			   end
		kbgt : begin 
				{SC_OUT, OUT} = 0; 
				assign EQ = (R0 > INPUT)? 1'b1 : 1'b0;
			   end
		korr : begin 
				 OUT    = R0^INPUT;  	     			   // exclusive OR
				 SC_OUT = 0;					   		       // clear carry out -- possible convenience
			   end
		kand : begin                                           // bitwise AND
				 OUT    = R0 & INPUT;
				 SC_OUT = 0;
			   end
		ksub : begin
				 OUT    = INPUTA + (~INPUTB) + SC_IN;	       // check me on this!
				 SC_OUT = 0;                                   // check me on this!
			   end
		default: {SC_OUT,OUT} = 0;						       // no-op, zero out
	  endcase
	case(OUT)
	  'b0     : ZERO = 1'b1;
	  default : ZERO = 1'b0;
	endcase
  end
//$display("ALU Out %d \n",OUT);
    op_mnemonic = op_mne'(OP);					  // displays operation name in waveform viewer
  end											
  always_comb BEVEN = OUT[0];          			  // note [0] -- look at LSB only
//    OP == 3'b101; //!INPUTB[0];               
// always_comb	branch_enable = opcode[8:6]==3'b101? 1 : 0;  
endmodule