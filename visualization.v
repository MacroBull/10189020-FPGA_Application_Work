

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
	
	reg	[10:0]	k, l;
	wire	[15:0]	r;
	
	rand_adc op0(r, iL[0], iY[0]);
	
	always	@(iX) begin
		k <= k + (r >> 12);
		l <= (k>1023)?2047-k:k;
	end
	
	assign	oB = l;
	assign	oG = l;
	assign	oR = l;
	
endmodule