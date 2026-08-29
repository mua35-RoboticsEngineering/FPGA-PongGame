// Username: mua35

module VgaController
(
	input		logic 	Clock,
	input		logic 	Reset,
	output	logic		blank_n,
	output	logic		sync_n,
	output	logic		hSync_n,
	output	logic 	vSync_n,
	output	logic	[10:0] nextX,
	output	logic	[ 9:0] nextY
);


	logic [10:0] hCount;
	logic [ 9:0] vCount;
	
	logic [10:0] HS_VIS = 11'd800;
	logic [10:0] HS_START = 11'd800 + 11'd56;
	logic [10:0] HS_END = 11'd800 + 11'd56 + 11'd120;
	logic [10:0] HS_PERIOD = 11'd1039;

	

	logic [10:0] VS_VIS = 10'd600;
	logic [10:0] VS_START = 10'd600 + 10'd37;
	logic [10:0] VS_END = 10'd600 + 10'd37 + 10'd6;
	logic [10:0] VS_PERIOD = 10'd665;
	

	always_ff @(posedge Clock)
	begin
		if( Reset == 1 )
			begin
				hCount <= 0;
				vCount <= 0;
			end
		else if( hCount > HS_PERIOD )
			begin
				hCount <= 0;
				if( vCount > VS_PERIOD )
					vCount <= 0;
				else
					vCount++;
			end
		else
			hCount++;
	end

	
	always_comb
	begin
		// hSync
		if( (hCount >= HS_START) && (hCount < HS_END) )
			hSync_n = 0;
		else
			hSync_n = 1;

		// vSync
		if( (vCount >= VS_START) && (vCount < VS_END) )
			vSync_n = 0;
		else
			vSync_n = 1;

		// nextX
		if( hCount < HS_VIS )
			nextX = hCount;
		else
			nextX = 0;

		// nextY		
		if( vCount < VS_VIS )
			nextY = vCount;
		else
			nextY = 0;
		
		// blank
		if( (hCount >= HS_VIS) || (vCount >= HS_VIS) )
			blank_n = 0;
		else
			blank_n = 1;

		// sync
		if( ((hCount >= HS_START) && (hCount < HS_END)) || ((vCount >= VS_START) && (vCount < VS_END)))
			sync_n = 0;
		else
			sync_n = 1;			
		
	end
	
endmodule
