`timescale 1ns / 1ps

module Test_modulator();

reg clk;    
initial clk=0;
always begin
    #5 clk = !clk;  // 100 MHz
end

reg en;
initial begin
 en = 0;
 #10 en = 1'b1;
end
 
 reg rst;
 initial begin
    rst = 1'b1;
    #30 rst = 1'b0;
 end


reg start_generation;
initial begin
 start_generation = 0;
 #100 start_generation = 1'b1;
end

wire [15:0] dac_out;
wire generation_complete;

Chirp_modulator Chirp_modulator_dut(
    .rst(rst)
    ,.en(en)
    ,.clk(clk)
    ,.start_generation(start_generation)
    ,.dac_out(dac_out)
    ,.generation_complete(generation_complete)
    );



endmodule
