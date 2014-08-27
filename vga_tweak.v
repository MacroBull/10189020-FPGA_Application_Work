	//////////////Video/////////////////////
	// Configure VGA output as 640x360@30Hz (on my Philips is 640x350@26Hz)
	// Alternative VGA profile is 1280x720, 640x480, 720x400
	// Choose for the demand of your monitor
	
	reg	[1:0] VGAClkDiv;
	reg	mVGA_CLK;
	wire	mVGA_VS; // Vsync wire
	wire	[9:0]	mVGA_X, mVGA_Y;
	
	/// 640x360 @8.75MHz = 50 /6
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
	assign	oVGA_SYNC_N=1;
	
	vga_time_generator drv3(
		.hp(1'b1), .vp(1'b1),
	
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

		.v_disp   (360),
		.v_fporch (vfp),
		.v_sync   (vsync),
		.v_bporch (vbp),
		
		.h_disp   (640),
		.h_fporch (hfp),
		.h_sync   (hsync), 
		.h_bporch (hbp),
		
		.vga_hs   (oVGA_HS), .vga_vs   (mVGA_VS), .vga_blank(oVGA_BLANK_N),
		.CounterY(mVGA_Y), .CounterX(mVGA_X), .pixel_clk(mVGA_CLK));
		
	/////////////Video Effects////////////////
	
	assign	oVGA_B = mVGA_X % mVGA_Y + mVGA_Y % mVGA_X;
	assign	oVGA_R = (640 - mVGA_X) % mVGA_Y + mVGA_Y %  (640 - mVGA_X);
	assign	oVGA_G = mVGA_X % (360-mVGA_Y) + (360-mVGA_Y) % mVGA_X;
	
	reg	[5:0]	vfp, vsync, vbp, hfp, hsync, hbp;
	
	
	always @(negedge mRST_N or posedge mCLK_50Div[21]) begin
		if (!mRST_N)  begin
			vfp <= 10;
			vsync <= 4;
			vbp <= 33;
			hfp <= 16;
			hsync <= 60;
			hbp <=48;
		end
		else if (`SW_LCD_LOCK) begin
			if	((!`KEY_FIR_PRESET_CHANGE)) vfp <= vfp -1;
			if	((!`KEY_VOL_UP)) vsync <= vsync -1;
			if	((!`KEY_VOL_DOWN)) vbp <= vbp -1;
		end 
		else begin
			if	((!`KEY_FIR_PRESET_CHANGE)) hfp <= hfp -1;
			if	((!`KEY_VOL_UP)) hsync <= hsync -1;
			if	((!`KEY_VOL_DOWN)) hbp <= hbp -1;
		end
			
	end
	
	/////////////////LCD ///////////////////////
	
	lcdEnable comp0(
		oLCD_ON, oLCD_BLON,
		oLCD_RW);
		
	logic	[3 * 8-1:0]	s0,s1,s2,s3,s4,s5;
	logic	[16*8-1:0]	LCD_line1, LCD_line2;
	
	assign	 LCD_line1 = {" ", s0, "  ", s1, "  ", s2, "  "};
	assign	 LCD_line2 = {" ", s3, "  ", s4, "  ", s5, "  "};
	
	utoa8	test_inst10(s0,	vfp);
	utoa8	test_inst11(s1,	vsync);
	utoa8	test_inst12(s2,	vbp);
	utoa8	test_inst13(s3,	hfp);
	utoa8	test_inst14(s4,	hsync);
	utoa8	test_inst15(s5,	hbp);
	
	lcdWrite drv0(
		oLCD_EN, oLCD_RS,
		oLCD_D,
		iCLK_50, mRST_N,
		LCD_line1, LCD_line2);
		
	