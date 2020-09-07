//This file defines the parameters used in the alu
// CSE141L
package definitions;
    
// Instruction map
    const logic [3:0]kmove  = 4'b0000;
    const logic [3:0]kassign  = 4'b0001;
    const logic [3:0]kload  = 4'b0010;
    const logic [3:0]kstore  = 4'b0011;
	const logic [3:0]kadd = 4'b0100;
	const logic [3:0]ksub= 4'b0101;
    const logic [3:0]kand  = 4'b0110;
	const logic [3:0]kor  = 4'b0111;
	const logic [3:0]klsr  = 4'b1000;
	const logic [3:0]klsl  = 4'b1001;
	const logic [3:0]kb	   = 4'b1010;
	const logic [3:0]kbnq  = 4'b1011;
	const logic [3:0]kbeq  = 4'b1100;
	const logic [3:0]kbge  = 4'b1101;
	const logic [3:0]kbgt  = 4'b1110;
	const logic [3:0]kblt  = 4'b1111;
// enum names will appear in timing diagram
    typedef enum logic[4:0] {
        MOVE, ASSIGN, LOAD, STORE,ADD, SUB,AND,OR,LSR,LSL,BRANCH,BNE,BEQ,BGE,BGT,BLT,SET} op_mne;
// note: kADD is of type logic[2:0] (3-bit binary)
//   ADD is of type enum -- equiv., but watch casting
//   see ALU.sv for how to handle this   
endpackage // definitions
