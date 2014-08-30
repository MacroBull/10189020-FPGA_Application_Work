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
	wire signed [31:0] l, m, n;

	reg  [15:0] e, f, g;
	reg  [31:0] o, p, q;
	
	wire	`fix	x,y;
	reg	`fix	z,w;
	
	reg	[31:0]	cnt;
	wire	CLK;
	reg R;
	
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
	int_sqrt_UAD	op6(a, o, CLK, R);
	
	dsp_SRC_power	#(8) dsp(s1, s0, CLK, R);
	
	always begin
		#40 R = ~R;
	end
	
	reg	signed[15:0]	s;
	wire	signed[15:0]	s0, s1;
	
	assign	s0 = s;
	
	initial	s = 0;
	always	@(posedge CLK) begin
		if (s>=16*70) s<=-16*70;
		else s <= s + 160;
// 		s <= 19;
	end
	
	initial begin
		cnt =0;
		$monitor("%b: %d	%d", R, s0, s1);
		
		R =0;
		#16 R = 1;
		
		
		#180;
		
		$finish;
	
	end
	
endmodule
/*
`define	audio	signed[15:0]

module	dsp_SRC_power(
	oOut,
	iIn,
	iCLK, iCHS
	);
	
	output	reg	`audio	oOut;
	input	`audio	iIn;
	input	iCLK, iCHS;
	
	parameter	cnt_ws = 12;
	
	wire	`audio	mOut;
	reg	[31:0]	avg, sum;
	reg	[cnt_ws - 1:0]	cnt;
	reg	mCHS_prev, ctrl;
	
	int_sqrt_UAD	op0(mOut, avg, iCLK, ctrl);
	
	always @(negedge iCLK) begin
		mCHS_prev <= iCHS;
		if ({mCHS_prev, iCHS} == 2'b01) begin
// 			$display(">> %d	%d	last=%d", sum, cnt, avg);
			avg <= (sum / cnt)<<cnt_ws;
			ctrl <= 1'b1;
			oOut <= mOut;
			sum <= 0;
			cnt <= 0;
		end
		else begin
			ctrl <= 1'b0;
			sum <= sum + (iIn * iIn >> cnt_ws);
			cnt <= cnt + 1;
		end
	end
	
endmodule
*/
