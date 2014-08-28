

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

	assign	y = (x>961)?31: (x>900)?30: (x>841)?29: (x>784)?28: (x>729)?27: (x>676)?26: (x>625)?25: (x>576)?24: (x>529)?23: (x>484)?22: (x>441)?21: (x>400)?20: (x>361)?19: (x>324)?18: (x>289)?17: (x>256)?16: (x>225)?15: (x>196)?14: (x>169)?13: (x>144)?12: (x>121)?11: (x>100)?10: (x>81)?9: (x>64)?8: (x>49)?7: (x>36)?6: (x>25)?5: (x>16)?4: (x>9)?3: (x>4)?2: (x>1)?1: 0;
	
endmodule