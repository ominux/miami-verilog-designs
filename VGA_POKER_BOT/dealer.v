/*-----------------------------------------------------------
-------------------------------------------------------------
dealer
Top of the dealer.  Responsible for the banks of both players,
dealing cards, deciding who wins, and getting players actions. 
-------------------------------------------------------------
-----------------------------------------------------------*/
module dealer(
clk, rst,
players_input,
players_money,
player_input_valid,
next_hand,
next_hand_user,
hand_done,
acknowledge_accepted_player_input,
P1C1, P1C2, P2C1, P2C2,
flop,
turn, river,
request_for_player_input,
invalid_action,
actions_from_last_betting_round,
money_bet_from_last_betting_round,
betting_done,
pot_size,
players_bank2,
players_bank1,
game_over,
change_in_screen,
debug_info
);

input clk, rst;
input [5:0]players_input; // 000 = fold, 001 = bet, 010 = all in, 011 = check, 100 = raise, 101 = 
input [15:0]players_money; // Max of 256 units of betting
input [1:0]player_input_valid; // valid signals for when players have sent their action

output [5:0]P1C1, P1C2, P2C1, P2C2; // Cards encoded 2 bits for suit 00 = Spade, 01 = Club, 10 = Hearts, 11 = Diamonds and 4 bits for value.  Note 000000 = no card
output [17:0]flop;
output [5:0]turn, river;

output [1:0]acknowledge_accepted_player_input; // response valid signals to players when their input is accepted
output [1:0]request_for_player_input; // request the player for action
output [1:0]invalid_action; // a response if the action is illegal

output [7:0]pot_size; // size of the pot
output [7:0]players_bank1; // the output of the banks
output [7:0]players_bank2; // the output of the banks
reg [7:0]players_bank1; // the output of the banks
reg [7:0]players_bank2; // the output of the banks
input next_hand; // tells players when the next hand happens
input next_hand_user; // tells players when the next hand happens
output hand_done; // tells the top level when a hand is done
reg hand_done; 

output [5:0]actions_from_last_betting_round; // Record of actions from the round
output [15:0]money_bet_from_last_betting_round; // Record of bets
output betting_done; // signal from machine when the round is done

input game_over; // tells the dealer if the game is over

output change_in_screen;
reg change_in_screen;

output [5:0]debug_info;
wire [5:0]debug_info;
assign debug_info = {S};

wire [1:0]waiting_for_request;
reg [1:0]get_player_input;

reg [1:0]dealer_player;
reg [1:0]other_player;

reg signal_new_hand; // control signal to get a new hand dealt
wire deck_shuffled; // tells the dealer when the hand is shuffled
wire [5:0]card; // a card coming out from the deal
wire card_valid; // indicates when the card is valid
// Deal a card when asked
card_deal instance_deal(clk, rst, signal_new_hand, deck_shuffled, next_cards, card, card_valid);

// tells the deal to generate a card depending on one of the possible cards
wire next_cards;
wire next_card_p;
wire next_card_r;
wire next_card_t;
wire next_card_f;
assign next_cards = next_card_p | next_card_f | next_card_t | next_card_r;

// control signal for state machine to indicate when the card is dealt
wire cards_dealt;
wire cards_dealt_p;
wire cards_dealt_t;
wire cards_dealt_r;
wire cards_dealt_f;
assign cards_dealt = cards_dealt_p | cards_dealt_t | cards_dealt_r | cards_dealt_f;

// deal a type of card control signals
reg deal_cards_p;
reg deal_cards_r;
reg deal_cards_t;
reg deal_cards_f;
// Deal the different type of cards into the appropriate spot
deal_player_cards pcards(clk, (deck_shuffled), deal_cards_p, card, card_valid, next_card_p, {P1C1, P1C2, P2C1, P2C2}, cards_dealt_p);
deal_a_card turnca(clk, (deck_shuffled), deal_cards_t, card, card_valid, next_card_t, turn, cards_dealt_t);
deal_a_card riverca(clk, (deck_shuffled), deal_cards_r, card, card_valid, next_card_r, river, cards_dealt_r);
deal_flop flopca(clk, (deck_shuffled), deal_cards_f, card, card_valid, next_card_f, flop, cards_dealt_f);

reg get_bets_for_players; // signal generated here to tell bet getter to get bets from players
reg [3:0]last_to_act_idx; // information of who is the last person to act
wire [5:0]actions_from_last_betting_round;
wire [15:0]money_bet_from_last_betting_round;
wire betting_done; // signal from machine when the round is done
reg first_round;
valid_move betting(clk, rst, get_bets_for_players, first_round, players_input, players_money, player_input_valid, request_for_player_input, acknowledge_accepted_player_input, invalid_action, {players_bank2, players_bank1}, last_to_act_idx, actions_from_last_betting_round, money_bet_from_last_betting_round, betting_done);

wire [1:0]who_wins; // the winner for the hand
wire checked; // indicates that the winner has been checked
wire winner_done; // indicates that there is a winner
reg check_for_winner; // signal to aks chwck winner machine to run
check_winner winner_decider(clk, rst, check_for_winner, P1C1, P1C2, P2C1, P2C2, flop, turn, river, checked, winner_done, actions_from_last_betting_round, who_wins);

reg [7:0]pot_size;
reg [8:0]player1_change, player2_change;
reg bank_change;
// always statement controls bank updates with player changes.  The MSb of player_changes tells to subtract or add
always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		players_bank1 <= 8'b01000000;
		players_bank2 <= 8'b01000000;
	end
	else if (game_over == 1'b1)
	begin
		players_bank1 <= 8'b01000000;
		players_bank2 <= 8'b01000000;
	end
	else
	begin
		if (bank_change == 1'b1)
		begin
			if (player1_change[8] == 1'b1)
			begin
				if (players_bank1 > player1_change[7:0])
				begin
					players_bank1 <= players_bank1 - player1_change[7:0];
				end
				else
				begin
					players_bank1 <= 8'b00000000;
				end
			end
			else
			begin
				players_bank1 <= players_bank1 + player1_change[7:0];
			end

			if (player2_change[8] == 1'b1)
			begin
				if (players_bank2 > player2_change[7:0])
				begin
					players_bank2 <= players_bank2 - player2_change[7:0];
				end
				else
				begin
					players_bank2 <= 8'b00000000;
				end
			end
			else
			begin
				players_bank2 <= players_bank2 + player2_change[7:0];
			end
		end	
	end
end

reg [5:0]S, NS;
parameter WAIT = 6'b000000,
S_NEXT_HAND = 6'b000001,
NEXT_HAND_2 = 6'b000010, 
DEAL_PLAYERS = 6'b000011,
DEAL_PLAYERS_2 = 6'b000100, 
S_FLOP = 6'b000101,
FLOP_2 = 6'b000110, 
S_TURN = 6'b000111,
TURN_2 = 6'b001000, 
S_RIVER = 6'b001001,
RIVER_2 = 6'b001010,
ACCEPT_BETS1 = 6'b001011,
ACCEPT_BETS2 = 6'b001100,
ACCEPT_BETS3 = 6'b001101,
ACCEPT_BETS4 = 6'b001110,
CHECK_WINNER1_1 = 6'b001111,
CHECK_WINNER2_1 = 6'b010000,
CHECK_WINNER3_1 = 6'b010001,
CHECK_WINNER4_1 = 6'b010010,
ACCEPT_BETS1_2 = 6'b010011,
ACCEPT_BETS2_2 = 6'b010100,
ACCEPT_BETS3_2 = 6'b010101,
ACCEPT_BETS4_2 = 6'b010110,
ACCEPT_BETS1_3 = 6'b010111,
ACCEPT_BETS2_3 = 6'b011000,
ACCEPT_BETS3_3 = 6'b011001,
ACCEPT_BETS4_3 = 6'b011010,
CHECK_WINNER1_0 = 6'b011011,
CHECK_WINNER2_0 = 6'b011100,
CHECK_WINNER3_0 = 6'b011101,
CHECK_WINNER4_0 = 6'b011110,
UPDATE_RESULTS = 6'b011111;

parameter 
PLAYER1 = 2'b01,
PLAYER2 = 2'b10,
NOTHING = 2'b00,
DRAW = 2'b11;

// state machine that controls all the actions that the dealer does
always @(S or next_hand or deck_shuffled or cards_dealt or winner_done or betting_done or checked)
begin
	case (S)
		WAIT:
		begin
			if (next_hand == 1'b1)
			begin
				NS = S_NEXT_HAND;
			end
			else
			begin
				NS = WAIT;
			end
		end
		S_NEXT_HAND:
		begin
			NS = NEXT_HAND_2;
		end
		NEXT_HAND_2:
		begin
			if (deck_shuffled == 1'b1)
			begin
				NS = DEAL_PLAYERS;
			end
			else
			begin
				NS = NEXT_HAND_2;
			end
		end
		DEAL_PLAYERS:
		begin
			NS = DEAL_PLAYERS_2;
		end
		DEAL_PLAYERS_2:
		begin
			if (cards_dealt == 1'b1)
			begin
				NS = ACCEPT_BETS1;
			end
			else
			begin
				NS = DEAL_PLAYERS_2;
			end
		end
		ACCEPT_BETS1:
		begin
			NS = ACCEPT_BETS1_2;
		end
		ACCEPT_BETS1_2:
		begin
			if (betting_done == 1'b1)
			begin
				NS = ACCEPT_BETS1_3;
			end
			else
			begin
				NS = ACCEPT_BETS1_2;
			end
		end
		ACCEPT_BETS1_3:
		begin
			NS = CHECK_WINNER1_0;
		end
		CHECK_WINNER1_0:
		begin
			NS = CHECK_WINNER1_1;
		end
		CHECK_WINNER1_1:
		begin
			if (winner_done == 1'b1)
			begin
				NS = UPDATE_RESULTS;
			end
			else if (checked == 1'b1)
			begin
				NS = S_FLOP;
			end
			else
			begin
				NS = CHECK_WINNER1_1;
			end
		end

		S_FLOP:
		begin
			NS = FLOP_2;
		end
		FLOP_2:
		begin
			if (cards_dealt == 1'b1)
			begin
				NS = ACCEPT_BETS2;
			end
			else
			begin
				NS = FLOP_2;
			end
		end
		ACCEPT_BETS2:
		begin
			NS = ACCEPT_BETS2_2;
		end
		ACCEPT_BETS2_2:
		begin
			if (betting_done == 1'b1)
			begin
				NS = ACCEPT_BETS2_3;
			end
			else
			begin
				NS = ACCEPT_BETS2_2;
			end
		end
		ACCEPT_BETS2_3:
		begin
			NS = CHECK_WINNER2_0;
		end
		CHECK_WINNER2_0:
		begin
			NS = CHECK_WINNER2_1;
		end
		CHECK_WINNER2_1:
		begin
			if (winner_done == 1'b1)
			begin
				NS = UPDATE_RESULTS;
			end
			else if (checked == 1'b1)
			begin
				NS = S_TURN;
			end
			else
			begin
				NS = CHECK_WINNER2_1;
			end
		end
		S_TURN:
		begin
			NS = TURN_2;
		end
		TURN_2:
		begin
			if (cards_dealt == 1'b1)
			begin
				NS = ACCEPT_BETS3;
			end
			else
			begin
				NS = TURN_2;
			end
		end
		ACCEPT_BETS3:
		begin
			NS = ACCEPT_BETS3_2;
		end
		ACCEPT_BETS3_2:
		begin
			if (betting_done == 1'b1)
			begin
				NS = ACCEPT_BETS3_3;
			end
			else
			begin
				NS = ACCEPT_BETS3_2;
			end
		end
		ACCEPT_BETS3_3:
		begin
			NS = CHECK_WINNER3_0;
		end
		CHECK_WINNER3_0:
		begin
			NS = CHECK_WINNER3_1;
		end
		CHECK_WINNER3_1:
		begin
			if (winner_done == 1'b1)
			begin
				NS = UPDATE_RESULTS;
			end
			else if (checked == 1'b1)
			begin
				NS = S_RIVER;
			end
			else
			begin
				NS = CHECK_WINNER3_1;
			end
		end
		S_RIVER:
		begin
			NS = RIVER_2;
		end
		RIVER_2:
		begin
			if (cards_dealt == 1'b1)
			begin
				NS = ACCEPT_BETS4;
			end
			else
			begin
				NS = RIVER_2;
			end
		end
		ACCEPT_BETS4:
		begin
			NS = ACCEPT_BETS4_2;
		end
		ACCEPT_BETS4_2:
		begin
			if (betting_done == 1'b1)
			begin
				NS = ACCEPT_BETS4_3;
			end
			else
			begin
				NS = ACCEPT_BETS4_2;
			end
		end
		ACCEPT_BETS4_3:
		begin
			NS = CHECK_WINNER4_0;
		end
		CHECK_WINNER4_0:
		begin
			NS = CHECK_WINNER4_1;
		end
		CHECK_WINNER4_1:
		begin
			if (winner_done == 1'b1)
			begin
				NS = UPDATE_RESULTS;
			end
			else if (checked == 1'b1)
			begin
				NS = UPDATE_RESULTS;
			end
			else
			begin
				NS = CHECK_WINNER4_1;
			end
		end
		UPDATE_RESULTS:
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
		signal_new_hand <= 1'b0;
		get_bets_for_players <= 1'b0;
		deal_cards_p <= 1'b0;
		deal_cards_f <= 1'b0;
		deal_cards_t <= 1'b0;
		deal_cards_r <= 1'b0;
		first_round <= 1'b0;
		last_to_act_idx <= 4'b0000;
		check_for_winner <= 1'b0;
		bank_change <= 1'b0;
		pot_size <= 8'b00000000;
		hand_done <= 1'b0;
		dealer_player <= 2'b00;
		other_player <= 2'b01;
		change_in_screen <= 1'b0;
	end
	else
	begin
		case (S)
			WAIT:
			begin
				signal_new_hand <= 1'b1;
				check_for_winner <= 1'b0;
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;

				pot_size <= 8'b00000000;
			end
			S_NEXT_HAND:
			begin
				signal_new_hand <= 1'b1; // asks for the shuffle
				check_for_winner <= 1'b0;
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;

				/* switch the dealer and other player for the next hand */
				if (dealer_player == 2'b00)
				begin
					dealer_player <= 2'b01;
					other_player <= 2'b00;
				end
				else
				begin
					dealer_player <= 2'b00;
					other_player <= 2'b01;
				end
			end
			NEXT_HAND_2:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;
			end
			DEAL_PLAYERS:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b1; // deal the player cards
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;
			end
			DEAL_PLAYERS_2:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;
			end
			ACCEPT_BETS1:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b1; // get bets
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b1; // indicate that this is the first round so big and small blinds involved
				change_in_screen <= 1'b0;
				
				// dealer is now last to act
				last_to_act_idx <= other_player;
			end
			ACCEPT_BETS1_2:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b1; 
				change_in_screen <= 1'b0;
			end
			ACCEPT_BETS1_3:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b1; // indicate a bank update needs to be done (pulse)
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;

				// store bets and take money
				player1_change <= {1'b1, money_bet_from_last_betting_round[7:0]};
				player2_change <= {1'b1, money_bet_from_last_betting_round[15:8]};
				pot_size <= pot_size +  money_bet_from_last_betting_round[7:0] + money_bet_from_last_betting_round[15:8];
			end
			CHECK_WINNER1_0:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b1; // check for winner
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;
			end
			CHECK_WINNER1_1:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;
			end
			S_FLOP:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b1; // deal flop
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;
			end
			FLOP_2:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;
			end
			ACCEPT_BETS2:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b1; // get bets
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;

				// dealer is now last to act
				last_to_act_idx <= dealer_player;
			end
			ACCEPT_BETS2_2:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;
			end
			ACCEPT_BETS2_3:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b1; // bank change (pulse)
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;

				// store bets and take money
				player1_change <= {1'b1, money_bet_from_last_betting_round[7:0]};
				player2_change <= {1'b1, money_bet_from_last_betting_round[15:8]};
				pot_size <= pot_size +  money_bet_from_last_betting_round[7:0] + money_bet_from_last_betting_round[15:8];
			end
			CHECK_WINNER2_0:
			begin
				signal_new_hand <= 1'b0;
				get_bets_for_players <= 1'b0;
				check_for_winner <= 1'b1; // check for winner
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;
			end
			CHECK_WINNER2_1:
			begin
				signal_new_hand <= 1'b0;
				get_bets_for_players <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;
			end
			S_TURN:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b1; // deal turn
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;
			end
			TURN_2:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;
			end
			ACCEPT_BETS3:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b1; // get bets
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;
			end
			ACCEPT_BETS3_2:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;
			end
			ACCEPT_BETS3_3:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b1; // bank change
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;

				// store bets and take money
				player1_change <= {1'b1, money_bet_from_last_betting_round[7:0]};
				player2_change <= {1'b1, money_bet_from_last_betting_round[15:8]};
				pot_size <= pot_size +  money_bet_from_last_betting_round[7:0] + money_bet_from_last_betting_round[15:8];
			end
			CHECK_WINNER3_0:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b1; // check for winner
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;
			end
			CHECK_WINNER3_1:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;
			end
			S_RIVER:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b1; // deal river
				first_round <= 1'b0;
				change_in_screen <= 1'b0;
			end
			RIVER_2:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;
			end
			ACCEPT_BETS4:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b1; // get bets
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;
			end
			ACCEPT_BETS4_2:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;
			end
			ACCEPT_BETS4_3:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b1; // bank change
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;

				// store bets and take money
				player1_change <= {1'b1, money_bet_from_last_betting_round[7:0]};
				player2_change <= {1'b1, money_bet_from_last_betting_round[15:8]};
				pot_size <= pot_size +  money_bet_from_last_betting_round[7:0] + money_bet_from_last_betting_round[15:8];
			end
			CHECK_WINNER4_0:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b1; // check for winner
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;
			end
			CHECK_WINNER4_1:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b0;
				hand_done <= 1'b0;
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b0;
			end
			UPDATE_RESULTS:
			begin
				signal_new_hand <= 1'b0;
				check_for_winner <= 1'b0;
				bank_change <= 1'b1; // bank change
				hand_done <= 1'b1; // hand finished
				get_bets_for_players <= 1'b0;
				deal_cards_p <= 1'b0;
				deal_cards_f <= 1'b0;
				deal_cards_t <= 1'b0;
				deal_cards_r <= 1'b0;
				first_round <= 1'b0;
				change_in_screen <= 1'b1;

				// who wins and how it affects the bank
				if (who_wins == PLAYER1)
				begin
					player1_change <= {1'b0, pot_size};
					player2_change <= 9'b000000000;
				end
				else if (who_wins == PLAYER2)
				begin
					player2_change <= {1'b0, pot_size};
					player1_change <= 9'b000000000;
				end
				else 
				begin
					// split the pot
					player1_change <= {1'b0, (pot_size >> 1)};
					player2_change <= {1'b0, (pot_size >> 1)};
				end
			end
		endcase
	end
end
endmodule