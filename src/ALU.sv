// Create Date:    2016.10.15
// Module Name:    ALU 
// Project Name:   CSE141L
//
// Revision 2018.01.27
// Additional Comments: 
//   combinational (unclocked) ALU
import definitions::*;			  // includes package "definitions"
module ALU(
  input [ 7:0] INPUT,      	  // data inputs
  input [ 7:0] ACCUM,
  input [ 3:0] OP,				  // ALU opcode, part of microcode
  input 	   SET,
  input        SC_IN,             // shift in/carry in 
  output logic [7:0] OUT,		  // or:  output reg [7:0] OUT,
  output logic SC_OUT,			  // shift out/carry out
  output logic EQ				  // compare flag
    );
	
  always_comb
// single instruction for both LSW & MSW
  if (SET) begin
	  OUT = INPUT;
	  SC_OUT = 0;
	  EQ = 0;
	  end
  else begin
	  {SC_OUT,OUT} = 0;
	  EQ = 0;
	  case(OP)
		kassign: begin OUT = ACCUM; end
		kstore: begin OUT = ACCUM; end
		kadd : begin {SC_OUT, OUT} = {1'b0,INPUT} + {1'b0,ACCUM} + SC_IN; end // add w/ carry-in & out
		klsl : begin  OUT = INPUT<<ACCUM[2:0]; end 	            // shift left 
		klsr : begin  OUT = INPUT>>ACCUM[2:0]; end		        // shift right
		kbnq : begin 
				if (ACCUM == INPUT)
					EQ = 1'b0;
				else
					EQ = 1'b1;
			   end
		kbeq : begin 
				if (ACCUM == INPUT)
					EQ = 1'b1;
				else
					EQ = 1'b0;
			   end
		kblt : begin  
				if (INPUT < ACCUM)
					EQ = 1'b1;
				else
					EQ = 1'b0;
			   end
		kbge : begin 
				if (INPUT >= ACCUM)
					EQ = 1'b1;
				else
					EQ = 1'b0;
			   end
		kbgt : begin 
				if (INPUT > ACCUM)
					EQ = 1'b1;
				else
					EQ = 1'b0;
			   end
		kor : begin 
				 OUT    = ACCUM | INPUT;  	     			   // exclusive OR
				 SC_OUT = 0;					   		       // clear carry out -- possible convenience
			   end
		kand : begin                                           // bitwise AND
				 OUT    = ACCUM & INPUT;
				 SC_OUT = 0;
			   end
		ksub : begin
				 OUT    = (~ACCUM) + INPUT + SC_IN + 1;	       // check me on this!
				 SC_OUT = OUT[7];                                   // check me on this!
			   end
		default: begin
		{SC_OUT,OUT} = 0;
		EQ = 0;
		end// no-op, zero out
	  endcase
	end										

endmodule