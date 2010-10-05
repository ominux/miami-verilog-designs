module poker_player_peter_v1(
clk, 
rst, 
output_valid, 
dealer_acknowledge, 
dealer_request_action, 
card1,
card2,
flop,
turn,
river,
action,
make_bet,
invalid_move,
money_left,
action_opponent,
bet_opponent,
pot_size,
next_deal,
betting_round_done
);

input clk;
input rst;
output output_valid;
input dealer_acknowledge;
input dealer_request_action;
input [5:0]card1, card2, turn, river;
input [17:0]flop;
output [2:0]action;
output [7:0]make_bet;
input invalid_move;
input [7:0]money_left; // how much you have
input [2:0]action_opponent; // opponents last move
input [7:0]bet_opponent; // opponents last bet
input [7:0]pot_size; // size of the current pot
input next_deal; // goes high if hand is done and next hand started
input betting_round_done; // tells the poker_bot the round of betting is done

reg action_defined; // signal set when the bot has set both action and bet as decisions
wire action_request; // signal to indicate when the action needs to be made
wire action_sent; // defines when the information has been sent
/* deals with the communication and sends valid when the action is properly set */
player_communication_protocol talk_with_dealer(clk, rst, output_valid, action_defined, action_decision, bet_decision, action_request, action, make_bet, action_sent, dealer_acknowledge, dealer_request_action);

reg [2:0]action_decision;
reg [7:0]bet_decision;

reg [7:0]round_in_round;

reg [4:0]S, NS;
parameter WAIT = 5'b00000,
WAIT1 = 5'b00001,
WAIT2 = 5'b00010,
WAIT3 = 5'b00011,
ROUND1_BET_0 = 5'b00100,
ROUND2_BET_0 = 5'b00101, 
ROUND3_BET_0 = 5'b00110,
ROUND4_BET_0 = 5'b00111,
ROUND1_BET_1 = 5'b01000,
ROUND2_BET_1 = 5'b01001, 
ROUND3_BET_1 = 5'b01010,
ROUND4_BET_1 = 5'b01011;

wire [2:0]strength;
// evaluates the strength of the starting 2 card hand
starting_hand_evaluation she(clk, rst, card1, card2, strength);

wire [5:0]rand_number;
lfsr_6bit_output randomizer(clk, rst, rand_number);

always @(S or invalid_move or action_request or action_sent or next_deal or betting_round_done)
begin
	case (S)
		WAIT:
		begin
			if (next_deal == 1'b1)
			begin
				NS = WAIT;
			end
			else if (action_request == 1'b1)
			begin
				NS = ROUND1_BET_0;
			end
			else
			begin
				NS = WAIT;
			end
		end
		ROUND1_BET_0:
		begin
			if (next_deal == 1'b1)
			begin
				NS = WAIT;
			end
			else if (action_sent == 1'b1)
			begin
				NS = ROUND1_BET_1;
			end
			else
			begin
				NS = ROUND1_BET_0;
			end
		end
		ROUND1_BET_1:
		begin
			if (next_deal == 1'b1)
			begin
				NS = WAIT;
			end
			else if (invalid_move == 1'b1)
			begin
				NS = ROUND1_BET_0;
			end
			else if (action_request == 1'b1)
			begin
				NS = ROUND1_BET_0;
			end
			else if (betting_round_done == 1'b1)
			begin
				NS = WAIT1;
			end
			else
			begin
				NS = ROUND1_BET_1;
			end
		end
		WAIT1:
		begin
			if (next_deal == 1'b1)
			begin
				NS = WAIT;
			end
			else if (action_request == 1'b1)
			begin
				NS = ROUND2_BET_0;
			end
			else
			begin
				NS = WAIT1;
			end
		end
		ROUND2_BET_0:
		begin
			if (next_deal == 1'b1)
			begin
				NS = WAIT;
			end
			else if (action_sent == 1'b1)
			begin
				NS = ROUND2_BET_1;
			end
			else
			begin
				NS = ROUND2_BET_0;
			end
		end
		ROUND2_BET_1:
		begin
			if (next_deal == 1'b1)
			begin
				NS = WAIT;
			end
			else if (invalid_move == 1'b1)
			begin
				NS = ROUND2_BET_0;
			end
			else if (action_request == 1'b1)
			begin
				NS = ROUND2_BET_0;
			end
			else if (betting_round_done == 1'b1)
			begin
				NS = WAIT2;
			end
			else
			begin
				NS = ROUND2_BET_1;
			end
		end
		WAIT2:
		begin
			if (next_deal == 1'b1)
			begin
				NS = WAIT;
			end
			else if (action_request == 1'b1)
			begin
				NS = ROUND3_BET_0;
			end
			else
			begin
				NS = WAIT2;
			end
		end
		ROUND3_BET_0:
		begin
			if (next_deal == 1'b1)
			begin
				NS = WAIT;
			end
			else if (action_sent == 1'b1)
			begin
				NS = ROUND3_BET_1;
			end
			else
			begin
				NS = ROUND3_BET_0;
			end
		end
		ROUND3_BET_1:
		begin
			if (next_deal == 1'b1)
			begin
				NS = WAIT;
			end
			else if (invalid_move == 1'b1)
			begin
				NS = ROUND3_BET_0;
			end
			else if (action_request == 1'b1)
			begin
				NS = ROUND3_BET_0;
			end
			else if (betting_round_done == 1'b1)
			begin
				NS = WAIT3;
			end
			else
			begin
				NS = ROUND3_BET_1;
			end
		end
		WAIT3:
		begin
			if (next_deal == 1'b1)
			begin
				NS = WAIT;
			end
			else if (action_request == 1'b1)
			begin
				NS = ROUND4_BET_0;
			end
			else
			begin
				NS = WAIT3;
			end
		end
		ROUND4_BET_0:
		begin
			if (next_deal == 1'b1)
			begin
				NS = WAIT;
			end
			else if (action_sent == 1'b1)
			begin
				NS = ROUND4_BET_1;
			end
			else
			begin
				NS = ROUND4_BET_0;
			end
		end
		ROUND4_BET_1:
		begin
			if (next_deal == 1'b1)
			begin
				NS = WAIT;
			end
			else if (invalid_move == 1'b1)
			begin
				NS = ROUND4_BET_0;
			end
			else if (action_request == 1'b1)
			begin
				NS = ROUND4_BET_0;
			end
			else if (betting_round_done == 1'b1)
			begin
				NS = WAIT;
			end
			else
			begin
				NS = ROUND4_BET_1;
			end
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

parameter // Note 000 reserved for no action
NO_ACTION = 3'b000,
FOLD = 3'b001,
CHECK = 3'b010,
BET = 3'b110,
RAISE = 3'b111,
ALL_IN = 3'b011,
CALL = 3'b100;

/* Outputs */
always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		action_decision <= NO_ACTION;
		bet_decision <= 8'b00000000;
		action_defined <= 1'b0;
		round_in_round <= 8'b00000000;
	end
	else
	begin
		case (S)
			WAIT:
			begin
				bet_decision <= 8'b00000000;
				action_defined <= 1'b0;
				round_in_round <= 8'b00000000;
			end
			ROUND1_BET_0:
			begin
				// logic for how to bet
				action_defined <= 1'b1;
				round_in_round <= round_in_round + 1'b1;
				case (action_opponent)
					NO_ACTION:
					begin
						case (strength)
							3'b111:
							begin
								action_decision <= BET;
								bet_decision <= 8'b00010000;
							end
							3'b110:
							begin
								action_decision <= BET;
								bet_decision <= 8'b00001010;
							end
							3'b101:
							begin
								action_decision <= BET;
								bet_decision <= 8'b00001000;
							end
							3'b100:
							begin
								action_decision <= BET;
								bet_decision <= 8'b00000100;
							end
							3'b011:
							begin
								action_decision <= BET;
								bet_decision <= 8'b00000100;
							end
							3'b000:
							begin
								action_decision <= CHECK;
							end
							default:
								action_decision <= NO_ACTION;
						endcase

					end
					FOLD:
					begin
						action_decision <= CHECK;
					end
					CHECK:
					begin
						case (strength)
							3'b111:
							begin
								action_decision <= BET;
								bet_decision <= 8'b00010000;
							end
							3'b110:
							begin
								action_decision <= BET;
								bet_decision <= 8'b00001010;
							end
							3'b101:
							begin
								action_decision <= BET;
								bet_decision <= 8'b00001000;
							end
							3'b100:
							begin
								action_decision <= BET;
								bet_decision <= 8'b00000100;
							end
							3'b011:
							begin
								action_decision <= BET;
								bet_decision <= 8'b00000100;
							end
							3'b000:
							begin
								action_decision <= CHECK;
							end
							default:
								action_decision <= FOLD;
						endcase
					end
					CALL:
					begin
						case (strength)
							3'b111:
							begin
								action_decision <= BET;
								bet_decision <= 8'b00010000;
							end
							3'b110:
							begin
								action_decision <= BET;
								bet_decision <= 8'b00001010;
							end
							3'b101:
							begin
								action_decision <= BET;
								bet_decision <= 8'b00001000;
							end
							3'b100:
							begin
								action_decision <= BET;
								bet_decision <= 8'b00000100;
							end
							3'b011:
							begin
								action_decision <= BET;
								bet_decision <= 8'b00000100;
							end
							3'b000:
							begin
								action_decision <= CALL;
							end
							default:
								action_decision <= FOLD;
						endcase
					end
					BET:
					begin
						case (strength)
							3'b111:
							begin
								if (bet_opponent > 8'b00000100)
								begin
									action_decision <= ALL_IN;
								end
								else
								begin
									action_decision <= RAISE;
									bet_decision <= 8'b00010000;
								end
							end
							3'b110:
							begin
								action_decision <= RAISE;
								bet_decision <= 8'b00010000;
							end
							3'b101:
							begin
								action_decision <= RAISE;
								bet_decision <= 8'b00010000;
							end
							3'b100:
							begin
								action_decision <= RAISE;
								bet_decision <= 8'b00010000;
							end
							3'b011:
							begin
								action_decision <= RAISE;
								bet_decision <= 8'b00010000;
							end
							3'b000:
							begin
								action_decision <= CALL;
							end
							default:
								action_decision <= FOLD;
						endcase
					end
					RAISE:
					begin
						case (strength)
							3'b111:
							begin
								action_decision <= ALL_IN;
							end
							3'b110:
							begin
								if (bet_opponent > 8'b00000100)
								begin
									action_decision <= ALL_IN;
								end
								else
								begin
									action_decision <= RAISE;
									bet_decision <= 8'b00000100;
								end
							end
							3'b101:
							begin
								action_decision <= CALL;
							end
							3'b100:
							begin
								// call 50% of the time
								if (rand_number > 6'b011111)
									action_decision <= CALL;
								else
									action_decision <= FOLD;

							end
							3'b011:
							begin
								action_decision <= FOLD;
							end
							3'b000:
							begin
								action_decision <= FOLD;
							end
							default:
								action_decision <= FOLD;
						endcase
					end
					ALL_IN:
					begin
						case (strength)
							3'b111:
							begin
								action_decision <= CALL;
							end
							3'b110:
							begin	
								action_decision <= CALL;
							end
							3'b101:
							begin
								action_decision <= FOLD;
							end
							3'b100:
							begin
								action_decision <= FOLD;
							end
							3'b011:
							begin
								action_decision <= FOLD;
							end
							3'b000:
							begin
								action_decision <= FOLD;
							end
							default:
								action_decision <= FOLD;
						endcase
					end
				endcase
			end
			ROUND1_BET_1:
			begin
				action_defined <= 1'b0;
			end
			WAIT1:
			begin
				action_defined <= 1'b0;
			end
			ROUND2_BET_0:
			begin
				action_defined <= 1'b1;
				if (action_opponent != CHECK)
				begin
					action_decision <= CALL;
				end
				else
				begin
					action_decision <= CHECK;
				end
			end
			ROUND2_BET_1:
			begin
				action_defined <= 1'b0;
			end
			WAIT2:
			begin
				action_defined <= 1'b0;
			end
			ROUND3_BET_0:
			begin
				action_defined <= 1'b1;
				if (action_opponent != CHECK)
				begin
					action_decision <= CALL;
				end
				else
				begin
					action_decision <= CHECK;
				end
			end
			ROUND3_BET_1:
			begin
				action_defined <= 1'b0;
			end
			WAIT3:
			begin
				action_defined <= 1'b0;
			end
			ROUND4_BET_0:
			begin
				action_defined <= 1'b1;
				if (action_opponent != CHECK)
				begin
					action_decision <= CALL;
				end
				else
				begin
					action_decision <= CHECK;
				end
			end
			ROUND4_BET_1:
			begin
				action_defined <= 1'b0;
			end
		endcase
	end
end

endmodule