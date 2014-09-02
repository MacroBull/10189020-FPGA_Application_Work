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

	wire [15:0] a, b, c;
	wire /*signed*/ [31:0] l, m, n;

	reg  [15:0] e, f, g;
	reg  [31:0] o, p, q;
	
	wire	`fix	x,y;
	reg	`fix	z,w;
	
	reg	[31:0]	cnt;
	wire	CLK;
	reg R;
	
	initial cnt <= 0;
	always #1 cnt <= cnt +1;
	assign CLK = cnt[0];
	
// 	initial begin
// 		cnt =0;
// 		R =0;
// 		
// // 		$monitor("%d, %d", z, a[7:0]);
// // 		$monitor("%d, %d", z, w, x);
// // 		$monitor("%d, %d", o, a);
// // 		$monitor("%d:	%b | %d,	%d", cnt, R, o, a);
// 		/*
// 		#10 e = -1;
// 		#10 e = 0;
// 		#10 e = 1;
// 		
// // 		#10 z = 0;
// 		#10 z = -255;
// 		#10 w = -8;
// 		#10 z = 250;
// 		
// 		#10 w = 250;
// 		#10 w = 7;*/
// 		
// 		
// 		#2 
// 		o = 4294574099; 
// 		R = 1;
// 		#2;
// 		R = 0;
// 		#38 
// 		R = 1;
// 		o = 49283; 
// 		#40 o = 56789*56789; 
// 		#8
// 		R = 0;
// 		#20;
// 		
// /*		
// 		#2 
// 		o = 4294574099; 
// 		#1
// 		R = 1;
// 		#10;
// 		#1 
// 		R = 0;
// 		o = 49283; 
// 		#1
// 		R = 1;
// 		
// 		#40 o = 0; 
// 		*/
// 		$finish;
// 	
// 	end
	
// 	fi_fix2int	op0(a[7:0], z);
// 	fi_div	op1(x, z, w);
// 	int_norm op2(a, e);
// 	int_sqrt	op3(a, o, CLK, R);
// 	int_sqrt_UAD	op6(a, o, CLK, R);
	
// 	dsp_SRC_power	#(8) dsp(s1, s0, CLK, R);
// 	dsp_iir_basic #(16, -507, 252, 256, -510, 256, 256)dsp2(s1, s0, CLK);
// 	dsp_iir_BS	dsp8(s1, s0, CLK);
// 	dsp_fir_multiband	dsp9(s1, s0, CLK);
	
// 	always begin
// 		#40 R = ~R;
// 	end
// 	
// 	reg	signed[15:0]	s;
// 	wire	signed[15:0]	s0, s1;
// 	
// 	assign	s0 = s;
// 	
// 	initial	begin
// 		s = 0;
// // 		s0 = 0;
// // 		s1 = 0;
// 		#4
// 		s = 100;
// // 		#2 s =0;
// 	end
	
// 	always	@(posedge CLK) begin
// 		if (s>=16*70) s<=-16*70;
// 		else s <= s + 160;
// // 		s <= 19;
// 	end
	
// 	initial begin
// 		cnt =0;
// // 		$monitor("%b: %d	%d", R, s0, s1);
// 		$dumpvars(0, cnt, CLK, s0, s1);
// 		$monitor(">>>%d\t: %d	%d", cnt, s0, s1);
// // 		$monitor("%d	%d", s0, s1);
// 		
// // 		R =0;
// // 		#16 R = 1;
// 		
// 		
// 		#960;
// 		$finish;
// 	
// 	end
	
	initial begin
		$dumpvars(0, cnt, CLK, l, a);
		$monitor(">>>%d\t: %d	%d	%d", cnt, CLK, l, a);
		
		R = 1;
		#2
		R = 0;
		o = 1;
		#2
		R = 1;
		
		
		
		#60;
		$finish;
	
	end
	
	rand_MT32 op0a(l, o, R, CLK);
	assign	a = l[15:0];
endmodule
