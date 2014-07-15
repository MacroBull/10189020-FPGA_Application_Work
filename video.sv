module video(
	oVGA_CLOCK, 
	oVGA_HS, oVGA_VS,
	oVGA_SYNC_N, oVGA_BLANK_N,
	oVGA_R, oVGA_G, oVGA_B,
	iVGA_CLK);

	output	oVGA_CLOCK;
	output	oVGA_HS, oVGA_VS;
	output	oVGA_SYNC_N, oVGA_BLANK_N;
	output	[9:0]	oVGA_R, oVGA_G, oVGA_B;
	
	input	iVGA_CLK;
	
	wire	[11:0]	x, y;
	
	assign	oVGA_CLOCK = iVGA_CLK;
	assign	oVGA_SYNC_N=1;
	
	vga_time_generator vga0(
		.pixel_clk(iVGA_CLK),
		
		.h_disp   (1280),
		.h_fporch (40),
		.h_sync   (120), 
		.h_bporch (160),
		
		.v_disp   (720),
		.v_fporch (3),
		.v_sync   (5),
		.v_bporch (13),
		
		.hp(1'b0), .vp(1'b1),
		
// 		.h_disp   (640),
// 		.h_fporch (16),
// 		.h_sync   (96), 
// 		.h_bporch (48),
// 		
// 		.v_disp   (480),
// 		.v_fporch (10),
// 		.v_sync   (2),
// 		.v_bporch (33),

		.vga_hs   (oVGA_HS),
		.vga_vs   (oVGA_VS),
		.vga_blank(oVGA_BLANK_N),
		.CounterY(y),
		.CounterX(x));
		
	
// 	reg	[9:0]	oVGA_R, oVGA_G, oVGA_B;
	
// 	wire	[7:0] my;
// 	wire	sig;
// 	
// 	cos_fix_8(my, sig, x);
// 	
// 	always @(x or y) begin
// 	
// 		if (((sig)?360-my:360+my) == y) begin
// 			oVGA_R <= 10'h3ff;
// 			oVGA_G <= x;
// 			oVGA_B <= y;
// 		end
// 		else begin
// 			oVGA_R <= 0;
// 			oVGA_G <= 0;
// 			oVGA_B <= 0;
// 		end
// 	end
	
	reg	[31:0]	c;
	wire	[maxIter:0][31:0]	z, zz;
	wire	[maxIter:0][31:0]	az;
	wire	[maxIter:0] cmp;
	
	parameter scale = 1;
	parameter thr = 4000;
	parameter maxIter = 8'd20;
	
	initial c = {16'd1, 16'd0};
	
	genvar i;
	
	generate 
		for (i=0;i<maxIter;i=i+1) begin : mapZ
			complex_absqr compInst0(az[i], z[i]);
			complex_mul comInst1(zz[i], z[i], z[i]);
			assign z[i+1] = zz[i] + c;
			assign cmp[i] = az[i] < thr;
		end
	endgenerate
			
	
	assign oVGA_B = cmp;
	assign z[0] = { 4'h0, y - 360, 4'h0, x - 640} * scale;
	

endmodule