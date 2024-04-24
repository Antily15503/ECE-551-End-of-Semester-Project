module UART_rx(clk,rst_n,clr_rdy,RX,rx_data,rdy);
// UART Receiver

input clk, rst_n;
input RX, clr_rdy; 
output reg rdy; 
output reg [7:0] rx_data; 

    typedef enum logic {IDLE,RECEIVING} state_t;
    state_t state, next_state;
	
	// Internal signal declarations
    logic [15:0] baud_cnt; // baud rate counter
    logic [3:0] bit_cnt; // bit counter
    logic [8:0] rx_shift_reg; // Shift register
	logic shift, start, receiving, set_rdy;
	logic df1_RX, df2_RX;
	
	// Double flopped RX to address meta-stability
	always_ff @(posedge clk) begin
        if (!rst_n) begin	
            df1_RX <= 1'b1;
			df2_RX <= 1'b1;
        end else begin
            df1_RX <= RX;
			df2_RX <= df1_RX;
		end
    end
	
    // State Machine
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) 
            state <= IDLE;
        else
            state <= next_state;
    end

    // State transitions
    always_comb begin
	// default outputs
	start = 0;
	receiving = 0;
	set_rdy = 0;
	next_state = IDLE;
        case (state)
			IDLE: begin  // Idle state waiting for start bit (falling edge)	               
                if (!df2_RX) begin
					start = 1'b1;
                    next_state = RECEIVING;
                end 
            end
            RECEIVING: begin	// Receiving data bits state
                if (bit_cnt == 4'd10) begin 	// After stop bit is received
                    set_rdy = 1'b1;
                    next_state = IDLE;
                end else begin		// Continue receiving data
					receiving = 1'b1;
					next_state = RECEIVING;
				end
            end			
        endcase
    end
	
	// Shift register logic
    always_ff @(posedge clk, negedge rst_n) begin 
        if (shift) 
            rx_shift_reg <= {df2_RX,rx_shift_reg[8:1]};
    end 
	
	// Assign the lower 8 bits of the shift register to the output data
	assign rx_data = rx_shift_reg[7:0];

    // Baud rate counter
    always_ff @(posedge clk) begin
        if (start)		// Initialize baud counter for first data bit sampling
			baud_cnt <= 1301;	
		else if (shift) 	// Reload baud counter for subsequent bit sampling
			baud_cnt <= 2603;
		else if (receiving)
			baud_cnt <= baud_cnt - 1'b1; 
    end
	
	// Generate shift signal based on baud counter reaching zero
	assign shift = (baud_cnt == 6'h0); 

    // Bit counter logic
    always_ff @(posedge clk) begin
        if (start) begin
            bit_cnt <= 4'h0;
        end else if (shift) begin
            bit_cnt <= bit_cnt + 1'b1;
        end
    end
     
    // rdy logic
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            rdy <= 1'b0;
        else if (start || clr_rdy)	// On start bit detection or clear ready signal
            rdy <= 1'b0;
        else if (set_rdy)	// Data ready
            rdy <= 1'b1;
    end

endmodule