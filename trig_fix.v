/*
* Triangle calculation tester modules
* Calculate sine and cosine for fixed number
* @Author: Macrobull
* @Project: DE2-70 Audio Effector and Visualization
* @Date: July 2014
* @Github: https://github.com/MacroBull/10189020-FPGA_application_work
*/

module	sin_fix_10(  
	/*
	* input and output fix point dp = 10
	* return sig == 1 if y is negative
	*/
	y,
	sig, 
	x);
	
	output	[ws - 1:0]	y;
	output	sig;
	input	[31:0]	x;
	
	parameter	ws = 10;
	parameter	per = 3142;
	
	wire	[ws:0]	mx;
	
	assign sig = (x / per);//[0];
	
	assign mx = (x % per > per /2) ? (per - x % per) : x % per;
	
	assign y = mx + (mx * mx / 35888) - (( mx * mx * mx / 6 ) >> (ws * 2));
	
endmodule

module	cos_fix_8( 
	/*
	* input and output fix point dp = 8
	* return sig == 1 if y is negative
	*/
	y,
	sig, 
	x);
	
	output	[ws - 1:0]	y;
	output	sig;
	input	[31:0]	x;
	
	parameter	ws = 8;
	parameter	per = 804;
	
	wire	[ws:0]	mx;
	
	assign sig = (x / per) ^ (x / (per/2));//[0];
	
	assign mx = (x % per > per /2) ? (per - x % per) : x % per;
	
	assign y = (1 << ws) - 1 - (mx / 100) - ((mx * mx / 2) >> ws) + ((mx * (mx * mx * mx / 24)) >> (ws * 3));
	
endmodule
