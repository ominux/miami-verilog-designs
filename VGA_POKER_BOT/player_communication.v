/*-----------------------------------------------------------
-------------------------------------------------------------
player_communication
Handles the communication between the player and the dealer.
Gets request, asks for decision, and then sends decision
-------------------------------------------------------------
-----------------------------------------------------------*/
module player_communication_protocol(clk, rst, valid, action_defined, action_decision, bet_decision, action_request, action, bet, information_sent, ack, request_player);

input clk, rst;
input action_defined; // signal from the player playing logic when it has decided the move
output valid; // signal to the dealer that the decision is available
input ack, request_player; // signals from the dealer to request action and acknowledge a recevied message
output action_request; // requests the plyer playing logic to decide on the action
input [2:0]action_decision; // the action from the player logic
input [7:0]bet_decision; // the bet from the player logic
output [2:0]action; // the values sent to the dealer
output [7:0]bet;
output information_sent; // tells the player that the decision has been sent

reg information_sent;

reg [2:0]action; 
reg [7:0]bet;

reg action_request;

reg valid;
reg [1:0]S, NS;

reg count;
reg [1:0]counter;

parameter 
WAIT = 2'b00, 
S_ACTION = 2'b01, 
SEND_VALID = 2'b10;

// three states for request from dealer, wait for player logic action, and sending action
always @(S or ack or request_player or action_defined or count)
begin	
	case (S)
		WAIT:
		begin
			if (ack == 1'b0 && request_player == 1'b1)
				NS = S_ACTION;
			else	
				NS = WAIT;
		end
		S_ACTION:
		begin
			if (action_defined == 1'b1)
				NS = SEND_VALID;
			else
				NS = S_ACTION;
		end
		SEND_VALID:
		begin
			if (ack == 1'b1 && count == 1'b1)
				NS = WAIT;
			else
				NS = SEND_VALID;
		end
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
		count <= 1'b0;
		counter <= 2'b00;
		valid <= 1'b0;
		action_request <= 1'b0;
		action <= 3'b000;
		bet <= 8'b00000000;
		information_sent <= 1'b0;
	end
	else
	begin
		case (S)
			WAIT:
			begin
				valid <= 1'b0;
				action_request <= 1'b0;
				information_sent <= 1'b1; // says that information was sent
				count <= 1'b0;
				counter <= 2'b00;
			end
			S_ACTION:
			begin
				valid <= 1'b0;
				action_request <= 1'b1; // says to the player logic to send action
				information_sent <= 1'b0;
				count <= 1'b0;
				counter <= 2'b00;
			end
			SEND_VALID:
			begin
				valid <= 1'b1; // send valid signal
				action_request <= 1'b0;
				information_sent <= 1'b0;
				// when counter is at number than signal that we've had signal up for required time
				if (counter == 2'b10)
				begin
					count <= 1'b1;
				end
				counter <= counter + 1'b1; // counts up

				// store the action and bet to be communicated
				action <= action_decision;
				bet <= bet_decision; 

			end
		endcase
	end
end

endmodule
