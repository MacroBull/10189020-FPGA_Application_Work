

// `define	color	[7:0]
// `define	coord	[9:0]
// `define	audio	[15:0]


module visual_shadingLevelWaves( // using abs
	oR, oG, oB,
	iX, iY,
	iL, iR
	);
	
	output	`color oR, oG, oB;
	input	`coord iX, iY;
	input	`audio iL, iR;
	
	assign	oB = (iX + iL) % iY + iY % (iX + iL);
	assign	oG = iX % (iY + iR) + (iY + iR) % iX;
	assign	oR = iX % iY + iY % iX;
	
endmodule

module visual_rationalFractal( // using abs
	oR, oG, oB,
	iX, iY,
	iL, iR
	);
	
	output	`color oR, oG, oB;
	input	`coord iX, iY;
	input	`audio iL, iR;
	
	assign	oB = ((iX + iL) % iY) & (iY % (iX + iL));
	assign	oG = (iX % (iY + iR)) | ((iY + iR) % iX);
	assign	oR = (iX % iY) + (iY % iX);
	
endmodule

module visual_foggy( // using abs
	oR, oG, oB,
	iX, iY,
	iL, iR
	);
	
	output	`color oR, oG, oB;
	input	`coord iX, iY;
	input	`audio iL, iR;
	
	reg	[10:0]	kr, lr, kg, lg, kb, lb;
	wire	[15:0]	r;
	reg	c;
	
	rand_LNRand op0(r, 12345, 1, c);
	
	always	@(iX) begin
		c = ~c;
		kr = kr + r[14:12];
		lr = (kr>1023)?2047-kr:kr;
		c = ~c;
		kg = kg + r[14:12];
		lg = (kg>1023)?2047-kg:kg;
		c = ~c;
		kb = kb + r[14:12];
		lb = (kb>1023)?2047-kb:kb;
	end
	
	assign	oB = lr;
	assign	oG = lg;
	assign	oR = lb;
	
endmodule

module visual_wave_vertical(
	oR, oG, oB,
	iX, iY,
	iL, iR
	);
	
	output	`color oR, oG, oB;
	input	`coord iX, iY;
	input	`peak iL, iR;
	
// 	assign	oR = (iX <= (iL-10) *60)?500:0;
// 	assign	oG = (iX <= (iR-10) *60)?500:0;
	assign	oR = (iX <= iL[14:6])?999:0;
	assign	oG = (iX <= iR[14:6])?999:0;
	assign	oB = (iX % iY) + (iY % iX);
	
endmodule

module visual_peak(
	oR, oG, oB,
	iX, iY,
	iL, iR
	);
	
	output	`color oR, oG, oB;
	input	`coord iX, iY;
	input	`peak iL, iR;
	
	reg	[64*8 - 1:0] xL, xR;
	wire	[8:0] p;
	
	always @(posedge (iY==0)) begin
		xL = {xL[63*8 - 1:0], iL[14:7]};
		xR = {xR[63*8 - 1:0], iR[14:7]};
	end
	
	assign p = iX >>> 3 <<< 3;
	
	assign	oR = (iY <= {xL[p+7], xL[p+6], xL[p+5], xL[p+4], xL[p+3], xL[p+2], xL[p+1], xL[p]})?499:0;
	assign	oG = (iY <= {xR[p+7], xR[p+6], xR[p+5], xR[p+4], xR[p+3], xR[p+2], xR[p+1], xR[p]})?499:0;
	assign	oB = (iX % iY) + (iY % iX);
	
endmodule