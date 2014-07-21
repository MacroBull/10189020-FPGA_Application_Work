/*
* Driver for CFAH1602BTMCJP LCD on DE2-70 board
* Original by Terasic Technologies Inc. 
* @Author: Macrobull
* @Project: DE2-70 Audio Effector and Visualization
* @Date: July 2014
* @Github: https://github.com/MacroBull/10189020-FPGA_application_work
*/
// 

module	lcdEnable( // LCD on, backlight on, write mode
	oLCD_ON, oLCD_BLON,
	oLCD_RW);
	
	output	oLCD_ON, oLCD_BLON;
	output	oLCD_RW;
	
	assign oLCD_ON = 1'b1;
	assign oLCD_BLON = 1'b1;
	assign oLCD_RW = 1'b0;
	
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

module	lcdWrite (
	/* 
	* Write two lines of 16-byte length string {iString0, iString1} to LCD
	* The refresh rate depends on LCD itself/the period of the loop
	* iCLK_50 must be 50MHz clock
	* lower iRST_N to reset LCD
	*/
	oLCD_EN, oLCD_RS,
	oLCD_D,
	iCLK_50, iRST_N,
	iString0, iString1);
	
	
	output	oLCD_EN, oLCD_RS;
	output	[7:0]	oLCD_D;
	
	input	iCLK_50, iRST_N;
	input	[0:15][7:0]	iString0, iString1;
	
	
	parameter	LCD_INTIAL = 0;
	parameter	LCD_LINE1 = 5;
	parameter	LCD_CH_LINE1 = 4;
	parameter	LCD_CH_LINE2 = LCD_LINE1+16;
	parameter	LCD_LINE2 = LCD_LINE1+16+1;
	parameter	INDEX_MAX = LCD_LINE1+32+1;
// 	parameter	LCD_INS = {8'h38, 8'h0C, 8'h01, 8'h06, 8'h80};
	
	
	reg	oLCD_RS;
	reg	[7:0]	oLCD_D;
	
	reg	mLCD_Start;
	
	wire	mLCD_Done;
	
	reg	[1:0]	ST;
	reg	[5:0]	index;
	reg	[17:0]	DLY;
	
	always @(posedge iCLK_50 or negedge iRST_N) begin
		if (!iRST_N) begin
			index <= 0;
			ST <= 0;
			DLY <= 0;
			mLCD_Start <= 0;
			oLCD_D <= 0;
			oLCD_RS <= 0;
		end
		else begin
			if(index<INDEX_MAX) begin
				case(ST)
					0:	begin
							case (index)
								0:	{oLCD_RS, oLCD_D} <= 9'h038;
								1:	{oLCD_RS, oLCD_D} <= 9'h00C;
								2:	{oLCD_RS, oLCD_D} <= 9'h001;
								3:	{oLCD_RS, oLCD_D} <= 9'h006;
								LCD_CH_LINE1:	{oLCD_RS, oLCD_D} <= 9'h080;
								LCD_CH_LINE2:	{oLCD_RS, oLCD_D} <= 9'h0C0;
								default:	if (index < LCD_CH_LINE2)
										{oLCD_RS, oLCD_D} <= {1'b1, iString0[index - LCD_LINE1]};
									else
										{oLCD_RS, oLCD_D} <= {1'b1, iString1[index - LCD_LINE2]};
							endcase
							
							mLCD_Start <= 1; // Send start
							ST <= 1;
						end
					1:	begin
							if (mLCD_Done) begin // got ACK
								mLCD_Start <= 0;
								ST <= 2;
							end
						end
					2:	begin
							if (DLY<18'h3FFFE) // delay > 1.7 ms
								DLY <= DLY+1;
							else	begin
								DLY <= 0;
								ST <= 3;
							end
						end
					3:	begin
							index <= index + 1;
							ST <= 0;
						end
				endcase
			end
			else index = LCD_CH_LINE1; // back to line1 when line2 done
		end
	end

	lcdController lcdConInst0(oLCD_EN, mLCD_Done,
		iCLK_50, iRST_N,
		mLCD_Start);

endmodule

module lcdController (
	oLCD_EN, 
	oDone,
	
	iCLK_50, iRST_N,
	iStart);
	
	
	parameter	clkDiv = 16;
	
	output oLCD_EN;
	output oDone;
	
	input iCLK_50, iRST_N;
	input iStart;
	
	reg oLCD_EN;
	reg oDone; 
	
	
	reg	[1:0]	ST;
	reg	[4:0]	cnt;


	always @(posedge iCLK_50 or negedge iRST_N) begin
		if (!iRST_N) begin
			oDone <= 1'b0;
			oLCD_EN <= 1'b0;
			cnt <= 0;
			ST	 <= 0;
		end
		else begin
			if (iStart) begin
				case(ST)
					0:	begin
							oDone <= 1'b0; // Clear ACK
							ST <= 1;
						end
					1:	begin
							oLCD_EN <= 1'b1; // output Enable
							ST	 <= 2;
						end
					2:	begin
							if(cnt < clkDiv) cnt <= cnt+1; // sync clock
							else ST  <= 3;
						end
					3:	begin
							oLCD_EN <= 1'b0; // done, return ACK
							oDone <= 1'b1;
							cnt <= 0;
							ST	 <= 0;
						end
				endcase
			end
		end
	end
	
endmodule
