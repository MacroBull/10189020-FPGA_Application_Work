/*
* Triangle calculation tester modules
* Calculate sine and cosine for fixed number
* @Author: Macrobull
* @Project: DE2-70 Audio Effector and Visualization
* @Date: July 2014
* @Github: https://github.com/MacroBull/10189020-FPGA_application_work
*/

module	fi_sin_10(  
	/*
	* input and output fix point dp = 10
	*/
	y, 
	x);
	
	output	signed	[ws - 1:0]	y;
	input	signed	[31:0]	x;
	
	parameter	ws = 16, dp = 10;
	parameter	per = 3142;
	
	wire	signed	[dp:0]	mx;
	wire	signed	[31:0]	mx2;
	
// 	assign sig = (x / per);//[0];
	assign	mx2 = mx * mx;
	
	assign mx = (x % per > per /2) ? (per - x % per) : x % per;
	
	assign y = mx + (mx2 / 35888) - (( mx2 * mx / 6 ) >>> (dp * 2));
	
endmodule

module	cos_fix_8( 
	/*
	* input and output fix point dp = 8
	* return sig == 1 if y is negative
	*/
	y,
// 	sig, 
	x);
	
	output	signed	[dp - 1:0]	y;
// 	output	sig;
	input	signed	[31:0]	x;
	
	parameter	dp = 8;
	parameter	per = 804;
	
	wire	[dp:0]	mx;
	wire	signed	[31:0]	mx2;
	
	assign sig = (x / per) ^ (x / (per/2));//[0];
	
	assign mx = (x % per > per /2) ? (per - x % per) : x % per;
	
	assign y = (1 << dp) - 1 - (mx / 100) - ((mx2 / 2) >> dp) + ((mx * (mx2 * mx / 24)) >> (dp * 3));
	
endmodule
