
`define real [ws - 1:0]
`define imag [2*ws - 1:ws]
`define fix [ws - 1:0]
`define int [ws - dp - 1:0]
`define complex [2*ws - 1:0]

module fractal(
	oIterCnt,
	x, y,
	c, 
	thres);
	
	output	[iterws - 1:0]	oIterCnt;
	
	input	`complex	c;
	input	[ws - 1:0]	x, y;
	input	`fix	thres;
	
	parameter	xOff = 640;
	parameter	yOff = 360;
	parameter	ws = 16, dp = 8;
	parameter	maxIter = 23, iterws = maxIter;
	
	wire	`fix	fx, fy;
	wire	[maxIter * ws * 2 -1:0]	z, zz;
	wire	[maxIter * ws -1:0]	az; // fix
	wire	[maxIter - 1:0] cmp;
	
	
	assign fx = x - xOff;
	assign fy = y - yOff;
	assign z[ws*2 - 1:0] = {fy, fx};
	
	genvar i;
	
	generate 
		for (i=0;i<maxIter-1;i=i+1) begin : mapIteration
			fixComplex_mul op0(
				zz[(i+1)*ws*2 - 1:i*ws*2], 
				z[(i+1)*ws*2 - 1:i*ws*2], z[(i+1)*ws*2 - 1:i*ws*2]);
			fixComplex_add op1(
				z[(i+2)*ws*2 - 1:(i+1)*ws*2], 
				zz[(i+1)*ws*2 - 1:i*ws*2], c);
			fixComplex_fixAbsqr op2(
				az[(i+1)*ws-1:i*ws],
				z[(i+1)*ws*2 - 1:i*ws*2]);
			assign cmp[i] = az[(i+1)*ws-1:i*ws] > thres; // both positie
		end
	endgenerate
	
	assign	cmp[maxIter - 1] = 1;
	assign	oIterCnt = cmp^ (cmp - 1);
	
	
// 	parameter r =  256/*.0*/, p = 10;
// 	initial begin
// 		#p $display("thres=%d", thres/r);
// 		#p $display("c=%di+%d", c[ws*2 - 1: ws]/r, z[ws-1: 0]/r);
// 		#p $display("z=%di+%d", z[ 0 * ws*2 + ws*2 - 1: 0 * ws*2 + ws]/r, z[0 * ws*2 +  ws-1: 0 * ws*2 + 0]/r);
// 		#p $display("z=%di+%d", z[ 1 * ws*2 + ws*2 - 1: 1 * ws*2 + ws]/r, z[1 * ws*2 +  ws-1: 1 * ws*2 + 0]/r);
// 		#p $display("z=%di+%d", z[ 2 * ws*2 + ws*2 - 1: 2 * ws*2 + ws]/r, z[2 * ws*2 +  ws-1: 2 * ws*2 + 0]/r);
// 		#p $display("az=%d", az[ 2 * ws +  ws-1: 2 * ws + 0]/r);
// 		#p $display("z=%di+%d", z[ 3 * ws*2 + ws*2 - 1: 3 * ws*2 + ws]/r, z[3 * ws*2 +  ws-1: 3 * ws*2 + 0]/r);
// 		#p $display("az=%d", az[ 3 * ws +  ws-1: 3 * ws + 0]/r);
// // 		#p $display({ my, mx});
// 		
// 	end
	
endmodule
	