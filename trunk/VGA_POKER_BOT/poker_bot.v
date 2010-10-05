
/*-----------------------------------------------------------
-------------------------------------------------------------
Poker bot
Top level module that hooks up 2 players and the dealer and
decodes information about the cards and game
-------------------------------------------------------------
-----------------------------------------------------------*/
module poker_bot (
clk, rst, 
game_over, 
start_game,
P1C1, P1C2, P2C1, P2C2, flop, turn, river,
pot,
p1_bank, p2_bank,
next_hand_user,
change,
done_draw_screen,
debug_info
);
input clk, rst;
input start_game; // pulse based signal to start a game
output game_over; // signal when someone has 0 left
reg game_over; 
output [5:0] P1C1, P1C2, P2C1, P2C2, river, turn; // Cards to players
output [17:0] flop; // flop
output [7:0]pot; 
output [7:0]p1_bank, p2_bank;
input next_hand_user;
output change;
input done_draw_screen;

output [9:0]debug_info;
wire [9:0]debug_info;
wire [5:0]debug1;
assign debug_info = {cur,debug1, S};

reg next_hand;

wire [2:0]p1_action, p2_action;
wire [7:0]p1_players_money, p2_players_money;
wire p1_valid, p2_valid;
wire next_deal;
wire p1_ack_from_dealer, p2_ack_from_dealer;
reg [5:0] P1C1, P1C2, P2C1, P2C2, river, turn;
reg [17:0] flop;
wire [5:0] P1C1o, P1C2o, P2C1o, P2C2o, rivero, turno;
wire [17:0] flopo;
wire p1_request_for_in, p2_request_for_in;
wire p1_invalid, p2_invalid;
wire [2:0]p1_last_action, p2_last_action;
wire [7:0]p1_last_bet, p2_last_bet;
wire [7:0]pot;
wire [7:0]p1_bank, p2_bank;
/* P1 */
poker_player_base p1(clk, rst, p1_valid, p1_ack_from_dealer, p1_request_for_in, 
	P1C1o, P1C2o, flopo, turno, rivero, p1_action, p1_players_money, p1_invalid,
	p1_bank, p2_last_action, p2_last_bet, pot, next_hand, betting_round_done);
/* P2 */
poker_player_base p2(clk, rst, p2_valid, p2_ack_from_dealer, p2_request_for_in, 
	P2C1o, P2C2o, flopo, turno, rivero, p2_action, p2_players_money, p2_invalid,
	p2_bank, p1_last_action, p1_last_bet, pot, next_hand, betting_round_done);

/* dealer */
wire hand_done;
wire betting_round_done;
wire change;
dealer the_dealer(clk, rst, {p2_action, p1_action}, {p2_players_money, p1_players_money}, {p2_valid, p1_valid}, next_hand, next_hand_user, hand_done,
	{p2_ack_from_dealer, p1_ack_from_dealer}, P1C1o, P1C2o, P2C1o, P2C2o, flopo, turno, rivero, {p2_request_for_in, p1_request_for_in},
	{p2_invalid, p1_invalid}, {p2_last_action, p1_last_action}, {p2_last_bet, p1_last_bet}, betting_round_done, pot, p2_bank, p1_bank, game_over, change, debug1);

reg[2:0]S, NS;

//reg next_hand;

// State machine waits for the game to start, then moves through hands until there is a winner.  Controls the next hand signal
parameter 
WAIT = 3'b001,
NEXT_HAND_START = 3'b010,
HAND_HAPPENING = 3'b011,
CHECK_RESULTS = 3'b100,
NEXT_HAND_USER_START = 3'b110,
NEXT_HAND_USER_FINISH = 3'b111,
CHECK_GAME = 3'b101;

reg cur;
always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		P1C1 <= 6'b0000000;
		P1C2 <= 6'b0000000;
		P2C1 <= 6'b0000000;
		P2C2 <= 6'b0000000;
		river <= 6'b0000000;
		turn <= 6'b0000000;
		flop <= 17'd0;
		cur <= 1'b0;
	end
	else
	begin
		if (change == 1'b1)
		begin
			P1C1 <= P1C1o;
			P1C2 <= P1C2o;
			P2C1 <= P2C1o;
			P2C2 <= P2C2o;
			river <= rivero;
			turn <= turno;
			flop <= flopo;
			cur <= cur ^ 1'b1;
		end
	end
end

always @(S or start_game or hand_done or game_over or next_hand_user or done_draw_screen)
begin
	case (S)
		WAIT:
		begin
			if (start_game == 1'b1)
				NS = NEXT_HAND_USER_START;
			else
				NS = WAIT;
		end
		NEXT_HAND_USER_START:
		begin
			if (next_hand_user == 1'b1)
				NS = NEXT_HAND_USER_FINISH;
			else
				NS = NEXT_HAND_USER_START;
		end
		NEXT_HAND_USER_FINISH:
		begin
			if (next_hand_user == 1'b0)
				NS = NEXT_HAND_START;
			else
				NS = NEXT_HAND_USER_FINISH;
		end
		NEXT_HAND_START:
		begin
				NS = HAND_HAPPENING;
		end
		HAND_HAPPENING:	
		begin
			if (hand_done == 1'b1)
				NS = CHECK_RESULTS;
			else
				NS = HAND_HAPPENING;
		end
		CHECK_RESULTS:
		begin
			NS = CHECK_GAME;
		end
		CHECK_GAME:
		begin
			if (game_over == 1'b1)
				NS = WAIT;
			else if (done_draw_screen == 1'b1)
				NS = NEXT_HAND_USER_START;
			else
				NS = CHECK_GAME;
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
		next_hand <= 1'b0;
		game_over <= 1'b0;
	end
	else
	begin
		case (S)
			WAIT:
			begin
				next_hand <= 1'b0;
				game_over <= 1'b0;
			end
			NEXT_HAND_USER_START:
			begin
				next_hand <= 1'b0;
				game_over <= 1'b0;
			end
			NEXT_HAND_USER_FINISH:
			begin
				next_hand <= 1'b0;
				game_over <= 1'b0;
			end
			NEXT_HAND_START:
			begin
				next_hand <= 1'b1;
				game_over <= 1'b0;
			end
			HAND_HAPPENING:	
			begin
				next_hand <= 1'b0;
				game_over <= 1'b0;
			end
			CHECK_RESULTS:
			begin
				next_hand <= 1'b0;
				if (p1_bank == 8'b00000000)
				begin
					game_over <= 1'b1;
				end
				else if (p2_bank == 8'b00000000)
				begin
					game_over <= 1'b1;
				end
				else 
				begin
					game_over <= 1'b0;
				end
			end
			CHECK_GAME:
			begin
				next_hand <= 1'b0;
			end
	
		endcase
	end
end

endmodule

