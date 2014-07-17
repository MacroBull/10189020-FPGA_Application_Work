///////////// NOTE  Using ~ instead of - to avoid -32768

// `define	dType	shortint
// `define	wsOff	(1 << (ws - 1))


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
	
	reg	[seqLen - 1:0][ws - 1:0]	x;
	
	reg	[ws - 1:0]	mx;
	
	assign	mx = x[(iX - 10'd128)/10'd4];
// 	assign	mx = (iX & 10'h3)?x[(iX - 10'd128)/10'd4]:0;
	
	assign oColor = (
		((iX>=128) & (iX<384) & (iY <= yPos)) &
		(iY >= yPos - ((mx[15]?~mx:mx) >> 9))
		) ? 
		{(yPos - iY) << 3, 10'd300, iY << 1}
		:0; // 128+-
	
	always	@(posedge iDataCLK) begin
		x <= {x[seqLen - 2:0], iIn};
	end
	
endmodule


module	dsp_iir_lowpass( 
	oOut,
	iIn,
	iCLK);
	
	output	[ws - 1: 0]	oOut;
	input	[ws - 1: 0]	iIn;
	input	iCLK;
// 	input	[argLen - 1:0]	args;
	
	parameter	ws = 16, ews = 32, dpa = 16, dpb = 16;
	parameter	seqLen = 7;
// 	parameter	argLen = 1;
	
	reg	[seqLen - 1:0][ews - 1:0]	x, y;
	
	wire	[ews - 1: 0] m32A, m32B, m32In, m32Out;

	i16to32	conv0(m32In, iIn);
	ishr32_16	conv1(m32Out, m32B - m32A);
// 	ishr32_8	conv1(m32Out, m32B - m32A);
// 	assign	m32Out = m32In;
	
	assign	oOut = {m32Out[31], m32Out[ws - 2:0]};// top
	
	always @(posedge iCLK) begin
		x <= {x[seqLen - 2:0], m32In};
		y <= {y[seqLen - 2:0], m32Out};
	end
	
	///////////////Process/////////////////
	
	// butterworth
	assign	m32B =
		+x[0] * 90
		+x[1] * 180
		+x[2] * 330
		+x[3] * 580
		+x[4] * 330
		+x[5] * 180
		+x[6] * 90
	;
	assign	m32A =
		+y[1] * -7588
		+y[2] * -7588
		+y[3] * 12644
		+y[4] * 12644
		+y[5] * -17870
		+y[6] * -17870
	;

	
endmodule

module	dsp_iir_bandpass( 
	oOut,
	iIn,
	iCLK);
	
	output	[ws - 1: 0]	oOut;
	input	[ws - 1: 0]	iIn;
	input	iCLK;
// 	input	[argLen - 1:0]	args;
	
	parameter	ws = 16, ews = 32, dpa = 16, dpb = 16;
	parameter	seqLen = 3;
// 	parameter	argLen = 1;
	
	reg	[seqLen - 1:0][ews - 1:0]	x, y;
	
	wire	[ews - 1: 0] m32A, m32B, m32In, m32Out;

	i16to32	conv0(m32In, iIn);
	ishr32_16	conv1(m32Out, m32B - m32A);
// 	ishr32_8	conv1(m32Out, m32B - m32A);
// 	assign	m32Out = m32In;
	
	assign	oOut = {m32Out[31], m32Out[ws - 2:0]};// top
	
	always @(posedge iCLK) begin
		x <= {x[seqLen - 2:0], m32In};
		y <= {y[seqLen - 2:0], m32Out};
	end
	
	///////////////Process/////////////////
	
	// Cheby2 bandpass
	assign	m32B =
		+x[0] * 15556 
		+x[1] * 0 
		+x[2] * -15556 
	;
	assign	m32A =
		+y[1] * -30174 	//BAD
		+y[2] * 30422 	//BAD
	;

	
endmodule

module	dsp_fir( 
	oOut,
	iIn,
	iCLK,
	iIndex);
	
	output	[ws - 1: 0]	oOut;
	input	[ws - 1: 0]	iIn;
	input	iCLK;
	input	[2:0]	iIndex;
	
	parameter	ws = 16, ews = 32, dp = 12;
	parameter	argLen = 1;
	parameter	seqLen = 15;
	
	reg	[seqLen - 1:0][ews - 1:0]	x;
	
	
	wire	[ews - 1: 0] m32In, m32B0
		, m32B1, m32B2, m32B3, m32B4, m32B5, m32B6, m32B7;

	i16to32	conv0(m32In, iIn);
	
// 	assign	oOut = m32B[31:16]; // gain - (16-dp)
// 	assign	oOut = {m32B[31], m32B[15:8]};

	assign	oOut = ((iIndex == 0)? m32B0[31:16]:
		(iIndex == 1)? m32B1[31:16]:
		(iIndex == 2)? m32B2[31:16]:
		(iIndex == 3)? m32B3[31:16]:
		(iIndex == 4)? m32B4[31:16]:
		(iIndex == 5)? m32B5[31:16]:
		(iIndex == 6)? m32B6[31:16]:
		 m32B7[31:16]);
	
	always @(posedge iCLK) begin
		x <= {x[seqLen - 2:0], m32In};
	end
	///////////////Process/////////////////
		
	//Dance
	assign	m32B0 =
		+x[0] * 11 
		+x[1] * -8 
		+x[2] * 89 
		+x[3] * -40 
		+x[4] * 378 
		+x[5] * 74 
		+x[6] * -422 
		+x[7] * 1775 
		+x[8] * -422 
		+x[9] * 74 
		+x[10] * 378 
		+x[11] * -40 
		+x[12] * 89 
		+x[13] * -8 
		+x[14] * 11 
	;
	//Bass
	assign	m32B1 =
		+x[0] * 2 
		+x[1] * 10 
		+x[2] * 33 
		+x[3] * 79 
		+x[4] * 158 
		+x[5] * 253 
		+x[6] * 376 
		+x[7] * 470 
		+x[8] * 376 
		+x[9] * 253 
		+x[10] * 158 
		+x[11] * 79 
		+x[12] * 33 
		+x[13] * 10 
		+x[14] * 2 
	;
	//Bass&Treble
	assign	m32B2 =
		+x[0] * 43 
		+x[1] * -170 
		+x[2] * 533 
		+x[3] * -890 
		+x[4] * 1371 
		+x[5] * -4211 
		+x[6] * -5263 
		+x[7] * 19281 
		+x[8] * -5263 
		+x[9] * -4211 
		+x[10] * 1371 
		+x[11] * -890 
		+x[12] * 533 
		+x[13] * -170 
		+x[14] * 43 
	;
	//Treble
	assign	m32B3 =
		+x[0] * 95 
		+x[1] * -192 
		+x[2] * 508 
		+x[3] * -1683 
		+x[4] * 276 
		+x[5] * -8052 
		+x[6] * -4146 
		+x[7] * 33106 
		+x[8] * -4146 
		+x[9] * -8052 
		+x[10] * 276 
		+x[11] * -1683 
		+x[12] * 508 
		+x[13] * -192 
		+x[14] * 95 
	;
	//Rock
	assign	m32B4 =
		+x[0] * 34 
		+x[1] * -82 
		+x[2] * 321 
		+x[3] * -571 
		+x[4] * 349 
		+x[5] * -3877 
		+x[6] * -2582 
		+x[7] * 14576 
		+x[8] * -2582 
		+x[9] * -3877 
		+x[10] * 349 
		+x[11] * -571 
		+x[12] * 321 
		+x[13] * -82 
		+x[14] * 34 
	;
	//Soft Rock
	assign	m32B5 =
		+x[0] * 29 
		+x[1] * -67 
		+x[2] * 232 
		+x[3] * -398 
		+x[4] * 801 
		+x[5] * -1016 
		+x[6] * -2576 
		+x[7] * 6471 
		+x[8] * -2576 
		+x[9] * -1016 
		+x[10] * 801 
		+x[11] * -398 
		+x[12] * 232 
		+x[13] * -67 
		+x[14] * 29 
	;
	//T3
	assign	m32B6 =
		+x[0] * -12 
		+x[1] * 28 
		+x[2] * 129 
		+x[3] * 288 
		+x[4] * -333 
		+x[5] * -2293 
		+x[6] * 190 
		+x[7] * 4224 
		+x[8] * 190 
		+x[9] * -2293 
		+x[10] * -333 
		+x[11] * 288 
		+x[12] * 129 
		+x[13] * 28 
		+x[14] * -12 
	;
	//Techno
	assign	m32B7 =
		+x[0] * 21 
		+x[1] * -68 
		+x[2] * 185 
		+x[3] * -488 
		+x[4] * 114 
		+x[5] * -2875 
		+x[6] * -1479 
		+x[7] * 11114 
		+x[8] * -1479 
		+x[9] * -2875 
		+x[10] * 114 
		+x[11] * -488 
		+x[12] * 185 
		+x[13] * -68 
		+x[14] * 21 
	;

	
endmodule

module	dsp_fir_spectrum( 
	oSpec,
	iIn,
	iCLK);
	
	output	[4*5 - 1: 0]	oSpec;
	input	[ws - 1: 0]	iIn;
	input	iCLK;
	
	parameter	ws = 16, ews = 32, dp = 12;
	parameter	seqLen = 15;
// 	parameter	bG0 = 30, bG1 = 30, bG2 = 30, bG3 = 30;
	parameter	cntMax = 6000;
	
	reg	[seqLen - 1:0][ews - 1:0]	x;
	
	
	wire	[ews - 1: 0] m32In, m32B0, m32B1, m32B2, m32B3;
	wire	[4: 0] m5B0, m5B1, m5B2, m5B3;
	reg	[4: 0] b5B0, b5B1, b5B2, b5B3, m5M0, m5M1, m5M2, m5M3;
	reg	[15: 0] cnt;

	i16to32	conv0(m32In, iIn);	
	assign	oSpec = {m5M3, m5M2, m5M1, m5M0};
	
	always @(posedge iCLK) begin
		x <= {x[seqLen - 2:0], m32In};
	end
	
	log2	op0(m5B0, m32B0[31]?~m32B0:m32B0);
	log2	op1(m5B1, m32B1[31]?~m32B1:m32B1);
	log2	op2(m5B2, m32B2[31]?~m32B2:m32B2);
	log2	op3(m5B3, m32B3[31]?~m32B3:m32B3);
	
	always @(posedge iCLK) begin
	
		b5B0 <= m5B0;
		b5B1 <= m5B1;
		b5B2 <= m5B2;
		b5B3 <= m5B3;
		
		if (b5B0>m5M0) m5M0 <= b5B0;
		if (b5B1>m5M1) m5M1 <= b5B1;
		if (b5B2>m5M2) m5M2 <= b5B2;
		if (b5B3>m5M3) m5M3 <= b5B3;
		
		if (cnt)
			cnt <= cnt -1;
		else begin
			cnt <= cntMax;
			m5M0 <= m5M0 >> 1;
			m5M1 <= m5M1 >> 1;
			m5M2 <= m5M2 >> 1;
			m5M3 <= m5M3 >> 1;
		end
	end
	
	
	///////////////Process/////////////////
		
	//100Hz
	assign	m32B0 =
		+x[0] * 10 
		+x[1] * 16 
		+x[2] * 32 
		+x[3] * 56 
		+x[4] * 82 
		+x[5] * 105 
		+x[6] * 122 
		+x[7] * 128 
		+x[8] * 122 
		+x[9] * 105 
		+x[10] * 82 
		+x[11] * 56 
		+x[12] * 32 
		+x[13] * 16 
		+x[14] * 10 
	;
	
	//1000Hz
	assign	m32B1 =
		+x[0] * -2 
		+x[1] * 2 
		+x[2] * 21 
		+x[3] * 65 
		+x[4] * 132 
		+x[5] * 208 
		+x[6] * 269 
		+x[7] * 292 
		+x[8] * 269 
		+x[9] * 208 
		+x[10] * 132 
		+x[11] * 65 
		+x[12] * 21 
		+x[13] * 2 
		+x[14] * -2 
	;
	
		//4000Hz
	assign	m32B2 =
		+x[0] * -8 
		+x[1] * -24 
		+x[2] * -56 
		+x[3] * -123 
		+x[4] * -272 
		+x[5] * -128 
		+x[6] * 686 
		+x[7] * 1258 
		+x[8] * 686 
		+x[9] * -128 
		+x[10] * -272 
		+x[11] * -123 
		+x[12] * -56 
		+x[13] * -24 
		+x[14] * -8 
	;
	
		//16000Hz
	assign	m32B3 =
		+x[0] * 5 
		+x[1] * 11 
		+x[2] * 15 
		+x[3] * -87 
		+x[4] * 489 
		+x[5] * -1246 
		+x[6] * -1465 
		+x[7] * 4620 
		+x[8] * -1465 
		+x[9] * -1246 
		+x[10] * 489 
		+x[11] * -87 
		+x[12] * 15 
		+x[13] * 11 
		+x[14] * 5 
	;
	
endmodule


module dsp_volume(
	oOut,
	iIn,
	iVolume);

	output	[ws - 1: 0]	oOut;
	input	[ws - 1: 0]	iIn;
	input	[vws: 0]	iVolume; // + twice volume!
	
	parameter	ws = 16, vws = 5;
	
	wire	[31:0]	m32In, m32Out;
	
	i16to32	conv0(m32In, iIn);
	
	assign m32Out = m32In * iVolume;
	
	assign	oOut = m32Out[ws + vws -1:vws];
	
endmodule

// module dsp_AGC_bit(
// 	oOut,
// 	iIn,
// 	iCLK,
// 	oVol);
// 
// 	output	[ws - 1: 0]	oOut;
// 	input	[ws - 1: 0]	iIn;
// 	output	[2:0]	oVol;
// 	input	iCLK;
// 	
// 	parameter	ws = 16;
// 	parameter	cntMax = 100;
// 	
// 	
// 	wire	[ws - 1:0]	mAbs;
// 	wire	[4:0]	mHigh;
// 	wire	mCmp;
// 	
// 	reg	[4:0]	mMax;
// 	reg	[2:0]	vol;
// 	reg	[15:0]	cnt;
// 	
// 	
// 	assign	mAbs = iIn[15]?~iIn:iIn;
// 	assign	mHigh = mAbs[14:10];
// 	assign	mCmp = (mHigh>mMax);
// 	assign	oOut = iIn << vol;
// 	assign	oVol = vol;
// 	
// 	always @(posedge iCLK or posedge mCmp) begin
// 		if (mCmp) begin
// 			mMax <= mHigh;
// 			vol <= mHigh[4]?0:mHigh[3]?1:mHigh[2]?2:
// 				mHigh[1]?3:mHigh[0]?4:5;
// 			cnt <= cntMax;
// 		end
// 		else if (cnt)
// 			cnt <= cnt - 1;
// 		else begin
// 			cnt <= cntMax;
// 			if (mMax >> 1 >mHigh) begin
// 				mMax <= mMax >> 1;
// 				vol <= vol + 1;
// 			end
// 		end
// 	end
// 	
// endmodule

module dsp_AGC(
	oOut,
	iIn,
	iCLK,
	oVol);

	output	[ws - 1: 0]	oOut;
	input	[ws - 1: 0]	iIn;
	output	[31:0]	oVol;
	input	iCLK;
	
	parameter	ws = 16;
	parameter	cntMax = 36;
	parameter	poMax = 8191 * 65536;
	parameter	vRamp = 32'd128, vMax = 32'h200000;
	
	wire	[31:0]	m32In, m32Out;
	
	reg	[31:0]	vol;
	reg	[15:0]	mAbs, mMax;
	reg	[15:0]	cnt;
	
	i16to32	conv0(m32In, iIn);
	assign	oOut = m32Out[31:16];
	assign	oVol = vol;
	
	assign	m32Out = m32In * vol;
	
	always @(posedge iCLK) begin
		mAbs <= iIn[15]?~iIn:iIn;
		if (mAbs > mMax) begin
			vol <= poMax / mAbs;
			mMax <= mAbs;
			cnt <=cntMax;
		end
		else 
			if (cnt)
				cnt <= cnt - 1;
			else begin
				cnt <= cntMax;
				if (vol < vMax)
					vol <= vol + vRamp;
				else
					vol <= vMax;
				mMax <= poMax / vol;
			end
	end
	
endmodule


// module dsp_oscilloscope(
// 	oColor,
// 	iX, iY,
// 	iDataCLK,
// 	iIn);
// 	
// // 	output	[29:0]	oColor;
// 	output	oColor;
// 	
// 	input	[9:0]	iX, iY;
// 	input	iDataCLK;
// 	input	[ws - 1:0]	iIn;
// 	
// 	parameter	ws = 16;
// 	parameter	seqLen = 64;
// 	
// 	reg	[seqLen - 1:0][ws - 1:0]	x;
// 	
// 	assign oColor = ((iX>=128) & (iX<384)) &
// 		(iY - 10'd47 == ((16'd32768+ x[(iX - 10'd128)/10'd4]) >> 8) ); // 128+-
// 	
// 	always	@(posedge iDataCLK) begin
// 		x <= {x[seqLen - 2:0], iIn};
// 	end
// 	
// endmodule


module	i16to32(
	o,
	i);
	output	[31:0]	o;
	input	[15:0]	i;
	assign	o = {i[15]?-16'h1:16'h0,i};
endmodule

module	ishr32_8(
	o,
	i);
	output	[31:0]	o;
	input	[31:0]	i;
	assign	o = {i[31]?~8'h0:8'h0,i[31:8]};
endmodule

module	ishr32_16(
	o,
	i);
	output	[31:0]	o;
	input	[31:0]	i;
	assign	o = {i[31]?~16'h0:16'h0,i[31:16]};
endmodule

module	log2(
	o,
	i);
	output	[4:0]	o;
	input	[31:0]	i;
	
	assign	o = 
		i[31]?31:i[30]?30:i[29]?29:i[28]?28:i[27]?27:i[26]?26:i[25]?25:i[24]?24:
		i[23]?23:i[22]?22:i[21]?21:i[20]?20:i[19]?19:i[18]?18:i[17]?17:i[16]?16:
		i[15]?15:i[14]?14:i[13]?13:i[12]?12:i[11]?11:i[10]?10:i[9]?9:i[8]?8:
		i[7]?7:i[6]?6:i[5]?5:i[4]?4:i[3]?3:i[2]?2:i[1]?1:0;
	
endmodule