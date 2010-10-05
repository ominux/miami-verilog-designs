/*-----------------------------------------------------------
-------------------------------------------------------------
valid_move
Takes in players inputs for bets and validates the action
-------------------------------------------------------------
-----------------------------------------------------------*/
module valid_move(
clk, 
rst, 
get_bets_for_players,
first_round,
players_input,
players_money,
player_valid_input,
request_for_player_input,
acknowledge_player_accepted_input,
accepted_action,
players_banks,
last_to_act_idx, 
actions,
money_bet,
betting_done
);

parameter NUM_PLAYERS = 2'b10;

input clk, rst;
input get_bets_for_players; // input to tell this machine to work
input first_round; // special case for first round when need to deal with blinds

input [5:0]players_input; // what type of action they would like to make
input [15:0]players_money; // how much there bet is for
input [1:0]player_valid_input; // states when they want to try an action
output [1:0]request_for_player_input; // asks a player for action
output [1:0]acknowledge_player_accepted_input; // tells player when the action has been recorded but not if its valid;

output [1:0]accepted_action; // indicator to player if there last attempt was valid ... goes high if action unnacepeted

input [15:0]players_banks;

input [3:0]last_to_act_idx; // changes depending on stage

output [5:0]actions; // actions of all the players
output [15:0]money_bet; // money bet in the end of the round

output betting_done; // signal to indicate when done

reg betting_done; // tells that the round of betting is done

reg [1:0]accepted_action; // indicator to player if there last attempt was valid

reg [5:0]actions;
reg [15:0]money_bet;
reg checked;

wire [2:0]player1_input;
wire [2:0]player2_input;
wire [7:0]player1_money;
wire [7:0]player2_money;

reg [1:0]is_valid_action;

reg [3:0]current_player_spot;
reg [3:0]player_count;

reg [2:0] last_action;
reg [2:0] action;
reg [7:0] money;
reg [7:0] last_money;


reg [1:0] get_player_input;
/* controllers to send all the signals for handshaking with players requests */
/* P1 */
receive_player_input player1(clk, rst, get_player_input[0], players_input[2:0], 
players_money[7:0], player_valid_input[0], request_for_player_input[0], acknowledge_player_accepted_input[0], 
player1_input, player1_money);
/* P2 */
receive_player_input player2(clk, rst, get_player_input[1], players_input[5:3], 
players_money[15:8], player_valid_input[1], request_for_player_input[1], acknowledge_player_accepted_input[1], 
player2_input, player2_money);

reg [2:0]S, NS;
parameter
WAIT = 3'b000,
INITIALIZE = 3'b001,
GET_INPUT = 3'b010,
VALID_INPUT = 3'b011,
NEXT_PLAYER = 3'b100,
STORE_INPUT = 3'b101,
S_FIX_BETS = 3'b110,
S_BETTING_DONE = 3'b111;

parameter // Note 000 reserved for no action
NO_ACTION = 3'b000,
FOLD = 3'b001,
CHECK = 3'b010,
BET = 3'b110,
RAISE = 3'b111,
ALL_IN = 3'b011,
CALL = 3'b100;

parameter 
VALID = 2'b10,
INVALID = 2'b01,
RESET_V = 2'b00;

always @(S or get_bets_for_players or acknowledge_player_accepted_input or is_valid_action or player_count or current_player_spot or last_action)
begin
	case (S)
		WAIT:
		begin
			if (get_bets_for_players == 1'b1)
			begin
				NS = INITIALIZE;
			end
			else
			begin
				NS = WAIT;
			end
		end
		INITIALIZE:
		begin
			NS = GET_INPUT;
		end
		GET_INPUT:
		begin
			if (acknowledge_player_accepted_input[current_player_spot] == 1'b1)
			begin
				NS = STORE_INPUT;
			end
			else
			begin
				NS = GET_INPUT;
			end
		end
		STORE_INPUT:
		begin
			if (acknowledge_player_accepted_input[current_player_spot] == 1'b0)
			begin
				NS = VALID_INPUT;
			end
			else 
			begin
				NS = STORE_INPUT;
			end
		end
		VALID_INPUT:
		begin
			if (is_valid_action == INVALID)
			begin
				NS = GET_INPUT;
			end
			else if (is_valid_action == VALID)
			begin
				NS = NEXT_PLAYER;
			end
			else
			begin 
				NS = VALID_INPUT;
			end
		end
		NEXT_PLAYER:
		begin
			if (player_count == NUM_PLAYERS-1 || last_action == FOLD)
			begin
				NS = S_FIX_BETS;
			end
			else
			begin
				NS = GET_INPUT;
			end
		end
		S_FIX_BETS:
		begin
			NS = S_BETTING_DONE;
		end
		S_BETTING_DONE:
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
			player_count <= 4'b000;
			last_action <= CHECK;
			last_money <= 8'b00000000;
			get_player_input[0] <= 1'b0;
			get_player_input[1] <= 1'b0;
			current_player_spot <= 4'b0000;
			actions <= 6'b000000;
			money_bet <= 16'b0000000000000000;
			is_valid_action <= RESET_V;
			accepted_action <= 2'b00;
			checked <= 1'b0;
			betting_done <= 1'b0;
	end
	else
	begin
		case (S)
			WAIT:
			begin
				betting_done <= 1'b0;
				player_count <= 4'b0000;
				last_action <= CHECK;
				last_money <= 8'b00000000;
				get_player_input[0] <= 1'b0;
				get_player_input[1] <= 1'b0;	
				accepted_action <= 2'b00;
				is_valid_action <= RESET_V;
				
				if (last_to_act_idx == NUM_PLAYERS-1)
				begin
					current_player_spot <= 4'b0000;
				end
				else
				begin
					current_player_spot <= last_to_act_idx + 1'b1;
				end
			end
			INITIALIZE:
			begin
				if (first_round == 1'b1)
				begin
					// first round means the dealer put in small blind
					if (current_player_spot == 4'b0000)
					begin
						// current player has to choose to pay up to big
						last_action <= BET;
						last_money <= 8'b00000010;
						money_bet[7:0] <= 8'b00000001;
						money_bet[15:8] <= 8'b00000010;
						actions <= {BET, NO_ACTION};
					end	
					else
					begin
						last_action <= BET;
						last_money <= 8'b00000010;
						money_bet[7:0] <= 8'b00000010;
						money_bet[15:8] <= 8'b00000001;
						actions <= {NO_ACTION, BET};
					end
				end
				else
				begin
					actions <= 6'b000000;
					money_bet <= 16'b0000000000000000;
				end
			end
			GET_INPUT:
			begin
				get_player_input[current_player_spot] <= 1'b1;
				if (current_player_spot == 0)
				begin
					if (is_valid_action == VALID)
					begin
						accepted_action[0] <= 1'b0;
					end
					else if (is_valid_action == INVALID)
					begin
						accepted_action[0] <= 1'b1;
					end
				end
				else
				begin
					if (is_valid_action == VALID)
					begin
						accepted_action[1] <= 1'b0;
					end
					else if (is_valid_action == INVALID)
					begin
						accepted_action[1] <= 1'b1;
					end
				end
			end
			STORE_INPUT:
			begin
				checked <= 1'b0;
				get_player_input[current_player_spot] <= 1'b0;
				if (current_player_spot == 0)
				begin
					action <= player1_input;
					money <= player1_money;
				end
				else
				begin
					action <= player2_input;
					money <= player2_money;
				end
				is_valid_action <= RESET_V;
			end
			VALID_INPUT:
			begin
				/* deal with all the betting situations */
				if (checked == 1'b0)
				begin
					/* Since we're in the checking for two cycles we need to make sure we only do the check once */
					checked <= 1'b1;

					if (current_player_spot == 4'b0000)
					begin
						// IF - payer 1
						if (action == FOLD)
						begin
							// IF the player folds then record and move on
							actions[2:0] <= action;
							is_valid_action <= VALID;
							last_action <= FOLD;
						end
						else if (last_action == CALL)
						begin
							// IF the last player calls ...
							if (action == CHECK || action == CALL)
							begin
								if (money_bet[7:0] >= players_banks[7:0])	
								begin
									// More money than you have in the bank = All in
									last_action <= ALL_IN;
									player_count <= 4'b0000;
									last_money <= players_banks[7:0];
									actions[2:0] <= ALL_IN;
									money_bet[7:0] <= players_banks[7:0];
									is_valid_action <= VALID;
								end
								else
								begin
									last_action <= CALL;
									actions[2:0] <= CALL;						
									money_bet[7:0] <= last_money;
									last_money <= last_money;
									is_valid_action <= VALID;
								end
							end
							else if (action == BET)
							begin
								// IF you BET is valid depending on value 
								if (money + money_bet[7:0] >= players_banks[7:0])
								begin
									// More money than you have in the bank = All in
									last_action <= ALL_IN;
									player_count <= 4'b0000;
									last_money <= players_banks[7:0];
									actions[2:0] <= ALL_IN;
									money_bet[7:0] <= players_banks[7:0];
									is_valid_action <= VALID;
								end
								else if (money > 0)
								begin
									// IF you bet a lesser bet than bank
									last_action <= BET;
									last_money <= money;
									player_count <= 4'b0000;
									actions[2:0] <= BET;
									money_bet[7:0] <= money;
									is_valid_action <= VALID;
								end
								else
								begin
									// If you have bet a value less than 0
									is_valid_action <= INVALID;
								end
							end
							else if (action == RAISE)
							begin
								// Raise
								if (money+money_bet[7:0] >= players_banks[7:0])
								begin
									// All in 
									last_action <= ALL_IN;
									last_money <= players_banks[7:0];
									actions[2:0] <= ALL_IN;
									money_bet[7:0] <= players_banks[7:0];
									if (players_banks[7:0] > last_money)
									begin
										// IF the all in call is > than the last bet
										player_count <= 4'b0000;
									end
									is_valid_action <= VALID;
								end
								else if (money+money_bet[7:0] <= last_money)
								begin
									// An invalid raise
									is_valid_action <= INVALID;
								end
								else if (money+money_bet[7:0] < players_banks[7:0] && money+money_bet[7:0] > last_money)
								begin
									last_action <= BET;
									last_money <= money+money_bet[7:0];
									actions[2:0] <= BET;
									money_bet[7:0] <= money+money_bet[7:0];
									player_count <= 4'b0000;
									is_valid_action <= VALID;
								end
							end
							else if (action == ALL_IN)
							begin
								// ALL In // More money than you have in the bank = All in
								last_action <= ALL_IN;
								player_count <= 4'b0000;
								last_money <= players_banks[7:0];
								actions[2:0] <= ALL_IN;
								money_bet[7:0] <= players_banks[7:0];
								is_valid_action <= VALID;
							end
						end
						else if (last_action == CHECK)
						begin
							// IF the last player checks
							if (action == CHECK || action == CALL)
							begin
								// IF this player checks then record and valid
								if (money_bet[7:0] >= players_banks[7:0])	
								begin
									// More money than you have in the bank = All in
									last_action <= ALL_IN;
									player_count <= 4'b0000;
									last_money <= players_banks[7:0];
									actions[2:0] <= ALL_IN;
									money_bet[7:0] <= players_banks[7:0];
									is_valid_action <= VALID;
								end
								else
								begin
									last_action <= CHECK;
									actions[2:0] <= CHECK;						
									is_valid_action <= VALID;
								end
							end
							else if (action == BET || action == RAISE)
							begin
								// IF you BET is valid depending on value 
								if (money+money_bet[7:0] >= players_banks[7:0])
								begin
									// More money than you have in the bank = All in
									last_action <= ALL_IN;
									player_count <= 4'b0000;
									last_money <= players_banks[7:0];
									actions[2:0] <= ALL_IN;
									money_bet[7:0] <= players_banks[7:0];
									is_valid_action <= VALID;
								end
								else if (money > 0)
								begin
									// IF you bet a lesser bet than bank
									last_action <= BET;
									last_money <= money;
									player_count <= 4'b0000;
									actions[2:0] <= BET;
									money_bet[7:0] <= money;
									is_valid_action <= VALID;
								end
								else
								begin
									// If you have bet a value less than 0
									is_valid_action <= INVALID;
								end
							end
							else if (action == ALL_IN)
							begin
								// ALL In // More money than you have in the bank = All in
								last_action <= ALL_IN;
								player_count <= 4'b0000;
								last_money <= players_banks[7:0];
								actions[2:0] <= ALL_IN;
								money_bet[7:0] <= players_banks[7:0];
								is_valid_action <= VALID;
							end
						end
						else if (last_action == BET)
						begin
							// If player before bet
							if (action == CHECK)
							begin
								// Can't check
								is_valid_action <= INVALID;
							end
							else if (action == CALL)
							begin
								// Call
								if (last_money >= players_banks[7:0]) 
								begin
									// IF the money bet is greater than what you have and you call...ALL_IN
									last_action <= ALL_IN;
									player_count <= 4'b0000;
									last_money <= players_banks[7:0];
									actions[2:0] <= ALL_IN;
									money_bet[7:0] <= players_banks[7:0];
									is_valid_action <= VALID;
								end
								else
								begin
									// IF legal call
									last_action <= CALL;
									last_money <= last_money;
									actions[2:0] <= CALL;
									money_bet[7:0] <= last_money;
									is_valid_action <= VALID;
								end
							end
							else if (action == ALL_IN)
							begin
								// ALL IN from a BET
								last_action <= ALL_IN;
								last_money <= players_banks[7:0];
								actions[2:0] <= ALL_IN;
								money_bet[7:0] <= players_banks[7:0];
								if (players_banks[7:0] > last_money)
								begin
									// IF the all in call is > than the last bet
									player_count <= 4'b0000;
								end
								is_valid_action <= VALID;
							end
							else if (action == RAISE || action == BET)
							begin
								// Raise
								if (money+money_bet[7:0] >= players_banks[7:0])
								begin
									// All in 
									last_action <= ALL_IN;
									last_money <= players_banks[7:0];
									actions[2:0] <= ALL_IN;
									money_bet[7:0] <= players_banks[7:0];
									if (players_banks[7:0] > last_money)
									begin
										// IF the all in call is > than the last bet
										player_count <= 4'b0000;
									end
									is_valid_action <= VALID;
								end
								else if (money+money_bet[7:0] <= last_money)
								begin
									// An invalid raise
									is_valid_action <= INVALID;
								end
								else if (money+money_bet[7:0] < players_banks[7:0] && money+money_bet[7:0] > last_money)
								begin
									last_action <= BET;
									last_money <= money+money_bet[7:0];
									actions[2:0] <= BET;
									money_bet[7:0] <= money+money_bet[7:0];
									player_count <= 4'b0000;
									is_valid_action <= VALID;
								end
							end
						end
						else if (last_action == ALL_IN)
						begin
							if (action == CHECK)
							begin
								is_valid_action <= INVALID;
							end
							else if (action == RAISE)
							begin
								is_valid_action <= INVALID;
							end
							else if (action == BET)
							begin
								is_valid_action <= INVALID;
							end
							else if (action == CALL || action == ALL_IN)
							begin
								last_action <= ALL_IN;
								last_money <= players_banks[7:0];
								actions[2:0] <= ALL_IN;
								money_bet[7:0] <= players_banks[7:0];
								is_valid_action <= VALID;
							end
						end
					end
					else if (current_player_spot == 4'b0001)
					begin
						// IF - payer 2
						if (action == FOLD)
						begin
							// IF the player folds then record and move on
							actions[5:3] <= action;
							is_valid_action <= VALID;
							last_action <= FOLD;
						end
						else if (last_action == CALL)
						begin
							// IF the last player calls ...
							if (action == CHECK || action == CALL)
							begin
								if (money_bet[15:8] >= players_banks[15:8])	
								begin
									// More money than you have in the bank = All in
									last_action <= ALL_IN;
									player_count <= 4'b0000;
									last_money <= players_banks[15:8];
									actions[5:3] <= ALL_IN;
									money_bet[15:8] <= players_banks[15:8];
									is_valid_action <= VALID;
								end
								else
								begin
									last_action <= CALL;
									actions[5:3] <= CALL;						
									money_bet[15:8] <= last_money;
									last_money <= last_money;
									is_valid_action <= VALID;
								end
							end
							else if (action == BET)
							begin
								// IF you BET is valid depending on value 
								if (money + money_bet[15:8] >= players_banks[15:8])
								begin
									// More money than you have in the bank = All in
									last_action <= ALL_IN;
									player_count <= 4'b0000;
									last_money <= players_banks[15:8];
									actions[5:3] <= ALL_IN;
									money_bet[15:8] <= players_banks[15:8];
									is_valid_action <= VALID;
								end
								else if (money > 0)
								begin
									// IF you bet a lesser bet than bank
									last_action <= BET;
									last_money <= money;
									player_count <= 4'b0000;
									actions[5:3] <= BET;
									money_bet[15:8] <= money;
									is_valid_action <= VALID;
								end
								else
								begin
									// If you have bet a value less than 0
									is_valid_action <= INVALID;
								end
							end
							else if (action == RAISE)
							begin
								// Raise
								if (money+money_bet[15:8] >= players_banks[15:8])
								begin
									// All in 
									last_action <= ALL_IN;
									last_money <= players_banks[15:8];
									actions[5:3] <= ALL_IN;
									money_bet[15:8] <= players_banks[15:8];
									if (players_banks[15:8] > last_money)
									begin
										// IF the all in call is > than the last bet
										player_count <= 4'b0000;
									end
									is_valid_action <= VALID;
								end
								else if (money+money_bet[15:8] <= last_money)
								begin
									// An invalid raise
									is_valid_action <= INVALID;
								end
								else if (money+money_bet[15:8] < players_banks[15:8] && money+money_bet[15:8] > last_money)
								begin
									last_action <= BET;
									last_money <= money+money_bet[15:8];
									actions[5:3] <= BET;
									money_bet[15:8] <= money+money_bet[15:8];
									player_count <= 4'b0000;
									is_valid_action <= VALID;
								end
							end
							else if (action == ALL_IN)
							begin
								// ALL In // More money than you have in the bank = All in
								last_action <= ALL_IN;
								player_count <= 4'b0000;
								last_money <= players_banks[15:8];
								actions[5:3] <= ALL_IN;
								money_bet[15:8] <= players_banks[15:8];
								is_valid_action <= VALID;
							end
						end
						else if (last_action == CHECK)
						begin
							// IF the last player checks
							if (action == CHECK || action == CALL)
							begin
								// IF this player checks then record and valid
								if (money_bet[15:8] >= players_banks[15:8])	
								begin
									// More money than you have in the bank = All in
									last_action <= ALL_IN;
									player_count <= 4'b0000;
									last_money <= players_banks[15:8];
									actions[5:3] <= ALL_IN;
									money_bet[15:8] <= players_banks[15:8];
									is_valid_action <= VALID;
								end
								else
								begin
									last_action <= CHECK;
									actions[5:3] <= CHECK;						
									is_valid_action <= VALID;
								end
							end
							else if (action == BET || action == RAISE)
							begin
								// IF you BET is valid depending on value 
								if (money+money_bet[15:8] >= players_banks[15:8])
								begin
									// More money than you have in the bank = All in
									last_action <= ALL_IN;
									player_count <= 4'b0000;
									last_money <= players_banks[15:8];
									actions[5:3] <= ALL_IN;
									money_bet[15:8] <= players_banks[15:8];
									is_valid_action <= VALID;
								end
								else if (money > 0)
								begin
									// IF you bet a lesser bet than bank
									last_action <= BET;
									last_money <= money;
									player_count <= 4'b0000;
									actions[5:3] <= BET;
									money_bet[15:8] <= money;
									is_valid_action <= VALID;
								end
								else
								begin
									// If you have bet a value less than 0
									is_valid_action <= INVALID;
								end
							end
							else if (action == ALL_IN)
							begin
								// ALL In // More money than you have in the bank = All in
								last_action <= ALL_IN;
								player_count <= 4'b0000;
								last_money <= players_banks[15:8];
								actions[5:3] <= ALL_IN;
								money_bet[15:8] <= players_banks[15:8];
								is_valid_action <= VALID;
							end
						end
						else if (last_action == BET)
						begin
							// If player before bet
							if (action == CHECK)
							begin
								// Can't check
								is_valid_action <= INVALID;
							end
							else if (action == CALL)
							begin
								// Call
								if (last_money >= players_banks[15:8]) 
								begin
									// IF the money bet is greater than what you have and you call...ALL_IN
									last_action <= ALL_IN;
									player_count <= 4'b0000;
									last_money <= players_banks[15:8];
									actions[5:3] <= ALL_IN;
									money_bet[15:8] <= players_banks[15:8];
									is_valid_action <= VALID;
								end
								else
								begin
									// IF legal call
									last_action <= CALL;
									last_money <= last_money;
									actions[5:3] <= CALL;
									money_bet[15:8] <= last_money;
									is_valid_action <= VALID;
								end
							end
							else if (action == ALL_IN)
							begin
								// ALL IN from a BET
								last_action <= ALL_IN;
								last_money <= players_banks[15:8];
								actions[5:3] <= ALL_IN;
								money_bet[15:8] <= players_banks[15:8];
								if (players_banks[15:8] > last_money)
								begin
									// IF the all in call is > than the last bet
									player_count <= 4'b0000;
								end
								is_valid_action <= VALID;
							end
							else if (action == RAISE || action == BET)
							begin
								// Raise
								if (money+money_bet[15:8] >= players_banks[15:8])
								begin
									// All in 
									last_action <= ALL_IN;
									last_money <= players_banks[15:8];
									actions[5:3] <= ALL_IN;
									money_bet[15:8] <= players_banks[15:8];
									if (players_banks[15:8] > last_money)
									begin
										// IF the all in call is > than the last bet
										player_count <= 4'b0000;
									end
									is_valid_action <= VALID;
								end
								else if (money+money_bet[15:8] <= last_money)
								begin
									// An invalid raise
									is_valid_action <= INVALID;
								end
								else if (money+money_bet[15:8] < players_banks[15:8] && money+money_bet[15:8] > last_money)
								begin
									last_action <= BET;
									last_money <= money+money_bet[15:8];
									actions[5:3] <= BET;
									money_bet[15:8] <= money+money_bet[15:8];
									player_count <= 4'b0000;
									is_valid_action <= VALID;
								end
							end
						end
						else if (last_action == ALL_IN)
						begin
							if (action == CHECK)
							begin
								is_valid_action <= INVALID;
							end
							else if (action == RAISE)
							begin
								is_valid_action <= INVALID;
							end
							else if (action == BET)
							begin
								is_valid_action <= INVALID;
							end
							else if (action == CALL || action == ALL_IN)
							begin
								last_action <= ALL_IN;
								last_money <= players_banks[15:8];
								actions[5:3] <= ALL_IN;
								money_bet[15:8] <= players_banks[15:8];
								is_valid_action <= VALID;
							end
						end
					end	
				end
			end
			NEXT_PLAYER:
			begin
				if (current_player_spot == NUM_PLAYERS-1)
				begin
					current_player_spot <= 4'b000;
				end
				else
				begin
					current_player_spot <= current_player_spot + 1'b1;
				end
				player_count <= player_count + 1'b1;
			end
			S_FIX_BETS:
			begin
				if (actions[2:0] == ALL_IN)
				begin
					if (actions[5:3] != FOLD)
					begin
						// IF one player is all in and the other is matching
						if (money_bet[7:0] >= money_bet[15:8])
							money_bet[7:0] <= money_bet[15:8];
						else
							money_bet[15:8] <= money_bet[7:0];
					end	
				end
				else if (actions[5:3] == ALL_IN)
				begin
					if (actions[2:0] != FOLD)
					begin
						// IF one player is all in and the other is matching
						if (money_bet[7:0] >= money_bet[15:8])
							money_bet[7:0] <= money_bet[15:8];
						else
							money_bet[15:8] <= money_bet[7:0];
					end	
				end
			end
			S_BETTING_DONE:
			begin
				betting_done <= 1'b1;
			end
		endcase
	end
end

endmodule
