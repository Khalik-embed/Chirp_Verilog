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
 #100 start_generation = 1;
end



wire [15:0] dac_out;
wire generation_complete;
reg [2:0]generation_complete_reg;

always @(posedge clk ) begin
    generation_complete_reg <= {generation_complete_reg[1:0],generation_complete};
    if (generation_complete_reg[2:1] == 2'b01) begin
        start_generation = 1'b0;
    end
    if (generation_complete_reg[2:1] == 2'b10) begin
        start_generation = 1'b1;
    end
end

wire clk_dac_p;
wire clk_dac_n;
Chirp_modulator Chirp_modulator_dut(
    .rst(rst)
    ,.en(en)
    ,.clk(clk)
    ,.start_generation(start_generation)
    ,.dac_out(dac_out)
    ,.clk_out_p(clk_dac_p)
    ,.clk_out_n(clk_dac_n)
    ,.generation_complete(generation_complete)
    );



endmodule
