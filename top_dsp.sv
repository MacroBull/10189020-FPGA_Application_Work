/*
* Top-level of DE2-70 Audio Effector and Visualization
* This is a project on Altera DE2-70 development and education board
* Providing several audio effects processing including:
*	IIR filter, FIR filter, AGC, linear volume control, undersampling.
* And audio visualzation processing including:
*	wave display, mini spectrum display, fractal visualzation.
*
* This code is successfully tested on Quartus 13.0
* See README.md for more information
* 
* @Author: Macrobull
* @Project: DE2-70 Audio Effector and Visualization
* @Date: July 2014
* @Github: https://github.com/MacroBull/10189020-FPGA_application_work
*/

module top(
	/////////////output////////////////
	oLEDR, oLEDG,
	
	oLCD_RW, oLCD_RS, oLCD_ON ,oLCD_EN ,oLCD_BLON,
	oLCD_D,
	
	oHEXs,
	
	oI2C_SCLK,
	
	oAUD_XCK, oAUD_DACDAT,
	
	oVGA_VS, oVGA_HS, 
	oVGA_CLOCK, oVGA_BLANK_N, oVGA_SYNC_N,
	
	oVGA_R, oVGA_G, oVGA_B,
	
	/////////////input//////////////////////
	
	iSW,
	iKEY,
	
	iAUD_ADCDAT,
	
//	iEXT_CLOCK,
	iCLK_50_2 ,iCLK_50 ,iCLK_28,
	iTD1_CLK27, iTD2_CLK27,
	
	////////////inout//////////////
	
	AUD_BCLK, AUD_DACLRCK, AUD_ADCLRCK,
	
	I2C_SDAT,
	
// 	ioA,
	ioB);
	
	/////////////output//////	//////////
	output	[17:0]	oLEDR;
	output	[8:0]	oLEDG;
	
	output	oLCD_RW, oLCD_RS, oLCD_ON ,oLCD_EN ,oLCD_BLON;
	output	[7:0]	oLCD_D;
	
	output	[63:0]	oHEXs;
	
	output	oAUD_XCK, oAUD_DACDAT;
	
	output	oI2C_SCLK;
	
	output	oVGA_VS, oVGA_HS; 
	output	oVGA_CLOCK, oVGA_BLANK_N, oVGA_SYNC_N;
	
	output	[9:0]	oVGA_R, oVGA_G, oVGA_B; // 10bit mode
// 	output	[7:0]	oVGA_R, oVGA_G, oVGA_B; // 8bit mode
	
//	output	oTD1_RESET_N, oTD2_RESET_N;
	
	/////////////input//////////////////////
	
	input	[17:0]	iSW;
	input	[3:0]	iKEY;
	
	input	iAUD_ADCDAT;
	
//	input	iEXT_CLOCK;
	input	iCLK_50_2, iCLK_50 ,iCLK_28;
	input	iTD1_CLK27, iTD2_CLK27;
	
	////////////inout//////////////
	
	inout	AUD_BCLK, AUD_DACLRCK, AUD_ADCLRCK;
	
	inout	I2C_SDAT;
	
// 	inout	[31:0]	ioA;
	inout	[7:0]	ioB;
	
	//////////////defines////////////////////
	
	// ws means word size
	
	`define	KEY_RESET	(iKEY[3])
	`define	KEY_FIR_PRESET_CHANGE	(iKEY[2])
	`define	KEY_VOL_UP	(iKEY[1])
	`define	KEY_VOL_DOWN	(iKEY[0])
	
	`define	SW_AUDIO_BYPASS	(iSW[0])
 	`define	SW_AUDIO_LED_INDICATOR_CHN	(iSW[1])
 	`define	SW_AUDIO_UNDERSAMPLEING	(iSW[2])
//  	`define	SW_VIS_INTERP	(iSW[14])
//  	`define	SW_VIS_USESRC	(iSW[13])
	`define	SW_DSP_VOL_OR_AGC	(iSW[3])
	`define	SW_DSP_VOL_CLK_DIR	(iSW[4])
// 	`define	SW_DSP_FIR_OR_IIR	iSW[4]
// 	`define	SW_DSP_IIR_SW0	iSW[5]
// 	`define	SW_DSP_IIR_SW1	iSW[6]
// 	//iSW[7] seems to have a pin assignment error
// 	`define	SW_DSP_FIR_DISPLAY	iSW[8]
// 	
// 	`define	SW_VIDEO_FRACTAL_ENABLE	iSW[16]
// 	`define	SW_LCD_LOCK	iSW[17]
	

	`define	LED_RESET oLEDG[8]
	`define	LED_AUDIO_CLK_DAT oLEDG[4:0]
	
	parameter	audio_ws = 16;
	
	`define	audio	signed	[15:0]
	`define	audio32	signed	[31:0]
	`define	peak	[14:0]
	// 15 bit, reduced
	`define	color	[9:0]  
	// 10bit mode better gradient
	// `define	color	[7:0] 
	// 8bit better formance
	`define	coord	[9:0]
	
	/////////////////////////////////
	
	
	///////////System Control/////////////////
	logic mRST_N;
	
	// Global clock divider
	reg	[23:0]	mCLK_50Div;
	always	@(posedge iCLK_50) begin
		mCLK_50Div <= mCLK_50Div +1;
	end
	
	// Global reset manager
	resetManager rstMan(mRST_N, 
		iCLK_50, `KEY_RESET, 0);  
	
	
	assign `LED_RESET = ~mRST_N;
	

	/////////////Audio Driver///////////////////
	assign	oAUD_XCK = mCLK_50Div[1]; // 12.5MHz audio MCLK

	wm8731Config	comp1(iCLK_50, mRST_N, oI2C_SCLK, I2C_SDAT);
	
	wire	`audio	 // input -> DSP -> volume -> output
		oL, oR,	// Output
		vL, vR,	// Volume level
		rL, rR,	// Raw input
		iL, iR;	// Input level
	wire	DACStream; // raw bit stream output, equivalent to oAUD_DACDAT, can be reused
	
	dacWrite	drv1(DACStream, mRST_N, oL, oR, AUD_DACLRCK, AUD_BCLK);//, oLEDG[7]); // debug
	adcRead	drv2(rL, rR, mRST_N,  iAUD_ADCDAT, AUD_ADCLRCK, AUD_BCLK);
	int_ovReduce	op000(iL, rL);
	int_ovReduce	op001(iR, rR);

	
	///////////////Audio Sink/Source Control////////////////////////
	
	assign	oAUD_DACDAT = (`SW_AUDIO_BYPASS)?iAUD_ADCDAT:DACStream; // bit stream bypass, no format convert process
	assign	oLEDG[4:0] = {DACStream, iAUD_ADCDAT, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK}; // Audio interface debugging on LED_GREEN
	assign	ioB[7:0] = {DACStream, 1'b1, AUD_DACLRCK, 1'b1, AUD_BCLK, 1'b1, AUD_ADCLRCK, iAUD_ADCDAT}; // Audio interface debugging on GPIO1
	
	int_redAbs op010(oLEDR[15:0], (`SW_AUDIO_BYPASS)? // Display amplitude on LED_RED, SW_AUDIO_LED_INDICATOR_CHN to select the channel
		((`SW_AUDIO_LED_INDICATOR_CHN)?iL:iR):((`SW_AUDIO_LED_INDICATOR_CHN)?oL:oR));
		
	///////////////////////Volume////////////////////////////
	assign	oLEDR[17] = (rR == 16'd32768); // overflow indicator
	
	wire	`audio	v0, v1, v2, v3;
	wire	[31:0]	vol_AGC;
	reg	[5:0]	volume;

	parameter	MAX_VOL	= 24;
// 	initial	volume = MAX_VOL / 2; 
	initial	volume = 15; 

	
	// Continuous manual volume change
	always @(posedge mCLK_50Div[21]) begin
		if	((!`KEY_VOL_UP) &(volume < MAX_VOL)) 
			volume <= volume + 1;
		else if	((!`KEY_VOL_DOWN) &(volume >0)) 
			volume <= volume - 1;
	end
	
	hex8 test_inst18(oHEXs[63:0], vol_AGC);
	
	dsp_AGC	dsp00(v0, vL, `SW_DSP_VOL_CLK_DIR ^ AUD_DACLRCK);
	dsp_AGC	dsp01(v1, vR, `SW_DSP_VOL_CLK_DIR ^ AUD_DACLRCK, vol_AGC);
	
	dsp_volume_log2	dsp02(v2, vL, volume);
	dsp_volume_log2	dsp03(v3, vR, volume);
	
	
	assign	oL = `SW_DSP_VOL_OR_AGC?v0:v2;
	assign	oR = `SW_DSP_VOL_OR_AGC?v1:v3;
	
	////////////////////?DSP/////////////////////////////////
	
	wire	mDSP_CLK;
	assign	mDSP_CLK = (`SW_AUDIO_UNDERSAMPLEING)?mVGA_HS:(~AUD_DACLRCK);
	
//  	dsp_iir_LS	dsp20(vR, iR, mDSP_CLK);
 	dsp_iir_LP	dsp20(vR, iR, mDSP_CLK);
	dsp_iir_LP	dsp21(vL, iL, mDSP_CLK);
//  	dsp_iir_BS	dsp20(vR, iR, mDSP_CLK);
// 	dsp_iir_BS	dsp21(vL, iL, mDSP_CLK);
// 	dsp_fir_cascade	dsp30(vR, iR, mDSP_CLK);



	//////////////Video/////////////////////
	// Configure VGA output as 640x360@28Hz (on my Philips is 640x350@26Hz)
	// Alternative VGA profile is 1280x720, 640x480, 720x400
	// Choose for the demand of your monitor
	
	reg	[1:0] VGAClkDiv;
	reg	mVGA_CLK;
	wire	mVGA_VS, mVGA_HS; // Vsync wire
	wire	`coord	mVGA_X, mVGA_Y;
	
	/// 640x360 @8.33MHz = 50 /6
	always @(posedge iCLK_50) begin
		if (VGAClkDiv == 2) begin
			mVGA_CLK <= ~mVGA_CLK;
			VGAClkDiv <= 0;
		end
		else
			VGAClkDiv <= VGAClkDiv +1;
	end
	
	assign	oVGA_CLOCK = mVGA_CLK;
	assign	oVGA_VS = mVGA_VS;
	assign	oVGA_HS = mVGA_HS;
	assign	oVGA_SYNC_N=1;
	
	vga_time_generator drv3(
		.hp(1'b0), .vp(1'b1),
	
// 		.h_disp   (1280),
// 		.h_fporch (40),
// 		.h_sync   (120), 
// 		.h_bporch (160),
// 		
// 		.v_disp   (720),
// 		.v_fporch (3),
// 		.v_sync   (5),
// 		.v_bporch (13),

// 		.v_disp   (480),
// 		.v_fporch (10),
// 		.v_sync   (2),
// 		.v_bporch (33),

// 		.v_disp   (400),
// 		.v_fporch (10),
// 		.v_sync   (4),
// 		.v_bporch (33),
// 		
// 		.h_disp   (720),
// 		.h_fporch (16),
// 		.h_sync   (96), 
// 		.h_bporch (48),

		.v_disp   (350),
		.v_fporch (16),
		.v_sync   (4),
		.v_bporch (32),
		
		.h_disp   (640),
		.h_fporch (16),
		.h_sync   (96), 
		.h_bporch (48),
		
		.vga_hs   (mVGA_HS), .vga_vs   (mVGA_VS), .vga_blank(oVGA_BLANK_N),
		.CounterY(mVGA_Y), .CounterX(mVGA_X), .pixel_clk(mVGA_CLK));
		
	/////////////Video Effects////////////////
	
// 	wire	`peak	aL, aR, pvL, pvR;
	wire	`audio	 phL, phR;
// 	wire	[3:0]	lL, lR;
	
// 	// Amplitude(reduced)
// 	int_redAbs	op10(aL, rL); 
// 	int_redAbs	op11(aR, rR);
// 	
// 	// Log2(Amp)
// 	uint15_log2	op12(lL, aL);
// 	uint15_log2	op13(lR, aR);
	 
	// Hold by HSync (per line)
// 	dsp_waveHolder_max	op16(r4, rL, AUD_ADCLRCK, mVGA_HS);
// 	dsp_waveHolder_max	op17(r6, rR, AUD_ADCLRCK, mVGA_HS);

// 	dsp_SRC_avg	op1c(phL, rL, AUD_ADCLRCK, mVGA_HS);
	dsp_SRC_avg	op1c(phL, oR, AUD_ADCLRCK, mVGA_HS);
	dsp_SRC_avg	op1d(phR, iR, AUD_ADCLRCK, mVGA_HS);
	
// 	dsp_SRC_power	#(12)	op1a(r5, rL, AUD_ADCLRCK, iCLK_50, mVGA_HS);
// 	dsp_SRC_power	#(12)	op1b(r7, rR, AUD_ADCLRCK, iCLK_50, mVGA_HS);
	

	visual_wave_vertical vsp10(oVGA_R, oVGA_G, oVGA_B, mVGA_X, mVGA_Y, 
		phL, phR, mVGA_HS);


endmodule


