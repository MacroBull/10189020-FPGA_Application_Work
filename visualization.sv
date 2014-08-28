
`define	audio	signed	[15:0]
`define	peak	[14:0]
`define	color	[9:0]  
`define	coord	[9:0]

/*
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

module visual_peak_progress(
	oR, oG, oB,
	iX, iY,
	iL, iR,
	iBCLK
	);
	
	output	`color oR, oG, oB;
	input	`coord iX, iY;
	input	`peak iL, iR;
	input	iBCLK;
	
	parameter	seqLen = 64;
	
	reg	[seqLen - 1:0][6:0]	xL, xR;
	reg	[5:0] p;
	reg	[3:0] alpha;
	
	always @(negedge iBCLK) begin
		xL = {xL[seqLen - 2:0], iL[14:8]};
		xR = {xR[seqLen - 2:0], iR[14:8]};
	end
	
	assign p = (576 - iX) >> 3;
	
	uint15_log2 op0(alpha, iX*22);
	
	parameter	ypL = 10'd160, ypR = 10'd320;
	
	assign	oR = ((iX>=64)&(iX<576)&(iY<ypL)&(iY>ypL-xL[p]))?
		(xL[p] + iX - 24 >> 3)*alpha:0;
	assign	oG = ((iX>=64)&(iX<576)&(iY<ypR)&(iY>ypR-xR[p]))?
		(xR[p] + iX - 24 >> 3)*alpha:0;
	assign	oB = (iX % iY) + (iY % iX);
	
endmodule

module visual_peak_log(
	oR, oG, oB,
	iX, iY,
	iL, iR,
	iBCLK
	);
	
	output	`color oR, oG, oB;
	input	`coord iX, iY;
	input	`peak iL, iR;
	input	iBCLK;
	
	parameter	seqLen = 64;
	
	reg	[seqLen - 1:0][4:0]	xL, xR;
	reg	[5:0] p;
	reg	[31:0] m32L, m32R;
	reg	[4:0] lL, lR;
	
	parameter	scale = 32'd4000;
	
	assign	m32L = iL;
	assign	m32R = iR;
	
	uint32_log2 op0(lL, m32L * scale);
	uint32_log2 op1(lR, m32R * scale);
	
	always @(negedge iBCLK) begin
		xL = {xL[seqLen - 2:0], lL-5'd20};
		xR = {xR[seqLen - 2:0], lR-5'd20};
	end
	
	assign p = (576 - iX) >> 3;
	
	parameter	ypL = 10'd160, ypR = 10'd320;
	
	assign	oR = ((iX>=64)&(iX<576)&(iY<ypL)&(iY>ypL-xL[p]*11))?
		(xL[p]+16)*((iX-64)>>4):0;
	assign	oG = ((iX>=64)&(iX<576)&(iY<ypR)&(iY>ypR-xR[p]*11))?
		(xL[p]+16)*((iX-64)>>4):0;
	assign	oB = (iX % iY) + (iY % iX);
	
endmodule*/


// module visual_freePainting( // using abs
// 	oR, oG, oB,
// 	iX, iY,
// 	iL, iR,
// 	iRAND_CLK, iRAND_RST
// 	);
// 	
// 	output	`color oR, oG, oB;
// 	input	`coord iX, iY;
// 	input	`audio iL, iR;
// 	input	iRAND_CLK, iRAND_RST;
// 	
// 	
// 	parameter	seqLen = 64;
// 	
// 	reg	[seqLen - 1:0][15:0]	xL;
// 	reg	`color mB;
// // 	reg	[9:0] r;
// 	reg	[15:0] r;
// 	reg	[5:0]	p;
// 	reg	[1:0]	dp;
// 	
// 	assign	p = iX >> 3;
// 	assign	dp = (r[3:2]==3)?2:(r[3:2]==2)?0:1;
// 
// 	rand_LNRand op0(r, 16'd1234, !iRAND_RST, iRAND_CLK);
// 	
// 	always @(iX) begin
// // 		if ((0 == iX[2:0]) & (0 == iY[2:0])) begin
// 			if (r<30) begin
// 				xL[p] <= r;
// 			end
// 			else begin
// 				xL[p] <= xL[p+dp-6'd1];
// 			end
// //  		end
// 		mB <= xL[p];
// 	end
// 	
// 	assign	oB = mB;
// 	
// endmodule

module visual_block( // using abs
	oR, oG, oB,
	iX, iY,
	iL, iR,
	iRAND_CLK, iRAND_RST
	);
	
	output	`color oR, oG, oB;
	input	`coord iX, iY;
	input	`audio iL, iR;
	input	iRAND_CLK, iRAND_RST;
	
	
	parameter	seqLen = 64;
	
	reg	[seqLen - 1:0]`color	stL0, stL1, sL;
	reg	`color mB;
	
	wire	[15:0] r;
	reg		[5:0]	p, dp;
	

// 	rand_LNRand op0(r, 16'd1234, !iRAND_RST, !iRAND_CLK);
	rand_LNRand op0(r, (iL >> 4) & 16'h0ff0, !iRAND_RST, !iRAND_CLK);
// 	rand_LNRand op0(r, (iL >> 4) & 16'h0ff0, 1, !iRAND_CLK);
	
	always @(negedge iRAND_RST) begin
		sL = {iL[14:5], sL[seqLen - 1:1]};
	end
	  
	always @(iX) begin
		p <= (iX-64)>>3;
// 		dp <= (r<25000)?p - 1:(r>40000)?p+1:p;
		dp <= (r<(iL<<1))?(r[1])?p - 1:p+1:p;
// 		dp <= (p>0)&(r<25000)?p - 1:(p<seqLen - 1)&(r>40000)?p+1:p;
		if ((3'd0 == iX[2:0]) & (3'd0 == iY[2:0])) begin
 			if (iY) begin
				stL0[p] <= stL1[dp];
				if (iX == 0) stL1 <= {10'd0, stL0[seqLen - 2:1], 10'd0};
// 				if (iX == 0) stL1 <= stL0;
			end
 			else stL0[p] <= sL[p];
		end
		mB <= stL0[p];
	end
	
	assign	oB = (iX>=64 + 8)&(iX<576 - 8)?mB:0;
	
endmodule

module visual_tablecloth( // using abs
	oR, oG, oB,
	iX, iY,
	iL, iR,
	iFS
	);
	
// 	parameter	MAXINT32 = 4294967295;
	parameter	MAXINT = 65535;
// 	parameter	MAXINT16 = 65535;
	parameter	DAP = 1<<29;
	
	parameter	FOOT = 12345;
	parameter	COLD = 1024 / 2 - 1;
	parameter	DIM = 640;
	parameter	Dd2 = DIM/2, D2 = DIM * 2;
	parameter	FR = 26*2;
	
	output	`color oR, oG, oB;
	input	`coord iX, iY;
	input	`peak iL, iR;
	input	iFS;
	
	wire	[31:0]	s;
	wire	`color	v;
	reg	[31:0]	fscnt;
	
	always @(negedge iFS) begin
		fscnt <= fscnt + DAP / FR;// - (fscnt >= DAP*2)?DAP*2:0;
	end
	
// 	assign	s = MAXINT*iL/(iY+99);
// 	assign	s = MAXINT32/iL/(iY+99);
	assign	s = MAXINT*(iL+FOOT)/(iY+ 60);
	assign	v = ( 
		( ((fscnt +(iX+DIM)*s) / DAP) & 1'b1) +
		( ((fscnt + (D2-iX)*s) / DAP) & 1'b1) 
		) * COLD;
	
	assign	oR = v;
	assign	oG = v;
	assign	oB = v;
	
endmodule


module visual_tablecloth_color( // using abs
	oR, oG, oB,
	iX, iY,
	iL, iR,
	iCLK
	);
	
// 	parameter	MAXINT32 = 4294967295;
 	parameter	MAXINT = 1<<30;
// 	parameter	MAXINT16 = 65535;
	parameter	DAP = 1<<29;
	
// 	parameter	FOOT = 12345;
	parameter	COLD = 1024 / 2 - 1;
	parameter	DIM = 640;
	parameter	Dd2 = DIM/2, D2 = DIM * 2;
	parameter	FR = 26*2;
	
	output	`color oR, oG, oB;
	input	`coord iX, iY;
	input	`peak iL, iR;
	input	iCLK;
	
	parameter	seqLen = 32;
	
	reg	[seqLen - 1:0]`peak	xL;//, xR;
	reg	[31:0]	fscnt;
	
	always @(negedge iCLK) begin
		xL = {xL[seqLen - 2:0], iL};
// 		xR = {xR[seqLen - 2:0], iR[14:8]};
		fscnt <= fscnt + DAP / FR;// - (fscnt >= DAP*2)?DAP*2:0;
	end
	
	
	wire	[31:0]	s, vx, vy;
	wire	[9:0]	d, dx, dy, y;
	
	assign	dx = iX>Dd2?iX-Dd2:Dd2-iX;
	assign	dy = iY>250?iY-250:250-iY;
	int_sqrt_cmp10 op0(d, (dx*dx + dy*dy*4) >> 9);
	
	assign	s = MAXINT/(iY+ 110);
	assign	y = xL[d] >> 7;
	assign	vx = fscnt +(iX+DIM+y)*s;
	assign	vy = fscnt +(D2-iX+y)*s;
	
	assign	oR = ( 
		( (vx / DAP) & 1'b1) +
		( (vy / DAP) & 1'b1) 
		) * COLD;
	assign	oG = ( 
		( (vx*5 / DAP) & 1'b1) +
		( (vy*5 / DAP) & 1'b1) 
		) * COLD;
	assign	oB = ( 
		( (vx*29 / DAP) & 1'b1) +
		( (vy*29 / DAP) & 1'b1) 
		) * COLD;
	
endmodule
