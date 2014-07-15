module video(
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