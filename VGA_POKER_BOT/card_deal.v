/*-----------------------------------------------------------
-------------------------------------------------------------
card_deal
This is the card deal module that shuffles using a swap method
and then can deal out a signal card from the deck when requested
-------------------------------------------------------------
-----------------------------------------------------------*/
module card_deal (clk, rst, new_hand, shuffled, next_card, card, card_valid);
input clk, rst;
input new_hand; // request the reshuffle
input next_card; // request for next card
output shuffled; // signal when the deck is shuffled
output [5:0] card; // the card dealt
output card_valid; // goes high when the output card is available

reg [5:0]cards[51:0]; // the deck
reg shuffled;
reg [7:0]count_swaps; // max shuffles = 256 for 8 bits
wire [5:0]rand_value; // rand_value should be capped at 51...

reg [1:0] S, NS;
parameter 
SHUFFLE = 2'b00, 
WAIT_FOR_REQUEST = 2'b01, 
DEAL_CARD = 2'b10, 
WAIT_FOR_REQUEST_TO_STOP_ASKING = 2'b11;		

reg card_valid;
reg [5:0]current_card; // max 52
reg [5:0]card;
reg [5:0]next_deal_card; // holds the next to deal card

// Do the shuffling by swaps...when done shuffled will go high to indicate shuffle complete
always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		shuffled <= 1'b0;
		count_swaps <= 1'b0;
	end
	else
	begin
		if (new_hand == 1'b1)
		begin
			cards[0] <= 6'b000010;		// Spades, 2
			cards[1] <= 6'b000011;
			cards[2] <= 6'b000100;
			cards[3] <= 6'b000101;
			cards[4] <= 6'b000110;
			cards[5] <= 6'b000111;
			cards[6] <= 6'b001000;
			cards[7] <= 6'b001001;
			cards[8] <= 6'b001010;		// Spades, 10
			cards[9] <= 6'b001011;		// Spades, J
			cards[10] <= 6'b001100;		// Spades, Q
			cards[11] <= 6'b001101;		// Spades, K
			cards[12] <= 6'b001110;		// Spades, A
			cards[13] <= 6'b010010;
			cards[14] <= 6'b010011;
			cards[15] <= 6'b010100;
			cards[16] <= 6'b010101;
			cards[17] <= 6'b010110;
			cards[18] <= 6'b010111;
			cards[19] <= 6'b011000;
			cards[20] <= 6'b011001;
			cards[21] <= 6'b011010;
			cards[22] <= 6'b011011;
			cards[23] <= 6'b011100;
			cards[24] <= 6'b011101;
			cards[25] <= 6'b011110;		// Clubs, A
			cards[26] <= 6'b100010;
			cards[27] <= 6'b100011;
			cards[28] <= 6'b100100;
			cards[29] <= 6'b100101;
			cards[30] <= 6'b100110;
			cards[31] <= 6'b100111;
			cards[32] <= 6'b101000;
			cards[33] <= 6'b101001;
			cards[34] <= 6'b101010;
			cards[35] <= 6'b101011;
			cards[36] <= 6'b101100;
			cards[37] <= 6'b101101;
			cards[38] <= 6'b101110;		// Diamonds, A
			cards[39] <= 6'b110010;
			cards[40] <= 6'b110011;
			cards[41] <= 6'b110100;
			cards[42] <= 6'b110101;
			cards[43] <= 6'b110110;
			cards[44] <= 6'b110111;
			cards[45] <= 6'b111000;
			cards[46] <= 6'b111001;
			cards[47] <= 6'b111010;
			cards[48] <= 6'b111011;
			cards[49] <= 6'b111100;
			cards[50] <= 6'b111101;
			cards[51] <= 6'b111110;		// Hearts, A
			
			shuffled <= 1'b0;
			count_swaps <= 1'b0;
		end
		else if (shuffled == 1'b0)
		begin
			/* count each swap */
			count_swaps <= count_swaps + 1'b1;
			
			/* do the swap... */
			cards[rand_value] <= cards[0];
			cards[0] <= cards[rand_value];
			
			/* if shuffled */
			if (count_swaps == 100)
			begin
				shuffled <= 1'b1;
			end
			else
			begin
				shuffled <= 1'b0;
			end
		end
	end
end
	
// get the random number to pick for swaps 
rand_number_max_51 instance1(clk, rst, rand_value);
	
// handle the interactions between the card giver and the requester (external module)

// State tranisitions for 4 states which all go to shuffle if new_hand is set
always @(shuffled or next_card or S or new_hand)
begin
	case (S)
		SHUFFLE: 
		begin
			if (new_hand == 1'b1)
			begin
				NS = SHUFFLE;
			end
			else if (shuffled == 1'b1)
			begin
				NS = WAIT_FOR_REQUEST;
			end
			else
			begin
				NS = SHUFFLE;
			end
		end
		WAIT_FOR_REQUEST: 
		begin
			if (new_hand == 1'b1)
			begin
				NS = SHUFFLE;
			end
			else if (next_card == 1'b1)
			begin
				NS = DEAL_CARD;
			end
			else
			begin
				NS = WAIT_FOR_REQUEST;
			end
		end
		DEAL_CARD: 
		begin
			if (new_hand == 1'b1)
			begin
				NS = SHUFFLE;
			end
			else if (next_card == 1'b1)
			begin
				NS = WAIT_FOR_REQUEST_TO_STOP_ASKING;
			end
			else
			begin
				NS = WAIT_FOR_REQUEST;
			end
		end
		WAIT_FOR_REQUEST_TO_STOP_ASKING:
		begin
			if (new_hand == 1'b1)
			begin
				NS = SHUFFLE;
			end
			else if (next_card == 1'b1)
			begin
				NS = WAIT_FOR_REQUEST_TO_STOP_ASKING;
			end
			else
			begin
				NS = WAIT_FOR_REQUEST;
			end
		end
		default: NS = WAIT_FOR_REQUEST;
	endcase
end

/* control the S based on NS */
always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		S <= SHUFFLE;
	end
	else
	begin
		S <= NS;
	end
end

/* control the outputs and internal variables to send out card, control next card to deal */
always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		card_valid <= 1'b0;
		current_card <= 6'b000000;
		card <= 6'b000000;
		next_deal_card <= 6'b000000;
	end
	else
	begin
		case (S)
			// similar to reset, but needed for when the new hand request happens
			SHUFFLE: 
			begin
				card_valid <= 1'b0;
				current_card <= 6'b000000;
				card <= 6'b000000;
				next_deal_card <= 6'b000000;
			end
			// waits for a request for next card and has the next_deal_card ready
			WAIT_FOR_REQUEST: 
			begin
				card_valid <= 1'b0;
				current_card <= current_card;
				card <= card;
				next_deal_card <= cards[current_card];
			end
			// increments the current_card, deals the next_deal into card, and sets card_valid = 1
			DEAL_CARD: 
			begin
				card_valid <= 1'b1;
				current_card <= current_card + 6'b000001;
				card <= next_deal_card;
				next_deal_card <= next_deal_card;
			end
			// requester is still sending a request for a card and hasn't ended there request, so keep card valid = 1
			WAIT_FOR_REQUEST_TO_STOP_ASKING:
			begin
				card_valid <= 1'b1;
				current_card <= current_card;
				card <= card;
				next_deal_card <= cards[current_card];
			end
		endcase
	end
end	
	
endmodule

/*-----------------------------------------------------------
-------------------------------------------------------------
rand_number_max_51
This a randome number module that guarantees the number is no greater than 51.  Note, this is not the best way to do it...Why? 
-------------------------------------------------------------
-----------------------------------------------------------*/
module rand_number_max_51(clk, rst, rand_out);
input clk, rst;
output [5:0] rand_out;

reg [5:0] rand_out;
wire [5:0] current_rand;

lfsr_6bit_output instance1(clk, rst, current_rand);

always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		rand_out <= 6'b000000;
	end
	else
	begin
		if (current_rand > 51)
		begin
			rand_out <= {1'b0, current_rand[4:0]};
		end
		else
		begin
			rand_out <= current_rand;
		end
	end
end
	
endmodule

/*-----------------------------------------------------------
-------------------------------------------------------------
lfsr_6bit_output
Linear shift feedback register for random numbers...it's not the same as the one in class ? 
-------------------------------------------------------------
-----------------------------------------------------------*/
module lfsr_6bit_output(clk, rst, out);
input clk, rst;
output [5:0] out;

wire [5:0] out;

reg [31:0] lfsr_register;

assign out = {lfsr_register[5],lfsr_register[4],lfsr_register[3],lfsr_register[2],lfsr_register[1],lfsr_register[0]};

always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		lfsr_register <= 32'heb53fd15; // Seed for random number
	end
	else
	begin
		lfsr_register <= 
		{lfsr_register[30],
		lfsr_register[29],
		lfsr_register[28],
		lfsr_register[27], 
		lfsr_register[26],
		lfsr_register[25],
		lfsr_register[24],
		lfsr_register[23],
		lfsr_register[22],
		lfsr_register[21],
		lfsr_register[20],
		lfsr_register[19],
		lfsr_register[18],
		lfsr_register[17], 
		lfsr_register[16],
		lfsr_register[15],
		lfsr_register[14],
		lfsr_register[13],
		lfsr_register[12],
		lfsr_register[11],
		lfsr_register[10],
		lfsr_register[9],
		lfsr_register[8],
		lfsr_register[7],
		lfsr_register[6],
		lfsr_register[5],
		lfsr_register[4],
		lfsr_register[3],
		lfsr_register[2],
		lfsr_register[1],
		lfsr_register[0],
		lfsr_register[31] ^ lfsr_register[30] ^ lfsr_register[12] ^ lfsr_register[7]};
	end
end

endmodule
