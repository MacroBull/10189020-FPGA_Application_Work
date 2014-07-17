
`define fix [ws - 1:0]
`define int [ws - dp - 1:0]

// module int2fix(
// 	b,
// 	a);
// 	
// 	output	`fix	b;
// 	input	`int	a;
// 	
// 	parameter	ws = 16, dp = 8;
// 	
// 	assign	b = a << dp;
// endmodule

module fix2int(
	b,
	a);
	
	output	`int	b;
	input	`fix	a;
	
	parameter	ws = 16, dp = 8;
	
	assign	b = a >> dp;
endmodule

// module fixAdd(
// 	c,
// 	a, b);
// 	
// 	output	`fix	c;
// 	input	`fix	a, b;
// 	
// 	parameter	ws = 16, dp = 8;
// 	
// 	assign	c = a + b;
// endmodule

module fixMul(
	c,
	a, b);
	
	output	`fix	c;
	input	`fix	a, b;
	
	parameter	ws = 16, dp = 8;
	
	wire	[ws * 2 - 1:0]	r0, ra, rb;
	
	assign ra = a[ws-1]?{-16'b1, a}:{16'b0, a};
	assign rb = b[ws-1]?{-16'b1, b}:{16'b0, b};
	assign r0 = ra * rb;
	
	assign	c = (r0 >> dp);
	
endmodule

// module fixDiv(
// 	c,
// 	a, b);
// 	
// 	output	`fix	c;
// 	input	`fix	a, b;
// 	
// 	parameter	ws = 16, dp = 8;
// 	
// 	wire	[ws * 2 - 1:0]	r0;
// 	
// 	assign r0 = a << dp;
// 	
// 	assign	c = (r0 / b);
// endmodule
	
// module normalize(
// 	o,
// 	i);
// 	
// 	output	[ws - 1:0] o;
// 	input	[ws - 1:0] i;
// 	
// 	parameter	ws = 16;
// 	
// 	assign o = (i[ws - 1])?():(i+ (1 << (ws - 1)))
