// CSE141L
import definitions::*;
// control decoder (combinational, not clocked)
// inputs from instrROM, ALU flags
// outputs to program_counter (fetch unit)

module Ctrl(Instruction, CLK, RST, EQ,write_reg, Halt, ac_ena, ram_write, SET, branch_en, jump_en, Target, program_done);

input CLK, RST;   		// clock, reset
input [8:0] Instruction;  		// instructions, 5 bits, 17 types
input EQ;

// Enable signals
output reg write_reg, Halt, ac_ena, ram_write, SET, branch_en, jump_en,program_done;
output reg [8:0] Target;



// State code(current state)
reg [3:0] state;		// current state
reg [3:0] next_state; 	// next state
reg [3:0] op;
reg [3:0] op_delay;
op_mne op_mnemonic;

assign op = Instruction[7:4];
// state code			 
parameter Sidle=4'hf,
			 S0=4'd0,
			 S1=4'd1,
			 S2=4'd2,
			 S3=4'd3,
			 S4=4'd4,
			 S5=4'd5,
			 S6=4'd6;
			 //S7=4'd7,
			 //S8=4'd8;
			 
	
	 
assign	op_mnemonic = Instruction[8]? op_mne'(5'b10000): op_mne'({1'b0,op});					  // displays operation name in waveform viewer

always_ff @(posedge CLK)
	op_delay <= op;

reg EQ_delay;
  
always_ff @(posedge CLK)
	EQ_delay <= EQ;
			 
//PART A: D flip latch; State register
always_ff @(posedge CLK or negedge RST) 
begin
	if(!RST) state<=Sidle;
		//current_state <= Sidle;
	else state<=next_state;
		//current_state <= next_state;	
end

//PART B: Next-state combinational logic
always_comb
begin
case(state)
S1:		begin
			if (Instruction[8]==1) next_state=S3;
			else if (op==kload | op==kmove)  next_state=S3;
			else if (op==kadd | op==ksub | op==kand | op==kor | op==klsl | op == klsr | op==kassign) next_state=S4;
			else if (op==kbeq | op==kblt | op==kbge | op==kbgt | op == kbnq | op == kb) next_state=S2;
			else if (op==kstore) next_state=S5;
			else next_state=S0;
		end
Sidle:	next_state=S0;
S0:		next_state=S1;
S2:	    begin
			if (Instruction == 9'b111111111) begin
				if (op_delay == kb)
					next_state = S6;
				else if (EQ_delay)
					next_state = S6;
				else
					next_state = S1;
			end
			else begin next_state = S1;end
		end
S3:		next_state=S0;
S4:		next_state=S0;
S5:		next_state=S0;
S6:		next_state=S6;
default: next_state=Sidle;
endcase
end

// another style
//PART C: Output combinational logic
always_comb
begin 
  write_reg = 0;
  Halt = 1;
  ac_ena = 0;
  ram_write = 0;
  SET = 0;
  branch_en = 0;
  jump_en = 0;
  program_done =0;
  Target = 0;
case(state)
// --Note: for each statement, we concentrate on the current state, not next_state
// because it is combinational logic.
  Sidle: begin
		 write_reg = 0;
		 Halt = 1;
		 ac_ena = 0;
		 ram_write = 0;
		 SET = 0;
		 branch_en = 0;
		 jump_en = 0;
		 program_done =0;
		 end
     S0: begin // PC+1
		 Halt = 0; 
		 end
     S1: begin // Decode Instruction
		 if (Instruction[8]==1) begin
			SET = 1;
			Halt = 1;
		 end
		 else begin
			SET = 0;
			if (op==kbeq | op==kblt | op==kbge | op==kbgt | op == kbnq | op == kb)
				Halt = 0;
			else
				Halt = 1;
		 end
		 end
	 S2: begin
			Halt = 0;
			Target = Instruction;
			if (op_delay == kb)
				jump_en = 1;
			else
				branch_en = 1;
		 end
     S3: begin
			ac_ena = 1;
		 end
     S4: begin 
			write_reg = 1;
		 end
	 S5: begin
			ram_write = 1;
		 end
	 S6: begin
			program_done = 1;
		 end
	 default: begin
		 write_reg = 0;
		 Halt = 1;
		 ac_ena = 0;
		 ram_write = 0;
		 SET = 0;
		 branch_en = 0;
		 jump_en = 0;
		 program_done =0;
		 end
endcase
end
endmodule
