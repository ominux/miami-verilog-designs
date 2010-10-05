/*-----------------------------------------------------------
-------------------------------------------------------------
receive_player_input
Function to accept a players input
-------------------------------------------------------------
-----------------------------------------------------------*/
module receive_player_input (
clk, 
rst, 
get_player_input, 
players_input, 
players_money, 
valid_input, 
request_input, 
accepted_input,  
accepted_players_input,
accepted_players_money);

input clk, rst;
input get_player_input; // request to get communicate with a player
input [2:0]players_input; // players input action
input [7:0]players_money; // players bet
input valid_input; // signal is high when the action and bet are valid
output request_input; // request to player
output accepted_input; // tells player when the data has been stored
output [2:0]accepted_players_input; // stored value of action
output [7:0]accepted_players_money; // stored value of input

reg [2:0]accepted_players_input;
reg [7:0]accepted_players_money;
reg request_input;
reg accepted_input;
reg doing_nothing;

reg [1:0]S, NS;
parameter 
DO_NOTHING = 2'b00, 
S_REQUEST_INPUT = 2'b01, 
ACCEPT_INPUT = 2'b10, 
WAIT_FOR_PLAYER_VALID_DONE = 2'b11;

always @(S or valid_input or get_player_input)
begin
	case (S)
		DO_NOTHING:
		begin
			if (get_player_input == 1'b1)
			begin
				NS = S_REQUEST_INPUT;
			end
			else
			begin
				NS = DO_NOTHING;
			end
		end
		S_REQUEST_INPUT:
		begin
			if (valid_input == 1'b1)
			begin
				NS = ACCEPT_INPUT;
			end
			else
			begin
				NS = S_REQUEST_INPUT;
			end
		end
		ACCEPT_INPUT:
		begin
			if (valid_input == 1'b1)
			begin
				NS = WAIT_FOR_PLAYER_VALID_DONE;
			end
			else
			begin
				NS = DO_NOTHING;
			end
		end
		WAIT_FOR_PLAYER_VALID_DONE:
		begin
			if (valid_input == 1'b1)
			begin
				NS = WAIT_FOR_PLAYER_VALID_DONE;
			end
			else
			begin
				NS = DO_NOTHING;
			end
		end
		default: NS = DO_NOTHING;
	endcase
end

/* control the S based on NS */
always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		S <= DO_NOTHING;
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
		request_input <= 1'b0;
		accepted_input <= 1'b0;
	end
	else
	begin
		case (S)
			DO_NOTHING:
			begin
				request_input <= 1'b0;
				accepted_input <= 1'b0;
			end
			S_REQUEST_INPUT:
			begin
				request_input <= 1'b1; // send request to player
				accepted_input <= 1'b0;
			end
			ACCEPT_INPUT:
			begin
				request_input <= 1'b0;
				accepted_input <= 1'b1; // tell them you have the data

				/* store the inputs */
				accepted_players_input <= players_input;
				accepted_players_money <= players_money;				
			end
			WAIT_FOR_PLAYER_VALID_DONE:
			begin
				request_input <= 1'b0;	
				accepted_input <= 1'b1; // tell them you still have the data and are waiting for them to put valid down
			end
		endcase
	end
end
endmodule
