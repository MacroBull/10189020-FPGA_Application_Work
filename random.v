

module	rand_adc(
	oOut,
	iIn,
	iCLK);
	
	output	[ws - 1:0]	oOut;
	input	iIn;
	input	iCLK;
	
	parameter	ws = 16;
	
	reg	[ws - 1:0]	oOut, oBuf;
	reg	[3:0]	mIndex;
	
	always	@(negedge iCLK) begin
		if (!mIndex) oOut <= oBuf;
		oBuf[mIndex] <= iIn;
		mIndex <= mIndex + 1;
	end
endmodule

module	rand_clk(
	oOut,
	iCLKH,
	iCLKL);
	
	output	[ws - 1:0]	oOut;
	input	iCLKH, iCLKL;
	
	parameter	ws = 16;
	
	reg	[ws - 1:0]	oOut, oBuf;
	reg	[3:0]	mIndex;
	
	always	@(negedge iCLKL) begin
		if (!mIndex) oOut <= oBuf;
		oBuf[mIndex] <= iCLKH;
		mIndex <= mIndex + 1;
	end
endmodule