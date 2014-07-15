
`define real [ws - 1:0]
`define imag [2*ws - 1:ws]
`define fix [ws - 1:0]
`define int [ws - dp - 1:0]
`define complex [2*ws - 1:0]


module test;
	
// 	reg iCLK_28;
// 	
// 	always begin
// 		#10 iCLK_28 = ~ iCLK_28;
// 	end
// 	
//   	reg [2:0] VGA_CLK_CNT;
//   	reg VGA_CLK;
//   	
//   	initial begin
// 		VGA_CLK_CNT = 0;
// 		VGA_CLK = 0;
// 		iCLK_28 = 0;
// 		#10 $monitor(iCLK_28, VGA_CLK_CNT, VGA_CLK);
// 		#200 $finish;
// 	end
//   	
//   	always @(iCLK_28) begin
// 		if (VGA_CLK_CNT == 2) begin
// 			VGA_CLK_CNT <= 0;
// 			VGA_CLK = ~ VGA_CLK;
// 		end
// 		else
// 			VGA_CLK_CNT <= VGA_CLK_CNT +1;
// 	end
  	
	
// 	parameter	ws = 16, dp = 8;
// 	parameter p = 1;
// 	
// 	wire [15:0] k;
// 	reg [15:0] x, y;
// 	
// 	wire `fix fcr, fci;
// 	wire `complex	fc;
// 	
// 	int2fix op0(fcr, 0);
// 	int2fix op1(fci, 1);
// 	assign fc = {fci, fcr};
// 	
// 	wire `fix fthres;
// 	int2fix op2(fthres, 4);
// 	
// 	
// 	wire `fix d, e;
// 	wire `complex	a, b;
// 	
// 	assign a = {16'd764, 16'd65532};
// 	assign e = 16'd65532;
// // 	fixComplex_fixAbsqr op9(d, a);
// // 	fixMul op8(d, e, e);
// 
// 	fractal inst0(k, x, y, fc, fthres);
// 	initial begin
// 		#p x = 640+18;
// 		#p y = 360;
// 		#p $display("%b",k);
// // 		#p $display("%d", d);
// 	end
// 	
// 	real r;
	
// 	assign r = 1e0;
// 	complex_mul inst0(c, a, b);
// 	initial begin
// 		$monitor("a=%di+%d, b=%di+%d, c=%di+%d.", a[31:16], a[15:0], b[31:16], b[15:0], c[31:16], c[15:0]);
// 		#10 a = 0;
// 		#10 b = 0;
// 		#10 a = {16'd33, 16'd22};
// 		#10 b = {16'd33, 16'd22};
// 	end
	
// 	parameter	ws = 16, dp = 8;
// 	wire [ws -1: 0] d, e, f;
// 	reg [ws -1: 0] a, b, c;
// 	wire [ws - dp -1 : 0] l, m, n;
// 	reg [ws - dp -1 : 0] i,j, k;
// 	
// 	int2fix inst0(d, i);
// 	int2fix inst1(e, j);
// 	fixDiv inst2(f, d, e);
// 	fix2int inst3(l, f);
// 	
// 	initial begin
// 		i = 0; j = 0;
// 		#10 i = 10; j = 20;
// 		
// 		#10 $display(d, e, " ", f);
// 	end

	parameter p = 1;
	
	reg AUD_BCLK, AUD_DACLRCK, mRST_N;
	reg	i;
	wire m, o;
	
	always begin
		#1 AUD_BCLK = ~AUD_BCLK;
		#1 AUD_BCLK = ~AUD_BCLK;
	end

	dacWrite	inst13(o, mRST_N, m, AUD_DACLRCK, AUD_BCLK);
 	adcRead	inst14(m, mRST_N, i, AUD_ADCLRCK, AUD_BCLK);



endmodule