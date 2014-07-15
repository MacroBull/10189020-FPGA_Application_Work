// wire [2*ws - 1:0]  = {im, re}


`define real [ws - 1:0]
`define imag [2*ws - 1:ws]
`define fix [ws - 1:0]
`define int [ws - dp - 1:0]
`define complex [2*ws - 1:0]


///////////////////////////fix point complex ////////////////////////

module fixComplex_add(
	c,
	a, b);
	
	output	`complex	c;
	
	input	`complex	a, b;
	
	parameter	ws = 16, dp = 8;
	
	assign c = {a`imag + b`imag, a`real + b`real};
	
endmodule

module fixComplex_mul(
	c,
	a, b);
	
	output	`complex	c;
	
	input	`complex	a, b;
	
	parameter	ws = 16, dp = 8;
	
	wire	`fix	p0, p1, p2, p3;
	
	fixMul	#(ws, dp)	op0(p0, a`imag, b`real);
	fixMul	#(ws, dp)	op1(p1, b`imag, a`real);
	fixMul	#(ws, dp)	op2(p2, a`real,  b`real);
	fixMul	#(ws, dp)	op3(p3, a`imag,  b`imag);
	
	assign c = {p0 + p1, p2 - p3};
	
endmodule


module fixComplex_fixAbsqr(
	b,
	a);
	
	output	`fix	b;
	
	input	`complex	a;
	
	parameter	ws = 16, dp = 8;
	
	wire	`fix	p0, p1;
	
	fixMul	#(ws, dp)	op0(p0, a`real,  a`real);
	fixMul	#(ws, dp)	op1(p1, a`imag,  a`imag);
	assign b = p0 + p1;
	
endmodule

module fixComplex_intAbsqr(
	b,
	a);
	
	output	`int	b;
	
	input	`complex	a;
	
	parameter	ws = 16, dp = 8;
	
	wire	`fix	p0, p1;
	
	fixMul	#(ws, dp)	op0(p0, a`real,  a`real);
	fixMul	#(ws, dp)	op1(p1, a`imag,  a`imag);
	fix2int	#(ws, dp)	op2(b, p0 + p1);
	
endmodule

	
	
	
///////////////////////int complex/////////////






module complex_add(
	c,
	a, b);
	
	output	`complex	c;
	
	input	`complex	a, b;
	

	parameter ws = 32;
	
	assign c = {a`imag + b`imag, a`real + b`real};
	
endmodule

module complex_mul(
	c,
	a, b);
	
	output	`complex	c;
	
	input	`complex	a, b;
	

	parameter ws = 32;
	
	assign c = {a`imag * b`real + b`imag * a`real,
		a`real * b`real - a`imag * b`imag};
	
endmodule

module complex_dmul(
	c,
	a, b);
	
	output	`complex	c;
	
	input	`complex	a;
	input	[ws - 1:0]	b;
	

	parameter ws = 32;
	
	assign c = {a`imag * b,a`real * b};
	
endmodule

module complex_ddiv( //positive c only
	c,
	a, b);
	
	output	`complex	c;
	
	input	`complex	a;
	input	[ws - 1:0]	b;
	
// 	integer	mai, mar;
	

	parameter ws = 32;
	
// 	assign {mai, mar} = a;
	
// 	assign c = {mai / b, mar / b};
	assign c = {(a[2*ws - 1])?(-(-a`imag / b)):(a`imag / b), (a[ws - 1])?(-(-a`real / b)):(a`real / b)};
	
endmodule

module complex_absqr(
	c,
	a);
	
	output	[ws - 1:0]	c;
	
	input	`complex	a;
	

	parameter ws = 32;
	
	assign c = a`real * a`real + a`imag * a`imag;
	
endmodule
	