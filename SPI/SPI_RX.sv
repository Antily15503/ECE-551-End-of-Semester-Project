module SPI_RX(clk, rst_n, SS_n, SCLK, MOSI, edg, len8, mask, match, SPItrig);
	input clk, rst_n, SS_n, SCLK, MOSI, edg, len8;
	input[15:0] mask, match;
	output SPItrig;
	wire SCLK_fall, SCLK_rise, SS_n_fall, SS_n_rise, comp_high_result, comp_low_result;
	reg[15:0] shft_reg;
	reg SCLK_ff1, SCLK_ff2, SCLK_ff3;
	reg MOSI_ff1, MOSI_ff2, MOSI_ff3;
	reg SS_n_ff1, SS_n_ff2, SS_n_ff3;
	reg shift, compare;
	
	typedef enum reg {IDLE, LOAD} state_t;
	state_t state, nxt_state;
	
    assign comp_low_result = (((shft_reg[7:0] | mask[7:0]) == (match[7:0] | mask[7:0])) ? 1 : 0) & compare; 
    assign comp_high_result = (((shft_reg[15:8] | mask[15:8]) == (match[15:8] | mask[15:8])) ? 1 : 0) & compare; 

	// State machine registers
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
	end
	
	// State machine logic
	always_comb begin
		compare = 0;
	
		case(state)
			IDLE: begin
				if(SS_n_fall)
					nxt_state = LOAD;
				else
					nxt_state = IDLE;
			end
			LOAD: begin
				if(SS_n_rise) begin
					nxt_state = IDLE;
					compare = 1;
				end
				else
					nxt_state = LOAD;
			end
		endcase
	end

	// SCLK and MOSI shift logic
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			SCLK_ff1 <= 0;
			SCLK_ff2 <= 0;
			SCLK_ff3 <= 0;
			
			MOSI_ff1 <= 0;
			MOSI_ff2 <= 0;
			MOSI_ff3 <= 0;
			
			SS_n_ff1 <= 0;
			SS_n_ff2 <= 0;
			SS_n_ff3 <= 0;
		end
		else begin
			SCLK_ff1 <= SCLK;
			SCLK_ff2 <=	SCLK_ff1;
			SCLK_ff3 <= SCLK_ff2;
			
			MOSI_ff1 <= MOSI;
			MOSI_ff2 <=	MOSI_ff1;
			MOSI_ff3 <= MOSI_ff2;
			
			SS_n_ff1 <= SS_n;
			SS_n_ff2 <= SS_n_ff1;
			SS_n_ff3 <= SS_n_ff2;
		end
	end
	
	// shft_reg logic
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			shft_reg <= 0;
		else if(shift)
            shft_reg <= {shft_reg[14:0], MOSI_ff3};
        else
            shft_reg <= shft_reg;
	end
	
	// SCLK fall/rise detection
	assign SCLK_fall = (SCLK_ff2 == 0 && SCLK_ff3 == 1) ? 1 : 0;
	assign SCLK_rise = (SCLK_ff2 == 1 && SCLK_ff3 == 0) ? 1 : 0;
	// SS_n fall/rise detection
	assign SS_n_fall = (SS_n_ff2 == 0 && SS_n_ff3 == 1) ? 1 : 0;
	assign SS_n_rise = (SS_n_ff2 == 1 && SS_n_ff3 == 0) ? 1 : 0;
	// edg determines if we should shift on the rise or fall of SCLK
	assign shift = edg ? SCLK_rise : SCLK_fall;
	// compare logic
	assign SPItrig = (comp_low_result & (comp_high_result | len8));
	
endmodule