`timescale 1ns / 1ps

// Given a CLK frequency of 1MHz and a Baud Rate of 9600bps 
// The value of Cycles per Bit = 1000000/9600 = 104  >>> 100,000,000/9600 = 10416.0
module uart_TX #(parameter CLKS_PER_BIT = 10416)
                (
                 input          i_CLK, i_DV,
                 input [7:0]    i_BYTE,
                 output reg     o_SERIAL
                );
                 
// Define FSM states:
parameter s_IDLE    = 2'b00;
parameter s_START   = 2'b01;
parameter s_DATA    = 2'b10;
parameter s_END     = 2'b11;

// Intermediate Variables:
reg [13:0]  t_CLK   = 0;
reg [2:0]   t_INDEX = 0;
reg [7:0]   t_BYTE  = 0;
reg [1:0]   t_MAIN  = 0;

// LOGIC
always @ (posedge i_CLK)
    case(t_MAIN)
        
        s_IDLE: begin
            o_SERIAL <= 1'b1;
            
            if (i_DV == 0) 
                t_MAIN <= s_IDLE;
            else begin
                t_CLK <= 0;
                t_BYTE <= i_BYTE;
                t_MAIN <= s_START;
            end
        end
        
        s_START: begin
            o_SERIAL <= 1'b0;
            
            if (t_CLK < CLKS_PER_BIT-1) begin
                t_CLK <= t_CLK + 1;
                t_MAIN <= s_START;
            end
            else begin
                t_CLK <= 0;
                t_MAIN <= s_DATA;
            end
        end
        
        s_DATA: begin
            o_SERIAL <= t_BYTE[t_INDEX];
            
            if (t_CLK < CLKS_PER_BIT-1) begin
                t_CLK <= t_CLK + 1;
                t_MAIN <= s_DATA;
            end
            else begin
                t_CLK <= 0;
                
                if (t_INDEX < 7) begin
                    t_INDEX <= t_INDEX + 1;
                    t_MAIN <= s_DATA;
                end
                else begin
                    t_INDEX <= 0;
                    t_MAIN <= s_END;
                end              
            end
        end
        
        s_END: begin
            o_SERIAL <= 1'b1;
            
            if (t_CLK < CLKS_PER_BIT-1) begin
                t_CLK <= t_CLK + 1;
                t_MAIN <= s_END;
            end
            else begin
                t_CLK <= 0;
                
                if (i_DV == 0)
                    t_MAIN <= s_IDLE;
                else begin 
                    t_BYTE <= i_BYTE;
                    t_MAIN <= s_START;
                end
            end
        end
        
        default:
            t_MAIN <= s_IDLE;
    endcase               
endmodule
