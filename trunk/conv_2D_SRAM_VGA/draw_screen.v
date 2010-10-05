// Colours:
// colour <= 3'b000; Black
// colour <= 3'b111; White
// colour <= 3'b001; Red
// colour <= 3'b010; Green
// colour <= 3'b100; Blue
// colour <= 3'b110; Yellow
// colour <= 3'b011; Magenta
// colour <= 3'b101; Cyan

module draw_screen(resetn, clock, color, x, y, writeEn,
P1C1, P1C2, P2C1, P2C2, flop, turn, river,
pot,
p1_bank, p2_bank,
draw_the_screen,
done_draw_screen,
game_over);
input resetn, clock;
output [2:0]color;
output [7:0] x; //0-159
output [6:0] y; //0-119
output writeEn;
input draw_the_screen;
output done_draw_screen;
input [5:0] P1C1, P1C2, P2C1, P2C2, river, turn; // Cards to players
input [17:0] flop; // flop
input [7:0]pot; 
input [7:0]p1_bank, p2_bank;
input game_over;

parameter RED = 3'b0001, BLUE = 3'b010, GREEN = 3'b100, BLACK = 3'b000;

wire [14:0]p1_bank_pixels1;
pixelize_hex_value b1(p1_bank[7:4], p1_bank_pixels1);
wire [14:0]p1_bank_pixels2;
pixelize_hex_value b2(p1_bank[3:0], p1_bank_pixels2);
wire [14:0]p2_bank_pixels1;
pixelize_hex_value b3(p2_bank[7:4], p2_bank_pixels1);
wire [14:0]p2_bank_pixels2;
pixelize_hex_value b4(p2_bank[3:0], p2_bank_pixels2);

wire [14:0]card_1_pixels;
pixelize_card_value card1(P1C1[3:0], card_1_pixels);
wire [14:0]card_2_pixels;
pixelize_card_value card2(P1C2[3:0], card_2_pixels);
wire [14:0]card_3_pixels;
pixelize_card_value card3(P2C1[3:0], card_3_pixels);
wire [14:0]card_4_pixels;
pixelize_card_value card4(P2C2[3:0], card_4_pixels);
wire [14:0]card_5_pixels;
pixelize_card_value card5(flop[3:0], card_5_pixels);
wire [14:0]card_6_pixels;
pixelize_card_value card6(flop[9:6], card_6_pixels);
wire [14:0]card_7_pixels;
pixelize_card_value card7(flop[15:12], card_7_pixels);
wire [14:0]card_8_pixels;
pixelize_card_value card8(river[3:0], card_8_pixels);
wire [14:0]card_9_pixels;
pixelize_card_value card9(turn[3:0], card_9_pixels);

wire [14:0]card_suit_1_pixels;
pixelize_card_suit card_suit1(P1C1[5:4], card_suit_1_pixels);
wire [14:0]card_suit_2_pixels;
pixelize_card_suit card_suit2(P1C2[5:4], card_suit_2_pixels);
wire [14:0]card_suit_3_pixels;
pixelize_card_suit card_suit3(P2C1[5:4], card_suit_3_pixels);
wire [14:0]card_suit_4_pixels;
pixelize_card_suit card_suit4(P2C2[5:4], card_suit_4_pixels);
wire [14:0]card_suit_5_pixels;
pixelize_card_suit card_suit5(flop[5:4], card_suit_5_pixels);
wire [14:0]card_suit_6_pixels;
pixelize_card_suit card_suit6(flop[11:10], card_suit_6_pixels);
wire [14:0]card_suit_7_pixels;
pixelize_card_suit card_suit7(flop[17:16], card_suit_7_pixels);
wire [14:0]card_suit_8_pixels;
pixelize_card_suit card_suit8(river[5:4], card_suit_8_pixels);
wire [14:0]card_suit_9_pixels;
pixelize_card_suit card_suit9(turn[5:4], card_suit_9_pixels);

reg[14:0] input_character;
reg[7:0] top_x;
reg[6:0] top_y;
reg start_draw;
wire finished_character;
wire writeEn;
reg [3:0]f_color;
draw_a_font font_drawer(clock, resetn, input_character, f_color, top_x, top_y, x, y, color, writeEn, start_draw, finished_character);

//rand_number_max_159 r1(clock, resetn, x);
//rand_number_max_119 r2(clock, resetn, y);
//lfsr_2bit_output r3(clock, resetn, color);
//assign writeEn = 1'b1;

reg done_draw_screen;
reg [4:0]S, NS;
parameter 
WAIT = 5'b00000,
DRAW_SCREEN = 5'b00001,
DRAW_C1 = 5'b00010,
DRAW_S1 = 5'b00011,
DRAW_C2 = 5'b00100,
DRAW_S2 = 5'b00101,
DRAW_C3 = 5'b00110,
DRAW_S3 = 5'b00111,
DRAW_C4 = 5'b01000,
DRAW_S4 = 5'b01001,
DRAW_C5 = 5'b01010,
DRAW_S5 = 5'b01011,
DRAW_C6 = 5'b01100,
DRAW_S6 = 5'b01101,
DRAW_C7 = 5'b01110,
DRAW_S7 = 5'b01111,
DRAW_C8 = 5'b10000,
DRAW_S8 = 5'b10001,
DRAW_C9 = 5'b10010,
DRAW_S9 = 5'b10011,
DRAW_B1 = 5'b10100,
DRAW_B2 = 5'b10101,
DRAW_B3 = 5'b10110,
DRAW_B4 = 5'b10111,
DRAW_GAME_OVER = 5'b11000,
DONE_DRAW = 5'b11111;

always @(S or draw_the_screen or finished_character)
begin
	case (S)
		WAIT:
			if (draw_the_screen == 1'b1)
				NS = DRAW_SCREEN;
			else
				NS = WAIT;
		DRAW_SCREEN:
			NS = DRAW_C1;
		DRAW_C1:
			if (finished_character == 1'b1)
				NS = DRAW_S1;
			else
				NS = DRAW_C1;
		DRAW_S1:
			if (finished_character == 1'b1)
				NS = DRAW_C2;
			else
				NS = DRAW_S1;
		DRAW_C2:
			if (finished_character == 1'b1)
				NS = DRAW_S2;
			else
				NS = DRAW_C2;
		DRAW_S2:
			if (finished_character == 1'b1)
				NS = DRAW_C3;
			else
				NS = DRAW_S2;
		DRAW_C3:
			if (finished_character == 1'b1)
				NS = DRAW_S3;
			else
				NS = DRAW_C3;
		DRAW_S3:
			if (finished_character == 1'b1)
				NS = DRAW_C4;
			else
				NS = DRAW_S3;
		DRAW_C4:
			if (finished_character == 1'b1)
				NS = DRAW_S4;
			else
				NS = DRAW_C4;
		DRAW_S4:
			if (finished_character == 1'b1)
				NS = DRAW_C5;
			else
				NS = DRAW_S4;
		DRAW_C5:
			if (finished_character == 1'b1)
				NS = DRAW_S5;
			else
				NS = DRAW_C5;
		DRAW_S5:
			if (finished_character == 1'b1)
				NS = DRAW_C6;
			else
				NS = DRAW_S5;
		DRAW_C6:
			if (finished_character == 1'b1)
				NS = DRAW_S6;
			else
				NS = DRAW_C6;
		DRAW_S6:
			if (finished_character == 1'b1)
				NS = DRAW_C7;
			else
				NS = DRAW_S6;
		DRAW_C7:
			if (finished_character == 1'b1)
				NS = DRAW_S7;
			else
				NS = DRAW_C7;
		DRAW_S7:
			if (finished_character == 1'b1)
				NS = DRAW_C8;
			else
				NS = DRAW_S7;
		DRAW_C8:
			if (finished_character == 1'b1)
				NS = DRAW_S8;
			else
				NS = DRAW_C8;
		DRAW_S8:
			if (finished_character == 1'b1)
				NS = DRAW_C9;
			else
				NS = DRAW_S8;
		DRAW_C9:
			if (finished_character == 1'b1)
				NS = DRAW_S9;
			else
				NS = DRAW_C9;
		DRAW_S9:
			if (finished_character == 1'b1)
				NS = DRAW_B1;
			else
				NS = DRAW_S9;
		DRAW_B1:
			if (finished_character == 1'b1)
				NS = DRAW_B2;
			else
				NS = DRAW_B1;
		DRAW_B2:
			if (finished_character == 1'b1)
				NS = DRAW_B3;
			else
				NS = DRAW_B2;
		DRAW_B3:
			if (finished_character == 1'b1)
				NS = DRAW_B4;
			else
				NS = DRAW_B3;
		DRAW_B4:
			if (finished_character == 1'b1)
				NS = DRAW_GAME_OVER;
			else
				NS = DRAW_B4;
		DRAW_GAME_OVER:
			if (finished_character == 1'b1)
				NS = DONE_DRAW;
			else
				NS = DRAW_GAME_OVER;
		DONE_DRAW:
			NS = WAIT;
		default:
			NS = WAIT;
	endcase
end

always @(posedge clock or negedge resetn)
begin
	if (resetn == 1'b0)
	begin
		S <= WAIT;
	end
	else
	begin
		S <= NS;
	end
end

reg first_time;

always @(posedge clock or negedge resetn)
begin
	if (resetn == 1'b0)
	begin
		input_character <= 15'b000000000000000;
		top_x <= 20; //0-159
		top_y <= 20; //0-119;
		start_draw <= 1'b0;
		first_time <= 1'b0;
		done_draw_screen <= 1'b0;
	end
	else
	begin
		case (S)
			WAIT:
			begin
				input_character <= 15'b000000000000000;
				top_x <= 20; //0-159
				top_y <= 20; //0-119;
				start_draw <= 1'b0;
				done_draw_screen <= 1'b0;
				first_time <= 1'b0;
			end
			DRAW_SCREEN:
			begin
				first_time <= 1'b0;
			end
			DRAW_C1:
			begin
				input_character <= card_1_pixels;
				top_x <= 20; //0-159
				top_y <= 20; //0-119;
				
				if (P1C1[5] == 1'b1)
					f_color <= RED;
				else
					f_color <= BLACK;
				
				if (first_time == 1'b0)
				begin
					start_draw <= 1'b1;
					first_time <= 1'b1;
				end
				else
				begin
					start_draw <= 1'b0;
				end
			end
			DRAW_S1:
			begin
				input_character <= card_suit_1_pixels;
				top_x <= 24; //0-159
				top_y <= 20; //0-119;
				
				if (P1C1[5] == 1'b1)
					f_color <= RED;
				else
					f_color <= BLACK;
					
				if (first_time == 1'b1)
				begin
					start_draw <= 1'b1;
					first_time <= 1'b0;
				end
				else
				begin
					start_draw <= 1'b0;
				end
			end
			DRAW_C2:
			begin
				input_character <= card_2_pixels;
				top_x <= 28; //0-159
				top_y <= 20; //0-119;
				
				if (P1C2[5] == 1'b1)
					f_color <= RED;
				else
					f_color <= BLACK;
					
				if (first_time == 1'b0)
				begin
					start_draw <= 1'b1;
					first_time <= 1'b1;
				end
				else
				begin
					start_draw <= 1'b0;
				end
			end
			DRAW_S2:
			begin
				input_character <= card_suit_2_pixels;
				top_x <= 32; //0-159
				top_y <= 20; //0-119;
				
				if (P1C1[5] == 1'b1)
					f_color <= RED;
				else
					f_color <= BLACK;
					
				if (first_time == 1'b1)
				begin
					start_draw <= 1'b1;
					first_time <= 1'b0;
				end
				else
				begin
					start_draw <= 1'b0;
				end
			end
			DRAW_C3:
			begin
				input_character <= card_3_pixels;
				top_x <= 20; //0-159
				top_y <= 26; //0-119;
				
				if (P2C1[5] == 1'b1)
					f_color <= RED;
				else
					f_color <= BLACK;
					
				if (first_time == 1'b0)
				begin
					start_draw <= 1'b1;
					first_time <= 1'b1;
				end
				else
				begin
					start_draw <= 1'b0;
				end
			end
			DRAW_S3:
			begin
				input_character <= card_suit_3_pixels;
				top_x <= 24; //0-159
				top_y <= 26; //0-119;
				
				if (P2C1[5] == 1'b1)
					f_color <= RED;
				else
					f_color <= BLACK;
					
				if (first_time == 1'b1)
				begin
					start_draw <= 1'b1;
					first_time <= 1'b0;
				end
				else
				begin
					start_draw <= 1'b0;
				end
			end
			DRAW_C4:
			begin
				input_character <= card_4_pixels;
				top_x <= 28; //0-159
				top_y <= 26; //0-119;
				
				if (P2C2[5] == 1'b1)
					f_color <= RED;
				else
					f_color <= BLACK;
					
				if (first_time == 1'b0)
				begin
					start_draw <= 1'b1;
					first_time <= 1'b1;
				end
				else
				begin
					start_draw <= 1'b0;
				end
			end
			DRAW_S4:
			begin
				input_character <= card_suit_4_pixels;
				top_x <= 32; //0-159
				top_y <= 26; //0-119;
				
				if (P2C2[5] == 1'b1)
					f_color <= RED;
				else
					f_color <= BLACK;
					
				if (first_time == 1'b1)
				begin
					start_draw <= 1'b1;
					first_time <= 1'b0;
				end
				else
				begin
					start_draw <= 1'b0;
				end
			end
			DRAW_C5:
			begin
				input_character <= card_5_pixels;
				top_x <= 20; //0-159
				top_y <= 32; //0-119;
				
				if (flop[5] == 1'b1)
					f_color <= RED;
				else
					f_color <= BLACK;
					
				if (first_time == 1'b0)
				begin
					start_draw <= 1'b1;
					first_time <= 1'b1;
				end
				else
				begin
					start_draw <= 1'b0;
				end
			end
			DRAW_S5:
			begin
				input_character <= card_suit_5_pixels;
				top_x <= 24; //0-159
				top_y <= 32; //0-119;
				
				if (flop[5] == 1'b1)
					f_color <= RED;
				else
					f_color <= BLACK;
					
				if (first_time == 1'b1)
				begin
					start_draw <= 1'b1;
					first_time <= 1'b0;
				end
				else
				begin
					start_draw <= 1'b0;
				end
			end
			DRAW_C6:
			begin
				input_character <= card_6_pixels;
				top_x <= 28; //0-159
				top_y <= 32; //0-119;
				
				if (flop[11] == 1'b1)
					f_color <= RED;
				else
					f_color <= BLACK;
					
				if (first_time == 1'b0)
				begin
					start_draw <= 1'b1;
					first_time <= 1'b1;
				end
				else
				begin
					start_draw <= 1'b0;
				end
			end
			DRAW_S6:
			begin
				input_character <= card_suit_6_pixels;
				top_x <= 32; //0-159
				top_y <= 32; //0-119;
				
				if (flop[11] == 1'b1)
					f_color <= RED;
				else
					f_color <= BLACK;
					
				if (first_time == 1'b1)
				begin
					start_draw <= 1'b1;
					first_time <= 1'b0;
				end
				else
				begin
					start_draw <= 1'b0;
				end
			end
			DRAW_C7:
			begin
				input_character <= card_7_pixels;
				top_x <= 36; //0-159
				top_y <= 32; //0-119;
				
				if (flop[17] == 1'b1)
					f_color <= RED;
				else
					f_color <= BLACK;
					
				if (first_time == 1'b0)
				begin
					start_draw <= 1'b1;
					first_time <= 1'b1;
				end
				else
				begin
					start_draw <= 1'b0;
				end
			end
			DRAW_S7:
			begin
				input_character <= card_suit_7_pixels;
				top_x <= 40; //0-159
				top_y <= 32; //0-119;
				
				if (flop[17] == 1'b1)
					f_color <= RED;
				else
					f_color <= BLACK;
					
				if (first_time == 1'b1)
				begin
					start_draw <= 1'b1;
					first_time <= 1'b0;
				end
				else
				begin
					start_draw <= 1'b0;
				end
			end
			DRAW_C8:
			begin
				input_character <= card_8_pixels;
				top_x <= 20; //0-159
				top_y <= 38; //0-119;
				
				if (turn[5] == 1'b1)
					f_color <= RED;
				else
					f_color <= BLACK;
					
				if (first_time == 1'b0)
				begin
					start_draw <= 1'b1;
					first_time <= 1'b1;
				end
				else
				begin
					start_draw <= 1'b0;
				end
			end
			DRAW_S8:
			begin
				input_character <= card_suit_8_pixels;
				top_x <= 24; //0-159
				top_y <= 38; //0-119;
				
				if (turn[5] == 1'b1)
					f_color <= RED;
				else
					f_color <= BLACK;
					
				if (first_time == 1'b1)
				begin
					start_draw <= 1'b1;
					first_time <= 1'b0;
				end
				else
				begin
					start_draw <= 1'b0;
				end
			end
			DRAW_C9:
			begin
				input_character <= card_9_pixels;
				top_x <= 20; //0-159
				top_y <= 44; //0-119;
				
				if (river[5] == 1'b1)
					f_color <= RED;
				else
					f_color <= BLACK;
					
				if (first_time == 1'b0)
				begin
					start_draw <= 1'b1;
					first_time <= 1'b1;
				end
				else
				begin
					start_draw <= 1'b0;
				end
			end
			DRAW_S9:
			begin
				input_character <= card_suit_9_pixels;
				top_x <= 24; //0-159
				top_y <= 44; //0-119;
				
				if (river[5] == 1'b1)
					f_color <= RED;
				else
					f_color <= BLACK;
					
				if (first_time == 1'b1)
				begin
					start_draw <= 1'b1;
					first_time <= 1'b0;
				end
				else
				begin
					start_draw <= 1'b0;
				end
			end
			DRAW_B1:
			begin
				input_character <= p1_bank_pixels1;
				top_x <= 38; //0-159
				top_y <= 20; //0-119;
				f_color <= BLUE;
				
				if (first_time == 1'b0)
				begin
					start_draw <= 1'b1;
					first_time <= 1'b1;
				end
				else
				begin
					start_draw <= 1'b0;
				end
			end
			DRAW_B2:
			begin
				input_character <= p1_bank_pixels2;
				top_x <= 42; //0-159
				top_y <= 20; //0-119;
				f_color <= BLUE;
				
				if (first_time == 1'b1)
				begin
					start_draw <= 1'b1;
					first_time <= 1'b0;
				end
				else
				begin
					start_draw <= 1'b0;
				end
			end
			DRAW_B3:
			begin
				input_character <= p2_bank_pixels1;
				
				top_x <= 38; //0-159
				top_y <= 26; //0-119;
				f_color <= GREEN;
				
				if (first_time == 1'b0)
				begin
					start_draw <= 1'b1;
					first_time <= 1'b1;
				end
				else
				begin
					start_draw <= 1'b0;
				end
			end
			DRAW_B4:
			begin
				input_character <= p2_bank_pixels2;
				top_x <= 42; //0-159
				top_y <= 26; //0-119;
				f_color <= GREEN;
				
				if (first_time == 1'b1)
				begin
					start_draw <= 1'b1;
					first_time <= 1'b0;
				end
				else
				begin
					start_draw <= 1'b0;
				end
			end
			DRAW_GAME_OVER:
			begin
				/*if (game_over == 1'b1)
					input_character <= 15'b111111111111111;
				else
					input_character <= 15'b000000000000000;*/
				input_character <= 15'b111111111111111;
				top_x <= 0; //0-159
				top_y <= 0; //0-119;
				
				if (first_time == 1'b0)
				begin
					start_draw <= 1'b1;
					first_time <= 1'b1;
				end
				else
				begin
					start_draw <= 1'b0;
				end
			end
			DONE_DRAW:
			begin
				done_draw_screen <= 1'b1;
			end
			default:
			begin
			end
		endcase
	end
end

endmodule

/*-----------------------------------------------------------
-------------------------------------------------------------
draw_a_font
Draws a small font (15 bits) at a location
-------------------------------------------------------------
-----------------------------------------------------------*/
module draw_a_font(
clk, 
rst, 
input_character, 
f_color,
top_x, top_y, 
output_x, output_y, colour, 
write_en, 
start_draw, 
finish_draw);
input clk, rst;
input [14:0]input_character; 
input [2:0]f_color;
input [7:0]top_x; 
input [6:0]top_y;
input start_draw;
output [7:0]output_x;
output [6:0]output_y;
output [2:0]colour;
output finish_draw;
output write_en;

reg write_en;
reg finish_draw;
reg [7:0]output_x;
reg [6:0]output_y;
reg [2:0]colour;
reg [1:0]bit_count_x;
reg [2:0]bit_count_y;

parameter WAIT = 2'b00, DRAWING = 2'b01, FIN_DRAW = 2'b11;
reg [1:0]S, NS;

always @(S or start_draw or bit_count_x or bit_count_y)
begin
	case (S)
		WAIT:
		begin
			if (start_draw == 1'b1)
				NS = DRAWING;
			else
				NS = WAIT;
			write_en = 1'b0;
		end
		DRAWING:
			if (bit_count_x == 2'b01 && bit_count_y == 3'b111)
			begin
				NS = FIN_DRAW;
				write_en = 1'b0;
			end
			else
			begin
				NS = DRAWING;
				write_en = 1'b1;
			end
		FIN_DRAW:
		begin
			NS = WAIT;
			write_en = 1'b0;
		end
		default:
		begin
			NS = WAIT;
			write_en = 1'b0;
		end
	endcase
end

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

always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		finish_draw <= 1'b0;
		output_x <= 7'b0000000;
		output_y <= 6'b000000;
		colour <= 3'b000;
		//write_en <= 1'b0;
		bit_count_x <= 2'b00;
		bit_count_y <= 3'b000;
	end
	else
	begin
		case (S)
			WAIT:
			begin
				finish_draw <= 1'b0;
				output_x <= 7'b0000000;
				output_y <= 6'b000000;
				colour <= 3'b000;
		//		write_en <= 1'b0;
				bit_count_x <= 2'b10;
				bit_count_y <= 3'b100;
			end
			DRAWING:
			begin
				finish_draw <= 1'b0;
			//	write_en <= 1'b1;
				
				if (input_character[4'd14 - (bit_count_x + bit_count_y*3)] == 1'b0)
				begin
					// colour
					output_x <= top_x + bit_count_x;
					output_y <= top_y + bit_count_y;
					colour <= 3'b111; // Background color = white
				end
				else
				begin
					output_x <= top_x + bit_count_x;
					output_y <= top_y + bit_count_y;
					colour <= f_color;
				end
				
				// incrememnt the counters
				if (bit_count_x == 2'b00)
				begin
					bit_count_x <= 2'b10;
					bit_count_y <= bit_count_y - 1'b1;
				end
				else
				begin
					bit_count_x <= bit_count_x - 1'b1;
				end
			end
			FIN_DRAW:
			begin
				finish_draw <= 1'b1;
				output_x <= 7'b0000000;
				output_y <= 6'b000000;
				colour <= 3'b000;
				//write_en <= 1'b0;
				bit_count_x <= 2'b00;
				bit_count_y <= 2'b00;
			end
		endcase
	end
end

endmodule

/*-----------------------------------------------------------
-------------------------------------------------------------
rand_number_max_159
-------------------------------------------------------------
-----------------------------------------------------------*/
module rand_number_max_159(clk, rst, rand_out);
input clk, rst;
output [7:0] rand_out;

reg [7:0] rand_out;
wire [7:0] current_rand;

lfsr_8bit_output instance1(clk, rst, current_rand);

always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		rand_out <= 8'b00000000;
	end
	else
	begin
		if (current_rand > 8'd159)
		begin
			rand_out <= {1'b0, current_rand[6:0]};
		end
		else
		begin
			rand_out <= current_rand;
		end
	end
end

endmodule

/*-----------------------------------------------------------
-------------------------------------------------------------
lfsr_8bit_output
-------------------------------------------------------------
-----------------------------------------------------------*/
module lfsr_8bit_output(clk, rst, out);
input clk, rst;
output [7:0] out;

wire [31:0] out;

reg [31:0] lfsr_register;

assign out = {lfsr_register[7], lfsr_register[6], lfsr_register[5],lfsr_register[4],lfsr_register[3],lfsr_register[2],lfsr_register[1],lfsr_register[0]};

always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		lfsr_register <= 32'hab135f16; // Seed for random number
	end
	else
	begin
		lfsr_register <= 
		{lfsr_register[30],
		lfsr_register[29],
		lfsr_register[28],
		lfsr_register[27], 
		lfsr_register[26],
		lfsr_register[25],
		lfsr_register[24],
		lfsr_register[23],
		lfsr_register[22],
		lfsr_register[21],
		lfsr_register[20],
		lfsr_register[19],
		lfsr_register[18],
		lfsr_register[17], 
		lfsr_register[16],
		lfsr_register[15],
		lfsr_register[14],
		lfsr_register[13],
		lfsr_register[12],
		lfsr_register[11],
		lfsr_register[10],
		lfsr_register[9],
		lfsr_register[8],
		lfsr_register[7],
		lfsr_register[6],
		lfsr_register[5],
		lfsr_register[4],
		lfsr_register[3],
		lfsr_register[2],
		lfsr_register[1],
		lfsr_register[0],
		lfsr_register[31] ^ lfsr_register[30] ^ lfsr_register[15] ^ lfsr_register[1]};
	end
end

endmodule

/*-----------------------------------------------------------
-------------------------------------------------------------
rand_number_max_119
-------------------------------------------------------------
-----------------------------------------------------------*/
module rand_number_max_119(clk, rst, rand_out);
input clk, rst;
output [6:0] rand_out;

reg [6:0] rand_out;
wire [6:0] current_rand;

lfsr_7bit_output instance1(clk, rst, current_rand);

always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		rand_out <= 7'b0000000;
	end
	else
	begin
		if (current_rand > 8'd159)
		begin
			rand_out <= {1'b0, current_rand[6:0]};
		end
		else
		begin
			rand_out <= current_rand;
		end
	end
end

endmodule

/*-----------------------------------------------------------
-------------------------------------------------------------
lfsr_8bit_output
32 31 30 10
32 31 29 1
32 31 26 18
32 31 26 9
32 31 26 7
32 31 23 10
32 31 22 17
32 31 21 16
32 31 21 5
32 31 18 10
32 31 16 2
32 31 15 10
32 31 14 4
32 31 13 8
-------------------------------------------------------------
-----------------------------------------------------------*/
module lfsr_7bit_output(clk, rst, out);
input clk, rst;
output [6:0] out;

wire [6:0] out;

reg [31:0] lfsr_register;

assign out = {lfsr_register[6], lfsr_register[5],lfsr_register[4],lfsr_register[3],lfsr_register[2],lfsr_register[1],lfsr_register[0]};

always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		lfsr_register <= 32'hab13ad26; // Seed for random number
	end
	else
	begin
		lfsr_register <= 
		{lfsr_register[30],
		lfsr_register[29],
		lfsr_register[28],
		lfsr_register[27], 
		lfsr_register[26],
		lfsr_register[25],
		lfsr_register[24],
		lfsr_register[23],
		lfsr_register[22],
		lfsr_register[21],
		lfsr_register[20],
		lfsr_register[19],
		lfsr_register[18],
		lfsr_register[17], 
		lfsr_register[16],
		lfsr_register[15],
		lfsr_register[14],
		lfsr_register[13],
		lfsr_register[12],
		lfsr_register[11],
		lfsr_register[10],
		lfsr_register[9],
		lfsr_register[8],
		lfsr_register[7],
		lfsr_register[6],
		lfsr_register[5],
		lfsr_register[4],
		lfsr_register[3],
		lfsr_register[2],
		lfsr_register[1],
		lfsr_register[0],
		lfsr_register[31] ^ lfsr_register[30] ^ lfsr_register[12] ^ lfsr_register[7]};
	end
end

endmodule

/*-----------------------------------------------------------
-------------------------------------------------------------

-------------------------------------------------------------
-----------------------------------------------------------*/
module lfsr_2bit_output(clk, rst, out);
input clk, rst;
output [2:0] out;

wire [2:0] out;

reg [31:0] lfsr_register;

assign out = {lfsr_register[6], lfsr_register[5],lfsr_register[4],lfsr_register[3],lfsr_register[2],lfsr_register[1],lfsr_register[0]};

always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		lfsr_register <= 32'heb53fd15; // Seed for random number
	end
	else
	begin
		lfsr_register <= 
		{lfsr_register[30],
		lfsr_register[29],
		lfsr_register[28],
		lfsr_register[27], 
		lfsr_register[26],
		lfsr_register[25],
		lfsr_register[24],
		lfsr_register[23],
		lfsr_register[22],
		lfsr_register[21],
		lfsr_register[20],
		lfsr_register[19],
		lfsr_register[18],
		lfsr_register[17], 
		lfsr_register[16],
		lfsr_register[15],
		lfsr_register[14],
		lfsr_register[13],
		lfsr_register[12],
		lfsr_register[11],
		lfsr_register[10],
		lfsr_register[9],
		lfsr_register[8],
		lfsr_register[7],
		lfsr_register[6],
		lfsr_register[5],
		lfsr_register[4],
		lfsr_register[3],
		lfsr_register[2],
		lfsr_register[1],
		lfsr_register[0],
		lfsr_register[31] ^ lfsr_register[30] ^ lfsr_register[12] ^ lfsr_register[7]};
	end
end

endmodule