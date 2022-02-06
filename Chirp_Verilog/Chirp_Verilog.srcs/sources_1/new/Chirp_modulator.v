module Chirp_modulator(
    input rst
    ,input en
    ,input clk
    ,input start_generation
    ,output reg [15:0] dac_out = 0
    ,output clk_out_p
    ,output clk_out_n
    ,output reg generation_complete = 0
    );

assign clk_out_p = clk;
assign clk_out_n = !clk;
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
localparam START_LATENCY = 18; // 16 for cordic + 2 for shift_reg

localparam PHAZE_WIFTH =24;
localparam DATA_WIDTH = 16;
localparam AMPLITUDE = 32768;
wire [DATA_WIDTH-1:0] sin;
wire [DATA_WIDTH-1:0] cos;

reg [PHAZE_WIFTH-1:0] phaze_in=0;
reg cordic_en = 0;
reg cordic_rst =1'b1;
Cordic #(
     .D_PHAZE_MEAN(D_PHAZE_MEAN_START)
    , .DATA_WIDTH(DATA_WIDTH))
Cordic_dut
(
    .clk(clk)
    ,.rst(cordic_rst)
    ,.en(cordic_en)
    ,.phaze_int(phaze_in)
    ,.x_int(AMPLITUDE)
    ,.out_sin(sin)
    ,.out_cos(cos)
);  
    
reg  [($clog2(SIGNAL_DURATION_IN_TICS)*2):0] dphaze_accumulator= 0;
reg  [$clog2(SIGNAL_DURATION_IN_TICS)-1:0] signal_duration_counter = 0;

reg [2:0] start_generation_reg = 0;
reg [$clog2(COMPLETE_DURATION_IN_TICS)-1:0] complete_signal_counter =0;
always @ (posedge clk)
    if(rst) begin
        start_generation_reg <= 0;
        dphaze_accumulator <= 0;
        phaze_in <= 0;
        signal_duration_counter <= 0;
        cordic_en <= 0;
        cordic_rst <= 0;
        generation_complete<=0;
    end else if (en) begin 

        start_generation_reg<={start_generation_reg[1:0],start_generation};
        if(start_generation_reg[2:1] == 2'b01) begin 
            if (signal_duration_counter==0) begin 
                cordic_en <= 1'b1;
                cordic_rst<= 1'b0;
                signal_duration_counter<= SIGNAL_DURATION_IN_TICS + START_LATENCY;
            end
        end else begin
            if(signal_duration_counter !=0 ) begin 
                signal_duration_counter <= signal_duration_counter - 1;
            end
            if(signal_duration_counter ==1 ) begin 
                complete_signal_counter<= COMPLETE_DURATION_IN_TICS;
                generation_complete <= 1;
                cordic_en<=0;
                cordic_rst<=1'b1;
            end
        end
        
        if(complete_signal_counter!=0) begin
           complete_signal_counter<= complete_signal_counter-1;
        end 
        if (complete_signal_counter == 1) begin 
            generation_complete <= 0;
        end
        
        if (signal_duration_counter>0) begin
            dphaze_accumulator<= dphaze_accumulator + STEP_OF_INCREMENTING_PHAZE;
            phaze_in <= dphaze_accumulator >> $clog2(SIGNAL_DURATION_IN_TICS)-1;
        end else begin 
            dphaze_accumulator<= 0;
            phaze_in <= 0;
        end    
            



    end

always @(posedge clk) begin 
    if(rst) begin
        dac_out<= 0;
    end else begin
        dac_out<= cos;
    end
end
    
endmodule
