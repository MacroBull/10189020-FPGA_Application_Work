/*
* Fractal of Julia set calculation modules
* @Author: Macrobull
* @Project: DE2-70 Audio Effector and Visualization
* @Date: July 2014
* @Github: https://github.com/MacroBull/10189020-FPGA_application_work
*/

`define real [ws - 1:0]
`define imag [2*ws - 1:ws]
`define fix [ws - 1:0]
`define int [ws - dp - 1:0]
`define complex [2*ws - 1:0]

module fi_fractal(
	/*
	* This is a generator for Julia set by:
	*
	* 	initial z0(real, image) = coord(x,y)
	* 	iterate z(i+1) = z(i)**2 + c
	* 	return i when abs(z(i)) > threshold
	*
	* represent i by a color value and we get map_of_color(x,y) = Julia(c, threshold)
	* which is the fractal graph of a Julia set.
	* See http://en.wikipedia.org/wiki/Julia_set for theory details.
	* 
	* In this module, we calculate the iteration by generated operation
	* compared results of abs(z) > threshold stores in cmp[maxIter - 1:0]
	* to get the iteration count when abs(z) > threshold appear first, simply to find the lowest bit 1
	* to conver such cmp to a color scheme, make use of "cmp^(cmp-1)" like:
	* cmp = 010011000 (low bit 1 at bit4) -> cmp^(cmp-1) = 1111 (4 * bit 1) -> {r, g, b} = 000...0001111
	*
	*
	* benchmark result shows a capability of 22 iterations at 8.75MHz pixel clock (changes on x,y), about 700MIPS
	*
	*/
	oIterCnt,
	x, y,
	c, 
	thres);
	
	output	[iterws - 1:0]	oIterCnt;
	
	input	`complex	c;
	input	[ws - 1:0]	x, y;
	input	`fix	thres; // here thres means threshold ** 2
	
	parameter	xOff = 640; // origin point offset
	parameter	yOff = 360;
	parameter	ws = 16, dp = 8;
	parameter	maxIter = 23, iterws = maxIter; // in this method, result word size equals the iteration limit
	
	wire	`fix	fx, fy; // in fix, x and y
	wire	[maxIter * ws * 2 -1:0]	z, zz; // in fix complex, zz = z*z
	wire	[maxIter * ws -1:0]	az; // in fix, abs(z) **2
	wire	[maxIter - 1:0] cmp; // in bits, compared result
	
	
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
	