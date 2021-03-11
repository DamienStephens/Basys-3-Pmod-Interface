`timescale 1ns / 1ps

/*
    Name: Damien Stephens
    Class: FPGA Design
    Last Modified: 03/10/2021
    
    About: This program is intended to be implemented on the Basys 3 FPGA. 
           Two Pmod boards, PmodACL and PmodGPS, are used to acquire data.
*/

module main(
    input btn0, btn1, clk, [7:0]sw,
    output TxD); 

// Set up the UART module so the board can transmit data to the computer.
UART uart(.clk(clk), .btn0(btn0), .btn1(btn1), .sw(sw), .TxD(TxD));


endmodule
