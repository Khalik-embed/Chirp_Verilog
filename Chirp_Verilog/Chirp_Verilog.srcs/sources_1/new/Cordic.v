module Cordic #(
	parameter D_PHAZE_MEAN=18'd72_000
	,parameter DATA_WIDTH=14)
(
    input clk
    ,input rst
    ,input en
    ,input signed 	[DEGREE_WIDTH-1:0]		phaze_int
    ,input signed 	[DATA_WIDTH-1:0] 			x_int
    ,output  reg signed 		[DATA_WIDTH-1:0]			out_sin=0
    ,output  reg signed 		[DATA_WIDTH-1:0]			out_cos=0
);

localparam	N=14;
localparam  DEGREE_WIDTH=24;
localparam 	DATA_WIDTH_EXTENDED=DATA_WIDTH+3; //17

integer i;
reg signed [DATA_WIDTH_EXTENDED-1:0] dphaze=0;
reg signed [DATA_WIDTH_EXTENDED-1:0] dphaze_buf=0;
reg signed [DEGREE_WIDTH-1:0] degree=0;
reg signed [DATA_WIDTH+1:0]	x   	[N:0];
reg signed [DATA_WIDTH+1:0]	y   	[N:0];
reg signed [DEGREE_WIDTH-1:0]	z 		[N:0];
reg signed [DEGREE_WIDTH-1:0] arctan 	[N:0];





always @(posedge clk ) begin
	if (rst) begin
		// reset
		for (i=0;i<N+1;i=i+1) begin
			x[i]<=0;
			y[i]<=0;
			z[i]<=0;
		end

	end
	else  if (en) begin
			x[0]<=x_int;///17'd10000;
 			z[0]<=degree;
 			y[0]<=17'b0;
			if (z[0]<0) z[1]<=z[0]+arctan[0];			
			else z[1]<=z[0]-arctan[0];
			
			for (i=0; i<N; i=i+1)
				begin : step
					if (z[i]<0)  begin
						x[i+1]<=$signed(x[i]+(y[i]>>>i));
						y[i+1]<=$signed(y[i]-(x[i]>>>i));
						z[i+1]<=$signed(z[i]+arctan[i]);			
					end
					else begin
						x[i+1]<=$signed(x[i]-(y[i]>>>i));
						y[i+1]<=$signed(y[i]+(x[i]>>>i));
						z[i+1]<=$signed(z[i]-arctan[i]);
					end
				end


	end
end

initial begin

    arctan[ 0 ]=	24'd450_000 ;
    arctan[ 1 ]=	24'd265650 ;
    arctan[ 2 ]=	24'd140362 ;
    arctan[ 3 ]=	24'd71250 ;
    arctan[ 4 ]=	24'd35763 ;
    arctan[ 5 ]=	24'd17899 ;
    arctan[ 6 ]=	24'd8952 ;
    arctan[ 7 ]=	24'd4476 ;
    arctan[ 8 ]=	24'd2238 ;
    arctan[ 9 ]=	24'd1119 ;
    arctan[ 10 ]=	24'd560 ;
    arctan[ 11 ]=	24'd280 ;
    arctan[ 12 ]=	24'd140 ;
    arctan[ 13 ]=	24'd70 ;
    arctan[ 14 ]=	24'd35 ;
    arctan[ 15 ]=	24'd17;

    for (i=0;i<N+1;i=i+1) begin
		x[i]<=			17'b0;
		y[i]<=			17'b0;
		z[i]<=			24'b0;
		quadrant[i]=	2'b00;
	end
	out_sin=1'b0;
	out_cos=1'b0;
end

reg [1:0]quadrant [N+1:0];
reg signed [DEGREE_WIDTH-1:0] half_pi=			24'd1800_000;
reg signed [DEGREE_WIDTH-1:0] quad_pi=			24'd900_000;
reg signed [DEGREE_WIDTH-1:0] dphaze_mean_reg=	D_PHAZE_MEAN;

//ila_0 your_instance_name (
//	.clk(clk), // input wire clk
//	.probe0(out_sin), // input wire [23:0]  probe0  
//	.probe1(degree) // input wire [23:0]  probe1
//);





always @(posedge clk ) begin
	if (rst) begin
	degree<=24'b0;
	dphaze<=24'b0;
	dphaze_buf<=24'b0;
	for (i=0;i<N+1;i=i+1) begin
		quadrant[i]=	2'b00;
	end
	end else begin

		dphaze<=(phaze_int+(dphaze_mean_reg));
		dphaze_buf<=dphaze;
		if ((degree+dphaze)<(half_pi)) 
			if ((degree+dphaze)<quad_pi)	degree<=degree+dphaze_buf;
     		else 	begin
     				quadrant[0]<=quadrant[0]+1'b1;
     				degree<=degree+dphaze_buf-quad_pi;		
     		end						
		else 	begin 
				degree<=degree+dphaze_buf-half_pi;   	
				quadrant[0]<=quadrant[0]+2'b10;
		end

     	for (i=1;i<N+2;i=i+1)
			begin
				quadrant[i]<=quadrant[i-1];
			end

     	casex (quadrant[N+1]) 
     		3'b00		:begin
     						out_cos<=x[N]>>>1;
							out_sin<=y[N]>>>1;
     					end					
     		3'b01		:begin
     						out_cos<=-(y[N]>>>1);
							out_sin<=x[N]>>>1;
     					end
     		3'b10		:begin
     					    out_cos<=-(x[N]>>>1);
							out_sin<=-(y[N]>>>1);
     					end 
     		3'b11		:begin
     		     			out_cos<=y[N]>>>1;
							out_sin<=-(x[N]>>>1);
     					end	

     	endcase
     				
		end
end


endmodule