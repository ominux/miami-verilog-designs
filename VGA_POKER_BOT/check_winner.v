module check_winner(clk, rst, check_the_winner, P1C1, P1C2, P2C1, P2C2, flop, turn, river, checked, winner_done, actions_from_last_betting_round, player_wins);
input clk, rst;
input [5:0]P1C1, P1C2, P2C1, P2C2, turn, river; // cards
input [17:0]flop;
input check_the_winner; // request to check if there is a winner
output winner_done; // signal goes high to indicate winner
reg winner_done;
output checked; // signal to indicate when winner has been picked
reg checked;
output [1:0]player_wins;
reg [1:0]player_wins;
reg [1:0]player_winner;

input [5:0]actions_from_last_betting_round;

reg done_fold_check;
reg done_hand_check;

reg[2:0] S, NS;
parameter 
WAIT = 3'b000,
CHECK_ACTIONS = 3'b001,
CHECK_HANDS = 3'b010,
S_WINNER_DONE = 3'b011,
INITIALIZE = 3'b100;

parameter // Note 000 reserved for no action
NO_ACTION = 3'b000,
FOLD = 3'b001,
CHECK = 3'b010,
BET = 3'b110,
RAISE = 3'b111,
ALL_IN = 3'b011;

parameter 
ID_PLAYER1 = 2'b01,
ID_PLAYER2 = 2'b10,
NOTHING = 2'b00,
DRAW = 2'b11;

always @(S or check_the_winner or done_fold_check or done_hand_check)
begin
	case (S)
		WAIT:
		begin
			if (check_the_winner == 1'b1)
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
			NS = CHECK_ACTIONS;
		end
		CHECK_ACTIONS:
		begin
			if (done_fold_check == 1'b1)
			begin
				NS = CHECK_HANDS;
			end
			else if (done_hand_check == 1'b1)
			begin
				NS = S_WINNER_DONE;
			end
			else
			begin
				NS = CHECK_ACTIONS;
			end
		end
		CHECK_HANDS:
		begin
			if (done_hand_check == 1'b1)
			begin
				NS = S_WINNER_DONE;
			end
			else
			begin
				NS = CHECK_HANDS;
			end
		end
		S_WINNER_DONE:
		begin
			NS = WAIT;
		end
		default:
			NS = WAIT;
	endcase
end

always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
		S <= WAIT;
	else
		S <= NS;
end

always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		done_fold_check <= 1'b0;
		done_hand_check <= 1'b0;
		checked <= 1'b0;
		winner_done <= 1'b0;
		player_wins <= NOTHING;
	end
	else
	begin
		case (S)
			WAIT:
			begin
				checked <= 1'b0;
				done_fold_check <= 1'b0;
				done_hand_check <= 1'b0;
				winner_done <= 1'b0;
			end
			INITIALIZE:
			begin
				player_wins <= NOTHING;
			end
			CHECK_ACTIONS:
			begin
				if (actions_from_last_betting_round[2:0] == FOLD)
				begin
					done_hand_check <= 1'b1;
					done_fold_check <= 1'b0;
					player_wins <= ID_PLAYER2; // PLAYER 2 wins
				end
				else if (actions_from_last_betting_round[5:3] == FOLD)
				begin
					done_hand_check <= 1'b1;
					done_fold_check <= 1'b0;
					player_wins <= ID_PLAYER1; // PLAYER 1 wins
				end
				else 
				begin
					done_hand_check <= 1'b0;
					done_fold_check <= 1'b1;
				end
			end
			CHECK_HANDS:
			begin
				done_fold_check <= 1'b0;
				done_hand_check <= 1'b1;
				if (river != 6'b000000)
					player_wins <= player_winner;
				else
					player_wins <= NOTHING;
			end
			S_WINNER_DONE:
			begin
				checked <= 1'b1;

				if (player_wins == ID_PLAYER1 || player_wins == ID_PLAYER2 || player_wins == DRAW)
				begin
					winner_done <= 1'b1;
				end
			end
		endcase
	end
end

wire [5:0]player1_card_one, player1_card_two, player1_card_three, player1_card_four, player1_card_five, player1_card_six, player1_card_seven;
wire [5:0]player2_card_one, player2_card_two, player2_card_three, player2_card_four, player2_card_five, player2_card_six, player2_card_seven;

/* sort the cards */
sort_cards player1(P1C1, P1C2, flop[5:0], flop[11:6], flop[17:12], turn, river, player1_card_one, player1_card_two, player1_card_three, player1_card_four, player1_card_five, player1_card_six, player1_card_seven);
sort_cards player2(P2C1, P2C2, flop[5:0], flop[11:6], flop[17:12], turn, river, player2_card_one, player2_card_two, player2_card_three, player2_card_four, player2_card_five, player2_card_six, player2_card_seven);

wire p1_flush;
wire[3:0] p1_flush_card_value1, p1_flush_card_value2, p1_flush_card_value3, p1_flush_card_value4, p1_flush_card_value5;
wire p2_flush;
wire[3:0] p2_flush_card_value1, p2_flush_card_value2, p2_flush_card_value3, p2_flush_card_value4, p2_flush_card_value5;
// find flush 
find_flush find_a_flush_for_player1(player1_card_one, player1_card_two, player1_card_three, player1_card_four, player1_card_five, player1_card_six, player1_card_seven, p1_flush, p1_flush_card_value1, p1_flush_card_value2, p1_flush_card_value3, p1_flush_card_value4, p1_flush_card_value5);
find_flush find_a_flush_for_player2(player2_card_one, player2_card_two, player2_card_three, player2_card_four, player2_card_five, player2_card_six, player2_card_seven, p2_flush, p2_flush_card_value1, p2_flush_card_value2, p2_flush_card_value3, p2_flush_card_value4, p2_flush_card_value5);

wire p1_full;
wire[3:0] p1_full_three_card_value;
wire[3:0] p1_full_two_card_value;
wire p2_full;
wire[3:0] p2_full_three_card_value;
wire[3:0] p2_full_two_card_value;
// find full house 
find_full_house find_full_for_player1(player1_card_one, player1_card_two, player1_card_three, player1_card_four, player1_card_five, player1_card_six, player1_card_seven, p1_full, p1_full_three_card_value, p1_full_two_card_value);
find_full_house find_full_for_player2(player2_card_one, player2_card_two, player2_card_three, player2_card_four, player2_card_five, player2_card_six, player2_card_seven, p2_full, p2_full_three_card_value, p2_full_two_card_value);

wire p1_four;
wire[3:0] p1_four_card_value;
wire p2_four;
wire[3:0] p2_four_card_value;
// find four of a kind 
find_four_of_a_kind find_four_for_player1(player1_card_one, player1_card_two, player1_card_three, player1_card_four, player1_card_five, player1_card_six, player1_card_seven, p1_four, p1_four_card_value);
find_four_of_a_kind find_four_for_player2(player2_card_one, player2_card_two, player2_card_three, player2_card_four, player2_card_five, player2_card_six, player2_card_seven, p2_four, p2_four_card_value);

wire p1_run, p1_run_flush;
wire[3:0] p1_run_card_value;
wire p2_run, p2_run_flush;
wire[3:0] p2_run_card_value;
// find run and highest card in run 
find_run find_a_run_for_player1(player1_card_one, player1_card_two, player1_card_three, player1_card_four, player1_card_five, player1_card_six, player1_card_seven, p1_run, p1_run_flush, p1_run_card_value);
find_run find_a_run_for_player2(player2_card_one, player2_card_two, player2_card_three, player2_card_four, player2_card_five, player2_card_six, player2_card_seven, p2_run, p2_run_flush, p2_run_card_value);


wire p1_three;
wire[3:0] p1_three_card_value;
wire[3:0] p1_three_kicker1, p1_three_kicker2;
wire p2_three;
wire[3:0] p2_three_card_value;
wire[3:0] p2_three_kicker1, p2_three_kicker2;
// find three of a kind 
find_three_of_a_kind find_three_for_player1(player1_card_one, player1_card_two, player1_card_three, player1_card_four, player1_card_five, player1_card_six, player1_card_seven, p1_three, p1_three_card_value, p1_three_kicker1, p1_three_kicker2);
find_three_of_a_kind find_three_for_player2(player2_card_one, player2_card_two, player2_card_three, player2_card_four, player2_card_five, player2_card_six, player2_card_seven, p2_three, p2_three_card_value, p2_three_kicker1, p2_three_kicker2);

wire p1_2pair;
wire[3:0]p1_2pair1_card_value, p1_2pair2_card_value, p1_kicker;
wire p2_2pair;
wire[3:0]p2_2pair1_card_value, p2_2pair2_card_value, p2_kicker;
// find 2 pair 
find_two_pair find_2_pair_player1(player1_card_one, player1_card_two, player1_card_three, player1_card_four, player1_card_five, player1_card_six, player1_card_seven, p1_2pair, p1_2pair1_card_value, p1_2pair2_card_value, p1_kicker);
find_two_pair find_2_pair_player2(player2_card_one, player2_card_two, player2_card_three, player2_card_four, player2_card_five, player2_card_six, player2_card_seven, p2_2pair, p2_2pair1_card_value, p2_2pair2_card_value, p2_kicker);

wire p1_pair;
wire[3:0]p1_pair1_card_value, p1_kicker1, p1_kicker2, p1_kicker3;
wire p2_pair;
wire[3:0]p2_pair1_card_value, p2_kicker1, p2_kicker2, p2_kicker3;
// find pair 
find_pair_hand find_pair_player1(player1_card_one, player1_card_two, player1_card_three, player1_card_four, player1_card_five, player1_card_six, player1_card_seven, p1_pair, p1_pair1_card_value, p1_kicker1, p1_kicker2, p1_kicker3);
find_pair_hand find_pair_player2(player2_card_one, player2_card_two, player2_card_three, player2_card_four, player2_card_five, player2_card_six, player2_card_seven, p2_pair, p2_pair1_card_value, p2_kicker1, p2_kicker2, p2_kicker3);

always @(
player1_card_one or player1_card_two or player1_card_three or player1_card_four or player1_card_five or
player2_card_one or player2_card_two or player2_card_three or player2_card_four or player2_card_five or
p1_full or p1_full_three_card_value or p1_full_two_card_value or p2_full or p2_full_three_card_value or p2_full_two_card_value or 
p1_four or p1_four_card_value or p2_four or p2_four_card_value or 
p1_flush or p1_flush_card_value1 or p1_flush_card_value2 or p1_flush_card_value3 or p1_flush_card_value4 or p1_flush_card_value5 or 
p2_flush or p2_flush_card_value1 or p2_flush_card_value2 or p2_flush_card_value3 or p2_flush_card_value4 or p2_flush_card_value5 or 
p1_2pair or p1_2pair1_card_value or p1_2pair2_card_value or p1_kicker or p2_2pair or p2_2pair1_card_value or p2_2pair2_card_value or p2_kicker or 
p1_pair or p1_pair1_card_value or p1_kicker1 or p1_kicker2 or p1_kicker3 or p2_pair or p2_pair1_card_value or p2_kicker1 or p2_kicker2 or p2_kicker3 or 
p1_three or p1_three_card_value or p2_three or p2_three_card_value or p1_three_kicker1 or p1_three_kicker2 or p2_three_kicker1 or p2_three_kicker2 or
p1_run or p1_run_flush or p2_run_flush or p1_run_card_value or p2_run or p2_run_card_value)
begin
	// FLUSH STRAIGHT 
	if (p1_run_flush == 1'b1)
	begin
		if (p2_run_flush == 1'b1)
		begin
			if (p1_run_card_value > p2_run_card_value)
			begin
				player_winner = ID_PLAYER1;
			end
			else if (p2_run_card_value > p1_run_card_value)
			begin
				player_winner = ID_PLAYER2;
			end
			else
			begin
				player_winner = DRAW;
			end
		end
		else
		begin
			player_winner = ID_PLAYER1;
		end
	end
	else if (p2_run_flush == 1'b1)
	begin
		player_winner = ID_PLAYER2;
	end
	// FOUR OF A KIND 
	else if (p1_four == 1'b1)
	begin
		if (p2_four == 1'b1)
		begin
			if (p1_four_card_value > p2_four_card_value)
			begin
				player_winner = ID_PLAYER1;
			end
			else if (p2_four_card_value > p1_four_card_value)
			begin
				player_winner = ID_PLAYER2;
			end
			else
			begin
				player_winner = DRAW;
			end
		end
		else
		begin
			player_winner = ID_PLAYER1;
		end
	end
	else if (p2_four == 1'b1)
	begin
		player_winner = ID_PLAYER2;
	end
	// FULL HOUSE LOGIC 
	else if (p1_full == 1'b1)
	begin
		if (p2_full == 1'b1)
		begin
			if (p1_full_three_card_value > p2_full_three_card_value)
			begin
				player_winner = ID_PLAYER1;
			end
			else if (p2_full_three_card_value > p1_full_three_card_value)
			begin
				player_winner = ID_PLAYER2;
			end
			else
			begin
				if (p1_full_two_card_value > p2_full_two_card_value)
				begin
					player_winner = ID_PLAYER1;
				end
				else if (p2_full_two_card_value > p1_full_two_card_value)
				begin
					player_winner = ID_PLAYER2;
				end
				else
				begin
					player_winner = DRAW;
				end
			end
		end
		else
		begin
			player_winner = ID_PLAYER1;
		end
	end
	else if (p2_full == 1'b1)
	begin
		player_winner = ID_PLAYER2;
	end
	// FLUSH 
	else if (p1_flush == 1'b1)
	begin
		if (p2_flush == 1'b1)
		begin
			if (p1_flush_card_value1 > p2_flush_card_value1)
			begin
				player_winner = ID_PLAYER1;
			end
			else if (p2_flush_card_value1 > p1_flush_card_value1)
			begin
				player_winner = ID_PLAYER2;
			end
			else
			begin
				if (p1_flush_card_value2 > p2_flush_card_value2)
				begin
					player_winner = ID_PLAYER1;
				end
				else if (p2_flush_card_value2 > p1_flush_card_value2)
				begin
					player_winner = ID_PLAYER2;
				end
				else
				begin
					if (p1_flush_card_value3 > p2_flush_card_value3)
					begin
						player_winner = ID_PLAYER1;
					end
					else if (p2_flush_card_value3 > p1_flush_card_value3)
					begin
						player_winner = ID_PLAYER2;
					end
					else
					begin
						if (p1_flush_card_value4 > p2_flush_card_value4)
						begin
							player_winner = ID_PLAYER1;
						end
						else if (p2_flush_card_value4 > p1_flush_card_value4)
						begin
							player_winner = ID_PLAYER2;
						end
						else
						begin
							if (p1_flush_card_value5 > p2_flush_card_value5)
							begin
								player_winner = ID_PLAYER1;
							end
							else if (p2_flush_card_value5 > p1_flush_card_value5)
							begin
								player_winner = ID_PLAYER2;
							end
							else
							begin
								player_winner = DRAW;
							end
						end
			
					end
				end
	
			end
		end
		else
		begin
			player_winner = ID_PLAYER1;
		end
	end
	else if (p2_flush == 1'b1)
	begin
		player_winner = ID_PLAYER2;
	end
	// STRAIGHT 
	else if (p1_run == 1'b1)
	begin
		if (p2_run == 1'b1)
		begin
			if (p1_run_card_value > p2_run_card_value)
			begin
				player_winner = ID_PLAYER1;
			end
			else if (p2_run_card_value > p1_run_card_value)
			begin
				player_winner = ID_PLAYER2;
			end
			else
			begin
				player_winner = DRAW;
			end
		end
		else
		begin
			player_winner = ID_PLAYER1;
		end
	end
	else if (p2_run == 1'b1)
	begin
		player_winner = ID_PLAYER2;
	end
	// THREE OF A KIND 
	else if (p1_three == 1'b1)
	begin
		if (p2_three == 1'b1)
		begin
			if (p1_three_card_value > p2_three_card_value)
			begin
				player_winner = ID_PLAYER1;
			end
			else if (p2_three_card_value > p1_three_card_value)
			begin
				player_winner = ID_PLAYER2;
			end
			else
			begin
				if (p1_three_kicker1 > p2_three_kicker1)
				begin
					player_winner = ID_PLAYER1;
				end
				else if (p2_three_kicker1 > p1_three_kicker1)
				begin
					player_winner = ID_PLAYER2;
				end
				else
				begin
					if (p1_three_kicker2 > p2_three_kicker2)
					begin
						player_winner = ID_PLAYER1;
					end
					else if (p2_three_kicker2 > p1_three_kicker2)
					begin
						player_winner = ID_PLAYER2;
					end
					else
					begin
						player_winner = DRAW;
					end
				end
			end
		end
		else
		begin
			player_winner = ID_PLAYER1;
		end
	end
	else if (p2_three == 1'b1)
	begin
		player_winner = ID_PLAYER2;
	end
	// TWO PAIR 
	else if (p1_2pair == 1'b1)
	begin
		if (p2_2pair == 1'b1)
		begin
			if (p1_2pair1_card_value > p2_2pair1_card_value)
			begin
				player_winner = ID_PLAYER1;
			end
			else if (p2_2pair1_card_value > p1_2pair1_card_value)
			begin
				player_winner = ID_PLAYER2;
			end
			else
			begin
				if (p1_2pair2_card_value > p2_2pair2_card_value)
				begin
					player_winner = ID_PLAYER1;
				end
				else if (p2_2pair2_card_value > p1_2pair2_card_value)
				begin
					player_winner = ID_PLAYER2;
				end
				else
				begin
					if (p1_kicker > p2_kicker)
					begin
						player_winner = ID_PLAYER1;
					end
					else if (p2_kicker > p1_kicker)
					begin
						player_winner = ID_PLAYER2;
					end
					else
					begin
						player_winner = DRAW;
					end
				end
			end
		end
		else
		begin
			player_winner = ID_PLAYER1;
		end
	end
	else if (p2_2pair == 1'b1)
	begin
		player_winner = ID_PLAYER2;
	end
	// pair 
	else if (p1_pair == 1'b1)
	begin
		if (p2_pair == 1'b1)
		begin
			if (p1_pair1_card_value > p2_pair1_card_value)
			begin
				player_winner = ID_PLAYER1;
			end
			else if (p2_pair1_card_value > p1_pair1_card_value)
			begin
				player_winner = ID_PLAYER2;
			end
			else
			begin
				if (p1_kicker1 > p2_kicker1)
				begin
					player_winner = ID_PLAYER1;
				end
				else if (p2_kicker1 > p1_kicker1)
				begin
					player_winner = ID_PLAYER2;
				end
				else
				begin
					if (p1_kicker2 > p2_kicker2)
					begin
						player_winner = ID_PLAYER1;
					end
					else if (p2_kicker2 > p1_kicker2)
					begin
						player_winner = ID_PLAYER2;
					end
					else
					begin
						if (p1_kicker3 > p2_kicker3)
						begin
							player_winner = ID_PLAYER1;
						end
						else if (p2_kicker3 > p1_kicker3)
						begin
							player_winner = ID_PLAYER2;
						end
						else
						begin
							player_winner = DRAW;
						end
			
					end
				end
	
			end
		end
		else
		begin
			player_winner = ID_PLAYER1;
		end
	end
	else if (p2_pair == 1'b1)
	begin
		player_winner = ID_PLAYER2;
	end
	// HIGH CARD
	else
	begin
		if (player1_card_one > player2_card_one)
		begin
			player_winner = ID_PLAYER1;
		end
		else if (player2_card_one > player1_card_one)
		begin
			player_winner = ID_PLAYER2;
		end
		else
		begin
			if (player1_card_two > player2_card_two)
			begin
				player_winner = ID_PLAYER1;
			end
			else if (player2_card_two > player1_card_two)
			begin
				player_winner = ID_PLAYER2;
			end
			else
			begin
				if (player1_card_three > player2_card_three)
				begin
					player_winner = ID_PLAYER1;
				end
				else if (player2_card_three > player1_card_three)
				begin
					player_winner = ID_PLAYER2;
				end
				else
				begin
					if (player1_card_four > player2_card_four)
					begin
						player_winner = ID_PLAYER1;
					end
					else if (player2_card_four > player1_card_four)
					begin
						player_winner = ID_PLAYER2;
					end
					else
					begin
						if (player1_card_five > player2_card_five)
						begin
							player_winner = ID_PLAYER1;
						end
						else if (player2_card_five > player1_card_five)
						begin
							player_winner = ID_PLAYER2;
						end
						else
						begin
							player_winner = DRAW;
						end
					end
				end
			end
		end
	end
end

endmodule

/*-----------------------------------------------------------
-------------------------------------------------------------
find_pair_hand
-------------------------------------------------------------
-----------------------------------------------------------*/
module find_pair_hand(one, two, three, four, five, six, seven, found, pair1_card_value, kicker1, kicker2, kicker3);
input [5:0]one, two, three, four, five, six, seven; 
output found;
output [3:0]pair1_card_value;
output [3:0]kicker1, kicker2, kicker3;
wire found;
wire [3:0]pair1_card_value;
reg [3:0]kicker1, kicker2, kicker3;

wire [3:0]n_one, n_two, n_three, n_four, n_five, n_six, n_seven; 
wire [3:0]o_one, o_two, o_three, o_four, o_five, o_six, o_seven; 
wire [3:0]p_one, p_two, p_three, p_four, p_five, p_six, p_seven; 

find_pair find_pair1(one, two, three, four, five, six, seven, found, pair1_card_value);

// remove the pair
assign p_one = (pair1_card_value == one[3:0]) ? 4'b0000 : one[3:0];
assign p_two = (pair1_card_value == two[3:0]) ? 4'b0000 : two[3:0];
assign p_three = (pair1_card_value == three[3:0]) ? 4'b0000 : three[3:0];
assign p_four = (pair1_card_value == four[3:0]) ? 4'b0000 : four[3:0];
assign p_five = (pair1_card_value == five[3:0]) ? 4'b0000 : five[3:0];
assign p_six = (pair1_card_value == six[3:0]) ? 4'b0000 : six[3:0];
assign p_seven = (pair1_card_value == seven[3:0]) ? 4'b0000 : seven[3:0];

assign n_one = (kicker1 == one[3:0]) ? 4'b0000 : one[3:0];
assign n_two = (kicker1 == two[3:0]) ? 4'b0000 : two[3:0];
assign n_three = (kicker1 == three[3:0]) ? 4'b0000 : three[3:0];
assign n_four = (kicker1 == four[3:0]) ? 4'b0000 : four[3:0];
assign n_five = (kicker1 == five[3:0]) ? 4'b0000 : five[3:0];
assign n_six = (kicker1 == six[3:0]) ? 4'b0000 : six[3:0];
assign n_seven = (kicker1 == seven[3:0]) ? 4'b0000 : seven[3:0];

assign o_one = (kicker2 == one[3:0]) ? 4'b0000 : one[3:0];
assign o_two = (kicker2 == two[3:0]) ? 4'b0000 : two[3:0];
assign o_three = (kicker2 == three[3:0]) ? 4'b0000 : three[3:0];
assign o_four = (kicker2 == four[3:0]) ? 4'b0000 : four[3:0];
assign o_five = (kicker2 == five[3:0]) ? 4'b0000 : five[3:0];
assign o_six = (kicker2 == six[3:0]) ? 4'b0000 : six[3:0];
assign o_seven = (kicker2 == seven[3:0]) ? 4'b0000 : seven[3:0];

always @(found or one or two or three or four or five or six or seven or 
n_one or  n_two or  n_three or  n_four or  n_five or  n_six or  n_seven or  
o_one or  o_two or  o_three or  o_four or  o_five or  o_six or  o_seven or  
p_one or  p_two or  p_three or  p_four or  p_five or  p_six or  p_seven) 
begin
	if (found == 1'b1)
	begin
		if (p_one != 4'b0000)
		begin
			kicker1 = one[3:0];
		end
		else if (p_two != 4'b0000)
		begin
			kicker1 = two[3:0];
		end
		else if (p_three != 4'b0000)
		begin
			kicker1 = three[3:0];
		end
		else if (p_four != 4'b0000)
		begin
			kicker1 = four[3:0];
		end
		else if (p_five != 4'b0000)
		begin
			kicker1 = five[3:0];
		end
		else if (p_six != 4'b0000)
		begin
			kicker1 = six[3:0];
		end
		else if (p_seven != 4'b0000)
		begin
			kicker1 = seven[3:0];
		end
		else
			kicker1 = 4'b0000;

		if (n_one != 4'b0000)
		begin
			kicker2 = one[3:0];
		end
		else if (n_two != 4'b0000)
		begin
			kicker2 = two[3:0];
		end
		else if (n_three != 4'b0000)
		begin
			kicker2 = three[3:0];
		end
		else if (n_four != 4'b0000)
		begin
			kicker2 = four[3:0];
		end
		else if (n_five != 4'b0000)
		begin
			kicker2 = five[3:0];
		end
		else if (n_six != 4'b0000)
		begin
			kicker2 = six[3:0];
		end
		else if (n_seven != 4'b0000)
		begin
			kicker2 = seven[3:0];
		end
		else
			kicker2 = 4'b0000;

		if (o_one != 4'b0000)
		begin
			kicker3 = one[3:0];
		end
		else if (o_two != 4'b0000)
		begin
			kicker3 = two[3:0];
		end
		else if (o_three != 4'b0000)
		begin
			kicker3 = three[3:0];
		end
		else if (o_four != 4'b0000)
		begin
			kicker3 = four[3:0];
		end
		else if (o_five != 4'b0000)
		begin
			kicker3 = five[3:0];
		end
		else if (o_six != 4'b0000)
		begin
			kicker3 = six[3:0];
		end
		else if (o_seven != 4'b0000)
		begin
			kicker3 = seven[3:0];
		end
		else
			kicker3 = 4'b0000;
	end
	else
	begin
		kicker1 = 4'b0000;
		kicker2 = 4'b0000;
		kicker3 = 4'b0000;
	end
end

endmodule

/*-----------------------------------------------------------
-------------------------------------------------------------
find_pair
-------------------------------------------------------------
-----------------------------------------------------------*/
module find_pair(one, two, three, four, five, six, seven, found, card_value);
input [5:0]one, two, three, four, five, six, seven; 
output found;
output [3:0]card_value;
reg found;
reg [3:0]card_value;

wire [3:0]m_one, m_two, m_three, m_four, m_five, m_six, m_seven; 

assign m_one = one[3:0];
assign m_two = two[3:0];
assign m_three = three[3:0];
assign m_four = four[3:0];
assign m_five = five[3:0];
assign m_six = six[3:0];
assign m_seven = seven[3:0];

always @(one or two or three or four or five or six or seven or 
m_one or  m_two or  m_three or  m_four or  m_five or  m_six or  m_seven)
begin
	if (m_one == m_two)
	begin
		card_value = one[3:0];
		found = 1'b1;
	end
	else if (m_two == m_three)
	begin
		card_value = two[3:0];
		found = 1'b1;
	end
	else if (m_three == m_four)
	begin
		card_value = three[3:0];
		found = 1'b1;
	end
	else if (m_four == m_five)
	begin
		card_value = four[3:0];
		found = 1'b1;
	end
	else if (m_five == m_six)
	begin
		card_value = five[3:0];
		found = 1'b1;
	end
	else if (m_six == m_seven)
	begin
		card_value = six[3:0];
		found = 1'b1;
	end
	else
	begin
		card_value = 4'b0000;
		found = 1'b0;
	end

end

endmodule
	
/*-----------------------------------------------------------
-------------------------------------------------------------
find_two_pair
-------------------------------------------------------------
-----------------------------------------------------------*/
module find_two_pair(one, two, three, four, five, six, seven, found, pair1_card_value, pair2_card_value, kicker);
input [5:0]one, two, three, four, five, six, seven; 
output found;
output [3:0]pair1_card_value;
output [3:0]pair2_card_value;
output [3:0]kicker;
reg found;
wire [3:0]pair1_card_value;
wire [3:0]pair2_card_value;
reg [3:0]kicker;

wire [3:0]m_one, m_two, m_three, m_four, m_five, m_six, m_seven; 
wire [3:0]n_one, n_two, n_three, n_four, n_five, n_six, n_seven; 

assign m_one = one[3:0];
assign m_two = two[3:0];
assign m_three = three[3:0];
assign m_four = four[3:0];
assign m_five = five[3:0];
assign m_six = six[3:0];
assign m_seven = seven[3:0];

wire pair1;
wire pair2;

find_pair find_pair1({2'b00, m_one}, {2'b00, m_two}, {2'b00, m_three}, {2'b00, m_four}, {2'b00, m_five}, {2'b00, m_six}, {2'b00, m_seven}, pair1, pair1_card_value);

// remove the pair
assign n_one = (pair1_card_value == one[3:0]) ? 4'b0000 : one[3:0];
assign n_two = (pair1_card_value == two[3:0]) ? 4'b0000 : two[3:0];
assign n_three = (pair1_card_value == three[3:0]) ? 4'b0000 : three[3:0];
assign n_four = (pair1_card_value == four[3:0]) ? 4'b0000 : four[3:0];
assign n_five = (pair1_card_value == five[3:0]) ? 4'b0000 : five[3:0];
assign n_six = (pair1_card_value == six[3:0]) ? 4'b0000 : six[3:0];
assign n_seven = (pair1_card_value == seven[3:0]) ? 4'b0000 :seven[3:0];

find_pair find_pair2({2'b00, n_one}, {2'b00, n_two}, {2'b00, n_three}, {2'b00, n_four}, {2'b00, n_five}, {2'b00, n_six}, {2'b00, n_seven}, pair2, pair2_card_value);

always @(one or two or three or four or five or six or seven or
pair1 or pair2 or pair1_card_value or pair2_card_value) 
begin
	if (pair1 == 1'b1 && pair2 == 1'b1)
	begin
		if (pair1_card_value != one[3:0] && pair2_card_value != one[3:0])
		begin
			found = 1'b1;
			kicker = one[3:0];
		end
		else if (pair1_card_value != two[3:0] && pair2_card_value != two[3:0])	
		begin
			found = 1'b1;
			kicker = two[3:0];
		end
		else if (pair1_card_value != three[3:0] && pair2_card_value != three[3:0])	
		begin
			found = 1'b1;
			kicker = three[3:0];
		end
		else if (pair1_card_value != four[3:0] && pair2_card_value != four[3:0])	
		begin
			found = 1'b1;
			kicker = four[3:0];
		end
		else if (pair1_card_value != five[3:0] && pair2_card_value != five[3:0])	
		begin
			found = 1'b1;
			kicker = five[3:0];
		end
		else if (pair1_card_value != six[3:0] && pair2_card_value != six[3:0])	
		begin
			found = 1'b1;
			kicker = six[3:0];
		end
		else if (pair1_card_value != seven[3:0] && pair2_card_value != seven[3:0])
		begin
			found = 1'b1;
			kicker = seven[3:0];
		end
		else
		begin
			kicker = 4'b0000;
			found = 1'b0;
		end
	end
	else
	begin
		kicker = 4'b0000;
		found = 1'b0;
	end
end

endmodule

/*-----------------------------------------------------------
-------------------------------------------------------------
find_full_house
-------------------------------------------------------------
-----------------------------------------------------------*/
module find_full_house(one, two, three, four, five, six, seven, found, three_card_value, two_card_value);
input [5:0]one, two, three, four, five, six, seven; 
output found;
output [3:0]three_card_value;
output [3:0]two_card_value;
reg found;
wire[3:0]three_card_value;
reg [3:0]two_card_value;

wire [3:0]m_one, m_two, m_three, m_four, m_five, m_six, m_seven; 

assign m_one = one[3:0];
assign m_two = two[3:0];
assign m_three = three[3:0];
assign m_four = four[3:0];
assign m_five = five[3:0];
assign m_six = six[3:0];
assign m_seven = seven[3:0];

wire three_found;
wire[3:0]kicker1;
wire[3:0]kicker2;
find_three_of_a_kind find_three({2'b00, m_one}, {2'b00, m_two}, {2'b00, m_three}, {2'b00, m_four}, {2'b00, m_five}, {2'b00, m_six}, {2'b00, m_seven}, three_found, three_card_value, kicker1, kicker2); // kickers not wired...

always @(three_found or three_card_value or one or two or three or four or five or six or seven or 
m_one or  m_two or  m_three or  m_four or  m_five or  m_six or  m_seven) 
begin
	if (three_found == 1'b1)
	begin
		if (three_card_value != one[3:0] && three_card_value != two[3:0] && m_one == m_two)
		begin
			two_card_value = one[3:0];
			found = 1'b1;
		end
		else if (three_card_value != two[3:0] && three_card_value != three[3:0] && m_two == m_three)
		begin
			two_card_value = two[3:0];
			found = 1'b1;
		end
		else if (three_card_value != three[3:0] && three_card_value != four[3:0] && m_three == m_four)
		begin
			two_card_value = three[3:0];
			found = 1'b1;
		end
		else if (three_card_value != four[3:0] && three_card_value != five[3:0] && m_four == m_five)
		begin
			two_card_value = four[3:0];
			found = 1'b1;
		end
		else if (three_card_value != five[3:0] && three_card_value != six[3:0] && m_five == m_six)
		begin
			two_card_value = five[3:0];
			found = 1'b1;
		end
		else if (three_card_value != six[3:0] && three_card_value != seven[3:0] && m_six == m_seven)
		begin
			two_card_value = six[3:0];
			found = 1'b1;
		end
		else
		begin
			two_card_value = 4'b0000;
			found = 1'b0;
		end
	end
	else
	begin
		two_card_value = 4'b0000;
		found = 1'b0;
	end
end

endmodule

/*-----------------------------------------------------------
-------------------------------------------------------------
find_three_of_a_kind
-------------------------------------------------------------
-----------------------------------------------------------*/
module find_three_of_a_kind(one, two, three, four, five, six, seven, found, card_value, kicker1, kicker2);
input [5:0]one, two, three, four, five, six, seven; 
output found;
output [3:0]card_value;
output [3:0]kicker1, kicker2;
reg found;
reg [3:0]card_value;
reg [3:0]kicker1, kicker2;

wire [3:0]m_one, m_two, m_three, m_four, m_five, m_six, m_seven; 

assign m_one = one[3:0];
assign m_two = two[3:0];
assign m_three = three[3:0];
assign m_four = four[3:0];
assign m_five = five[3:0];
assign m_six = six[3:0];
assign m_seven = seven[3:0];

always @(one or two or three or four or five or six or seven or
m_one or  m_two or  m_three or  m_four or  m_five or  m_six or  m_seven) 
begin
	if (m_one == m_two && m_two == m_three)
	begin
		card_value = one[3:0];
		kicker1 = four[3:0];
		kicker2 = five[3:0];
		found = 1'b1;
	end
	else if (m_two == m_three && m_three == m_four)
	begin
		card_value = two[3:0];
		kicker1 = one[3:0];
		kicker2 = four[3:0];
		found = 1'b1;
	end
	else if (m_four == m_five && m_three == m_four)
	begin
		card_value = three[3:0];
		kicker1 = one[3:0];
		kicker2 = two[3:0];
		found = 1'b1;
	end
	else if (m_four == m_five && m_five == m_six)
	begin
		card_value = four[3:0];
		kicker1 = one[3:0];
		kicker2 = two[3:0];
		found = 1'b1;
	end
	else if (m_six == m_seven && m_five == m_six)
	begin
		card_value = five[3:0];
		kicker1 = one[3:0];
		kicker2 = two[3:0];
		found = 1'b1;
	end
	else
	begin
		card_value = 4'b0000;
		kicker1 = 4'b0000;
		kicker2 = 4'b0000;
		found = 1'b0;
	end
end

endmodule

/*-----------------------------------------------------------
-------------------------------------------------------------
 find_four_of_a_kind
-------------------------------------------------------------
-----------------------------------------------------------*/
module find_four_of_a_kind(one, two, three, four, five, six, seven, found, card_value);
input [5:0]one, two, three, four, five, six, seven; 
output found;
output [3:0]card_value;
reg found;
reg [3:0]card_value;

wire [3:0]m_one, m_two, m_three, m_four, m_five, m_six, m_seven; 

assign m_one = one[3:0];
assign m_two = two[3:0];
assign m_three = three[3:0];
assign m_four = four[3:0];
assign m_five = five[3:0];
assign m_six = six[3:0];
assign m_seven = seven[3:0];

always @(one or two or three or four or five or six or seven or
m_one or  m_two or  m_three or  m_four or  m_five or  m_six or  m_seven) 
begin
	if (m_one == m_two && m_two == m_three && m_three == m_four)
	begin
		card_value = one[3:0];
		found = 1'b1;
	end
	else if (m_four == m_five && m_two == m_three && m_three == m_four)
	begin
		card_value = two[3:0];
		found = 1'b1;
	end
	else if (m_four == m_five && m_five == m_six && m_three == m_four)
	begin
		card_value = three[3:0];
		found = 1'b1;
	end
	else if (m_four == m_five && m_five == m_six && m_six == m_seven)
	begin
		card_value = four[3:0];
		found = 1'b1;
	end
	else
	begin
		card_value = 4'b0000;
		found = 1'b0;
	end
end

endmodule

/*-----------------------------------------------------------
-------------------------------------------------------------
find_flush
-------------------------------------------------------------
-----------------------------------------------------------*/
module find_flush(one, two, three, four, five, six, seven, flush, card_value1, card_value2, card_value3, card_value4, card_value5);
input [5:0]one, two, three, four, five, six, seven; 
output flush;
output [3:0]card_value1;
output [3:0]card_value2;
output [3:0]card_value3;
output [3:0]card_value4;
output [3:0]card_value5;
reg flush;
wire [3:0]card_value, card_value2, card_value3, card_value4, card_value5;

wire [1:0]suit_one, suit_two, suit_three, suit_four, suit_five, suit_six, suit_seven; 
assign suit_one = one[5:4];
assign suit_two = two[5:4];
assign suit_three = three[5:4];
assign suit_four = four[5:4];
assign suit_five = five[5:4];
assign suit_six = six[5:4];
assign suit_seven = seven[5:4];

wire heart_one, heart_two, heart_three, heart_four, heart_five, heart_six, heart_seven; 
assign heart_one   = (suit_one   == 2'b11) ? 1'b1 : 1'b0;
assign heart_two   = (suit_two   == 2'b11) ? 1'b1 : 1'b0;
assign heart_three = (suit_three == 2'b11) ? 1'b1 : 1'b0;
assign heart_four  = (suit_four  == 2'b11) ? 1'b1 : 1'b0;
assign heart_five  = (suit_five  == 2'b11) ? 1'b1 : 1'b0;
assign heart_six   = (suit_six   == 2'b11) ? 1'b1 : 1'b0;
assign heart_seven = (suit_seven == 2'b11) ? 1'b1 : 1'b0;
wire diamond_one, diamond_two, diamond_three, diamond_four, diamond_five, diamond_six, diamond_seven; 
assign diamond_one   = (suit_one   == 2'b10) ? 1'b1 : 1'b0;
assign diamond_two   = (suit_two   == 2'b10) ? 1'b1 : 1'b0;
assign diamond_three = (suit_three == 2'b10) ? 1'b1 : 1'b0;
assign diamond_four  = (suit_four  == 2'b10) ? 1'b1 : 1'b0;
assign diamond_five  = (suit_five  == 2'b10) ? 1'b1 : 1'b0;
assign diamond_six   = (suit_six   == 2'b10) ? 1'b1 : 1'b0;
assign diamond_seven = (suit_seven == 2'b10) ? 1'b1 : 1'b0;
wire spade_one, spade_two, spade_three, spade_four, spade_five, spade_six, spade_seven; 
assign spade_one   = (suit_one   == 2'b00) ? 1'b1 : 1'b0;
assign spade_two   = (suit_two   == 2'b00) ? 1'b1 : 1'b0;
assign spade_three = (suit_three == 2'b00) ? 1'b1 : 1'b0;
assign spade_four  = (suit_four  == 2'b00) ? 1'b1 : 1'b0;
assign spade_five  = (suit_five  == 2'b00) ? 1'b1 : 1'b0;
assign spade_six   = (suit_six   == 2'b00) ? 1'b1 : 1'b0;
assign spade_seven = (suit_seven == 2'b00) ? 1'b1 : 1'b0;
wire club_one, club_two, club_three, club_four, club_five, club_six, club_seven; 
assign club_one   = (suit_one   == 2'b01) ? 1'b1 : 1'b0;
assign club_two   = (suit_two   == 2'b01) ? 1'b1 : 1'b0;
assign club_three = (suit_three == 2'b01) ? 1'b1 : 1'b0;
assign club_four  = (suit_four  == 2'b01) ? 1'b1 : 1'b0;
assign club_five  = (suit_five  == 2'b01) ? 1'b1 : 1'b0;
assign club_six   = (suit_six   == 2'b01) ? 1'b1 : 1'b0;
assign club_seven = (suit_seven == 2'b01) ? 1'b1 : 1'b0;

wire [3:0]heart_card_one, heart_card_two, heart_card_three, heart_card_four, heart_card_five, heart_card_six, heart_card_seven; 
assign heart_card_one   = (suit_one   == 2'b11) ? one[3:0] : 4'b0000;
assign heart_card_two   = (suit_two   == 2'b11) ? two[3:0] : 4'b0000;
assign heart_card_three = (suit_three == 2'b11) ? three[3:0] : 4'b0000;
assign heart_card_four  = (suit_four  == 2'b11) ? four[3:0] : 4'b0000;
assign heart_card_five  = (suit_five  == 2'b11) ? five[3:0] : 4'b0000;
assign heart_card_six   = (suit_six   == 2'b11) ? six[3:0] : 4'b0000;
assign heart_card_seven = (suit_seven == 2'b11) ? seven[3:0] : 4'b0000;
wire [3:0]diamond_card_one, diamond_card_two, diamond_card_three, diamond_card_four, diamond_card_five, diamond_card_six, diamond_card_seven; 
assign diamond_card_one   = (suit_one   == 2'b10) ? one[3:0] : 4'b0000;
assign diamond_card_two   = (suit_two   == 2'b10) ? two[3:0] : 4'b0000;
assign diamond_card_three = (suit_three == 2'b10) ? three[3:0] : 4'b0000;
assign diamond_card_four  = (suit_four  == 2'b10) ? four[3:0] : 4'b0000;
assign diamond_card_five  = (suit_five  == 2'b10) ? five[3:0] : 4'b0000;
assign diamond_card_six   = (suit_six   == 2'b10) ? six[3:0] : 4'b0000;
assign diamond_card_seven = (suit_seven == 2'b10) ? seven[3:0] : 4'b0000;
wire [3:0]spade_card_one, spade_card_two, spade_card_three, spade_card_four, spade_card_five, spade_card_six, spade_card_seven; 
assign spade_card_one   = (suit_one   == 2'b00) ? one[3:0] : 4'b0000;
assign spade_card_two   = (suit_two   == 2'b00) ? two[3:0] : 4'b0000;
assign spade_card_three = (suit_three == 2'b00) ? three[3:0] : 4'b0000;
assign spade_card_four  = (suit_four  == 2'b00) ? four[3:0] : 4'b0000;
assign spade_card_five  = (suit_five  == 2'b00) ? five[3:0] : 4'b0000;
assign spade_card_six   = (suit_six   == 2'b00) ? six[3:0] : 4'b0000;
assign spade_card_seven = (suit_seven == 2'b00) ? seven[3:0] : 4'b0000;
wire [3:0]club_card_one, club_card_two, club_card_three, club_card_four, club_card_five, club_card_six, club_card_seven; 
assign club_card_one   = (suit_one   == 2'b01) ? one[3:0] : 4'b0000;
assign club_card_two   = (suit_two   == 2'b01) ? two[3:0] : 4'b0000;
assign club_card_three = (suit_three == 2'b01) ? three[3:0] : 4'b0000;
assign club_card_four  = (suit_four  == 2'b01) ? four[3:0] : 4'b0000;
assign club_card_five  = (suit_five  == 2'b01) ? five[3:0] : 4'b0000;
assign club_card_six   = (suit_six   == 2'b01) ? six[3:0] : 4'b0000;
assign club_card_seven = (suit_seven == 2'b01) ? seven[3:0] : 4'b0000;

wire [2:0]hearts;
assign hearts = heart_one + heart_two + heart_three + heart_four + heart_five + heart_six + heart_seven;
wire [2:0]diamonds;
assign diamonds = diamond_one + diamond_two + diamond_three + diamond_four + diamond_five + diamond_six + diamond_seven;
wire [2:0]spades;
assign spades = spade_one + spade_two + spade_three + spade_four + spade_five + spade_six + spade_seven;
wire [2:0]clubs;
assign clubs = club_one + club_two + club_three + club_four + club_five + club_six + club_seven;

reg [5:0]flush_card1, flush_card2, flush_card3, flush_card4, flush_card5, flush_card6, flush_card7;
wire [5:0]not_need1, not_need2;
sort_cards sort_the_flush(flush_card1, flush_card2, flush_card3, flush_card4, flush_card5, flush_card6, flush_card7, card_value1, card_value2, card_value3, card_value4, card_value5, not_need1, not_need2); 

always @(hearts or diamonds or spades or clubs or
heart_card_one or  heart_card_two or  heart_card_three or  heart_card_four or  heart_card_five or  heart_card_six or  heart_card_seven or  
diamond_card_one or  diamond_card_two or  diamond_card_three or  diamond_card_four or  diamond_card_five or  diamond_card_six or  diamond_card_seven or  
spade_card_one or  spade_card_two or  spade_card_three or  spade_card_four or  spade_card_five or  spade_card_six or  spade_card_seven or  
club_card_one or  club_card_two or  club_card_three or  club_card_four or  club_card_five or  club_card_six or  club_card_seven)
begin
	if (hearts >= 5)
	begin
		flush = 1'b1;
		flush_card1 = {2'b00, heart_card_one};
		flush_card2 = {2'b00, heart_card_two};
		flush_card3 = {2'b00, heart_card_three};
		flush_card4 = {2'b00, heart_card_four};
		flush_card5 = {2'b00, heart_card_five};
		flush_card6 = {2'b00, heart_card_six};
		flush_card7 = {2'b00, heart_card_seven};
	end
	else if (diamonds >= 5)
	begin
		flush = 1'b1;
		flush_card1 = {2'b00, diamond_card_one};
		flush_card2 = {2'b00, diamond_card_two};
		flush_card3 = {2'b00, diamond_card_three};
		flush_card4 = {2'b00, diamond_card_four};
		flush_card5 = {2'b00, diamond_card_five};
		flush_card6 = {2'b00, diamond_card_six};
		flush_card7 = {2'b00, diamond_card_seven};
	end
	else if (spades >= 5)
	begin
		flush = 1'b1;
		flush_card1 = {2'b00, spade_card_one};
		flush_card2 = {2'b00, spade_card_two};
		flush_card3 = {2'b00, spade_card_three};
		flush_card4 = {2'b00, spade_card_four};
		flush_card5 = {2'b00, spade_card_five};
		flush_card6 = {2'b00, spade_card_six};
		flush_card7 = {2'b00, spade_card_seven};
	end
	else if (clubs >= 5)
	begin
		flush = 1'b1;
		flush_card1 = {2'b00, club_card_one};
		flush_card2 = {2'b00, club_card_two};
		flush_card3 = {2'b00, club_card_three};
		flush_card4 = {2'b00, club_card_four};
		flush_card5 = {2'b00, club_card_five};
		flush_card6 = {2'b00, club_card_six};
		flush_card7 = {2'b00, club_card_seven};
	end
	else
	begin
		flush = 1'b0;
		flush_card1 = 6'b000000;
		flush_card2 = 6'b000000;
		flush_card3 = 6'b000000;
		flush_card4 = 6'b000000;
		flush_card5 = 6'b000000;
		flush_card6 = 6'b000000;
		flush_card7 = 6'b000000;
	end
end

endmodule

/*-----------------------------------------------------------
-------------------------------------------------------------
 find_run
-------------------------------------------------------------
-----------------------------------------------------------*/
module find_run(one, two, three, four, five, six, seven, run, run_flush, card_value);
input [5:0]one, two, three, four, five, six, seven; 
output run;
output run_flush;
output [3:0]card_value;
reg run;
reg run_flush;
reg [3:0]card_value;

wire [5:0]/*m_one,*/ m_two, m_three, m_four, m_five, m_six, m_seven; 
wire [5:0]u_one, u_two, u_three, u_four, u_five, u_six, u_seven; // unique
wire [5:0]us_one, us_two, us_three, us_four, us_five, us_six, us_seven; 

// for any duplicates put a 0 in that card spot
unique_set remove_duplicates(one, two, three, four, five, six, seven, u_one, u_two, u_three, u_four, u_five, u_six, u_seven); 
// unique put 0's in duplicate spots, so we sort again to check for runs
sort_cards sort_the_unique(u_one, u_two, u_three, u_four, u_five, u_six, u_seven, us_one, us_two, us_three, us_four, us_five, us_six, us_seven); 

// pre do the subtraction
//assign m_one = {us_one[5:4], us_one[3:0] - 1'b1};
assign m_two = {us_two[5:4], us_two[3:0] - 1'b1};
assign m_three = {us_three[5:4], us_three[3:0] - 1'b1};
assign m_four = {us_four[5:4], us_four[3:0] - 1'b1};
assign m_five = {us_five[5:4], us_five[3:0] - 1'b1};
assign m_six = {us_six[5:4], us_six[3:0] - 1'b1};
assign m_seven = {us_seven[5:4], us_seven[3:0] - 1'b1};

always @(u_two or one or two or three or four or five or six or seven or m_two or m_three or m_four or m_five or m_six or m_seven or us_one or us_two or us_three or us_four or us_five or us_six or us_seven)
begin
	// Only three possible run spots starting at 1, 2, or 3...
	if (us_one[3:0] == m_two && us_two[3:0] == m_three && us_three[3:0] == m_four && us_four[3:0] == m_five && 
			us_one[5:4] == us_two[5:4] && us_two[5:4] == us_three[5:4] && us_three[5:4] == us_four[5:4] && us_four[5:4] == us_five[5:4])
	begin
		run_flush = 1'b1;
		run = 1'b0;
		card_value = one[3:0]; // 1
	end
	else if (us_two[3:0] == m_three  &&  us_three[3:0] == m_four  &&  us_four[3:0] == m_five  &&  us_five[3:0] == m_six &&
			us_two[5:4] == us_three[5:4] && us_three[5:4] == us_four[5:4] && us_four[5:4] == us_five[5:4] && us_five[5:4] == us_six[5:4])
	begin
		run_flush = 1'b1;
		run = 1'b0;
		// special case when the second card starts the run...could be the third card if duplicates
		if (u_two == 6'b000000)
			card_value = three[3:0]; // 3
		else
			card_value = two[3:0]; // 2
	end
	else if (us_three[3:0] == m_four  &&  us_four[3:0] == m_five  &&  us_five[3:0] == m_six  &&  us_six[3:0] == m_seven &&
			us_three[5:4] == us_four[5:4] && us_four[5:4] == us_five[5:4] && us_five[5:4] == us_six[5:4] && us_six[5:4] == us_seven[5:4])
	begin
		run_flush = 1'b1;
		run = 1'b0;
		card_value = three[3:0]; // 3
	end
	else if (us_one[3:0] == m_two && us_two[3:0] == m_three && us_three[3:0] == m_four && us_four[3:0] == m_five)
	begin
		run_flush = 1'b0;
		run = 1'b1;
		card_value = one[3:0]; // 1
	end
	else if (us_two[3:0] == m_three  &&  us_three[3:0] == m_four  &&  us_four[3:0] == m_five  &&  us_five[3:0] == m_six)
	begin
		run_flush = 1'b0;
		run = 1'b1;
		// special case when the second card starts the run...could be the third card if duplicates
		if (u_two == 6'b000000)
			card_value = three[3:0]; // 3
		else
			card_value = two[3:0]; // 2
	end
	else if (us_three[3:0] == m_four  &&  us_four[3:0] == m_five  &&  us_five[3:0] == m_six  &&  us_six[3:0] == m_seven)
	begin
		run_flush = 1'b0;
		run = 1'b1;
		card_value = three[3:0]; // 3
	end
	else
	begin
		run_flush = 1'b0;
		run = 1'b0;
		card_value = 4'b0000; // no run
	end
end

endmodule

/*-----------------------------------------------------------
-------------------------------------------------------------
unique_set
-------------------------------------------------------------
-----------------------------------------------------------*/
module unique_set (one, two, three, four, five, six, seven, u_one, u_two, u_three, u_four, u_five, u_six, u_seven); 
input [5:0]one, two, three, four, five, six, seven; 
output [5:0]u_one, u_two, u_three, u_four, u_five, u_six, u_seven; 
reg [5:0]u_one, u_two, u_three, u_four, u_five, u_six, u_seven; 

always @(one or two or three or four or five or six or seven) 
begin
	u_one = one;
	if (two == one)
		u_two = 6'b000000;
	else
		u_two = two;
	
	if (three == two)
		u_three = 6'b000000;
	else
		u_three = three;

	if (four == three)
		u_four = 6'b000000;
	else
		u_four = four;

	if (five == four)
		u_five = 6'b000000;
	else
		u_five = four;

	if (six == five)
		u_six = 6'b000000;
	else
		u_six = five;

	if (seven == six)
		u_seven = 6'b000000;
	else
		u_seven = five;
end
endmodule

/*-----------------------------------------------------------
-------------------------------------------------------------
 sort_cards
// sorts the cards combinationally via swaps
-------------------------------------------------------------
-----------------------------------------------------------*/
module sort_cards(one, two, three, four, five, six, seven, s_one, s_two, s_three, s_four, s_five, s_six, s_seven);
input [5:0]one, two, three, four, five, six, seven; 
output [5:0]s_one, s_two, s_three, s_four, s_five, s_six, s_seven;
wire [5:0]s_one, s_two, s_three, s_four, s_five, s_six, s_seven;

wire [5:0]s1_one, s1_two, s1_three, s1_four, s1_five, s1_six;
wire [5:0]s2_two, s2_three, s2_four, s2_five, s2_six;
wire [5:0]s3_one, s3_two, s3_three, s3_four, s3_five;
wire [5:0]s4_two, s4_three, s4_four, s4_five;
wire [5:0]s5_one, s5_two, s5_three, s5_four;
wire [5:0]s6_two, s6_three, s6_four;
wire [5:0]s7_one, s7_two, s7_three;
wire [5:0]s8_two, s8_three;
wire [5:0]s9_one, s9_two;
wire [5:0]s10_two;

// finds smallest and outputs in s_seven
sort_2 a1(one, two, s1_one, s1_two);
sort_2 b1(s1_two, three, s2_two, s1_three);
sort_2 c1(s1_three, four, s2_three, s1_four);
sort_2 d1(s1_four, five, s2_four, s1_five);
sort_2 e1(s1_five, six, s2_five, s1_six);
sort_2 f1(s1_six, seven, s2_six, s_seven);

sort_2 a2(s1_one,   s2_two,   s3_one,   s3_two);
sort_2 b2(s3_two,   s2_three, s4_two,   s3_three);
sort_2 c2(s3_three, s2_four,  s4_three, s3_four);
sort_2 d2(s3_four,  s2_five,  s4_four,  s3_five);
sort_2 e2(s3_five,  s2_six,   s4_five,  s_six);

sort_2 a3(s3_one,   s4_two,   s5_one,   s5_two);
sort_2 b3(s5_two,   s4_three, s6_two,   s5_three);
sort_2 c3(s5_three, s4_four,  s6_three, s5_four);
sort_2 d3(s5_four,  s4_five,  s6_four,  s_five);

sort_2 a4(s5_one,   s6_two,   s7_one,   s7_two);
sort_2 b4(s7_two,   s6_three, s8_two,   s7_three);
sort_2 c4(s7_three, s6_four,  s8_three, s_four);

sort_2 a5(s7_one,   s8_two,   s9_one,   s9_two);
sort_2 b5(s9_two,   s8_three, s10_two,   s_three);

sort_2 a6(s9_one,   s10_two,   s_one,   s_two);

endmodule

/*-----------------------------------------------------------
-------------------------------------------------------------
sort_2
-------------------------------------------------------------
-----------------------------------------------------------*/
module sort_2(one, two, s_one, s_two);
input [5:0]one, two;
output [5:0]s_one, s_two;
reg [5:0]s_one, s_two;

always @(one or two)
begin
	if (one > two)
	begin
		s_one = one;
		s_two = two;
	end
	else
	begin
		s_one = two;
		s_two = one;
	end


end
endmodule
