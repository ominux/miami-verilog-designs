module alu (
		clk,
		reset_n,
		input_port_A,
		input_port_B,
		output_port_C,
		status_register,
		control_signals
		);

input clk, reset_n;
input [15:0]input_port_A, input_port_B;
output [15:0] output_port_C;
reg [15:0] output_port_C;

output [1:0]status_register;
reg [1:0]status_register;

input [2:0]control_signals;

parameter 
ADD = 2'b01,
SUBTRACT = 2'b10,
PASS_THROUGH = 2'b11;

wire is_zero_bit, is_negative_bit;
wire [15:0]adding, subtracting;

/* For the ALU calculations */
assign adding = input_port_A + input_port_B;
assign subtracting = input_port_A - input_port_B;
assign is_zero_bit = (output_port_C == 0) ? 1'b1 : 1'b0;
assign is_negative_bit = (output_port_C[15] == 1'b1) ? 1'b1 : 1'b0;

/* For the choosing of the ALU operation */
always @(input_port_A or input_port_B or control_signals or adding or subtracting)
begin
	case (control_signals[1:0])
		ADD:
		begin
			output_port_C = adding;
		end
		SUBTRACT:
		begin
			output_port_C = subtracting;
		end
		PASS_THROUGH:
		begin
			output_port_C = input_port_A;
		end
		default:
		begin
			output_port_C = 16'hffff;
		end
	endcase
end

/* For the status register */
always @(posedge clk or negedge reset_n)
begin
	if (reset_n == 1'b0)
	begin
		status_register <= 2'b00;
	end
	else
	begin
		/* only set the status if it's an operation that impacts status */
		if (control_signals[2] == 1'b1)
			status_register <=  {is_zero_bit, is_negative_bit} ;
	end
end

endmodule