module top(
	/////////////output////////////////
	oLEDR, oLEDG,
	
	oLCD_RW, oLCD_RS, oLCD_ON ,oLCD_EN ,oLCD_BLON,
	oLCD_D,
	
	oI2C_SCLK,
	
	oHEXs,
	
	oAUD_XCK, oAUD_DACDAT,
	
	/////////////input//////////////////////
	
	iSW,
	iKEY,
	
	iAUD_ADCDAT,
	
	iEXT_CLOCK,
	iCLK_50_4, iCLK_50_3 ,iCLK_50_2 ,iCLK_50 ,iCLK_28,
	
	////////////inout//////////////
	
	ioGPIOs);
	
	/////////////output////////////////
	output	[17:0]	oLEDR;
	output	[8:0]	oLEDG;
	
	output	oLCD_RW, oLCD_RS, oLCD_ON ,oLCD_EN ,oLCD_BLON;
	output	[7:0]	oLCD_D;
	
	output	oI2C_SCLK;
	
	output	[7:0]	oHEXs;
	
	output	oAUD_XCK, oAUD_DACDAT;
	
	/////////////input//////////////////////
	
	input	[17:0]	iSW;
	input	[3:0]	iKEY;
	
	input	iAUD_ADCDAT;
	
	input	iEXT_CLOCK;
	input	iCLK_50_4, iCLK_50_3 ,iCLK_50_2 ,iCLK_50 ,iCLK_28;
	
	////////////inout//////////////
	
	inout	[3:0]	ioGPIOs;
	
	/////////////memory////////////////////
	
	reg	[7:0]	RAM	[31:0];
	
	//////////////defines////////////////////
	
	`define RESETKEY iKEY[0]
	
	/////////////////////////////////
	
	hexTest test_inst0(oHEXs);
	
// 	lcdTest test_inst1(	//	Host Side
// 					iCLK_50,`RESETKEY,
// 					//	LCD Side
// 					oLCD_D,oLCD_RW,oLCD_EN,oLCD_RS,
// 					oLCD_ON, oLCD_BLON);
	//"ABCDEFGhijklmnopqRSTUVWXYZ 123"
// 	lcdWrite test_inst11(	//	Host Side
// 					iCLK_50,`RESETKEY,
// 					//	LCD Side
// 					oLCD_D,oLCD_RW,oLCD_EN,oLCD_RS,
// 					oLCD_ON, oLCD_BLON,
// 					RAM
// 					);
// 					

	reg [7:0] arr [1:0];
	reg [23:0] cnt;
	reg [8:0] oLEDG;
	reg [3:0] gg = 0;
	reg	[17:0]	oLEDR;
	
	
	initial begin
		$monitor("%b",oLEDG);
		#10 gg = gg +1;
		#10 gg = gg +1;
	end
	
	initial begin
		cnt = 0;
	end
	
	always @(negedge iKEY[3]) begin
		cnt = cnt + 1;
		if (cnt == 5000000)
			cnt = 0;
		arr[0] = cnt;
	end
	
	
	always @(iSW[2]) begin 
		oLEDR[iSW[2]] = iSW[iSW[2]];
		oLEDR[7:4] = 4'b1010;
	end
	
// 	assign oLEDG[7:0] = cnt[7:0];
	

 	svTest testInst3(oLEDR[15:0], arr);

	
endmodule