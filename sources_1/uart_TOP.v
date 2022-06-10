`timescale 1ns / 1ps

module uart_TOP(
                //CLOCK SIGNAL
                input clk,
                //RECEIVE + TRANSMISSION
                input RsRx,
                output RsTx
                );
                
// Intermediate Variables:
wire        data_VALID;
wire [7:0]  byte_MSG;                
                
                
// RECEIVER MODULE:
uart_RX ux00 (.i_CLK(clk), .i_SERIAL(RsRx), .o_DV(data_VALID), .o_BYTE(byte_MSG));
// TRANSMISSION MODULE:
uart_TX ux01 (.i_CLK(clk), .i_DV(data_VALID), .i_BYTE(byte_MSG), .o_SERIAL(RsTx));
                
endmodule
