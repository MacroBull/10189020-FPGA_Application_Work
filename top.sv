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
	
	oTD1_RESET_N, oTD2_RESET_N,
	
	/////////////input//////////////////////
	
	iSW,
	iKEY,
	
	iAUD_ADCDAT,
	
	iEXT_CLOCK,
	iCLK_50_4, iCLK_50_3 ,iCLK_50_2 ,iCLK_50 ,iCLK_28,
	iTD1_CLK27, iTD2_CLK27,
	
	////////////inout//////////////
	
	AUD_BCLK, AUD_DACLRCK, AUD_ADCLRCK,
	
	I2C_SDAT,
	
	ioGPIOs);
	
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
	
	output	oTD1_RESET_N, oTD2_RESET_N;
	
	/////////////input//////////////////////
	
	input	[17:0]	iSW;
	input	[3:0]	iKEY;
	
	input	iAUD_ADCDAT;
	
	input	iEXT_CLOCK;
	input	iCLK_50_4, iCLK_50_3 ,iCLK_50_2 ,iCLK_50 ,iCLK_28;
	input	iTD1_CLK27, iTD2_CLK27;
	
	////////////inout//////////////
	
	inout	AUD_BCLK, AUD_DACLRCK, AUD_ADCLRCK;
	
	inout	I2C_SDAT;
	
	inout	[3:0]	ioGPIOs;
	
	/////////////memory////////////////////
	
// 	reg	[7:0]	RAM	[31:0];
	
	//////////////defines////////////////////
	`define	VGA_COLOR_WS	30
	
	`define	KEY_RESET	iKEY[3]
	`define	KEY_VOL_UP	iKEY[1]
	`define	KEY_VOL_DOWN	iKEY[0]
	
	`define	SW_AUDIO_BYPASS	iSW[0]
	`define	SW_AUDIO_LED_INDICATOR_CHN	iSW[1]
	`define	SW_AUDIO_VOL_CTL_ENABLE	iSW[2]
	
	
	`define	LED_RESET oLEDG[8]
	`define	LED_AUDIO_CLK_DAT oLEDG[4:0]
	
	/////////////////////////////////
	
	
	///////////System Control/////////////////
	logic mRST_N;
	
	
	reg	[31:0]	mCLK_50Div;
	always	@(posedge iCLK_50) begin
		mCLK_50Div <= mCLK_50Div +1;
	end
	
	resetManager rstMan(mRST_N, 
		iCLK_50, `KEY_RESET, );  
	
	
	assign `LED_RESET = ~mRST_N;
	
	/////////////Audio Driver///////////////////
	assign	oAUD_XCK = mCLK_50Div[1];

	wm8731Config	comp0(iCLK_50, mRST_N, oI2C_SCLK, I2C_SDAT);
	
	wire	[31:0]	oL, oR, iL, iR;
	wire	DACStream;
	
	dacWrite	drv0(DACStream, mRST_N, oL, oR, AUD_DACLRCK, AUD_BCLK);//, oLEDG[7]); // debug
 	adcRead	drv1(iL, iR, mRST_N,  iAUD_ADCDAT, AUD_ADCLRCK, AUD_BCLK);

	///////////////Audio Sink/Source Control////////////////////////
 	
	assign	oAUD_DACDAT = (`SW_AUDIO_BYPASS)?iAUD_ADCDAT:DACStream;
 	assign	oLEDG[4:0] = {DACStream, iAUD_ADCDAT, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK};
	
	assign oLEDR[15:0] = (iSW[0])?((iSW[1])?(oL[15]?-oL:oL):(oR[15]?-oR:oR)):((iSW[1])?(iL[15]?-iL:iL):(iR[15]?-iR:iR));
	
	wire	[`VGA_COLOR_WS - 1: 0]	cWave, mWave0, mWave1;
	logic	[3:0]	volume;
	
	initial	volume = 8;
	
	always @(posedge mCLK_50Div[22]) begin
		if (`SW_AUDIO_VOL_CTL_ENABLE)
			if	((!`KEY_VOL_UP) &(volume < 15)) 
				volume <= volume + 1;
			else if	((!`KEY_VOL_DOWN) &(volume >0)) 
				volume <= volume - 1;
	end
	
	dsp_volume	dsp0(oL, iR, volume);
	dsp_volume	dsp3(oR, iR, volume);
	
	dsp_peak	#(16, 64, 10'd120)	dsp1(mWave0, vga_x, vga_y, mVGA_VS, iL);
	dsp_peak	#(16, 64, 10'd300)	dsp2(mWave1, vga_x, vga_y, mVGA_VS, iR);
	
 	assign cWave = mWave0?mWave0:mWave1?mWave1:0;
	
	//////////////Video/////////////////////
  	
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
  	wire	mVGA_VS; // Vsync!
  	
  	assign	oVGA_VS = mVGA_VS;
  	
	video video_inst0(
		oVGA_CLOCK, 
		oVGA_HS, mVGA_VS,
		oVGA_SYNC_N, oVGA_BLANK_N,
		vga_x, vga_y, 
		VGA_CLK);
	///////////////Video Overlays./////////////////
	
	wire	[`VGA_COLOR_WS - 1:0]	mPixel;
	
	assign	{oVGA_R, oVGA_G, oVGA_B} = mPixel;
	assign	mPixel = cWave ^ cFractal;
	
	///////////////Video - Fractal ////////////////
// 	logic	[31:0]	fractal_c;
	logic	[31:0]	fractal_thres;
	
// 	always @(posedge mCLK_50Div[23]) begin
	always @(posedge mVGA_VS) begin
		fractal_thres <= (oL[15]?-oL:oL) >> 3;
// 		fractal_c <= {16'd40  + ( ((oL[15])?-oL:oL) >> 13), 16'd115}; 
// 		fractal_c <= {16'd37, 16'd104 + (oL + 16'd32768) / 16'd2730}; 
	end
		
	parameter fractal_c = {16'd37, 16'd115}; // c = 0.45 -0.142857j;
// 	parameter c = {16'd1 << 8, 16'd0};
// 	parameter c = {16'd40, -16'd205};
// 	parameter fractal_thres = 16'd16 << 8;
	
	wire	[`VGA_COLOR_WS - 1:0]	cFractal;
	wire	[22:0]	fractal_z;
	
	assign {cFractal[29:23], cFractal[19:12], cFractal[9:1]} = fractal_z + 1;
// // 	
	fractal #(175, 320, 16, 8) fracInst0(fractal_z, vga_y, vga_x, fractal_c, fractal_thres);
// 	fractal #(320, 240, 16, 8) fracInst0(z, x, y, c, thres);
// 	fractal #(640, 360, 16, 8) fracInst0(z, x, y, c, thres);
	
	
	//////////////////////////////////////////////////////////////
	
	///////////playground///////////
	lcdEnable lcdEnableInst0(
		oLCD_ON, oLCD_BLON,
		oLCD_RW);
	
	
	lcdWrite test_inst11(
		oLCD_EN, oLCD_RS,
		oLCD_D,
		iCLK_50, mRST_N,
		"QWERTYGhijklmnop", {"AA fa hao !f", {11'h0,iSW,iKEY}});
		
  	
	wire	[31:0]	hexDisp;
	
	shortint intx = -1;
	
	assign	hexDisp = (~iSW[9])?intx:
		(iSW[8])?(iSW[7])?oL:oR:
		(iSW[7])?iL:iR
		;
	
	hex8 inst16(oHEXs[63:0], hexDisp);
	
endmodule