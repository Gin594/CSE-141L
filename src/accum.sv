module accum( in, out, ena, CLK, RST); // a register, to storage result after computing
input CLK,RST,ena;
input [7:0] in;
output reg [7:0] out;

always_ff @(posedge CLK or negedge RST) begin	
	if(!RST) out <= 8'd0;
	else begin
		if(ena)	out <= in;
		else	out <= out;
	end
end

endmodule