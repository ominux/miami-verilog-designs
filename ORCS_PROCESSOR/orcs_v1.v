module orcs_v1(
		clk, 
		reset_n,

		input_to_reg_file, A, B, M1, Ao1, Co1, S, control
	      );
input clk, reset_n;
output [15:0]input_to_reg_file;
output [15:0]A, B, M1, Ao1, Co1; 
output [1:0]S;
output [19:0]control;

wire [19:0]control;

wire [15:0]A, B, M1, Ao1, Co1; 
reg  [15:0]input_to_reg_file;
wire [1:0]S;

/* Memory */
memory main_memory(
		.address(B[9:0]), // 1K memory only needs 10 bits of address
		.byteena(2'b11),
		.clken(control[0]),
		.clock(clk),
		.data(A),
		.wren(control[1]),
		.q(M1));

/* Control */
control the_control(
		.clk(clk), 
		.reset_n(reset_n),
		.control_signals(control),
		.memory_word(M1),
		.immediate_line(Co1),
		.status_register(S)
	       );

/* Register file */
/* REgister $15 reserved as the address register */
register_file the_reg_file(
		.clk(clk),
		.reset_n(reset_n),
		.input_port(input_to_reg_file),
		.output_port1(A),
		.output_port2(B),
		.control_signals(control[14:2])
		);

/* Alu */
alu the_alu(
		.clk(clk),
		.reset_n(reset_n),
		.input_port_A(A),
		.input_port_B(B),
		.output_port_C(Ao1),
		.status_register(S),
		.control_signals(control[17:15])
		);

always @(control or M1 or Ao1 or Co1)
begin
	case(control[19:18])
		2'b00: input_to_reg_file = M1;
		2'b01: input_to_reg_file = Ao1;
		2'b10: input_to_reg_file = Co1;
		default: input_to_reg_file = M1;
	endcase  
end

endmodule

