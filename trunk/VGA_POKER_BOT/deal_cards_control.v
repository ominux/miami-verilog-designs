module deal_player_cards(clk, rst, deal_cards, card, card_valid, next_card, players_cards, card_deal_done);
input clk, rst;
input [5:0]card;
input deal_cards;
input card_valid;
output next_card;
output [23:0]players_cards;
output card_deal_done;

reg card_deal_done;
reg next_card;
reg [23:0]players_cards;
reg [23:0]cards;

reg [2:0]S, NS;
parameter WAIT = 3'b000, CARD_R = 3'b001, CARD_A = 3'b010, DONE = 3'b011, WAIT_FOR_VALID_DOWN = 3'b111;
reg [2:0] cards_dealt;

always @(S or deal_cards or card_valid or cards_dealt)
begin
	case (S)
		WAIT:
		begin
			if (deal_cards == 1'b1)
			begin
				NS = CARD_R;
			end
			else
			begin
				NS = WAIT;
			end
		end
		CARD_R:
		begin
			if (card_valid == 1'b1)
			begin
				NS = CARD_A;
			end
			else
			begin
				NS = CARD_R;
			end
		end
		CARD_A:
		begin
			NS = WAIT_FOR_VALID_DOWN;
		end
		WAIT_FOR_VALID_DOWN:
		begin
			if (cards_dealt == 3'b100)
			begin 
				NS = DONE;
			end
			else if (card_valid == 1'b0)
			begin
				NS = CARD_R;
			end
			else
			begin
				NS = WAIT_FOR_VALID_DOWN;
			end
		end
		DONE:
		begin
			NS = WAIT;
		end
		default: NS = WAIT;
	endcase
end

/* control the S based on NS */
always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		S <= WAIT;
	end
	else
	begin
		S <= NS;
	end
end

/* Outputs */
always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		cards_dealt <= 3'b000;
		next_card <= 1'b0;
		players_cards <= 0;
		card_deal_done <= 1'b0;
	end
	else
	begin
		case (S)
			WAIT:
			begin
				cards_dealt <= 3'b000;
				next_card <= 1'b0;
				card_deal_done <= 1'b0;
				
				/* do the assignment out once all the cards are dealt */
				if (cards_dealt == 3'b100)
				begin
					players_cards <= cards;
				end
				else if (deal_cards == 1'b1)
				begin
					players_cards <= 0;
				end
			end
			CARD_R:
			begin
				cards_dealt <= cards_dealt;
				next_card <= 1'b1;
				players_cards <= 0;
				card_deal_done <= 1'b0;
			end
			CARD_A:
			begin
				cards_dealt <= cards_dealt + 1'b1;
				next_card <= 1'b0;
				players_cards <= 0;
				card_deal_done <= 1'b0;
				
				/* assign the cards into there spot */
				if (cards_dealt == 3'b000)
				begin
					cards[5:0] <= card;
				end
				else if (cards_dealt == 3'b001)
				begin
					cards[11:6] <= card;
				end
				else if (cards_dealt == 3'b010)
				begin
					cards[17:12] <= card;
				end
				else if (cards_dealt == 3'b011)
				begin
					cards[23:18] <= card;
				end
			end
			WAIT_FOR_VALID_DOWN:
			begin
				cards_dealt <= cards_dealt;
				next_card <= 1'b0;
				players_cards <= 0;
				card_deal_done <= 1'b0;
			end
			DONE:
			begin
				card_deal_done <= 1'b1;
			end
		endcase
	end
end
endmodule

module deal_a_card(clk, rst, deal_cards, card, card_valid, next_card, players_cards, card_deal_done);
input clk, rst;
input [5:0]card;
input deal_cards;
input card_valid;
output next_card;
output [5:0]players_cards;
output card_deal_done;

reg card_deal_done;
reg next_card;
reg [5:0]players_cards;
reg [5:0]cards;

reg [2:0]S, NS;
parameter WAIT = 3'b000, CARD_R = 3'b001, CARD_A = 3'b010, DONE = 3'b011, WAIT_FOR_VALID_DOWN = 3'b111;
reg [2:0] cards_dealt;

always @(S or deal_cards or card_valid or cards_dealt)
begin
	case (S)
		WAIT:
		begin
			if (deal_cards == 1'b1)
			begin
				NS = CARD_R;
			end
			else
			begin
				NS = WAIT;
			end
		end
		CARD_R:
		begin
			if (card_valid == 1'b1)
			begin
				NS = CARD_A;
			end
			else
			begin
				NS = CARD_R;
			end
		end
		CARD_A:
		begin
			NS = WAIT_FOR_VALID_DOWN;
		end
		WAIT_FOR_VALID_DOWN:
		begin
			if (cards_dealt == 3'b001)
			begin 
				NS = DONE;
			end
			else if (card_valid == 1'b0)
			begin
				NS = CARD_R;
			end
			else
			begin
				NS = WAIT_FOR_VALID_DOWN;
			end
		end
		DONE:
		begin
			NS = WAIT;
		end
		default: NS = WAIT;
	endcase
end

/* control the S based on NS */
always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		S <= WAIT;
	end
	else
	begin
		S <= NS;
	end
end

/* Outputs */
always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		cards_dealt <= 3'b000;
		next_card <= 1'b0;
		players_cards <= 0;
		card_deal_done <= 1'b0;
	end
	else
	begin
		case (S)
			WAIT:
			begin
				cards_dealt <= 3'b000;
				next_card <= 1'b0;
				card_deal_done <= 1'b0;
				
				/* do the assignment out once all the cards are dealt */
				if (cards_dealt == 3'b001)
				begin
					players_cards <= cards;
				end
				else if (deal_cards == 1'b1)
				begin
					players_cards <= 0;
				end
			end
			CARD_R:
			begin
				cards_dealt <= cards_dealt;
				next_card <= 1'b1;
				players_cards <= 0;
				card_deal_done <= 1'b0;
			end
			CARD_A:
			begin
				cards_dealt <= cards_dealt + 1'b1;
				next_card <= 1'b0;
				players_cards <= 0;
				card_deal_done <= 1'b0;
				
				/* assign the cards into there spot */
				if (cards_dealt == 3'b000)
				begin
					cards[5:0] <= card;
				end
				
			end
			WAIT_FOR_VALID_DOWN:
			begin
				cards_dealt <= cards_dealt;
				next_card <= 1'b0;
				players_cards <= 0;
				card_deal_done <= 1'b0;
			end
			DONE:
			begin
				card_deal_done <= 1'b1;
			end
		endcase
	end
end
endmodule

module deal_flop(clk, rst, deal_cards, card, card_valid, next_card, players_cards, card_deal_done);
input clk, rst;
input [5:0]card;
input deal_cards;
input card_valid;
output next_card;
output [17:0]players_cards;
output card_deal_done;

reg card_deal_done;
reg next_card;
reg [17:0]players_cards;
reg [17:0]cards;

reg [2:0]S, NS;
parameter WAIT = 3'b000, CARD_R = 3'b001, CARD_A = 3'b010, DONE = 3'b011, WAIT_FOR_VALID_DOWN = 3'b111;
reg [2:0] cards_dealt;

always @(S or deal_cards or card_valid or cards_dealt)
begin
	case (S)
		WAIT:
		begin
			if (deal_cards == 1'b1)
			begin
				NS = CARD_R;
			end
			else
			begin
				NS = WAIT;
			end
		end
		CARD_R:
		begin
			if (card_valid == 1'b1)
			begin
				NS = CARD_A;
			end
			else
			begin
				NS = CARD_R;
			end
		end
		CARD_A:
		begin
			NS = WAIT_FOR_VALID_DOWN;
		end
		WAIT_FOR_VALID_DOWN:
		begin
			if (cards_dealt == 3'b011)
			begin 
				NS = DONE;
			end
			else if (card_valid == 1'b0)
			begin
				NS = CARD_R;
			end
			else
			begin
				NS = WAIT_FOR_VALID_DOWN;
			end
		end
		DONE:
		begin
			NS = WAIT;
		end
		default: NS = WAIT;
	endcase
end

/* control the S based on NS */
always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		S <= WAIT;
	end
	else
	begin
		S <= NS;
	end
end

/* Outputs */
always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		cards_dealt <= 3'b000;
		next_card <= 1'b0;
		players_cards <= 0;
		card_deal_done <= 1'b0;
	end
	else
	begin
		case (S)
			WAIT:
			begin
				cards_dealt <= 3'b000;
				next_card <= 1'b0;
				card_deal_done <= 1'b0;
				
				/* do the assignment out once all the cards are dealt */
				if (cards_dealt == 3'b011)
				begin
					players_cards <= cards;
				end
				else if (deal_cards == 1'b1)
				begin
					players_cards <= 0;
				end
			end
			CARD_R:
			begin
				cards_dealt <= cards_dealt;
				next_card <= 1'b1;
				players_cards <= 0;
				card_deal_done <= 1'b0;
			end
			CARD_A:
			begin
				cards_dealt <= cards_dealt + 1'b1;
				next_card <= 1'b0;
				players_cards <= 0;
				card_deal_done <= 1'b0;
				
				/* assign the cards into there spot */
				if (cards_dealt == 3'b000)
				begin
					cards[5:0] <= card;
				end
				else if (cards_dealt == 3'b001)
				begin
					cards[11:6] <= card;
				end
				else if (cards_dealt == 3'b010)
				begin
					cards[17:12] <= card;
				end
				
			end
			WAIT_FOR_VALID_DOWN:
			begin
				cards_dealt <= cards_dealt;
				next_card <= 1'b0;
				players_cards <= 0;
				card_deal_done <= 1'b0;
			end
			DONE:
			begin
				card_deal_done <= 1'b1;
			end
		endcase
	end
end
endmodule

