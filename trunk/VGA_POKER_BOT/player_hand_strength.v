/*-----------------------------------------------------------
-------------------------------------------------------------
starting_hand_evaluation

Highest Hands
AA, KK, AK-S, 
QQ, JJ, 1010, AQ-S, AK 
99, 88, AJ-S, A10-S, A9-S, KQ-S, QJ-S, AQ 
77, 66, A8-S, A7-S, A6-S, A5-S, A2-S, KJ-S, Q10-S J10-S, 109-S AJ, A10, A9, KQ, QJ, 
55, 44, 33, 22, 98-S, 87-S, 65-S, A8, A7, A6, A5, A2, J10, 109
-------------------------------------------------------------
-----------------------------------------------------------*/
module starting_hand_evaluation(clk, rst, card1, card2, strength);
input clk, rst;
input [5:0]card1, card2;

output [2:0]strength; // at present 6 levels of hand strength
reg [2:0]strength;

wire[3:0] c1, c2;

assign c1 = (card1[3:0] > card2[3:0]) ? card1[3:0] : card2[3:0]; 
assign c2 = (card1[3:0] > card2[3:0]) ? card2[3:0] : card1[3:0]; 

wire pocket_pair;
assign pocket_pair = (card1[3:0] == card2[3:0]) ? 1'b1 : 1'b0;

wire suited;
assign suited = (card1[5:4] == card2[5:4]) ? 1'b1 : 1'b0;

parameter 
CD = 4'b0010,
C3 = 4'b0011,
C4 = 4'b0100,
C5 = 4'b0101,
C6 = 4'b0110,
C7 = 4'b0111,
C8 = 4'b1000,
C9 = 4'b1001,
C10 = 4'b1010,
CJ = 4'b1011,
CQ = 4'b1100,
CK = 4'b1101,
CA = 4'b1110;

always @(card1 or card2 or c1 or c2 or pocket_pair or suited)
begin
	if ((pocket_pair == 1'b1 && (c1 == CA || c1 == CK)) || 
	    (suited == 1'b1 && ((c1 == CA && c2 == CK))))
	begin
		strength = 3'b111;
	end
	else if ((pocket_pair == 1'b1 && (c1 == CQ || c1 == CJ || c1 == C10)) || 
	         (suited == 1'b1 && ((c1 == CA && c2 == CQ))) ||
		 ((c1 == CA && c2 == CK)))
	begin
		strength = 3'b110;
	end
	else if ((pocket_pair == 1'b1 && (c1 == C9 || c1 == C8)) || 
	         (suited == 1'b1 && ((c1 == CA && c2 == CJ) || (c1 == CA && c2 == C10) || (c1 == CA && c2 == C9) || (c1 == CK && c2 == CJ) || (c1 == CQ && c2 == CJ))) ||
		 ((c1 == CA && c2 == CQ)))
	begin
		strength = 3'b101;
	end
	else if ((pocket_pair == 1'b1 && (c1 == C7 || c1 == C6)) || 
	         (suited == 1'b1 && ((c1 == CA && c2 == C8) || (c1 == CA && c2 == C7) || (c1 == CA && c2 == C6) || (c1 == CA && c2 == C5) || (c1 == CA && c2 == CD) || (c1 == CK && c2 == CJ) || (c1 == CQ && c2 == C10) || (c1 == CJ && c2 == C10) || (c1 == C10 && c2 == C9))) ||
		 ((c1 == CA && c2 == CJ) || (c1 == CA && c2 == C10) || (c1 == CA && c2 == C9) || (c1 == CK && c2 == CJ) || (c1 == CQ && c2 == CJ)))
	begin
		strength = 3'b100;
	end
	else if ((pocket_pair == 1'b1 && (c1 == C5 || c1 == C4 || c1 == C3 || c1 == CD)) || 
	         (suited == 1'b1 && ((c1 == C9 && c2 == C8) || (c1 == C8 && c2 == C7) || (c1 == C6 && c2 == C5))) ||
		 ((c1 == CA && c2 == C8) || (c1 == CA && c2 == C7) || (c1 == CA && c2 == C6) || (c1 == CA && c2 == C5) || (c1 == CA && c2 == CD) || (c1 == CJ && c2 == C10) || (c1 == C10 && c2 == C9)))
	begin
		strength = 3'b011;
	end
	else
	begin
		strength = 3'b000;
	end
end

endmodule
