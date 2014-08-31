/*
* Audio DSP modules
* @Author: Macrobull
* @Project: DE2-70 Audio Effector and Visualization
* @Date: July 2014
* @Github: https://github.com/MacroBull/10189020-FPGA_application_work
*/



`define	audio	signed	[15:0]
`define	audio32	signed	[31:0]
`define	peak	[14:0]   // 15 bit, reduced

`define	vgaVersEdge	negedge

module	dsp_peakHolder_max(
	oOut,
	iIn,
	iiCLK, ioCLK
	);
	
	output	reg	`peak	oOut;
	input	`peak	iIn;
	input	iiCLK, ioCLK;
	
	reg	`peak	mMax;
	reg	moCLK_prev;
	
	always @(negedge iiCLK) begin
		moCLK_prev <= ioCLK;
		if ({moCLK_prev,ioCLK} == 2'b10) begin
			oOut <= mMax;
			mMax <= iIn; 
		end
		else begin
			if (iIn>mMax) mMax <= iIn;
		end
	end
	
endmodule

module	dsp_waveHolder_max(
	oOut,
	iIn,
	iiCLK, ioCLK
	);
	
	output	reg	`audio	oOut;
	input	`audio	iIn;
	input	iiCLK, ioCLK;
	
	reg	`audio	mMax;
	wire	`audio	 iAmp, mAmp;
	reg	moCLK_prev;
	
	int_redAbs	op0(iAmp, iIn);
	int_redAbs	op1(mAmp, mMax);
	
	always @(negedge iiCLK) begin
		moCLK_prev <= ioCLK;
		if ({moCLK_prev,ioCLK} == 2'b10) begin
			oOut <= mMax;
			mMax <= iIn; 
		end
		else begin
			if (iAmp>mAmp) mMax <= iIn;
		end
	end
	
endmodule


module	dsp_SRC_avg(
	oOut,
	iIn,
	iCLK, iCHS
	);
	
	output	reg	`audio	oOut;
	input	`audio	iIn;
	input	iCLK, iCHS;
	
	reg	`audio32	sum;
	reg	`audio32	cnt;
	reg	mCHS_prev, ctrl;
	
	always @(negedge iCLK) begin
		mCHS_prev <= iCHS;
		if ({mCHS_prev, iCHS} == 2'b01) begin
			oOut <= sum / cnt;
			
			sum <= 0;
			cnt <= 0;
		end
		else begin
			ctrl <= 1'b0;
			sum <= sum + iIn;
			cnt <= cnt + 1;
		end
	end
	
endmodule

module	dsp_SRC_power(
	oOut,
	iIn,
	iCLK, iCCLK, iCHS
	);
	
	output	reg	`audio	oOut;
	input	`audio	iIn;
	input	iCLK, iCCLK, iCHS;
	
	parameter	cnt_ws = 12;
	
	wire	`audio	mOut;
	reg	`audio32	avg, ssum;
// 	reg	[cnt_ws - 1:0]	cnt;
	reg	`audio32	cnt;
	reg	mCHS_prev, ctrl;
	
	int_sqrt_UAD	op0(mOut, (avg>=0)?avg:-avg, iCCLK, ctrl);
	
	always @(negedge iCLK) begin
		mCHS_prev <= iCHS;
		if ({mCHS_prev, iCHS} == 2'b01) begin
//  			$display(">> %d	%d	last=%d", ssum, cnt, avg);
			avg <= (ssum / cnt)<<<cnt_ws;
			ctrl <= 1'b1;
			oOut <= (ssum>=0)?mOut:-mOut;
			
			ssum <= 0;
			cnt <= 0;
		end
		else begin
			ctrl <= 1'b0;
//  			$display("<< %d	%d", ssum, cnt);
			ssum <= ssum + ( ((iIn>=0)?iIn:-iIn) * iIn >>> cnt_ws);
			cnt <= cnt + 1;
		end
	end
	
endmodule

module	dsp_iir_basic(
	oOut,
	iIn,
	iCLK);
	
	output	reg	`audio	oOut;
	input	`audio	iIn;
	input	iCLK;
// 	input	[argLen - 1:0]	args;
	
// 	parameter	dpa = 16, dpb = 16; 
	parameter	dp = 16; 
	parameter	A1 = 256, A2 = 256; 
	parameter	B0 = 256, B1 = 256, B2 = 256; 
	parameter	gain = 256;//, order = 2;
	
// 	reg	signed	[order:0][31:0]	x, y;
	reg	`audio	x0, x1, x2, y0, y1, y2;
// 	wire	`audio32	m;

	initial begin x0= 0;x1=0; x2=0; y0=0; y1=0; y2=0; end
	
// 	assign	m = (x0*B0+x1*B1+x2*B2-y1*A1-y2*A2)*gain;
	
	always @(negedge iCLK) begin
		oOut <= y0;
		y0 <= ((x0*B0+x1*B1+x2*B2-y1*A1-y2*A2)*gain)>>>dp;
//  		y0 <= m[dp+15:dp] + (m[31]&m[dp]);
	end
	
	always @(posedge iCLK) begin
// 		$display("P:%d %d %d |	%d %d %d | %d", x0, x1, x2, y0, y1,y2, m);
		x0 <= iIn;
		x1 <= x0;
		x2 <= x1;
		y1 <= y0;
		y2 <= y1;
	end
	
endmodule

module	dsp_fir_basic(
	oOut,
	iIn,
	iCLK);
	
	output	reg	`audio	oOut;
	input	`audio	iIn;
	input	iCLK;
// 	input	[argLen - 1:0]	args;
	
	parameter	dp = 16; 
	parameter	B0 = 256, B1 = 256, B2 = 256; 
	parameter	gain = 256;//, order = 2;
	
	reg	`audio	x0, x1, x2;
	
	always @(negedge iCLK) begin
		oOut <= ((x0*B0+x1*B1+x2*B2)*gain)>>>dp;
	end
	
	always @(posedge iCLK) begin
		x0 <= iIn;
		x1 <= x0;
		x2 <= x1;
	end
	
endmodule

module	dsp_iir_LP(
	oOut,
	iIn,
	iCLK);
	
	output	`audio	oOut;
	input	`audio	iIn;
	input	iCLK;
	
	wire	`audio	f0, f1, f2, f3, f4;
	
	assign	f0 = iIn;
	assign	oOut = f4;
	
// 	always	@iCLK $display("--- %d %d %d %d %d", f0, f1, f2, f3, f4);
	
	dsp_iir_basic	#(16, -507, 252, 256, -510, 256, 256) dsp0(f1, f0, iCLK);
	dsp_iir_basic	#(16, -498, 243, 256, -510, 256, 256) dsp1(f2, f1 >>> 2, iCLK);
  	dsp_iir_basic	#(16, -488, 233, 256, -508, 256, 256) dsp2(f3, f2 >>> 2, iCLK);
 	dsp_iir_basic	#(16, -478, 223, 256, -472, 220, 256) dsp3(f4, f3 >>> 2, iCLK);
	
endmodule

module	dsp_iir_BS(
	oOut,
	iIn,
	iCLK);
	
	output	`audio	oOut;
	input	`audio	iIn;
	input	iCLK;
	
	wire	`audio	f0, f1, f2, f3, f4;
	
	assign	f0 = iIn;
	assign	oOut = f4;
	
	dsp_iir_basic	#(16, -1741, 740, 1024, -1830, 1016, 27) 	dsp0(f1, f0, iCLK);
// 	dsp_iir_basic	#(16, -1741, 740, 1024, -2031, 1024, 64) 	dsp1(f2, f1 , iCLK);

	dsp_iir_basic	#(16, -507, 252, 256, -510, 256, 256) dsp1x(f2, f1, iCLK);

  	dsp_iir_basic	#(16, -1741, 740, 1024, -2045, 1028, 64) 	dsp2(f3, f2, iCLK);
 	dsp_iir_basic	#(16, -1741, 740, 1024, -1978, 1024, 64) 	dsp3(f4, f3, iCLK);
	
endmodule

module	dsp_fir_cascade(
	oOut,
	iIn,
	iCLK);
	
	output	`audio	oOut;
	input	`audio	iIn;
	input	iCLK;
	
	wire	`audio	f0, f1, f2, f3, f4;
	
	assign	f0 = iIn;
	assign	oOut = f4;
	
	dsp_fir_basic	#(16, 1472, -1002, -3649, 12) 	dsp0(f1, f0, iCLK);
	dsp_fir_basic	#(16, 4096, 1124, -1652, 12) 	dsp1(f2, f1, iCLK);
	dsp_fir_basic	#(16, 4096, 5642, 4647, 12) 	dsp2(f3, f2, iCLK);
	dsp_fir_basic	#(16, 4096, -6958, 4096, 12) 	dsp5(f4, f3, iCLK);
	
endmodule



// 
module	dsp_fir_multiband( 
	/*
	* This is a designed FIR Filter by:(python)
	*	from scipy.signal import *
	*	b = firwin2(order, freqs, gains, antisymmetric = False)
	*
	* oOut = filter(iIn, @iClk)
	* y = b[n-1] * x + b[n-2] * x(1) + b[n-3] * x(2) ... + b[0] * x(n) @ T = iCLK
	* 
	* iIndex to select preset from Techno .. T3
	* gain values reffered from pulseaudio-equalizer
	*/
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
	parameter	order = 15;
	
	reg	[order - 1:0][ews - 1:0]	x;
	
	
	wire	[ews - 1: 0] m32In, m32B0
		, m32B1, m32B2, m32B3, m32B4, m32B5, m32B6, m32B7;

	i16to32	conv0(m32In, iIn);
	
	// m32Bx = filter(m32In)
	assign	oOut = ((iIndex == 0)? m32B0[31:16]: 
		(iIndex == 1)? m32B1[31:16]:
		(iIndex == 2)? m32B2[31:16]:
		(iIndex == 3)? m32B3[31:16]:
		(iIndex == 4)? m32B4[31:16]:
		(iIndex == 5)? m32B5[31:16]:
		(iIndex == 6)? m32B6[31:16]:
		 m32B7[31:16]);
	
	always @(posedge iCLK) begin
		x <= {x[order - 2:0], m32In};
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

module	dsp_fir_spectrum( /*
	* Derived from FIR filter
	* Amp@freq = filter@bandpass_centr_freq(iIn, @iClk)
	* Gain@freq = abs(Amp@freq)
	* oSpec = Holder(log2(Gain), T = iCLK)  (5bits)
	*/
	oSpec,
	iIn,
	iCLK);
	
	output	[4*5 - 1: 0]	oSpec;
	input	[ws - 1: 0]	iIn;
	input	iCLK;
	
	parameter	ws = 16, ews = 32, dp = 12;
	parameter	order = 15;
	parameter	cntMax = 6000;
	
	reg	[order - 1:0][ews - 1:0]	x;
	
	
	wire	[ews - 1: 0] m32In, m32B0, m32B1, m32B2, m32B3; // 32-bit registers for x and y
	wire	[4: 0] m5B0, m5B1, m5B2, m5B3; // 5-bit wire for log(gain)
	reg	[4: 0] b5B0, b5B1, b5B2, b5B3, m5M0, m5M1, m5M2, m5M3; // 5-bit registers for synced/holded log(gain)
	reg	[15: 0] cnt;

	i16to32	conv0(m32In, iIn);	
	assign	oSpec = {m5M3, m5M2, m5M1, m5M0};
	
	always @(posedge iCLK) begin
		x <= {x[order - 2:0], m32In};
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
		
		// only values syned to registers are stable and valid
		if (b5B0>m5M0) m5M0 <= b5B0; 
		if (b5B1>m5M1) m5M1 <= b5B1;
		if (b5B2>m5M2) m5M2 <= b5B2;
		if (b5B3>m5M3) m5M3 <= b5B3;
		
		if (cnt)
			cnt <= cnt -1;
		else begin // outputs holder fall a bit every cnt == 0
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


module dsp_volume_linear(
	/*
	* oOut = iIn *iVolume / (iVolume / 2) = iIn *iVolume >> (volume word size)
	* output = 2x input max
	*/
	oOut,
	iIn,
	iVolume);

	output	`audio	oOut;
	input	`audio	iIn;
	input	[vws: 0]	iVolume;
	
	parameter	vws = 5; // volume word size
	
	wire	`audio32	m32In, m32Out;
	
	assign	m32In = iIn;
	
	assign m32Out = m32In * iVolume;
	
	assign	oOut = m32Out[16 + vws -1:vws];
	
endmodule

module dsp_volume_log2(
	oOut,
	iIn,
	iVolume);

	output	`audio	oOut;
	input	`audio	iIn;
	input	[vws: 0]	iVolume;
	
	parameter	vws = 5; // volume word size
	
	assign	oOut = (iVolume<15)?(iIn >>> (15-iVolume)):
				   (iVolume>15)?(iIn<<<(iVolume - 15)):iIn;
	
endmodule


module dsp_AGC(
	/*
	* oOut = iIn *iVolume
	* max volume = (vMax >> ws)(32x)
	* max output Amp = 8191
	* volume ramp rate = vRamp per cntMax@iCLK
	*/
	oOut,
	iIn,
	iCLK,
	oVol);

	output	`audio	oOut;
	input	`audio	iIn;
	output	[31:0]	oVol;
	input	iCLK;
	
	parameter	cntMax = 1234;
// 	parameter	cntMax = 36;
	parameter	poMax = 16384 * 65536;
// 	parameter	vMax = 32'h400000;
// 	parameter	vRamp = 32'd1, vInc = 32'd260;
	parameter	vRamp = 32'd4095, vInc = 32'd1023, vDP = 10;//vMax = 32'h400000
// 	parameter	vRamp = 32'd2047, vInc = 32'd1023, vDP = 10;//vMax = 32'h200000
	
	wire	`audio32	m32In;
	reg	`audio32	m32Out;
	
	reg	[31:0]	vol;
	reg	[15:0]	mMax;
	reg	[15:0]	cnt;
	wire	[15:0]	mAbs;
	
	assign	m32In = iIn;
	assign	oOut = m32Out[31:16];
	assign	oVol = vol;
	
	int_redAbs	op0(mAbs, iIn);
	
	always @(negedge iCLK) begin
		m32Out <= m32In * vol;
	end
	
	always @(posedge iCLK) begin
		if (mAbs > mMax) begin // a higher peak, lower the volume
			vol <= poMax / mAbs;
			mMax <= mAbs;
			cnt <=cntMax;
		end
		else 
			if (cnt)
				cnt <= cnt - 1;
			else begin // not a higher peak, raise volume by vRamp if less than vMax
				cnt <= cntMax;
				vol <= (vol * vInc >> vDP) + vRamp;
// 				vol <= (vol < vMax)?((vol * vInc >> vDP) + vRamp):vMax;
				mMax <= poMax / vol; // dosen't matter to use last vol
			end
	end
	
endmodule
