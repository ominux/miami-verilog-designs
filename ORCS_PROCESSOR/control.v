module control (
		clk, 
		reset_n,
		control_signals,
		memory_word,
		immediate_line,
		status_register
	       );

input clk, reset_n;
output [19:0]control_signals;
wire [19:0]control_signals;
input [15:0]memory_word;
output [15:0]immediate_line;
reg [15:0]immediate_line;
input [1:0]status_register;

/* join all the various control signals into one bus */
reg [1:0]mux_reg_file_c;
reg [2:0]alu_c;
reg [12:0]register_file_c;
reg [1:0]main_memory_c;
assign control_signals = {mux_reg_file_c, alu_c, register_file_c, main_memory_c};

reg [15:0] pc;
reg [15:0] instruction_register1;
reg [15:0] instruction_register2;
reg [1:0]instruction_fetch_sequence;

reg[5:0]S, NS;
// State machine for fetch, decode, execute, pc+1
parameter 
FETCH = 5'b00000,
FETCH2 = 5'b00001,
FETCH3 = 5'b00010,
FETCH4 = 5'b00011,
FETCH5 = 5'b00100,
DECODE = 5'b01000,
EXECUTE = 5'b10000,
EXECUTE2 = 5'b10001,
EXECUTE3 = 5'b10010,
EXECUTE4 = 5'b10011,
INCREMENT = 5'b11000,
WAIT = 5'b11111;

parameter 
MOVE = 4'b0000,
MOVEI = 4'b0001,

LOAD = 4'b0100,
STORE = 4'b0101,
LOADR = 4'b0110,
STORER = 4'b0111,

ADD = 4'b1000,
SUB = 4'b1001,

JMPNEG = 4'b1100,
JMPZ = 4'b1101,
JMP = 4'b1110,

END = 4'b1111;

/* bit to determine if we need a 2nd fetch */
wire second_instruction_to_fetch;
assign second_instruction_to_fetch = (instruction_register1[3:0] == MOVEI || instruction_register1[3:0] == LOAD || instruction_register1[3:0] == STORE || instruction_register1[3:0] == JMP || instruction_register1[3:0] == JMPNEG || instruction_register1[3:0] == JMPZ) ? 1'b1 : 1'b0;

always @(S or second_instruction_to_fetch or instruction_fetch_sequence or instruction_register1)
begin
	case (S)
		WAIT:
		begin
			NS = WAIT;
		end
		FETCH:
		begin
			NS = FETCH2;
		end
		FETCH2:
		begin
			/* signals for reading instruction are going out */
			NS = FETCH3;
		end
		FETCH3:
		begin
			/* now the data is in the memory registers */
			NS = FETCH4;
		end
		FETCH4:
		begin
			/* now the data is being fetched */
			NS = FETCH5;
		end
		FETCH5:
		begin
			/* now the data is stored in the register */
			NS = DECODE;
		end
		DECODE:
		begin
			if (second_instruction_to_fetch == 1'b1 && instruction_fetch_sequence == 2'b00)
				NS = FETCH;
			else
				NS = EXECUTE;
		end
		EXECUTE:
		begin
			case (instruction_register1[3:0])
				MOVE:
				begin
					NS = INCREMENT;
				end
				MOVEI:
				begin
					NS = INCREMENT;
				end
				LOAD :
				begin
					NS = EXECUTE2;
				end
				STORE :
				begin
					NS = EXECUTE2;
				end
				LOADR :
				begin
					NS = EXECUTE2;
				end
				STORER :
				begin
					NS = EXECUTE2;
				end
				ADD :
				begin
					NS = INCREMENT;
				end
				SUB :
				begin
					NS = INCREMENT;
				end
				JMPNEG :
				begin
					NS = INCREMENT;
				end
				JMPZ :
				begin
					NS = INCREMENT;
				end
				JMP :
				begin
					NS = INCREMENT;
				end
				END : NS = WAIT;
				default: NS = WAIT;
			endcase
		end
		EXECUTE2:
		begin
			NS = EXECUTE3;
		end
		EXECUTE3:
		begin
			NS = EXECUTE4;
		end
		EXECUTE4:
		begin
			NS = INCREMENT;
		end
		INCREMENT:
		begin
			NS = FETCH;
		end
		default: NS = WAIT;
	endcase
end

always @(posedge clk or negedge reset_n)
begin
	if (reset_n == 1'b0)
		S <= FETCH;
	else
		S <= NS;
end

always @(posedge clk or negedge reset_n)
begin
	if (reset_n == 1'b0)
	begin
		pc <= 16'h0000;
		mux_reg_file_c <= 2'b00; 
		alu_c <= 3'b000;
	       	register_file_c <= 13'b000000000000; 
	      	main_memory_c <= 2'b00; 
		immediate_line <= 16'h0000;
		instruction_fetch_sequence <= 2'b00;
	end
	else
	begin
		case (S)
			FETCH:
			begin
				/* fetch instruction */
				/* step 1 is to move the pc to register 15 which will talk to memory */
				mux_reg_file_c <= 2'b10; // Write the immediate line to the regfile
				alu_c <= 3'b011; // set to pass through
			       	register_file_c <= 13'b1111111111111; // Write to register $15
				main_memory_c <= 2'b00; // do nothing
				immediate_line <= pc;
			end
			FETCH2:
			begin
				/* step 2 is to move the register to the memory addressing */
				mux_reg_file_c <= 2'b11; // Doesn't matter
				alu_c <= 3'b000; // Doesn't matter
			       	register_file_c <= 13'b1111111111110; // Read register $15 as Address
			       	main_memory_c <= 2'b01; // load the registers to read
			end
			FETCH3:
			begin
				/* step 2 maintanance */
				mux_reg_file_c <= 2'b11; // Doesn't matter
				alu_c <= 3'b000; // Doesn't matter
			       	register_file_c <= 13'b1111111111110; // Read register $15 as Address
			       	main_memory_c <= 2'b01; // load the registers to read
			end
			FETCH4:
			begin
				/* step 2 maintanance */
				mux_reg_file_c <= 2'b11; // Doesn't matter
				alu_c <= 3'b000; // Doesn't matter
			       	register_file_c <= 13'b1111111111110; // Read register $15 as Address
			       	main_memory_c <= 2'b01; // load the registers to read
			end
			FETCH5:
			begin
				if (instruction_fetch_sequence == 2'b00)
					instruction_register1 <= memory_word;
				else
					instruction_register2 <= memory_word;
			end
			DECODE:
			begin
				if (second_instruction_to_fetch == 1'b1 && instruction_fetch_sequence == 2'b00)
				begin
					/* If this is a 2 word instruction then fetch second word */
					pc <= pc + 2'h1;
					instruction_fetch_sequence <= 2'b01;
				end
				else
				begin
					instruction_fetch_sequence <= 2'b00;
				end

				mux_reg_file_c <= 2'b00; // do nothing
				alu_c <= 3'b000; // do nothing
			       	register_file_c <= 13'b0000000000000; // do nothing 
			       	main_memory_c <= 2'b00; // do nothing
			end
			EXECUTE:
			begin
				case (instruction_register1[3:0])
					MOVE:
					begin
						/* ONE step instruction that sends out source, through alu, and into destination */
						mux_reg_file_c <= 2'b01; // writeback the alu pass thorugh line
						alu_c <= 3'b011; // set to pass through
					       	register_file_c <= {4'b0000,instruction_register1[11:8]/*source register*/,instruction_register1[7:4]/*destination_register*/,1'b1}; // Write to destination register (last bit = 1) and read from source
					       	main_memory_c <= 2'b00; // do nothing
					end
					MOVEI:
					begin
						/* ONE step instruction that sends out from control to register */
						mux_reg_file_c <= 2'b10; // Write the immediate line to the regfile
						immediate_line <= instruction_register2;
						alu_c <= 3'b000; // doesn't matter
					       	register_file_c <= {4'b0000,4'b0000,instruction_register1[7:4]/*destination_register*/,1'b1}; // Write to destination register (last bit = 1)
					       	main_memory_c <= 2'b00; // do nothing
					end
					LOAD :
					begin
						/* MULTI step - first, load the immediate address */
						mux_reg_file_c <= 2'b10; // Write the immediate line to the regfile
						alu_c <= 3'b011; // set to pass through
					       	register_file_c <= 13'b1111111111111; // Write to register $15
						main_memory_c <= 2'b00; // do nothing
						immediate_line <= instruction_register2;
					end
					STORE :
					begin
						/* MULTI step - first, load the immediate address */
						mux_reg_file_c <= 2'b10; // Write the immediate line to the regfile
						alu_c <= 3'b011; // set to pass through
					       	register_file_c <= 13'b1111111111111; // Write to register $15
						main_memory_c <= 2'b00; // do nothing
						immediate_line <= instruction_register2;
					end
					LOADR :
					begin
						/* MULTI step - first, load the register address to the address register */
						mux_reg_file_c <= 2'b01; // writeback the alu pass thorugh line
						alu_c <= 3'b011; // set to pass through
					       	register_file_c <= {4'b0000,instruction_register1[11:8]/*source register 2 */,4'b1111/*destination_register - $15 */,1'b1}; // Write to destination register (last bit = 1) and read from source
					       	main_memory_c <= 2'b00; // do nothing
					end
					STORER :
					begin
						/* MULTI step - first, load the register address to the address register */
						mux_reg_file_c <= 2'b01; // writeback the alu pass thorugh line
						alu_c <= 3'b011; // set to pass through
					       	register_file_c <= {4'b0000,instruction_register1[11:8]/*source register 2 */,4'b1111/*destination_register - $15 */,1'b1}; // Write to destination register (last bit = 1) and read from source
					       	main_memory_c <= 2'b00; // do nothing
					end
					ADD :
					begin
						/* ONE step instruction that does addition */
						mux_reg_file_c <= 2'b01; // writeback the alu output line
						alu_c <= 3'b101; // set add
					       	register_file_c <= {instruction_register1[7:4]/*source1*/,instruction_register1[11:8]/*source2*/,instruction_register1[7:4]/*destination_register*/,1'b1}; // Write to destination register (last bit = 1) and read from source
					       	main_memory_c <= 2'b00; // do nothing
					end
					SUB :
					begin
						/* ONE step instruction that does subtraction */
						mux_reg_file_c <= 2'b01; // writeback the alu output line
						alu_c <= 3'b110; // set add
					       	register_file_c <= {instruction_register1[11:8]/*source1*/,instruction_register1[7:4]/*source2*/,instruction_register1[7:4]/*destination_register*/,1'b1}; // Write to destination register (last bit = 1) and read from source
					       	main_memory_c <= 2'b00; // do nothing
					end
					JMPNEG :
					begin
						if (status_register[0] == 1'b1)
						begin
							mux_reg_file_c <= 2'b00; // do nothing
							alu_c <= 3'b000; // do nothing
						       	register_file_c <= 13'b0000000000000; // do nothing 
						       	main_memory_c <= 2'b00; // do nothing
							/* set the instruction to the jump point -2 since we'll still increment */
							pc <= instruction_register2 - 2'h1; 
						end
					end
					JMPZ :
					begin
						if (status_register[1] == 1'b1)
						begin
							mux_reg_file_c <= 2'b00; // do nothing
							alu_c <= 3'b000; // do nothing
						       	register_file_c <= 13'b0000000000000; // do nothing 
						       	main_memory_c <= 2'b00; // do nothing
							/* set the instruction to the jump point -2 since we'll still increment */
							pc <= instruction_register2 - 2'h1; 
						end
					end
					JMP :
					begin
						mux_reg_file_c <= 2'b00; // do nothing
						alu_c <= 3'b000; // do nothing
					       	register_file_c <= 13'b0000000000000; // do nothing 
					       	main_memory_c <= 2'b00; // do nothing
						/* set the instruction to the jump point -2 since we'll still increment */
						pc <= instruction_register2 - 2'h1; 
					end
					default:
					begin
					end
				endcase
			end
			EXECUTE2:
			begin
				case (instruction_register1[3:0])
					LOAD :
					begin
						/* MULTI step - two, move the address and the memory direction */
						mux_reg_file_c <= 2'b11; // Doesn't matter
						alu_c <= 3'b000; // Doesn't matter
					       	register_file_c <= 13'b1111111111110; // Read register $15 as Address
					       	main_memory_c <= 2'b01; // load the registers to read
					end
					LOADR :
					begin
						/* MULTI step - two, move the address and the memory direction */
						mux_reg_file_c <= 2'b11; // Doesn't matter
						alu_c <= 3'b000; // Doesn't matter
					       	register_file_c <= 13'b1111111111110; // Read register $15 as Address
					       	main_memory_c <= 2'b01; // load the registers to read
					end
					STORE :
					begin
						/* MULTI step - two, move the address and the memory direction */
						mux_reg_file_c <= 2'b11; // Doesn't matter
						alu_c <= 3'b000; // Doesn't matter
					       	register_file_c <= {4'b1111,instruction_register1[7:4]/*source register 2 */,4'b1111/*destination_register - $15 */,1'b0}; // Have read address and value to store
					       	main_memory_c <= 2'b11; // load the registers to write
					end
					STORER :
					begin
						/* MULTI step - two, move the address and the memory direction */
						mux_reg_file_c <= 2'b11; // Doesn't matter
						alu_c <= 3'b000; // Doesn't matter
					       	register_file_c <= {4'b1111,instruction_register1[7:4]/*source register 2 */,4'b1111/*destination_register - $15 */,1'b0}; // Have read address and value to store
					       	main_memory_c <= 2'b11; // load the registers to write
					end
				endcase
			end
			EXECUTE3:
			begin
				case (instruction_register1[3:0])
					LOAD :
					begin
						/* MULTI step - two, maintanance */
						mux_reg_file_c <= 2'b11; // Doesn't matter
						alu_c <= 3'b000; // Doesn't matter
					       	register_file_c <= 13'b1111111111110; // Read register $15 as Address
					       	main_memory_c <= 2'b01; // load the registers to read
					end
					LOADR :
					begin
						/* MULTI step - two, maintanance */
						mux_reg_file_c <= 2'b11; // Doesn't matter
						alu_c <= 3'b000; // Doesn't matter
					       	register_file_c <= 13'b1111111111110; // Read register $15 as Address
					       	main_memory_c <= 2'b01; // load the registers to read
					end
					STORE :
					begin
						/* MULTI step - two, maintanance */
						mux_reg_file_c <= 2'b11; // Doesn't matter
						alu_c <= 3'b000; // Doesn't matter
					       	register_file_c <= {4'b1111,instruction_register1[7:4]/*source register 2 */,4'b1111/*destination_register - $15 */,1'b0}; // Have read address and value to store
					       	main_memory_c <= 2'b11; // load the registers to write
					end
					STORER :
					begin
						/* MULTI step - two, maintanance */
						mux_reg_file_c <= 2'b11; // Doesn't matter
						alu_c <= 3'b000; // Doesn't matter
					       	register_file_c <= {4'b1111,instruction_register1[7:4]/*source register 2 */,4'b1111/*destination_register - $15 */,1'b0}; // Have read address and value to store
					       	main_memory_c <= 2'b11; // load the registers to write
					end
				endcase
			end
			EXECUTE4:
			begin
				case (instruction_register1[3:0])
					LOAD :
					begin
						/* MULTI step - three, write to register */
						mux_reg_file_c <= 2'b00; // writeback the memory path
						alu_c <= 3'b000; // Doesn't matter
					       	register_file_c <= {4'b0000,4'b0000,instruction_register1[7:4]/*destination_register*/,1'b1}; // Write to destination register (last bit = 1)
					       	main_memory_c <= 2'b01; // do nothing
					end
					LOADR :
					begin
						/* MULTI step - three, write to register */
						mux_reg_file_c <= 2'b00; // writeback the memory path
						alu_c <= 3'b000; // Doesn't matter
					       	register_file_c <= {4'b0000,4'b0000,instruction_register1[7:4]/*destination_register*/,1'b1}; // Write to destination register (last bit = 1)
					       	main_memory_c <= 2'b01; // do nothing
					end
					STORE :
					begin
						/* MULTI step - two, maintanance */
						mux_reg_file_c <= 2'b11; // Doesn't matter
						alu_c <= 3'b000; // Doesn't matter
					       	register_file_c <= {4'b1111,instruction_register1[7:4]/*source register 2 */,4'b1111/*destination_register - $15 */,1'b0}; // Have read address and value to store
					       	main_memory_c <= 2'b11; // load the registers to write
					end
					STORER :
					begin
						/* MULTI step - two, maintanance */
						mux_reg_file_c <= 2'b11; // Doesn't matter
						alu_c <= 3'b000; // Doesn't matter
					       	register_file_c <= {4'b1111,instruction_register1[7:4]/*source register 2 */,4'b1111/*destination_register - $15 */,1'b0}; // Have read address and value to store
					       	main_memory_c <= 2'b11; // load the registers to write
					end
				endcase
			end
			INCREMENT:
			begin
				mux_reg_file_c <= 2'b00; // do nothing
				alu_c <= 3'b000; // do nothing
			       	register_file_c <= 13'b0000000000000; // do nothing 
			       	main_memory_c <= 2'b00; // do nothing
				/* increment counter */
				pc <= pc + 2'h1;
			end
			default:
			begin
				mux_reg_file_c <= 2'b00; // do nothing
				alu_c <= 3'b000; // do nothing
			       	register_file_c <= 13'b0000000000000; // do nothing 
			       	main_memory_c <= 2'b00; // do nothing
			end
		endcase
	end
end

endmodule
