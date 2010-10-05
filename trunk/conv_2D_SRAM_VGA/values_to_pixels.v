/*-----------------------------------------------------------
-------------------------------------------------------------
pixelize card value
Converts the magnitude of the card into pixels
-------------------------------------------------------------
-----------------------------------------------------------*/
module pixelize_card_value(input_card, output_bits);
input [3:0]input_card;
output [14:0]output_bits;

// start at top left corner and go to right then down
reg [14:0]output_bits;

always @(input_card)
begin
	case (input_card)
		4'd1:
		begin
			output_bits <= 15'b001011001001001;
		end
		4'd2:
		begin
			output_bits <= 15'b111001010100111;
		end
		4'd3:
		begin
			output_bits <= 15'b110001011001110;
		end
		4'd4:
		begin
			output_bits <= 15'b101101011001001;
		end
		4'd5:
		begin
			output_bits <= 15'b111100010001111;
		end
		4'd6:
		begin
			output_bits <= 15'b010100111101111;
		end
		4'd7:
		begin
			output_bits <= 15'b111001010010010;
		end
		4'd8:
		begin
			output_bits <= 15'b111101010101111;
		end
		4'd9:
		begin
			output_bits <= 15'b111101111001010;
		end
		4'd10:
		begin
			output_bits <= 15'b111010010010010;
		end
		4'd11: // J
		begin
			output_bits <= 15'b111010010010100;
		end
		4'd12: // Q
		begin
			output_bits <= 15'b111101101110001;
		end
		4'd13: // K
		begin
			output_bits <= 15'b101110100110101;
		end
		4'd14: // A
		begin
			output_bits <= 15'b010101111101101;
		end
		default:
			output_bits <= 15'b000000000000000;
	endcase
end

endmodule

/*-----------------------------------------------------------
-------------------------------------------------------------
pixelize card suit
Converts the magnitude of the card into pixels
-------------------------------------------------------------
-----------------------------------------------------------*/
module pixelize_card_suit(input_suit, output_bits);
input [1:0]input_suit;
output [14:0]output_bits;

// start at top left corner and go to right then down
reg [14:0]output_bits;

always @(input_suit)
begin
	case (input_suit)
		2'b00: // spades
		begin
			output_bits <= 15'b011100010001110;
		end
		2'b01: // clubs
		begin
			output_bits <= 15'b011100100100011;
		end
		2'b10: // diamonds
		begin
			output_bits <= 15'b110101101101110;
		end
		2'b11: // Hearts
		begin
			output_bits <= 15'b101101111101101;
		end
		default:
			output_bits <= 15'b000000000000000;
	endcase
end

endmodule

/*-----------------------------------------------------------
-------------------------------------------------------------
pixelize hex value
-------------------------------------------------------------
-----------------------------------------------------------*/
module pixelize_hex_value(input_val, output_bits);
input [3:0]input_val;
output [14:0]output_bits;

// start at top left corner and go to right then down
reg [14:0]output_bits;

always @(input_val)
begin
	case (input_val)
		4'd0:
		begin
			output_bits <= 15'b111101101101111;
		end
		4'd1:
		begin
			output_bits <= 15'b001011001001001;
		end
		4'd2:
		begin
			output_bits <= 15'b111001010100111;
		end
		4'd3:
		begin
			output_bits <= 15'b110001011001110;
		end
		4'd4:
		begin
			output_bits <= 15'b101101011001001;
		end
		4'd5:
		begin
			output_bits <= 15'b111100010001111;
		end
		4'd6:
		begin
			output_bits <= 15'b010100111101111;
		end
		4'd7:
		begin
			output_bits <= 15'b111001010010010;
		end
		4'd8:
		begin
			output_bits <= 15'b111101010101111;
		end
		4'd9:
		begin
			output_bits <= 15'b111101111001010;
		end
		4'd10: // A
		begin
			output_bits <= 15'b010101111101101;
		end
		4'd11: // B
		begin
			output_bits <= 15'b110101111101110;
		end
		4'd12: // C
		begin
			output_bits <= 15'b011100100100011;
		end
		4'd13: // D
		begin
			output_bits <= 15'b110101101101110;
		end
		4'd14: // E
		begin
			output_bits <= 15'b111100110100111;
		end
		4'd15:
		begin
			output_bits <= 15'b111100110100100;
		end
		default:
			output_bits <= 15'b000000000000000;
	endcase
end

endmodule
