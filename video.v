/*
* Video module
* @Author: Macrobull
* @Project: DE2-70 Audio Effector and Visualization
* @Date: July 2014
* @Github: https://github.com/MacroBull/10189020-FPGA_application_work
*/

module video(
	/* 
	* Configure VGA parameter and generate pixel coord(x,y) signal
	* to draw pixels, assign oVGA_xs to your painting function like:
	* 	{oVGA_R, oVGA_G, oVGA_B} = paint(x,y)
	*
	* to configure VGA clock, use cvt command:
	* 	> cvt 1024 576 60
	* 	# 1024x576 59.90 Hz (CVT 0.59M9) hsync: 35.88 kHz; pclk: 46.50 MHz
	* 	Modeline "1024x576_60.00"   46.50  1024 1064 1160 1296  576 579 584 599 -hsync +vsync
	* 
	* i.e. iVGA_CLK = 46.50MHz, h_disp = 1024, h_fporch = 40, h_sync = 16, h_bporch = 136
	* v_disp = 576, h_fporch = 3, h_sync = 5, h_bporch = 15, hp = 0, vp = 1
	*/
	oVGA_CLOCK, 
	oVGA_HS, oVGA_VS,
	oVGA_SYNC_N, oVGA_BLANK_N,
	oX, oY,
	iVGA_CLK);

	output	oVGA_CLOCK;
	output	oVGA_HS, oVGA_VS;
	output	oVGA_SYNC_N, oVGA_BLANK_N;
	output	[9:0]	oX, oY;
	
	input	iVGA_CLK;
	
	assign	oVGA_CLOCK = iVGA_CLK;
	assign	oVGA_SYNC_N=1;
	
	vga_time_generator vga0(
		.pixel_clk(iVGA_CLK),
		
// 		.h_disp   (1280),
// 		.h_fporch (40),
// 		.h_sync   (120), 
// 		.h_bporch (160),
// 		
// 		.v_disp   (720),
// 		.v_fporch (3),
// 		.v_sync   (5),
// 		.v_bporch (13),
		
		.hp(1'b0), .vp(1'b1),
		
		.v_disp   (350),
		.v_fporch (10),
		.v_sync   (4),
		.v_bporch (33),
		
		.h_disp   (640),
		.h_fporch (16),
		.h_sync   (96), 
		.h_bporch (48),
		
// 		.v_disp   (480),
// 		.v_fporch (10),
// 		.v_sync   (2),
// 		.v_bporch (33),

		.vga_hs   (oVGA_HS),
		.vga_vs   (oVGA_VS),
		.vga_blank(oVGA_BLANK_N),
		.CounterY(oY),
		.CounterX(oX));
	
endmodule