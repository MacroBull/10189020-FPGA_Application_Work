module top(
	dummy
	);
	
	input dummy;
	
	wire a, b;
	wire [15:0] x;
	
	assign x = {2'b0, a};
	assign b = a;
	
	
endmodule