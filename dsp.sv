
`define	dType	shortint


module dsp_peak(
	oColor,
	iX, iY,
	iDataCLK,
	iIn);
	
	output	[29:0]	oColor;
// 	output	oColor;
	
	input	[9:0]	iX, iY;
	input	iDataCLK;
	input	[ws - 1:0]	iIn;
	
	parameter	ws = 16;
	parameter	seqLen = 64;
	parameter	yPos = 10'd120;
	
	logic	[seqLen - 1:0][ws - 1:0]	x;
	
	logic	[ws - 1:0]	mx;
	
	assign	mx = x[(iX - 10'd128)/10'd4];
	
	assign oColor = (
		((iX>=128) & (iX<384) & (iY <= yPos)) &
		(iY >= yPos - ((mx[15]?-mx:mx) >> 9))
		) ? 
		{(yPos - iY) << 3, 10'd300, iY << 1}
		:0; // 128+-
	
	always	@(posedge iDataCLK) begin
		x <= {x[seqLen - 2:0], iIn};
	end
	
endmodule


module	dsp_iir(
	oOut,
	iCLK,
	iIn,
	args);
	
	
	output	[ws - 1: 0]	oOut;
	input	[ws - 1: 0]	iIn;
	input	iCLK;
	input	[argcnt - 1:0]	args;
	
	parameter	ws = 16, ews = 32;
	parameter	argcnt = 16;
	parameter	seqLen = 64;
	
	logic	[seqLen - 1:0][ws - 1:0]	x, y;
	
	wire	[ews - 1: 0] eres;
	wire	[ws - 1: 0] res;
	
	assign out = eres[ws - 1 + 8:8];
	assign res = eres[ws - 1 + 8:8];
	
	assign	eres = 
// 			(
			+x[0] 
// 			+x[1] * 34
// 			+x[2] * 17
// 			)-(
// 			+y[1] * -292
// 			+y[2] * 105
// 			)
			;
			
			
	always @(iCLK) begin
		
		
	end
	
endmodule


module dsp_volume(
	oOut,
	iIn,
	iValue16);

	output	[ws - 1: 0]	oOut;
	input	[ws - 1: 0]	iIn;
	input	[3: 0]	iValue16;
	
	parameter	ws = 16;
	
	assign	oOut = (`dType'(iIn) / 16 * iValue16);
	
endmodule


module dsp_oscilloscope(
	oColor,
	iX, iY,
	iDataCLK,
	iIn);
	
// 	output	[29:0]	oColor;
	output	oColor;
	
	input	[9:0]	iX, iY;
	input	iDataCLK;
	input	[ws - 1:0]	iIn;
	
	parameter	ws = 16;
	parameter	seqLen = 64;
	
	logic	[seqLen - 1:0][ws - 1:0]	x;
	
	assign oColor = ((iX>=128) & (iX<384)) &
		(iY - 10'd47 == ((16'd32768+ x[(iX - 10'd128)/10'd4]) >> 8) ); // 128+-
	
	always	@(posedge iDataCLK) begin
		x <= {x[seqLen - 2:0], iIn};
	end
	
endmodule


module _dsp_protype_single(
	oOut,
	iIn,
	iDataCLK,
	args);

	output	[ws - 1: 0]	oOut;
	input	[ws - 1: 0]	iIn;
	input	iDataCLK;
	input	[argcnt - 1:0]	args;
	
	parameter	ws = 16;
	parameter	argcnt = 3;
	parameter	seqLen = 64;
	
// 	integer	xL, xR, yL, yR	[seqLen - 1:0];
	logic	[seqLen - 1:0][ws - 1:0]	x,y;
	
	`dType	mOut, mIn;
	
	assign	oOut = mOut;
	assign	mIn = iIn;
	
	always	@(posedge iDataCLK) begin
		x <= {x[seqLen - 2:0], iIn};
		y <= {y[seqLen - 2:0], mOut};
	end
	
	//////////////Process////////////////
	assign	mOut = mIn / 2;
	
endmodule

// module _dsp_protype(
// 	oL, oR,
// 	iL, iR,
// 	iDataCLK,
// 	args);
// 
// 	output	[ws - 1: 0]	oL, oR;
// 	input	[ws - 1: 0]	iL, iR;
// 	input	iDataCLK;
// 	inout	[argcnt - 1:0]	args;
// 	
// 	parameter	ws = 16;
// 	parameter	argcnt = 21;
// 	parameter	seqLen = 64;
// 	
// // 	integer	xL, xR, yL, yR	[seqLen - 1:0];
// 	reg	[seqLen - 1:0][ws - 1:0]	xL, xR, yL, yR;
// 	
// 	wire	[ws - 1: 0] 
// 		mL0, mR0,
// 		mL1, mR1;
// 	
// 	assign oL = mL0;
// 	assign oR = mR0;
// 	
// 	always	@(posedge iDataCLK) begin
// 		xL <= {xL[seqLen - 2:0], iL};
// 		xR <= {xR[seqLen - 2:0], iR};
// 		yL <= {yL[seqLen - 2:0], mL0};
// 		yR <= {yR[seqLen - 2:0], mR0};
// 	end
// 	
// 	pass	dsp0(mL0, iR);
// 	
// 	wire	[ws - 1: 0]	mWave;
// 	
// 	assign	args[20] = (mWave[7 +8:0 +8] == args[7:0]);
// 	
//  	oscilloscope	dsp1(mWave, args[19:10], xR);
// 	
// endmodule
