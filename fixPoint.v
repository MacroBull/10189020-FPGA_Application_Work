/*
* Fix point calculation modules
* @Author: Macrobull
* @Project: DE2-70 Audio Effector and Visualization
* @Date: July 2014
* @Github: https://github.com/MacroBull/10189020-FPGA_application_work
*/


`define fix [ws - 1:0]
`define int [ws - dp - 1:0]

// -1 == 0

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

// convert between different integer type, especially for negative numbers
module	i16to32(
	o,
	i);
	output	[31:0]	o;
	input	[15:0]	i;
	assign	o = {i[15]?-16'h1:16'h0,i};
endmodule

module	ishr32_8(
	o,
	i);
	output	[31:0]	o;
	input	[31:0]	i;
	assign	o = {i[31]?~8'h0:8'h0,i[31:8]};
endmodule

module	ishr32_16(
	o,
	i);
	output	[31:0]	o;
	input	[31:0]	i;
	assign	o = {i[31]?~16'h0:16'h0,i[31:16]};
endmodule

module	log2( // log2(0) == 0
	o,
	i);
	output	[4:0]	o;
	input	[31:0]	i;
	
	assign	o = 
		i[31]?31:i[30]?30:i[29]?29:i[28]?28:i[27]?27:i[26]?26:i[25]?25:i[24]?24:
		i[23]?23:i[22]?22:i[21]?21:i[20]?20:i[19]?19:i[18]?18:i[17]?17:i[16]?16:
		i[15]?15:i[14]?14:i[13]?13:i[12]?12:i[11]?11:i[10]?10:i[9]?9:i[8]?8:
		i[7]?7:i[6]?6:i[5]?5:i[4]?4:i[3]?3:i[2]?2:i[1]?1:0;
	
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
