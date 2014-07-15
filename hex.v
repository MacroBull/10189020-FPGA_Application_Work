
module hex1(oHex, 
	iNum);
	
	output	[7:0]	oHex;
	
	input	[3:0]	iNum;
	
	assign	oHex = (iNum == 4'h0)?8'b11000000:
		(iNum == 4'h1)?8'b11111001:
		(iNum == 4'h2)?8'b10100100:
		(iNum == 4'h3)?8'b10110000:
		(iNum == 4'h4)?8'b10011001:
		(iNum == 4'h5)?8'b10010010:
		(iNum == 4'h6)?8'b10000010:
		(iNum == 4'h7)?8'b11111000:
		(iNum == 4'h8)?8'b10000000:
		(iNum == 4'h9)?8'b10010000:
		(iNum == 4'ha)?8'b10001000:
		(iNum == 4'hb)?8'b10000011:
		(iNum == 4'hc)?8'b10100111:
		(iNum == 4'hd)?8'b10100001:
		(iNum == 4'he)?8'b10000110:
		(iNum == 4'hf)?8'b10001110:
		8'b11111111;
	
endmodule

module hex4(oHex, 
	iNum);
	
	output	[31:0]	oHex;
	
	input	[15:0]	iNum;
	
	hex1	comp0(oHex[7:0], iNum[3:0]);
	hex1	comp1(oHex[15:8], iNum[7:4]);
	hex1	comp2(oHex[23:16], iNum[11:8]);
	hex1	comp3(oHex[31:24], iNum[15:12]);
	
endmodule

module hex8(oHex, 
	iNum);
	
	output	[63:0]	oHex;
	
	input	[31:0]	iNum;
	
	hex1	comp0(oHex[7:0], iNum[3:0]);
	hex1	comp1(oHex[15:8], iNum[7:4]);
	hex1	comp2(oHex[23:16], iNum[11:8]);
	hex1	comp3(oHex[31:24], iNum[15:12]);
	hex1	comp4(oHex[32 + 7:32 + 0], iNum[19:16]);
	hex1	comp5(oHex[32 + 15:32 + 8], iNum[23:20]);
	hex1	comp6(oHex[32 + 23:32 + 16], iNum[27:24]);
	hex1	comp7(oHex[32 + 31:32 + 24], iNum[31:28]);
	
endmodule