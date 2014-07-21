/*
* driver for Wolfson WM8731 audio codec
* @Author: Macrobull
* @Project: DE2-70 Audio Effector and Visualization
* @Date: July 2014
* @Github: https://github.com/MacroBull/10189020-FPGA_application_work
*/


module dacWrite(
	/*
	* write stereo data to DAC in master mode + 16bit + right justfied
	* each channel contains 32 bits data, justfied by SET_FORMAT
	*/
	oAUD_DACDAT,
	iRST_N,
	iLData, iRData,
	AUD_DACLRCK, AUD_BCLK
// 	,debug
	);
	output	oAUD_DACDAT;
	input	iRST_N;
	input	[ws - 1:0]	iLData, iRData;
	input	AUD_DACLRCK, AUD_BCLK;
	
// 	output	reg debug;
	
	parameter	ws = 32;
	
	reg	[ws - 1:0]	dataBuff;
	reg	[4:0] dataIndex;
	
	reg	sync; // use sync register to reset data index every edge of AUD_DACLRCK
	
	always @(AUD_DACLRCK) begin
		dataBuff <= ((AUD_DACLRCK)?iLData:iRData); // load data to buffer
	end
	
	always @(posedge AUD_BCLK) begin
		sync <= AUD_DACLRCK;
		if (sync != AUD_DACLRCK)
			dataIndex <= 1; // next index is 1 !!
		else
			dataIndex <= dataIndex + 1;
	end
	
	assign	oAUD_DACDAT = dataBuff[~dataIndex];  // MSB first
	
endmodule

module adcRead(
	/*
	* read stereo data from ADC in master mode + 16bit + right justfied
	* each channel contains 32 bits data, justfied by SET_FORMAT
	*/
	oLData, oRData,
	iRST_N,
	iAUD_ADCDAT,
	AUD_ADCLRCK, AUD_BCLK);
	
	output	[ws - 1:0]	oLData, oRData;
	input	iRST_N;
	input	iAUD_ADCDAT;
	input	AUD_ADCLRCK, AUD_BCLK;
	
	parameter	ws = 32;
	
	reg	[ws - 1:0]	oLData, oRData;
	reg	[ws - 1:0]	dataBuff;
	
	// Move buffer to output
	always @(posedge AUD_ADCLRCK) begin
		oRData <= dataBuff;// & 16'h0fff;//^ 16'hfc20;
	end
	
	always @(negedge AUD_ADCLRCK) begin
		oLData <= dataBuff;// & 16'h0fff;// ^ 16'hfc20;
	end
	
	// Shif left to receive data
	always @(posedge AUD_BCLK or negedge iRST_N) begin
		if (!iRST_N)
			dataBuff <= 0;
		else begin
			dataBuff <= {dataBuff[ws - 2 : 0], iAUD_ADCDAT};
		end
	end
	
endmodule
	
module wm8731Config (
	/*
	* Configure Wolfson WM8731 via I2C
	* 10~400kHz I2C clock is divided from iCLK_50/50M
	* The writing hardware address is 0x34
	* See datasheet about the registers to config the chip
	*/
	iCLK_50,
	iRST_N,
	I2C_SCLK, I2C_SDAT);
	//	Host Side
	input		iCLK_50;
	input		iRST_N;
	//	I2C Side
	output		I2C_SCLK;
	inout		I2C_SDAT;
	
	//	Internal Registers/Wires
	reg	[15:0]	mI2C_CLK_DIV;
	reg	[23:0]	mI2C_DATA;
	reg			mI2C_CTRL_CLK;
	reg			mI2C_GO;
	wire		mI2C_END;
	wire		mI2C_ACK;
	reg	[15:0]	LUT_DATA;
	reg	[5:0]	LUT_INDEX;
	reg	[3:0]	mSetup_ST;

	//	Clock Setting
	parameter	CLK_Freq	=	50000000;	//	50	MHz
	parameter	I2C_Freq	=	100000;		//	100	KHz
	//	LUT Data Number
	parameter	LUT_SIZE	=	9;
	//	Audio Data Index
	parameter	Dummy_DATA	=	0;
	parameter	SET_LIN_L	=	1;
	parameter	SET_LIN_R	=	2;
	parameter	A_PATH_CTRL	=	3;
	parameter	D_PATH_CTRL	=	4;
	parameter	POWER_ON	=	5;
	parameter	SET_FORMAT	=	6;
	parameter	SAMPLE_CTRL	=	7;
	parameter	SET_ACTIVE	=	8;

	/////////////////////	I2C Control Clock	////////////////////////
	always@(posedge iCLK_50 or negedge iRST_N) begin
		if(!iRST_N) begin
			mI2C_CTRL_CLK <= 0;
			mI2C_CLK_DIV <= 0;
		end
		else begin
			if( mI2C_CLK_DIV	< (CLK_Freq/I2C_Freq/2) )
				mI2C_CLK_DIV <= mI2C_CLK_DIV+1;
			else begin
				mI2C_CLK_DIV <= 0;
				mI2C_CTRL_CLK <= ~mI2C_CTRL_CLK;
			end
		end
	end
	
	//////////////////////	Config Control	////////////////////////////
	always@(posedge mI2C_CTRL_CLK or negedge iRST_N) begin
		if(!iRST_N) begin
			LUT_INDEX <= 0;
			mSetup_ST <= 0;
			mI2C_GO <= 0;
		end
		else begin
			if(LUT_INDEX<LUT_SIZE) begin
				case(mSetup_ST)
				0:	begin
						mI2C_DATA <= {8'h34,LUT_DATA};
						mI2C_GO <= 1;
						mSetup_ST <= 1;
					end
				1:	if (mI2C_END) begin
						mSetup_ST <= (mI2C_ACK)?0:2;
						mI2C_GO <= 0;
					end
				2:	begin
						LUT_INDEX <= LUT_INDEX+1;
						mSetup_ST <= 0;
					end
				endcase
			end
		end
	end
	
	/////////////////////	Config Data LUT	  //////////////////////////	
	always @(LUT_INDEX) begin
		case(LUT_INDEX) //	Audio Config Data
			SET_LIN_L	:	LUT_DATA <= {7'b0000000, 9'b000011111};// ---- Left LINE IN gain
			SET_LIN_R	:	LUT_DATA <= {7'b0000001, 9'b000011111};// ---- Right LINE IN gain
 			A_PATH_CTRL	:	LUT_DATA <= {7'b0000100, 9'b000010010};// ---- Select DAC
			D_PATH_CTRL	:	LUT_DATA <= {7'b0000101, 9'b000000111};// ---- ADC HPF
			POWER_ON	:	LUT_DATA <= {7'b0000110, 9'b000000010};// ---- Disable MIC
// 			SET_FORMAT	:	LUT_DATA <= {7'b0000111, 9'b000000001};// ---- Slave Mode + MSBLJ
			SET_FORMAT	:	LUT_DATA <= {7'b0000111, 9'b001000000};// ---- 16bit + Master Mode + MSBRJ
// 			SET_FORMAT	:	LUT_DATA <= {7'b0000111, 9'b001001000};// ---- 24bit + Master Mode + MSBRJ
			SAMPLE_CTRL	:	LUT_DATA <= {7'b0001000, 9'b000000000};// ---- 48 + 48 * 256 @ 12.288MHz
			SET_ACTIVE	:	LUT_DATA <= {7'b0001001, 9'b000000001};//16'h1201;
			default:		LUT_DATA <= 16'd0 ;
		endcase
	end
	
	////////////////////////////////////////////////////////////////////
	I2C_Controller 	u0	(	.CLOCK(mI2C_CTRL_CLK),		//	Controller Work Clock
							.I2C_SCLK(I2C_SCLK),		//	I2C CLOCK
							.I2C_SDAT(I2C_SDAT),		//	I2C DATA
							.I2C_DATA(mI2C_DATA),		//	DATA:[SLAVE_ADDR,SUB_ADDR,DATA]
							.GO(mI2C_GO),      			//	GO transfor
							.END(mI2C_END),				//	END transfor 
							.ACK(mI2C_ACK),				//	ACK
							.RESET(iRST_N)	);
							
endmodule
