module	rand_LNRand(
	oOut,
	iSeed,
	iRST_N,
	iCLK);
	
	output	[ws - 1:0]	oOut;
	input	[ws - 1:0]	iSeed;
	input	iRST_N;
	input	iCLK;
	
	parameter	ws = 16, M = 65519;
	
	reg	[ws - 1:0]	oOut, r;
	
	always	@(negedge iRST_N or negedge iCLK) begin
		if (!iRST_N) r <= iSeed;
		else begin
			oOut <= r;
			r<= ((r << 1)>M)?(r << 1)-M:M-(r << 1);
		end
	end
endmodule


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