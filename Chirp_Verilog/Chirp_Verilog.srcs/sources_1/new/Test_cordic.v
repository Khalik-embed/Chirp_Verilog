`timescale 1ns / 100ps


module Test_cordic();

reg clk;    
initial clk=0;
always begin
    #5 clk = !clk;  // 100 MHz
end

reg en;
initial begin
 en = 1;
 #10 en = 1'b1;
end
 
 reg rst;
 initial begin
    rst = 1'b0;
    #30 rst = 1'b0;
 end

parameter D_PHAZE_MEAN=36000;
parameter DATA_WIDTH=14;
parameter AMPLITUDE=8192;
wire [DATA_WIDTH-1:0]sin;
wire [DATA_WIDTH-1:0]cos;

Cordic #(
     .D_PHAZE_MEAN(D_PHAZE_MEAN)
    , .DATA_WIDTH(DATA_WIDTH))
Cordic_dut
(
    .clk(clk)
    ,.rst(rst)
    ,.en(en)
    ,.phaze_int(0)
    ,.x_int(AMPLITUDE)
    ,.out_sin(sin)
    ,.out_cos(cos)
);


endmodule
