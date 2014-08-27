/*
* Fix point calculation modules
* @Author: Macrobull
* @Project: DE2-70 Audio Effector and Visualization
* @Date: July 2014
* @Github: https://github.com/MacroBull/10189020-FPGA_application_work
*/


`define	fix	signed	[ws - 1:0]
`define	int	signed	[ws - dp - 1:0]

// -1 == ~0

module fi_int2fix(
	b,
	a);
	
	output	`fix	b;
	input	`int	a;
	
	parameter	ws = 16, dp = 8;
	
	assign	b = a << dp;
endmodule

module fi_fix2int(
	b,
	a);
	
	output	`int	b;
	input	`fix	a;
	
	parameter	ws = 16, dp = 8;
	
// 	assign	b = a >> dp;
	assign	b = a[ws - 1:dp] + a[dp - 1];
endmodule

module fi_dpInc(
	b,
	a);
	
	output	`fix	b;
	input	`fix	a;
	
	parameter	ws = 16, ddp = 0;
	
	assign	b = a << ddp;
endmodule

module fi_dpDec(
	b,
	a);
	
	output	`fix	b;
	input	`fix	a;
	
	parameter	ws = 16, ddp = 0;
	
 	assign	b = (a >>> ddp);// + a[ddp - 1]; //{a[ws - 1]?~32'h0:32'h0, a[ws - 1:ddp]};
endmodule

module fi_add(
	c,
	a, b);
	
	output	`fix	c;
	input	`fix	a, b;
	
 	parameter	ws = 16, dp = 8;
	
	assign	c = a + b;
endmodule

module fi_sub(
	c,
	a, b);
	
	output	`fix	c;
	input	`fix	a, b;
	
 	parameter	ws = 16, dp = 8;
	
	assign	c = a - b;
endmodule

module fi_mul(
	c,
	a, b);
	
	output	`fix	c;
	input	`fix	a, b;
	
	parameter	ws = 16, dp = 8;
	
	wire	signed	[ws * 2 - 1:0]	rc, ra, rb;
	
// 	int_extend	#(ws*2, ws)	op0(ra, a);
// 	int_extend	#(ws*2, ws)	op1(rb, b);
	assign	ra = a;
	assign	rb = b;
	
	assign	rc = ra * rb;
	
	assign	c = rc[ws + dp - 1: dp] + rc[dp - 1];
	
endmodule

module fi_div(
	c,
	a, b);
	
	output	`fix	c;
	input	`fix	a, b;
	
	parameter	ws = 16, dp = 8;
	
	wire	signed	[ws * 2 - 1:0]	rc, ra, rb;
	
// 	int_extend	#(ws*2, ws)	op0(rb, b);
	
	assign	ra = a << dp;
	assign	rb = b;
	assign	rc = ra / rb;
	
	assign	c = rc[ws - 1: 0];
	
endmodule