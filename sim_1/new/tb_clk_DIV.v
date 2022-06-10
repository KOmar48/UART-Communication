`timescale 1ns / 1ps

//Testbench for Clock Divider
module tb_clk_DIV;

reg clk, EN;
reg [7:0] BYTE;
wire serial, active, stop;
wire flag;
wire [7:0] msg;
wire serialF, activeF, stopF;

uart_Tx utx00 (.i_CLK(clk), .i_DV(EN), .i_BYTE(BYTE), .o_SERIAL(serial), .o_ACTIVE(active), .o_STOP(stop));
uart_Rx urx00 (.i_CLK(clk), .i_SERIAL(serial), .o_DV(flag), .o_BYTE(msg));
uart_Tx utx01 (.i_CLK(clk), .i_DV(flag), .i_BYTE(msg), .o_SERIAL(serialF), .o_ACTIVE(activeF), .o_STOP(stopF));

initial begin
    clk = 1;
    EN = 1;
    BYTE = 8'h4C;
end

always #5 clk = ~clk;

initial begin
    # 1000000
    BYTE = 8'h41;
    # 1000000
    BYTE = 8'h43;
    # 1000000
    BYTE = 8'h53;
    # 1000000
    BYTE = 8'h41;
    # 1000000
    EN = 0;
    # 1000000
    $finish;
end

    
endmodule
