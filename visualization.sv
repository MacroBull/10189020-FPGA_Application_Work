/*
* Audio Visualization modules
* @Author: Macrobull
* @Project: DE2-70 Audio Effector and Visualization
* @Date: July 2014
* @Github: https://github.com/MacroBull/10189020-FPGA_application_work
*/


`define	audio	signed	[15:0]
`define	peak	[14:0]
`define	color	[9:0]  
`define	coord	[9:0]


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
	input	`peak iL, iR;
	
	assign	oB = ((iX + iL) % iY) & (iY % (iX + iL));
	assign	oG = (iX % (iY + iR)) | ((iY + iR) % iX);
	assign	oR = (iX % iY) + (iY % iX);
	
endmodule


module visual_wave_vertical(
	oR, oG, oB,
	iX, iY,
	iL, iR,
	iSync
	);
	
	output	`color oR, oG, oB;
	input	`coord iX, iY;
	input	`audio iL, iR;
	input	iSync;
	
	parameter	glowSize = 200;
	
	reg	`coord	xL, xR, mL, mR;
	
	always @(negedge iSync) begin
		xL <= mL;
		xR <= mR;
		mL[9:0] <= (iL[15:8] ^ 10'd128) + 10'd64;// - 10'd64;
		mR[9:0] <= (iR[15:8] ^ 10'd128) + 10'd320;//+ 10'd192;
	end
	
	
	assign	oR = ((iX==mL)|(iX<xL)^(iX<mL))?999:
		((iX>mL)&(iX<mL+glowSize))?glowSize-iX+mL:
		((iX<mL)&(iX+glowSize>mL))?glowSize+iX-mL:0;
	assign	oG = ((iX==mR)|(iX<xR)^(iX<mR))?999:
		((iX>mR)&(iX<mR+glowSize))?glowSize-iX+mR:
		((iX<mR)&(iX+glowSize>mR))?glowSize+iX-mR:0;
// 	assign	oR = (iX <= mL)?499:0;
// 	assign	oG = (iX <= mR)?499:0;
// 	assign	oB = (iX[7:0]==0)?999:((iX % iY) + (iY % iX));
	assign	oB = ((iX==192)|(iX==448))?199:((iX % iY) + (iY % iX));
// 	assign	oB = ((iX==256)|(iX==384))?999:((iX % iY) + (iY % iX));
	
endmodule

module visual_peak_progression(
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
	
endmodule


module visual_freePainting(
	oR, oG, oB,
	iX, iY,
	iRAND_CLK, iRAND_RST
	);
	
	output	`color oR, oG, oB;
	input	`coord iX, iY;
	input	iRAND_CLK, iRAND_RST;
	
	
	parameter	seqLen = 64;
	
	reg	[seqLen - 1:0]`color	xL;
	reg	`color mB;
	reg	[15:0] r;
	reg	[5:0]	p, dp;
	
	rand_LNRand op0(r, 16'd1234, !iRAND_RST, iRAND_CLK);
	
	always @(iX) begin
		p <= (iX-64)>>3;
		dp <= (r[3:2]==3)?2:(r[3:2]==2)?0:1;
		if (r<30) xL[p] <= r;
		else xL[p] <= xL[p+dp-6'd1];
		mB <= xL[p];
	end
	
	assign	oB = mB;
	
endmodule


module visual_blocks(
	oR, oG, oB,
	iX, iY,
	iL, iR,
	iRAND_CLK, iRAND_RST
	);
	
	output	`color oR, oG, oB;
	input	`coord iX, iY;
	input	`peak iL, iR;
	input	iRAND_CLK, iRAND_RST;
	
	parameter	seqLen = 80;
	
	reg	[seqLen - 1:0]`color	t;
	reg	`color mB;
	
	wire	[15:0] r;  // randomizer
	wire	[6:0]	p; // index
	
// 	rand_LNRand op0(r, 16'd1234, !iRAND_RST, !iRAND_CLK);
	rand_LNRand op0(r, (iL >> 4) & 16'h0ff0, !iRAND_RST, iX[2]);
	assign	p = iX >> 3;
	
	always @(iX) begin
		if ((3'd0 == iX[2:0]) & (3'd0 == iY[2:0])) t[p] = r;
		mB <= t[p];
	end
	
// 	assign	oB = (iX>=64)&(iX<576)?mB:0; //  Valid region
	assign	oB = mB;
	
endmodule


module visual_franticStripes(
	oR, oG, oB,
	iX, iY,
	iL, iR,
	iRAND_CLK, iRAND_RST
	);
	
	output	`color oR, oG, oB;
	input	`coord iX, iY;
	input	`peak iL, iR;
	input	iRAND_CLK, iRAND_RST;
	
	
	parameter	seqLen = 64;
	
	reg	[seqLen - 1:0]`color	stL0, stL1, sL;
	reg	`color mB;
	
	wire	[15:0] r;  // randomizer
	reg		[5:0]	p, dp; // index
	

// 	rand_LNRand op0(r, 16'd1234, !iRAND_RST, !iRAND_CLK);
	rand_LNRand op0(r, (iL >> 4) & 16'h0ff0, !iRAND_RST, !iRAND_CLK);
// 	rand_LNRand op0(r, (iL >> 4) & 16'h0ff0, 1, !iRAND_CLK);
	
	always @(negedge iRAND_RST) begin
		sL = {iL[14:5], sL[seqLen - 1:1]};
	end
	  
	always @(iX) begin
		p <= (iX-64)>>3;
		dp <= ((r>>1)<iL)?(r[1])?p - 1:p+1:p; // Larger volume, more twist
// 		dp <= (r<25000)?p - 1:(r>40000)?p+1:p;
// 		dp <= (p>0)&(r<25000)?p - 1:(p<seqLen - 1)&(r>40000)?p+1:p;
		if ((3'd0 == iX[2:0]) & (3'd0 == iY[2:0])) begin // for every block 
 			if (iY) begin  
				stL0[p] <= stL1[dp];
				if (iX == 0) stL1 <= {10'd0, stL0[seqLen - 2:1], 10'd0};
// 				if (iX == 0) stL1 <= stL0;
			end
 			else stL0[p] <= sL[p]; // line 0, from audio
		end
		mB <= stL0[p];
	end
	
	assign	oB = (iX>=64 + 8)&(iX<576 - 8)?mB:0; // Valid region
	
endmodule

module visual_tablecloth( // using abs
	oR, oG, oB,
	iX, iY,
	iL, iR,
	iFS
	);
	
	parameter	MAXINT = 65535; // Altitude
	parameter	ELEVATION = 70; // Elevation
	parameter	DP = 29;
	parameter	DAP = 1<<DP;   // Prescale for calculation
	
	parameter	FOOT = 12345; // Base altitude
	parameter	COLD = (1024-1) / 2;  // Color value per layer
	parameter	WID = 640, HEI = 360;  // Screen definition
	parameter	WD2 = WID/2, WM2 = WID * 2;
	parameter	HD2 = HEI/2, HM2 = HEI * 2;
	parameter	SPF = 26*2; // Step per frame
	
	output	`color oR, oG, oB;
	input	`coord iX, iY;
	input	`peak iL, iR;
	input	iFS;
	
	wire	[31:0]	s;
	wire	`color	v;
	reg	[31:0]	frcnt;
	
	always @(negedge iFS) begin
		frcnt <= frcnt + DAP / SPF;
	end
	
	assign	s = MAXINT*(iL+FOOT)/(iY+ ELEVATION);
	assign	v = ( 
		( ((frcnt +(iX+WID)*s) >> DP) & 1'b1) +
		( ((frcnt + (WM2-iX)*s) >> DP) & 1'b1) 
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
	
	parameter	MAXINT = 7<<(DP - 2); // Altitude
	parameter	ELEVATION = 110; // Elevation
	parameter	DP = 27;
	parameter	DAP = 1<<DP;   // Prescale for calculation
	
	parameter	COLD = (1024-1) / 2;  // Color value per layer
	parameter	WID = 640, HEI = 360;  // Screen definition
	parameter	WD2 = WID/2, WM2 = WID * 2;
	parameter	HD2 = HEI/2, HM2 = HEI * 2;
	parameter	PL = 115, PR = 525, CY = 260; // Wave origins
	parameter	SPF = 26*2; // Step per frame
	
	output	`color oR, oG, oB;
	input	`coord iX, iY;
	input	`peak iL, iR;
	input	iCLK;
	
	parameter	seqLen = 32; // 32 / 26 = waves stay for 1.23s
	
	reg	[seqLen - 1:0]`peak	xL, xR;
	reg	[31:0]	frcnt; // Frame counter
	
	always @(negedge iCLK) begin
		xL = {xL[seqLen - 2:0], iL};
 		xR = {xR[seqLen - 2:0], iR};
		frcnt <= frcnt + DAP / SPF;  // DAP should be 1<<x
	end
	
	
	wire	[31:0]	s, vx, vy;
	wire	`coord	dL, dR, dxL, dxR, dy, y;
	
	assign	dxL = iX>PL?iX-PL:PL-iX;
	assign	dxR = iX>PR?iX-PR:PR-iX;
	assign	dy = iY>CY?iY-CY:CY-iY;
	int_sqrt_cmp10 op0(dL, (dxL*dxL + dy*dy*4) >> 9);
	int_sqrt_cmp10 op1(dR, (dxR*dxR + dy*dy*4) >> 9);
	
	assign	s = MAXINT/(iY+ ELEVATION);
	assign	y = (xL[dL] / (10'd4 + dL) + xR[dR] / (10'd4 + dR) ) >> 10'd5;
	assign	vx = frcnt + (iX+WID+y)*s;
	assign	vy = frcnt + (WM2-iX+y)*s;
	
	assign	oR = ( 
		( (vx >> DP) & 1'b1) +
		( (vy >> DP) & 1'b1) 
		) * COLD;
	assign	oG = ( 
		( (vx*32'd5 >> DP) & 1'b1) +
		( (vy*32'd5 >> DP) & 1'b1) 
		) * COLD;
	assign	oB = ( 
		( (vx*32'd29 >> DP) & 1'b1) +
		( (vy*32'd29 >> DP) & 1'b1) 
		) * COLD;
	
endmodule
