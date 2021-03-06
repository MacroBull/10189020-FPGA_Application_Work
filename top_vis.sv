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
	
	`define	SW_VIS_LOCK	(iSW[17])
 	`define	SW_AUDIO_LED_INDICATOR_CHN	(iSW[16])
 	`define	SW_AUDIO_UNDERSAMPLEING	(iSW[15])
 	`define	SW_VIS_INTERP	(iSW[14])
 	`define	SW_VIS_USESRC	(iSW[13])
// 	`define	SW_AUDIO_BYPASS	iSW[0]
// 	`define	SW_DSP_FILTER_CLK	iSW[2]
// 	`define	SW_DSP_VOL_OR_AGC	iSW[3]
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
//		vL, vR,	// Volume level
		rL, rR,	// Raw input
		iL, iR;	// Input level
	wire	DACStream; // raw bit stream output, equivalent to oAUD_DACDAT, can be reused
	
	dacWrite	drv1(DACStream, mRST_N, oL, oR, AUD_DACLRCK, AUD_BCLK);//, oLEDG[7]); // debug
	adcRead	drv2(rL, rR, mRST_N,  iAUD_ADCDAT, AUD_ADCLRCK, AUD_BCLK);
	int_ovReduce	op000(iL, rL);
	int_ovReduce	op001(iR, rR);

	
	///////////////Audio Sink/Source Control////////////////////////
	
	assign	oLEDR[17] = (rR == 16'd32768); // overflow indicator
	
// 	assign	oAUD_DACDAT = (`SW_AUDIO_BYPASS)?iAUD_ADCDAT:DACStream; // bit stream bypass, no format convert process
	assign	oAUD_DACDAT = DACStream; // bit stream bypass, no format convert process
	assign	oLEDG[4:0] = {DACStream, iAUD_ADCDAT, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK}; // Audio interface debugging on LED_GREEN
	assign	ioB[7:0] = {DACStream, 1'b1, AUD_DACLRCK, 1'b1, AUD_BCLK, 1'b1, AUD_ADCLRCK, iAUD_ADCDAT}; // Audio interface debugging on GPIO1
	
// 	int_redAbs op010(oLEDR[15:0], (`SW_AUDIO_BYPASS)? // Display amplitude on LED_RED, SW_AUDIO_LED_INDICATOR_CHN to select the channel
// 		((`SW_AUDIO_LED_INDICATOR_CHN)?iL:iR):((`SW_AUDIO_LED_INDICATOR_CHN)?oL:oR));
	int_redAbs op010(oLEDR[15:0], ((`SW_AUDIO_LED_INDICATOR_CHN)?oL:oR));
	
// 	assign	oL = -iL;
// 	assign	oR = -iR;u

// 	assign	oR = y0;
// 
// 	reg	`audio	y0, y1, x0;
// 	
// 	always	@(negedge iAUD_ADCDAT) begin
// 		y1 <= y0;
// // 		y0 <= (y1 >>> 4) * 15 + (x0 >>> 4);
//  		y0 <= (y0 + x0) >>> 1;
// 		x0 <= iL;
// 	end

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
	
	wire	`peak	aL, aR, pvL, pvR;
	wire	`audio	 phL, phR;
	wire	`audio	 r0, r1, r2, r3, r4, r5, r6, r7;
	wire	[3:0]	lL, lR;
	
	// Amplitude(reduced)
	int_redAbs	op10(aL, rL); 
	int_redAbs	op11(aR, rR);
	
	// Log2(Amp)
	uint15_log2	op12(lL, aL);
	uint15_log2	op13(lR, aR);
	
	// Hold by VSync (per frame)
	dsp_peakHolder_max	op14(r0, aL, AUD_ADCLRCK, mVGA_VS);
	dsp_peakHolder_max	op15(r2, aR, AUD_ADCLRCK, mVGA_VS);
	 
	// Hold by HSync (per line)
// 	dsp_waveHolder_max	op16(r4, rL, AUD_ADCLRCK, mVGA_HS);
// 	dsp_waveHolder_max	op17(r6, rR, AUD_ADCLRCK, mVGA_HS);

	dsp_SRC_avg	op1c(r4, rL, AUD_ADCLRCK, mVGA_HS);
	dsp_SRC_avg	op1d(r6, rR, AUD_ADCLRCK, mVGA_HS);
	
	dsp_SRC_power	#(12)	op18(r1, aL, AUD_ADCLRCK, iCLK_50, mVGA_VS);
	dsp_SRC_power	#(12)	op19(r3, aR, AUD_ADCLRCK, iCLK_50, mVGA_VS);
	
	dsp_SRC_power	#(12)	op1a(r5, rL, AUD_ADCLRCK, iCLK_50, mVGA_HS);
	dsp_SRC_power	#(12)	op1b(r7, rR, AUD_ADCLRCK, iCLK_50, mVGA_HS);
	
	assign	pvL = `SW_VIS_USESRC?r1:r0;
	assign	pvR = `SW_VIS_USESRC?r3:r2;
	assign	phL = `SW_VIS_USESRC?r5:r4;
	assign	phR = `SW_VIS_USESRC?r7:r6;

// 	visual_shadingLevelWaves	vsp0(oVGA_R, oVGA_G, oVGA_B, mVGA_X, mVGA_Y, 
// 		(lL - 10) << 2, (lR - 10)<< 2);
	
// 	visual_peak_log vsp24(oVGA_R, oVGA_G, oVGA_B, mVGA_X, mVGA_Y, 
// 		pvL, pvR, mVGA_VS, `SW_VIS_INTERP);
		
// 	visual_tablecloth_color vsp51(oVGA_R, oVGA_G, oVGA_B, mVGA_X, mVGA_Y, 
// 		pvL, pvR, mVGA_VS);

// 	visual_peak_progression vsp24(oVGA_R, oVGA_G, oVGA_B, mVGA_X, mVGA_Y, 
// 		pvL, pvR, mVGA_VS, `SW_VIS_INTERP);

// 	visual_wave_vertical vsp10(oVGA_R, oVGA_G, oVGA_B, mVGA_X, mVGA_Y, 
// 		phL, phR, mVGA_HS);



	visual_shadingLevelWaves	vsp00(v0R, v0G, v0B, mVGA_X, mVGA_Y, 
		phL >>> 11, phR >>> 11);

	visual_wave_vertical vsp10(v1R, v1G, v1B, mVGA_X, mVGA_Y, 
		phL, phR, mVGA_HS | `SW_VIS_LOCK);

	visual_peak_progression vsp24(v2R, v2G, v2B, mVGA_X, mVGA_Y, 
		pvL, pvR, mVGA_VS | `SW_VIS_LOCK, `SW_VIS_INTERP);
		
	visual_peak_log vsp28(v3R, v3G, v3B, mVGA_X, mVGA_Y, 
		pvL, pvR, mVGA_VS | `SW_VIS_LOCK, `SW_VIS_INTERP);

	visual_freePainting	vsp30(v4R, v4G, v4B, mVGA_X, mVGA_Y, 
		mCLK_50Div[3], mVGA_VS | `SW_VIS_LOCK);
		
	visual_blocks	vsp40(v5R, v5G, v5B, mVGA_X, mVGA_Y, 
		pvL, pvR, mVGA_CLK, mVGA_VS | `SW_VIS_LOCK);

	visual_franticStripes	vsp41(v6R, v6G, v6B, mVGA_X, mVGA_Y, 
		pvL, pvR, mCLK_50Div[9], mVGA_VS | `SW_VIS_LOCK);

	visual_tablecloth vsp50(v7R, v7G, v7B, mVGA_X, mVGA_Y, 
		pvL, pvR, mVGA_VS | `SW_VIS_LOCK);

	visual_tablecloth_color vsp51(v8R, v8G, v8B, mVGA_X, mVGA_Y, 
		pvL, pvR, mVGA_VS | `SW_VIS_LOCK);
		
	wire	`color	
		v0R, v1R, v2R, v3R, v4R, v5R, v6R, v7R, v8R,
		v0G, v1G, v2G, v3G, v4G, v5G, v6G, v7G, v8G,
		v0B, v1B, v2B, v3B, v4B, v5B, v6B, v7B, v8B;
	
	assign	oVGA_R = 
		(iSW[3:1] == 0)?v0R:
		(iSW[3:1] == 1)?v1R:
		(iSW[3:1] == 2)?(iSW[0])?v3R:v2R:
		(iSW[3:1] == 3)?v4R:
		(iSW[3:1] == 4)?(iSW[0])?v5R:v6R:
		(iSW[0])?v7R:v8R;
	assign	oVGA_G = 
		(iSW[3:1] == 0)?v0G:
		(iSW[3:1] == 1)?v1G:
		(iSW[3:1] == 2)?(iSW[0])?v3G:v2G:
		(iSW[3:1] == 3)?v4G:
		(iSW[3:1] == 4)?(iSW[0])?v5G:v6G:
		(iSW[0])?v7G:v8G;
	assign	oVGA_B = 
		(iSW[3:1] == 0)?v0B:
		(iSW[3:1] == 1)?v1B:
		(iSW[3:1] == 2)?(iSW[0])?v3B:v2B:
		(iSW[3:1] == 3)?v4B:
		(iSW[3:1] == 4)?(iSW[0])?v5B:v6B:
		(iSW[0])?v7B:v8B;
		
	
	// Try undersampling? XD
	assign	oL = `SW_AUDIO_UNDERSAMPLEING?phL:rL;
	assign	oR = `SW_AUDIO_UNDERSAMPLEING?phR:rR;
	
endmodule


