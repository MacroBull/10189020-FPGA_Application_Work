

`define int signed [ws - 1:0]

module int_ovReduce(
	o,
	i);
	
	output	`int	o;
	input	`int	i;
	
	parameter	ws = 16;
	
// 	assign o = i+ (1 << (ws - 1));
	assign o = (i<0)?i+1:i;
	
endmodule

module int_redAbs(
	o,
	i);
	
	output	`int	o;
	input	`int	i;
	
	parameter	ws = 16;
	
// 	assign o = i+ (1 << (ws - 1));
	assign o = (i<0)?~i:i;
	
endmodule

module	uint15_log2( // log+1,log2(0) ==0,  for audio peaks
	o,
	i);
	output	[3:0]	o;
	input	[15:0]	i;
	
	assign	o = 
		i[14]?4'd15:i[13]?4'd14:i[12]?4'd13:i[11]?4'd12:i[10]?4'd11:
		i[9]?4'd10:i[8]?4'd9:i[7]?4'd8:i[6]?4'd7:i[5]?4'd6:
		i[4]?4'd5:i[3]?4'd4:i[2]?4'd3:i[1]?4'd2:i[0]?4'd1:4'd0;
	
endmodule

module	uint32_log2( // log2(1) == log2(0) == 0
	o,
	i);
	output	[4:0]	o;
	input	[31:0]	i;
	
	assign	o = 
		i[31]?5'd31:i[30]?5'd30:
		i[29]?5'd29:i[28]?5'd28:i[27]?5'd27:i[26]?5'd26:i[25]?5'd25:
		i[24]?5'd24:i[23]?5'd23:i[22]?5'd22:i[21]?5'd21:i[20]?5'd20:
		i[19]?5'd19:i[18]?5'd18:i[17]?5'd17:i[16]?5'd16:i[15]?5'd15:
		i[14]?5'd14:i[13]?5'd13:i[12]?5'd12:i[11]?5'd11:i[10]?5'd10:
		i[9]?5'd9:i[8]?5'd8:i[7]?5'd7:i[6]?5'd6:i[5]?5'd5:
		i[4]?5'd4:i[3]?5'd3:i[2]?5'd2:i[1]?5'd1:5'd0;
	
endmodule

module int_norm( // 127~0~-127 => 255~128~0
	o,
	i);
	
	output	`int o;
	input	`int i;
	
	parameter	ws = 16;
	
// 	assign o = i+ (1 << (ws - 1));
	assign o = {~i[ws - 1], i[ws - 2:0]};
	
endmodule

module int_sqrt_cmp10(
	y,
	x
	);
	
	output	[4:0]	y;
	input	[9:0]	x;

// 	// use > instead for additional Sensitivity
// 	assign	y = (x>961)?31: (x>900)?30: (x>841)?29: (x>784)?28: (x>729)?27: (x>676)?26: (x>625)?25: (x>576)?24: (x>529)?23: (x>484)?22: (x>441)?21: (x>400)?20: (x>361)?19: (x>324)?18: (x>289)?17: (x>256)?16: (x>225)?15: (x>196)?14: (x>169)?13: (x>144)?12: (x>121)?11: (x>100)?10: (x>81)?9: (x>64)?8: (x>49)?7: (x>36)?6: (x>25)?5: (x>16)?4: (x>9)?3: (x>4)?2: (x>1)?1: 0;
	
	
	assign	y = 
		(x>=961)?31: (x>=900)?30: 
		(x>=841)?29: (x>=784)?28: (x>=729)?27: (x>=676)?26: (x>=625)?25: 
		(x>=576)?24: (x>=529)?23: (x>=484)?22: (x>=441)?21: (x>=400)?20: 
		(x>=361)?19: (x>=324)?18: (x>=289)?17: (x>=256)?16: (x>=225)?15: 
		(x>=196)?14: (x>=169)?13: (x>=144)?12: (x>=121)?11: (x>=100)?10: 
		(x>=81)?9: (x>=64)?8: (x>=49)?7: (x>=36)?6: (x>=25)?5: 
		(x>=16)?4: (x>=9)?3: (x>=4)?2: (x>=1)?1: 0;
		
endmodule



/* Intrepolation coeffs:
	[0, 65536, 0, 0]
	[-4657, 63864, 9123, -2794]
	[-7661, 59003, 19667, -5472]
	[-9042, 51394, 30836, -7651]
	[-8953, 41721, 41721, -8953]
	[-7651, 30836, 51394, -9042]
	[-5472, 19667, 59003, -7661]
	[-2794, 9123, 63864, -4657]

* Generated by(Python):
* P = 65536
* for i in range(8):
	v = np.sinc(linspace(1,-2,4)+i/8.)
	if v[0]+v[3] != 0:
		r = -(v[1] + v[2] - 1)/(v[0]+v[3])
		v[0] *= r
		v[3] *= r
	c = [int(i*P) for i in v]
	
*/

module int_interpolate_sinc8x2_16(
	oOut,
	iIndex,
	iP2, iP1, iS1, iS2
	);
	
	output	signed	[15:0]	oOut;
	input	[2:0]	iIndex;
	input	signed	[15:0]	iP2, iP1, iS1, iS2;
	
	wire	[31:0]	m32O;

// 	assign	m32O = 
// 		(iIndex==1)? (iP1*63864 + iP2*-4657 + iS2*-2794 + iS1*9123):
// 		(iIndex==2)? (iP1*59003 + iP2*-7661 + iS2*-5472 + iS1*19667):
// 		(iIndex==3)? (iP1*51394 + iP2*-9042 + iS2*-7651 + iS1*30836):
// 		(iIndex==4)? (iP1*41721 + iP2*-8953 + iS2*-8953 + iS1*41721):
// 		(iIndex==7)? (iS1*63864 + iS2*-4657 + iP2*-2794 + iP1*9123):
// 		(iIndex==6)? (iS1*59003 + iS2*-7661 + iP2*-5472 + iP1*19667):
// 		(iIndex==5)? (iS1*51394 + iS2*-9042 + iP2*-7651 + iP1*30836):
// 		(iP1*32768);
// 	
// 	assign	oOut = m32O[31:16];

	assign	m32O = 
		(iIndex==1)? (iP1*31932 + iP2*-2328 + iS2*-1397 + iS1*4561):
		(iIndex==2)? (iP1*29501 + iP2*-3830 + iS2*-2736 + iS1*9833):
		(iIndex==3)? (iP1*25696 + iP2*-4521 + iS2*-3825 + iS1*15418):
		(iIndex==4)? (iP1*20860 + iP2*-4476 + iS2*-4476 + iS1*20860):
		(iIndex==7)? (iS1*31932 + iS2*-2328 + iP2*-1397 + iP1*4561):
		(iIndex==6)? (iS1*29501 + iS2*-3830 + iP2*-2736 + iP1*9833):
		(iIndex==5)? (iS1*25696 + iS2*-4521 + iP2*-3825 + iP1*15418):
		(iP1*32768);
	
	assign	oOut = m32O[30]?32768:m32O[30:15]; // overflow proof for peak
		
endmodule

module	int_sqrt(
	y,
	x,
	iCLK, iCTRL
	);
	
	output	reg	[15:0]	y;
	input	[31:0]	x;
	input	iCLK, iCTRL;
	
	reg	[31:0]	mx;
	reg	[15:0]	t, my;
	
// 	initial	$monitor("( %d,	%d\t)\t| %d	%d	%d	%d", iCTRL,t,x,mx,my,y);
	
	always	@(negedge iCTRL or negedge iCLK) begin
		if (!iCTRL) begin
			t <= 16'h8000;
			y <= 0;
			mx <= x;
			my <= 0;
		end
		else if (0 == t) begin
			y <= my;
		end
		else begin
			if ((my+t)*(my+t)<=mx) my <= my+t;
			t <= t >> 1;
		end
	end
	
endmodule

module	int_sqrt_UAD( 
	// uninterruptable, direct read X, 16 iCLk to send out
	// iCTRL == 1 to enable
	y,
	x,
	iCLK, iCTRL
	);
	
	output	reg	[15:0]	y;
	input	[31:0]	x;
	input	iCLK, iCTRL;
	
	reg	[15:0]	t, my;
	
// 	initial	begin
// // 		$monitor("( %d,	%d\t)\t| %d	%d	%d", iCTRL,t,x,my,y);
// 		t = 0;
// 	end
	
	always	@(negedge iCLK) begin
		if (0 == t) begin
			if (iCTRL) begin
				t <= 16'h8000;
				my <= 16'd0;
			end
			y <= my;
		end
		else begin
			if ((my+t)*(my+t)<=x) my <= my+t;
			t <= t >> 16'd1;
		end
	end
	
endmodule