`timescale 1ns / 1ps
//CLKS_PER_BIT = Frequency of Clock/Frequency of UART 
//CBP => 100000000/9600 = 10416

module uart_RX #(parameter CLKS_PER_BIT = 10416)
               (
                input       i_CLK, i_SERIAL,
                output      o_DV,
                output[7:0] o_BYTE
               );

// States                
parameter s_IDLE    = 2'b00;
parameter s_START   = 2'b01;
parameter s_DATA    = 2'b10;
parameter s_END     = 2'b11;

// Intermediate Variables
reg r_DATA_R        = 1'b1;
reg r_DATA          = 1'b1;

reg [13:0]  r_CLK   = 0;
reg [2:0]   r_INDEX = 0;
reg [7:0]   r_BYTE  = 0;
reg         r_DV    = 0;
reg [1:0]   r_MAIN  = 0;

assign o_DV     = r_DV;
assign o_BYTE   = r_BYTE;

//Enter serial twice
always @ (posedge i_CLK) begin
    r_DATA_R <= i_SERIAL;
    r_DATA   <= r_DATA_R;     
end

// Rx FSM:
always @ (posedge i_CLK) begin

    case (r_MAIN)
        s_IDLE: begin 
            r_DV    <= 1'b0;
            r_CLK   <= 0;
            r_INDEX <= 0;
            
            if (r_DATA == 1'b0)
                r_MAIN <= s_START;
            else
                r_MAIN <= s_IDLE;
        end
        
        s_START: begin
            if (r_CLK == (CLKS_PER_BIT-1)/2)
            
                if (r_DATA == 1'b0) begin
                    r_CLK   <= 0;
                    r_MAIN  <= s_DATA;
                end
                else 
                    r_MAIN  <= s_IDLE;
                    
            else begin
                r_CLK   <= r_CLK + 1;
                r_MAIN  <= s_START;
            end
        end
        
        s_DATA: begin
            if (r_CLK < CLKS_PER_BIT -1) begin 
                r_CLK   <= r_CLK + 1;
                r_MAIN  <= s_DATA;
            end
            
            else begin
                r_CLK <= 0;
                r_BYTE[r_INDEX] <= r_DATA;
                
                if (r_INDEX < 7) begin
                    r_INDEX <= r_INDEX + 1;
                    r_MAIN <= s_DATA;
                end 
                else begin 
                    r_INDEX <= 0;
                    r_MAIN  <= s_END;
                end
            end
        end
          
        s_END: begin
            if (r_CLK < CLKS_PER_BIT - 1) begin
                r_CLK   <= r_CLK + 1;
                r_MAIN  <= s_END;
            end
            
            else begin
                r_DV    <= 1'b1;
                r_CLK   <= 0;
                r_MAIN  <= s_IDLE;
            end       
        end
        default:
            r_MAIN <= s_IDLE;
    endcase   
end
endmodule
