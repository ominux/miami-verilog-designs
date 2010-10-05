module vga_poker_bot(
			rst,
			clk,
			start_game,
			next_hand,
			vga_r,
			vga_g,
			vga_b,
			vga_hs,
			vga_vs,
			vga_blank,
			vga_sync,
			VGA_clk,
			tenMHz_clk,
			led);

output [11:0]led;
wire [11:0]led;
input rst, clk;
input start_game;
input next_hand;
output [9:0]vga_r,vga_g,vga_b;
output vga_hs,vga_vs,vga_blank,vga_sync,VGA_clk;
output tenMHz_clk;

wire VGA_clk;
wire tenMHz_clk;

wire next_hand_o;
assign led[0] = next_hand_o;
debouncer d1(rst, clk, next_hand, next_hand_o);
wire start_game_o;
assign led[1] = start_game_o;
debouncer d2(rst, clk, start_game, start_game_o);

wire [2:0]color;
wire [7:0] x; //0-159
wire [6:0] y; //0-119
wire writeEn;
// Instantiate the vga adapter
// x 0-159, y 0-119
VgaAdapter inst(rst,tenMHz_clk,color,x,y,writeEn,vga_r,vga_g,vga_b,vga_hs,vga_vs,vga_blank,vga_sync,VGA_clk);

wire done_draw_screen;
wire change;
draw_screen my_draw(.resetn(rst), .clock(tenMHz_clk), .color(color), .x(x), .y(y), .writeEn(writeEn), 
	.P1C1(P1C1), .P1C2(P1C2), .P2C1(P2C1), .P2C2(P2C2), .flop(flop), .turn(turn), .river(river), 
	.pot(pot), .p1_bank(p1_bank), .p2_bank(p2_bank), 
	.draw_the_screen(change), .done_draw_screen(done_draw_screen), .game_over(game_over));

wire [5:0] P1C1, P1C2, P2C1, P2C2, river, turn; // Cards to players
wire [17:0] flop; // flop
wire [7:0]pot; 
wire [7:0]p1_bank, p2_bank;
wire game_over;
poker_bot poker_game(.clk(tenMHz_clk), .rst(rst), .game_over(game_over), .start_game(start_game_o),
	.P1C1(P1C1), .P1C2(P1C2), .P2C1(P2C1), .P2C2(P2C2), .flop(flop), .turn(turn), .river(river),
	.pot(pot), .p1_bank(p1_bank), .p2_bank(p2_bank), .next_hand_user(next_hand_o), .change(change), 
	.done_draw_screen(done_draw_screen), .debug_info(led[11:2]));

// two slowed down clocks
poker_clk tenMhzvlovk(clk, tenMHz_clk, VGA_clk);

endmodule

