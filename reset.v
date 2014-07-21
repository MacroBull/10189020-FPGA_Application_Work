/*
* ResetManager module
* @Author: Macrobull
* @Project: DE2-70 Audio Effector and Visualization
* @Date: July 2014
* @Github: https://github.com/MacroBull/10189020-FPGA_application_work
*/

module resetManager(
	/* 
	* Reset manager can generate reset signal(low) by:
	* 	power up
	* 	manually negative edge, e.g. a push button input
	* 	every period@iCLK
	* reset pulse width = holdCycles@iCLK
	*/
	oRST_N,
	
	iCLK,
	iManualN,
	iPeriod
);
	output	oRST_N;
	
	input	iCLK, iManualN;
	input	[31:0]	iPeriod;
	
	parameter	holdCycles = -16'h1;
	
	reg	[31:0]	cnt;
	
	assign oRST_N = cnt >= holdCycles;
	
	initial cnt = 0;
	
	always @(posedge iCLK) begin
		if (!iManualN)
			cnt <= 0;
		else if (iPeriod) begin
			cnt <= cnt+1;
			if (cnt + 1 == iPeriod) 
				cnt <= 0;
		end
		else if (cnt < holdCycles)
			cnt <= cnt+1;
	end
	
endmodule