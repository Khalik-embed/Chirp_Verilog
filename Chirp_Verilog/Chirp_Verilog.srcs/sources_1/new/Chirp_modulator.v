module Chirp_modulator(
    input rst
    ,input en
    ,input clk
    ,input start_generation
    ,output reg [15:0] dac_out = 0
    ,output reg generation_complete= 0
    );


parameter SYSTEM_CLK = 100_000_000;    
parameter START_FREQ = 1_000_000;
parameter STOP_FREQ = 2_000_000;
parameter SIGNAL_DURATION_IN_US = 100;
parameter COMPLETE_DURATION_IN_US = 1;

localparam D_PHAZE_MEAN_START = (360 * 10000) / (SYSTEM_CLK / START_FREQ);
localparam D_PHAZE_MEAN_STOP = (360 * 10000) / (SYSTEM_CLK / STOP_FREQ);
localparam DELTA_FREQ = D_PHAZE_MEAN_STOP - D_PHAZE_MEAN_START;
localparam SIGNAL_DURATION_IN_TICS = (SYSTEM_CLK /1000_000) * SIGNAL_DURATION_IN_US;
localparam STEP_OF_INCREMENTING_PHAZE = ((DELTA_FREQ<<$clog2(SIGNAL_DURATION_IN_TICS)-1) / SIGNAL_DURATION_IN_TICS);
localparam COMPLETE_DURATION_IN_TICS = (SYSTEM_CLK /1000_000) * COMPLETE_DURATION_IN_US;
localparam START_LATENCY = 16;

localparam PHAZE_WIFTH =24;
localparam DATA_WIDTH = 16;
localparam AMPLITUDE = 32768;
wire [DATA_WIDTH-1:0] sin;
wire [DATA_WIDTH-1:0] cos;

reg [PHAZE_WIFTH-1:0] phaze_in=0;
Cordic #(
     .D_PHAZE_MEAN(D_PHAZE_MEAN_START)
    , .DATA_WIDTH(DATA_WIDTH))
Cordic_dut
(
    .clk(clk)
    ,.rst(rst)
    ,.en(en)
    ,.phaze_int(phaze_in)
    ,.x_int(AMPLITUDE)
    ,.out_sin(sin)
    ,.out_cos(cos)
);  
    
reg  [($clog2(SIGNAL_DURATION_IN_TICS)*2):0] dphaze_accumulator= 0;
always @ (posedge clk)
    if(rst) begin
        dphaze_accumulator<=0;
        phaze_in <=0;
    end else if (en) begin 

        dphaze_accumulator<= dphaze_accumulator + STEP_OF_INCREMENTING_PHAZE;
        phaze_in <= dphaze_accumulator >> $clog2(SIGNAL_DURATION_IN_TICS)-1;



    end


    
endmodule
