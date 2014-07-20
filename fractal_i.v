
`define real [ws - 1:0]
`define imag [2*ws - 1:ws]
`define fix [ws - 1:0]
`define int [ws - dp - 1:0]
`define complex [2*ws - 1:0]

module fractal(
	/*
	* This is a generator for Julia set by:
	*
	* 	initial z0(real, image) = coord(x,y)
	* 	iterate z(i+1) = z(i)**2 + c
	* 	return i when abs(z) > threshold
	*
	* represent i by a color value and we get map_of_color = Julia(c, threshold)
	* which is the fractal graph of a Julia set.
	* 
	* In this module, we calculate the iteration in parallel
	* compared results of abs(z) > threshold stores in cmp
	* to get the iteration count when abs(z) > threshold appear first, simply find the lowest bit 1
	* to conver such cmp to a color scheme, simply make use of cmp^(cmp-1)
	* cmp = 010011000 (low bit 1 at bit4) -> cmp^(cmp-1) = 1111 (4 * bit 1) -> {r, g, b} = 1111
	*/
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
	assign z[ws*2 - 1:0] = {fy, fx}; // initial z(0)
	
	genvar i;
	
	generate 
		for (i=0;i<maxIter-1;i=i+1) begin : mapIteration // z(i+1) = z(i)**2 + c, cmp(i) = z(i) > threshold
			fixComplex_mul op0(
				zz[(i+1)*ws*2 - 1:i*ws*2], 
				z[(i+1)*ws*2 - 1:i*ws*2], z[(i+1)*ws*2 - 1:i*ws*2]);
			fixComplex_add op1(
				z[(i+2)*ws*2 - 1:(i+1)*ws*2], 
				zz[(i+1)*ws*2 - 1:i*ws*2], c);
			fixComplex_fixAbsqr op2(
				az[(i+1)*ws-1:i*ws],
				z[(i+1)*ws*2 - 1:i*ws*2]);
			assign cmp[i] = az[(i+1)*ws-1:i*ws] > thres; // both positie values
		end
	endgenerate
	
	assign	cmp[maxIter - 1] = 1; // itercount = maxIter if itercount > maxIter
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
	