module	utoa8(
	o,
	i);
	
	output	[3 * 8-1:0]	o;
	input	[7:0]	i;
	
	wire	[7:0]	d0, d1, d2;
	
	assign	d2 = i / 8'd100;
	assign	d1 = i / 8'd10 % 8'd10;
	assign	d0 = i % 8'd10;
	
	assign	o = "00000" + { d2, d1, d0};
	
endmodule

module	utoa16( // Convert 16-bit unsigned interger to string in length of 5
	o,
	i);
	
	output	[5 * 8-1:0]	o;
	input	[15:0]	i;
	
	wire	[7:0]	d0, d1, d2, d3 ,d4;
	
	assign	d4 = i / 16'd10000;
	assign	d3 = i / 16'd1000 % 16'd10;
	assign	d2 = i / 16'd100 % 16'd10;
	assign	d1 = i / 16'd10 % 16'd10;
	assign	d0 = i % 16'd10;
	
	assign	o = "00000" + {d4, d3, d2, d1, d0};
	
endmodule

module	itoa16( // Convert 16-bit signed interger to string in length of 6
	o,
	i);
	
	output	[6 * 8-1:0]	o;
	input	[15:0]	i;
	
	wire	[15:0]	mi;
	
	wire	[7:0]	d0, d1, d2, d3 ,d4;
	
	assign	mi = i[15]?-i:i;
	
	assign	d4 = mi / 16'd10000;
	assign	d3 = mi / 16'd1000 % 16'd10;
	assign	d2 = mi / 16'd100 % 16'd10;
	assign	d1 = mi / 16'd10 % 16'd10;
	assign	d0 = mi % 16'd10;
	
	assign	o = "00000" + {i[15]?"-":"+", d4, d3, d2, d1, d0};
	
endmodule