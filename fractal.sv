module fractal(
	iterVal,
	x, y,
	c, 
	thres);
	
	output	[iterws:0]	iterVal;
	
	input	[11:0]	x, y;
	input	[31:0]	c;
	input	[31:0]	thres;
	
	
	wire	[maxIter:0][31:0]	z, zz;
	wire	[maxIter:0][31:0]	az;
	wire	[maxIter:0] cmp;
	
	parameter	scale = 1;
	parameter	xOff = 0;
	parameter	yOff = 0;
	parameter	maxIter = 20;
	parameter	iterws = maxIter;
	
	assign iterVal = cmp;
	assign z[0] = { 4'h0, y - yOff, 4'h0, x - xOff} * scale;
	
	genvar i;
	
	generate 
		for (i=0;i<maxIter;i=i+1) begin : mapIteration
			complex_absqr compInst0(az[i], z[i]);
			complex_mul comInst1(zz[i], z[i], z[i]);
			assign z[i+1] = zz[i] + c;
			assign cmp[i] = az[i] < thr;
		end
	endgenerate
	
endmodule
	