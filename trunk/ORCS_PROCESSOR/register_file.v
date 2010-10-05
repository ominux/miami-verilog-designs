module register_file (
		clk,
		reset_n,
		input_port,
		output_port1,
		output_port2,
		control_signals
		);


input clk, reset_n;
input [15:0]input_port;
output [15:0]output_port1;
output [15:0]output_port2;
reg [15:0]output_port1;
reg [15:0]output_port2;
input [12:0]control_signals; // 0th bit Write enable, 1-4 for write address, 5-8 for read port1, 9-12 for read port 2

reg [15:0] register0;
reg [15:0] register1;
reg [15:0] register2;
reg [15:0] register3;
reg [15:0] register4;
reg [15:0] register5;
reg [15:0] register6;
reg [15:0] register7;
reg [15:0] register8;
reg [15:0] register9;
reg [15:0] register10;
reg [15:0] register11;
reg [15:0] register12;
reg [15:0] register13;
reg [15:0] register14;
reg [15:0] register15;

/* handles the writing to the proper register */
always @(posedge clk or negedge reset_n)
begin
	if (reset_n == 1'b0)
	begin
		register0 <= 16'h0000;
		register1 <= 16'h0000;
		register2 <= 16'h0000;
		register3 <= 16'h0000;
		register4 <= 16'h0000;
		register5 <= 16'h0000;
		register6 <= 16'h0000;
		register7 <= 16'h0000;
		register8 <= 16'h0000;
		register9 <= 16'h0000;
		register10 <= 16'h0000;
		register11 <= 16'h0000;
		register12 <= 16'h0000;
		register13 <= 16'h0000;
		register14 <= 16'h0000;
		register15 <= 16'h0000;
	end
	else
	begin
		if (control_signals[0] == 1'b1) // WRITE
		begin
			case(control_signals[4:1])
				4'h0: register0 <= input_port;
				4'h1: register1 <= input_port;
				4'h2: register2 <= input_port;
				4'h3: register3 <= input_port;
				4'h4: register4 <= input_port;
				4'h5: register5 <= input_port;
				4'h6: register6 <= input_port;
				4'h7: register7 <= input_port;
				4'h8: register8 <= input_port;
				4'h9: register9 <= input_port;
				4'ha: register10 <= input_port;
				4'hb: register11 <= input_port;
				4'hc: register12 <= input_port;
				4'hd: register13 <= input_port;
				4'he: register14 <= input_port;
				4'hf: register15 <= input_port;
				default: register0 <= 16'hffff;
			endcase
		end
	end
end

/* Muxes for the output ports */
always @(control_signals or register0 or register1 or register2 or register3 or register4 or register5 or register6 or register7 or register8 or register9 or register10 or register11 or register12 or register13 or register14 or register15)
begin
	case(control_signals[8:5])
		4'h0: output_port1 = register0;
		4'h1: output_port1 = register1;
		4'h2: output_port1 = register2;
		4'h3: output_port1 = register3;
		4'h4: output_port1 = register4;
		4'h5: output_port1 = register5;
		4'h6: output_port1 = register6;
		4'h7: output_port1 = register7;
		4'h8: output_port1 = register8;
		4'h9: output_port1 = register9;
		4'ha: output_port1 = register10;
		4'hb: output_port1 = register11;
		4'hc: output_port1 = register12;
		4'hd: output_port1 = register13;
		4'he: output_port1 = register14;
		4'hf: output_port1 = register15;
		default: output_port1 = 16'hffff;
	endcase
	case(control_signals[12:9])
		4'h0: output_port2 = register0;
		4'h1: output_port2 = register1;
		4'h2: output_port2 = register2;
		4'h3: output_port2 = register3;
		4'h4: output_port2 = register4;
		4'h5: output_port2 = register5;
		4'h6: output_port2 = register6;
		4'h7: output_port2 = register7;
		4'h8: output_port2 = register8;
		4'h9: output_port2 = register9;
		4'ha: output_port2 = register10;
		4'hb: output_port2 = register11;
		4'hc: output_port2 = register12;
		4'hd: output_port2 = register13;
		4'he: output_port2 = register14;
		4'hf: output_port2 = register15;
		default: output_port2 = 16'hffff;
	endcase
end

endmodule
