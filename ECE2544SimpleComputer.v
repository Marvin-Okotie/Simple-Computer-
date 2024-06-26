////////////////////////////////////////////////////////////////////////////////////////////////////
//
// File: ECE2544SimpleComputer.v
// Top-level file for Simple Computer projects
//
// ******************************************
// YOU ARE NOT PERMITTED TO MODIFY THIS FILE.
// ******************************************
//  
// This is a simplified version of the simple computer module created by Xin Xin in June 2012.
//
// Created by Tom Martin, 11/29/2012
// Modified by P. Athanas, 3/2013
// Modified by KLC, 11/2013
// Modified by Hsiao, 10/2015
// Modified by KLC, 11/2015
// Modified by Addison Ferrari, 7/2019
// Modified by JST, 11/2019
// Modified by KLC, 03/2020
// Modified by KLC, 03/2022
//
// Current Changes:
// 1.  The accelerometer has been removed.
// 2.  The modules have been re-arranged in the files to indicate which modules can be changed and
//     which must not be changed.
// 5.  The synthesis keep directive has been added to signals of interest in the cpu module.
// 7.  Added connections to seven-segment displays on DE10-Lite board.
// 8.  Change 3 is repealed: the DE-10 Lite uses a different input interface.
// 9.  Change 4 is repealed: KEY1 is the reset and KEY0 is the clock enable, to be consistent with
//     Learning Experience E.
// 10. Change 6 is repealed: r6 and r7 are no longer multiplexed with PC and IR on the DE10-Lite.
//
// Former Changes: (DE0-Nano)
// 3.  This version uses all four DIP switches to control the LEDs instead of having one control
//     whether the clock is enabled by the pushbutton.
// 4.  KEY0 is the reset and KEY1 is the clock enable to be consistent with previous assignments.
// 6.  Add toggling of LEDS using KEY[0] for SW[3:1] = 110 and 111 so that r6 and r7 can be
//     displayed. This might lead to poor behavior, but the board is input-constrained.
//
// ================================================
// This code is generated by Terasic System Builder
// ================================================
//
// 
// 
////////////////////////////////////////////////////////////////////////////////////////////////////

module ECE2544SimpleComputer(CLOCK_50, KEY, SW, LED, HEX3, HEX2, HEX1, HEX0);
	input        CLOCK_50;
	input  [1:0] KEY;
	input  [4:0] SW;
	output [7:0] LED;
	output [6:0] HEX3;
	output [6:0] HEX2;
	output [6:0] HEX1;
	output [6:0] HEX0;

	wire        reset_inv;
	wire        cpu_clk_en;
	reg         cpu_clk_en_delay0;
	reg         cpu_clk_en_delay1;
	wire        cpu_clk;

	wire [15:0] r0;
	wire [15:0] r1;
	wire [15:0] r2;
	wire [15:0] r3;
	wire [15:0] r4;
	wire [15:0] r5;
	wire [15:0] r6;
	wire [15:0] r7;
	wire [15:0] IR;
	wire [15:0] PC;
	wire [3:0]  status;					
	wire [15:0] hex_out;

// BEGIN TOP-LEVEL MODULE
	
// Reset inverts active-low KEY1.

	assign reset_inv = ~KEY[1];

// Instantiate push-button finite state machine.
// The FSM and clock assignments allow the CPU to use KEY1 as the enable signal.
// KEY1 is gated with the 50 MHz clock to generate one 50 MHz clock pulse each time KEY1 is pushed.
// The FSM generates one clock enable signal per button press and release.

	button_fsm button_fsm0(CLOCK_50, reset_inv, KEY[0], cpu_clk_en);
	
// This is Altera's recommended way to implement clock gating.

	always@(posedge CLOCK_50) // Make sure cpu0_clk_en_delay0 is one clock cycle
		cpu_clk_en_delay0 = cpu_clk_en;
			
	always@(negedge CLOCK_50)
		cpu_clk_en_delay1 = cpu_clk_en_delay0;

	assign cpu_clk = cpu_clk_en_delay1 & CLOCK_50;

// End of clock generation portion.
 
// Instantiate CPU.

	cpu cpu0(cpu_clk, reset_inv, r0, r1, r2, r3, r4, r5, r6, r7, IR, PC, status);

// Assign the LEDs based upon the DIP switch settings.  
// LED_mux is a 20-to-1 mux that selects half of a register value to display.

/*	mux20to1_8bits LED_mux(SW, r0[7:0], r0[15:8], r1[7:0], r1[15:8], r2[7:0], r2[15:8], r3[7:0], r3[15:8], r4[7:0], r4[15:8],
 	                           r5[7:0], r5[15:8], r6[7:0], r6[15:8], r7[7:0], r7[15:8], PC[7:0], PC[15:8], IR[7:0], IR[15:8], LED);
										*/
// LED_mux is a 2-to-1 mux that selects half of the PC value to display.
	mux2to1_16bit LED_mux(SW[4], PC[7:0], PC[15:8], LED);
										
// Assign the seven-segment displays based upon the DIP switch settings.
// HEX_mux is a 10-to-1 mux that shows an entire register to display.

	mux10to1_16bits HEX_mux(SW[3:0], r0, r1, r2, r3, r4, r5, r6, r7, PC, IR, {12'h000,status}, hex_out);

// Use four seven-segment displays to show the chosen register value.	

	hexDecoder_7seg upper(hex_out[15:8], HEX3, HEX2);
	hexDecoder_7seg lower(hex_out[ 7:0], HEX1, HEX0);

endmodule
