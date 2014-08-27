/*
* Test bench
* @Author: Macrobull
* @Project: DE2-70 Audio Effector and Visualization
* @Date: July 2014
* @Github: https://github.com/MacroBull/10189020-FPGA_application_work
*/



`define	fix	signed	[ws - 1:0]
`define	int	signed	[ws - dp - 1:0]

module test;

	parameter	ws = 16, dp = 8;

	wire signed [15:0] a, b, c;
	wire signed [31:0] l, m, n;

	reg signed [15:0] e, f, g;
	reg signed [31:0] o, p, q;
	
	wire	`fix	x,y;
	reg	`fix	z,w;
	
	
	initial begin
		
// 		$monitor("%d, %d", z, a[7:0]);
// 		$monitor("%d, %d", z, w, x);
		$monitor("%d, %d", e, a);
		
		#10 e = -32760;
		#10 e = 0;
		#10 e = 1;
		
// 		#10 z = 0;
		#10 z = -255;
		#10 w = -8;
		#10 z = 250;
		
		#10 w = 250;
		#10 w = 7;
	
	end
	
// 	fi_fix2int	op0(a[7:0], z);
// 	fi_div	op1(x, z, w);
	int_redAbs op2(a, e);
	
endmodule