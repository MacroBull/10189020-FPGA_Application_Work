/*
* Top-level of DE2-70 Audio Effector and Visualization
* This is a project on Altera DE2-70 development and education board
* Providing several audio effects processing including:
* 	IIR filter, FIR filter, AGC, linear volume control, undersampling.
* And audio visualzation processing including:
* 	wave display, mini spectrum display, fractal visualzation.
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
	
// 	iEXT_CLOCK,
	iCLK_50_2 ,iCLK_50 ,iCLK_28,
	iTD1_CLK27, iTD2_CLK27,
	
	////////////inout//////////////
	
	AUD_BCLK, AUD_DACLRCK, AUD_ADCLRCK,
	
	I2C_SDAT);
	
	/////////////output////////////////
	output	[17:0]	oLEDR;
	output	[8:0]	oLEDG;
	
	output	oLCD_RW, oLCD_RS, oLCD_ON ,oLCD_EN ,oLCD_BLON;
	output	[7:0]	oLCD_D;
	
	output	[63:0]	oHEXs;
	
	output	oAUD_XCK, oAUD_DACDAT;
	
	output	oI2C_SCLK;
	
	output	oVGA_VS, oVGA_HS; 
	output	oVGA_CLOCK, oVGA_BLANK_N, oVGA_SYNC_N;
	
	output	[9:0]	oVGA_R, oVGA_G, oVGA_B;
	
// 	output	oTD1_RESET_N, oTD2_RESET_N;
	
	/////////////input//////////////////////
	
	input	[17:0]	iSW;
	input	[3:0]	iKEY;
	
	input	iAUD_ADCDAT;
	
// 	input	iEXT_CLOCK;
	input	iCLK_50_2, iCLK_50 ,iCLK_28;
	input	iTD1_CLK27, iTD2_CLK27;
	
	////////////inout//////////////
	
	inout	AUD_BCLK, AUD_DACLRCK, AUD_ADCLRCK;
	
	inout	I2C_SDAT;
	
// 	inout	[3:0]	ioGPIOs;
	
	//////////////defines////////////////////
	
	// ws means word size
	// 3-channel 10-bit VGA color output
	`define	VGA_COLOR_WS	30
	
	`define	KEY_RESET	iKEY[3]
	`define	KEY_VOL_UP	iKEY[1]
	`define	KEY_VOL_DOWN	iKEY[0]
	`define	KEY_FIR_PRESET_CHANGE	iKEY[2]
	
	`define	SW_AUDIO_BYPASS	iSW[0]
	`define	SW_AUDIO_LED_INDICATOR_CHN	iSW[1]
	`define	SW_DSP_FILTER_CLK	iSW[2]
	`define	SW_DSP_VOL_OR_AGC	iSW[3]
	`define	SW_DSP_FIR_OR_IIR	iSW[4]
	`define	SW_DSP_IIR_SW0	iSW[5]
	`define	SW_DSP_IIR_SW1	iSW[6]
	//iSW[7] seems to have a pin assignment error
	`define	SW_DSP_FIR_DISPLAY	iSW[8]
	
	`define	SW_VIDEO_FRACTAL_ENABLE	iSW[16]
	`define	SW_LCD_LOCK	iSW[17]
	

	`define	LED_RESET oLEDG[8]
	`define	LED_AUDIO_CLK_DAT oLEDG[4:0]
	
	parameter	audio_ws = 16;
	
	/////////////////////////////////
	
	
	///////////System Control/////////////////
	logic mRST_N;
	
	// Global clock divider
	reg	[31:0]	mCLK_50Div;
	always	@(posedge iCLK_50) begin
		mCLK_50Div <= mCLK_50Div +1;
	end
	
	// Global reset manager
	resetManager rstMan(mRST_N, 
		iCLK_50, `KEY_RESET, );  
	
	
	assign `LED_RESET = ~mRST_N;
	
	/////////////////LCD ///////////////////////
	
	lcdEnable comp0(
		oLCD_ON, oLCD_BLON,
		oLCD_RW);
		
	// Strings to display on LCD
	logic	[6 * 8-1:0]	s0,s1,s2,s3;
	logic	[5 * 8-1:0]	svol;
	wire	[6*8 - 1: 0]	firPresetName;
	logic	[16*8-1:0]	LCD_line1, LCD_line2;
	
	// SW_DSP_FIR_DISPLAY is line1 content selector
	assign	 LCD_line1 = `SW_DSP_FIR_DISPLAY?{" ", firPresetName, " : ", svol, " "}:{"iL", s0,"iR", s1};
	assign	 LCD_line2 = {"oL", s2, "oR", s3};
	
	itoa16	test_inst10(s0,	iL);
	itoa16	test_inst11(s1,	iR);
	itoa16	test_inst12(s2,	oL);
	itoa16	test_inst13(s3,	oR);
	utoa16	test_inst14(svol,	volume);
	
	lcdWrite drv0(
		oLCD_EN, oLCD_RS,
		oLCD_D,
		`SW_LCD_LOCK | iCLK_50, mRST_N,
		LCD_line1, LCD_line2);
		
	
	/////////////Audio Driver///////////////////
	assign	oAUD_XCK = mCLK_50Div[1]; // 12.5MHz audio MCLK

	wm8731Config	comp1(iCLK_50, mRST_N, oI2C_SCLK, I2C_SDAT);
	
	wire	[audio_ws - 1:0]	oL, oR, vL, vR, iL, iR; // input -> DSP -> volume -> output
	wire	DACStream; // raw bit stream output, equivalent to oAUD_DACDAT, can be reused
	
	dacWrite	drv1(DACStream, mRST_N, oL, oR, AUD_DACLRCK, AUD_BCLK);//, oLEDG[7]); // debug
 	adcRead	drv2(iL, iR, mRST_N,  iAUD_ADCDAT, AUD_ADCLRCK, AUD_BCLK);

	///////////////Audio Sink/Source Control////////////////////////
 	
	assign	oAUD_DACDAT = (`SW_AUDIO_BYPASS)?iAUD_ADCDAT:DACStream; // bit stream bypass, no format convert process
 	assign	oLEDG[4:0] = {DACStream, iAUD_ADCDAT, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK}; // Audio interface debugging on LED_GREEN
	
	assign oLEDR[15:0] = (`SW_AUDIO_BYPASS)? // Display amplitude on LED_RED, SW_AUDIO_LED_INDICATOR_CHN to select the channel
		((`SW_AUDIO_LED_INDICATOR_CHN)?(iL[15]?~iL:iL):(iR[15]?~iR:iR)):
		((`SW_AUDIO_LED_INDICATOR_CHN)?(oL[15]?~oL:oL):(oR[15]?~oR:oR));
	
	logic	[5:0]	volume;
	
	initial	volume = 16; 
	
	// Continuous manual volume change
	always @(posedge mCLK_50Div[21]) begin
		if	((!`KEY_VOL_UP) &(volume < 63)) 
			volume <= volume + 1;
		else if	((!`KEY_VOL_DOWN) &(volume >0)) 
			volume <= volume - 1;
	end
	
	assign	oLEDG[7] = (iR == 16'd32768); // overflow indicator
	/////////////////////Audio DSP////////////////////////////////
	
	//Clock divider for undersampling effects, SW_DSP_FILTER_CLK to select
	reg	[15:0]	mAUDCLKDiv;
	always	@(posedge AUD_ADCLRCK) begin
		mAUDCLKDiv <= mAUDCLKDiv +1;
	end
	wire	DSP_FILTER_CLK;
	
	assign	DSP_FILTER_CLK = (`SW_DSP_FILTER_CLK)?mAUDCLKDiv[3]:AUD_DACLRCK;
	/////////////////DSP-Final Volume Control///////////////////////
	wire	[audio_ws - 1:0]	VOL_L, VOL_R, AGC_L, AGC_R;
	
	dsp_volume	dsp0(VOL_L, vL, volume);
	dsp_volume	dsp2(VOL_R, vR, volume);
	dsp_AGC		dsp3(AGC_L, vL, AUD_ADCLRCK);
	dsp_AGC		dsp4(AGC_R, vR, AUD_ADCLRCK, AGC_VOL);
	
	assign	oL = `SW_DSP_VOL_OR_AGC?AGC_L:VOL_L;
	assign	oR = `SW_DSP_VOL_OR_AGC?AGC_R:VOL_R;
	
	wire	[31:0]	AGC_VOL;
	hex8 test_inst18(oHEXs[63:0], AGC_VOL);
	
	assign vL = `SW_DSP_FIR_OR_IIR? vIIR:vFIRL;
	assign vR = `SW_DSP_FIR_OR_IIR? vIIR:vFIRR;
		
	
	///////////////////////DSP - IIR////////////////////////////////
	//To simply make a demo, IIR has only effect on one channel 
	//filters can be connected stage by stage, temporary results store in mTubes
	wire	[15:0]	mTube0, mTube1, mTube2, mTube3, mTube4, mTube5, mTube6, mTube7, vIIR;
	parameter iirGain0 = 17;
	parameter iirGain1 = 6;
	
	assign	vIIR = `SW_DSP_IIR_SW1? mTube7 * iirGain1: mTube6 * iirGain0;
	
	dsp_iir_lowpass		dsp5(mTube1, iR, DSP_FILTER_CLK,);
	dsp_iir_lowpass		dsp6(mTube2, mTube1 * iirGain0, DSP_FILTER_CLK,);
	dsp_iir_bandpass	dsp7(mTube3, iR, DSP_FILTER_CLK,);
	assign	mTube4 = `SW_DSP_IIR_SW0? mTube3 * iirGain1: mTube2 * iirGain0;
	dsp_iir_lowpass		dsp8(mTube5, mTube4, DSP_FILTER_CLK,);
	dsp_iir_lowpass		dsp9(mTube6, mTube5 * iirGain0, DSP_FILTER_CLK,);
	dsp_iir_bandpass	dsp10(mTube7, mTube4, DSP_FILTER_CLK,);

	///////////////////////DSP - FIR////////////////////////////////
	// FIR filters use presets generated on computer, which can be switched by push KEY_FIR_PRESET_CHANGE
	logic	[2:0]	firPresetIndex;
	always @(posedge `KEY_FIR_PRESET_CHANGE) begin
		firPresetIndex <= firPresetIndex +1;
	end
	
	assign	firPresetName = (firPresetIndex == 0)?"Dance ":
		(firPresetIndex == 1)?" Bass ":
		(firPresetIndex == 2)?"V Like":
		(firPresetIndex == 3)?"Treble":
		(firPresetIndex == 4)?" Rock ":
		(firPresetIndex == 5)?" Soft ":
		(firPresetIndex == 6)?"  T3  ":
		"Techno";
	
	wire	[15:0]	vFIRL, vFIRR;

	dsp_fir	dsp11(vFIRL, iL, DSP_FILTER_CLK, firPresetIndex);
	dsp_fir	dsp12(vFIRR, iR, DSP_FILTER_CLK, firPresetIndex);
	
	/////////////////////DSP - Spectrum/////////////////////////////
	//Mini spectrum display a 4 band spectrum on screen, using different FIR filter gains on different frequencies
	//painting parameter xSpecx, yScale, ySpecx configure the width, height, and position of each graph
	
	wire	onSpecL, onSpecR;
	wire	[19:0]	mSpecL, mSpecR;
	wire	[`VGA_COLOR_WS - 1: 0]	cSpec;
	
	dsp_fir_spectrum	dsp13(mSpecL, iL, DSP_FILTER_CLK);
	dsp_fir_spectrum	dsp14(mSpecR, iR, DSP_FILTER_CLK);
// 	hex8 test_inst17(oHEXs[63:0], mSpec);
// 	itoa16	test_inst12(s0,	mSpec[4:0]);
// 	itoa16	test_inst13(s1,	mSpec[9:5]);
// 	itoa16	test_inst14(s2,	mSpec[14:10]);
// 	itoa16	test_inst15(s3,	mSpec[19:15]);
	
	parameter	xSpec0 = 10'd500, xSpec1 = 10'd506, xSpec2 = 10'd512, xSpec3 = 10'd518, xSpec4 = 10'd524;
	parameter	yScale = 10'd5;
	parameter	ySpecL0 = 10'd120, ySpecR0 = 10'd300;
	
	// convert bit predicates to VGA color
	assign	cSpec = (onSpecL|onSpecR)?{10'd500-vga_y, 10'd300, vga_y << 10'd1}:30'd0;
	
	assign	onSpecL = ((vga_x>xSpec0) & (vga_x<xSpec1))?((vga_y<=ySpecL0) & (vga_y > ySpecL0 - yScale*(mSpecL[4:0]-16))):
		((vga_x>xSpec1) & (vga_x<xSpec2))? ((vga_y<=ySpecL0) & (vga_y > ySpecL0 - yScale*(mSpecL[9:5]-16))):
		((vga_x>xSpec2) & (vga_x<xSpec3))? ((vga_y<=ySpecL0) & (vga_y > ySpecL0 - yScale*(mSpecL[14:10]-16))):
		((vga_x>xSpec3) & (vga_x<xSpec4))? ((vga_y<=ySpecL0) & (vga_y > ySpecL0 - yScale*(mSpecL[19:15]-16))):
		1'b0;
		
	assign	onSpecR = ((vga_x>xSpec0) & (vga_x<xSpec1))?((vga_y<=ySpecR0) & (vga_y > ySpecR0 - yScale*(mSpecR[4:0]-16))):
		((vga_x>xSpec1) & (vga_x<xSpec2))? ((vga_y<=ySpecR0) & (vga_y > ySpecR0 - yScale*(mSpecR[9:5]-16))):
		((vga_x>xSpec2) & (vga_x<xSpec3))? ((vga_y<=ySpecR0) & (vga_y > ySpecR0 - yScale*(mSpecR[14:10]-16))):
		((vga_x>xSpec3) & (vga_x<xSpec4))? ((vga_y<=ySpecR0) & (vga_y > ySpecR0 - yScale*(mSpecR[19:15]-16))):
		1'b0;
	
	////////////////////DSP - Wave Display//////////////////////////////////
	//Wave display show waves on screen
	//Each wave is a data sequence of audio source
	//The content to display is synced with VGA vSync signal mVGA_VS
	//Graph parameters is assigned to module parameters
	
	wire	[`VGA_COLOR_WS - 1: 0]	cWave, cWave0, cWave1;
	
	dsp_peak	#(16, 64, 10'd120)	dsp15(cWave0, vga_x, vga_y, mVGA_VS, iL);
	dsp_peak	#(16, 64, 10'd300)	dsp16(cWave1, vga_x, vga_y, mVGA_VS, iR);
	
	// overlay two channels
	assign cWave = cWave0?cWave0:cWave1?cWave1:0;
	
	//////////////////////End of DSPs//////////////////////////
	
	//////////////Video/////////////////////
	// Configure VGA output as 640x360(350)@25(26)Hz
	// See video.v for parameter details
  	
  	reg [3:0] VGAClkDiv;
  	reg VGA_CLK;
  	/// 640x360 @8.75MHz = 50 /6
  	always @(posedge iCLK_50) begin
		if (VGAClkDiv == 2) begin
			VGA_CLK <= ~VGA_CLK;
			VGAClkDiv <= 0;
		end
		else
			VGAClkDiv <= VGAClkDiv +1;
	end
  	
  	wire	[9:0]	vga_x, vga_y;
  	wire	mVGA_VS; // Vsync wire
  	
  	assign	oVGA_VS = mVGA_VS;
  	
	video drv3(
		oVGA_CLOCK, 
		oVGA_HS, mVGA_VS,
		oVGA_SYNC_N, oVGA_BLANK_N,
		vga_x, vga_y, 
		VGA_CLK);
	///////////////Video Overlays./////////////////
	// Manipulate different graph sources to final screen content
	
	wire	[`VGA_COLOR_WS - 1:0]	cPixel;
	
	assign	{oVGA_R, oVGA_G, oVGA_B} = cPixel;
// 	assign	cPixel = cFractal;
	assign	cPixel = `SW_VIDEO_FRACTAL_ENABLE?cFractal ^ (cSpec | cWave):(cSpec | cWave);
// 	assign	cPixel =  (cSpec | cWave);
	
	///////////////Video - Fractal ////////////////
	// Generate fractal graphics on screen in real time
	// Some of the parameter is configure to vary with audio data to make cool effects
	// See http://en.wikipedia.org/wiki/Julia_set for the algorithm and fractal_i.v for details
	
// 	logic	[31:0]	fractal_c;
	logic	[31:0]	fractal_thres;
	logic	[15:0]	fThc0, fThc1;
	
	// use vSync to avoid tearing
// 	always @(posedge mCLK_50Div[23]) begin
	always @(posedge mVGA_VS) begin
		fThc0 <= (iR[15]?~iR:iR) >> 16'd3;
		fThc1 <= (fThc1 + fThc0) >> 16'd1;
		fractal_thres <= {16'd0, fThc1}; // use threshold as variable
// 		fractal_c <= {16'd40  + ( ((oL[15])?-oL:oL) >> 13), 16'd115};   // use c as variable
// 		fractal_c <= {16'd37, 16'd104 + (oL + 16'd32768) / 16'd2730}; 
	end
		
	parameter fractal_c = {16'd37, 16'd115}; // c = 0.45 -0.142857j;   // use threshold as variable
// 	parameter fractal_thres 100= 16'd16 << 8; // use c as variable
	
	wire	[`VGA_COLOR_WS - 1:0]	cFractal;
	wire	[22:0]	fractal_z;
	
	assign {cFractal[29:25], cFractal[19:12], cFractal[9:1]} = fractal_z + 1; // map the result to a color shceme

	// Origin location, fix point word size and dp
	fractal #(175, 320, 16, 8) op0(fractal_z, vga_y, vga_x, fractal_c, fractal_thres);
// 	fractal #(320, 240, 16, 8) fracInst0(z, x, y, c, thres);
// 	fractal #(640, 360, 16, 8) fracInst0(z, x, y, c, thres);
	
	
	//////////////////////////////////////////////////////////////
	
// 	///////////playground///////////
		
	
// 	wire	[31:0]	hexDisp;
// 	
// 	shortint intx = -1;
// 	
// 	assign	hexDisp = (~iSW[9])?intx:
// 		(iSW[8])?(iSW[7])?oL:oR:
// 		(iSW[7])?iL:iR
// 		;
// 	
// 	
// 	
endmodule
