//Mark Stratis, Summer 2010

module lempel_ziv_compression
	(
		////////////////////	Clock Input	 	////////////////////	 
		CLOCK_27,						//	27 MHz
		CLOCK_50,						//	50 MHz
		EXT_CLOCK,						//	External Clock
		////////////////////	Push Button		////////////////////
		KEY,							//	Pushbutton[3:0]
		////////////////////	DPDT Switch		////////////////////
		SW,								//	Toggle Switch[17:0]
		////////////////////	7-SEG Dispaly	////////////////////
		HEX0,							//	Seven Segment Digit 0
		HEX1,							//	Seven Segment Digit 1
		HEX2,							//	Seven Segment Digit 2
		HEX3,							//	Seven Segment Digit 3
		HEX4,							//	Seven Segment Digit 4
		HEX5,							//	Seven Segment Digit 5
		HEX6,							//	Seven Segment Digit 6
		HEX7,							//	Seven Segment Digit 7
		////////////////////////	LED		////////////////////////
		LEDG,							//	LED Green[8:0]
		LEDR,							//	LED Red[17:0]
		////////////////////////	UART	////////////////////////
		UART_TXD,						//	UART Transmitter
		UART_RXD,						//	UART Receiver
		////////////////////////	IRDA	////////////////////////
		IRDA_TXD,						//	IRDA Transmitter
		IRDA_RXD,						//	IRDA Receiver
		/////////////////////	SDRAM Interface		////////////////
		DRAM_DQ,						//	SDRAM Data bus 16 Bits
		DRAM_ADDR,						//	SDRAM Address bus 12 Bits
		DRAM_LDQM,						//	SDRAM Low-byte Data Mask 
		DRAM_UDQM,						//	SDRAM High-byte Data Mask
		DRAM_WE_N,						//	SDRAM Write Enable
		DRAM_CAS_N,						//	SDRAM Column Address Strobe
		DRAM_RAS_N,						//	SDRAM Row Address Strobe
		DRAM_CS_N,						//	SDRAM Chip Select
		DRAM_BA_0,						//	SDRAM Bank Address 0
		DRAM_BA_1,						//	SDRAM Bank Address 0
		DRAM_CLK,						//	SDRAM Clock
		DRAM_CKE,						//	SDRAM Clock Enable
		////////////////////	Flash Interface		////////////////
		FL_DQ,							//	FLASH Data bus 8 Bits
		FL_ADDR,						//	FLASH Address bus 22 Bits
		FL_WE_N,						//	FLASH Write Enable
		FL_RST_N,						//	FLASH Reset
		FL_OE_N,						//	FLASH Output Enable
		FL_CE_N,						//	FLASH Chip Enable
		////////////////////	SRAM Interface		////////////////
		SRAM_DQ,						//	SRAM Data bus 16 Bits
		SRAM_ADDR,						//	SRAM Address bus 18 Bits
		SRAM_UB_N,						//	SRAM High-byte Data Mask 
		SRAM_LB_N,						//	SRAM Low-byte Data Mask 
		SRAM_WE_N,						//	SRAM Write Enable
		SRAM_CE_N,						//	SRAM Chip Enable
		SRAM_OE_N,						//	SRAM Output Enable
		////////////////////	ISP1362 Interface	////////////////
		OTG_DATA,						//	ISP1362 Data bus 16 Bits
		OTG_ADDR,						//	ISP1362 Address 2 Bits
		OTG_CS_N,						//	ISP1362 Chip Select
		OTG_RD_N,						//	ISP1362 Write
		OTG_WR_N,						//	ISP1362 Read
		OTG_RST_N,						//	ISP1362 Reset
		OTG_FSPEED,						//	USB Full Speed,	0 = Enable, Z = Disable
		OTG_LSPEED,						//	USB Low Speed, 	0 = Enable, Z = Disable
		OTG_INT0,						//	ISP1362 Interrupt 0
		OTG_INT1,						//	ISP1362 Interrupt 1
		OTG_DREQ0,						//	ISP1362 DMA Request 0
		OTG_DREQ1,						//	ISP1362 DMA Request 1
		OTG_DACK0_N,					//	ISP1362 DMA Acknowledge 0
		OTG_DACK1_N,					//	ISP1362 DMA Acknowledge 1
		////////////////////	LCD Module 16X2		////////////////
		LCD_ON,							//	LCD Power ON/OFF
		LCD_BLON,						//	LCD Back Light ON/OFF
		LCD_RW,							//	LCD Read/Write Select, 0 = Write, 1 = Read
		LCD_EN,							//	LCD Enable
		LCD_RS,							//	LCD Command/Data Select, 0 = Command, 1 = Data
		LCD_DATA,						//	LCD Data bus 8 bits
		////////////////////	SD_Card Interface	////////////////
		SD_DAT,							//	SD Card Data
		SD_DAT3,						//	SD Card Data 3
		SD_CMD,							//	SD Card Command Signal
		SD_CLK,							//	SD Card Clock
		////////////////////	USB JTAG link	////////////////////
		TDI,  							// CPLD -> FPGA (data in)
		TCK,  							// CPLD -> FPGA (clk)
		TCS,  							// CPLD -> FPGA (CS)
	    TDO,  							// FPGA -> CPLD (data out)
		////////////////////	I2C		////////////////////////////
		I2C_SDAT,						//	I2C Data
		I2C_SCLK,						//	I2C Clock
		////////////////////	PS2		////////////////////////////
		PS2_DAT,						//	PS2 Data
		PS2_CLK,						//	PS2 Clock
		////////////////////	VGA		////////////////////////////
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK,						//	VGA BLANK
		VGA_SYNC,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,  						//	VGA Blue[9:0]
		////////////	Ethernet Interface	////////////////////////
		ENET_DATA,						//	DM9000A DATA bus 16Bits
		ENET_CMD,						//	DM9000A Command/Data Select, 0 = Command, 1 = Data
		ENET_CS_N,						//	DM9000A Chip Select
		ENET_WR_N,						//	DM9000A Write
		ENET_RD_N,						//	DM9000A Read
		ENET_RST_N,						//	DM9000A Reset
		ENET_INT,						//	DM9000A Interrupt
		ENET_CLK,						//	DM9000A Clock 25 MHz
		////////////////	Audio CODEC		////////////////////////
		AUD_ADCLRCK,					//	Audio CODEC ADC LR Clock
		AUD_ADCDAT,						//	Audio CODEC ADC Data
		AUD_DACLRCK,					//	Audio CODEC DAC LR Clock
		AUD_DACDAT,						//	Audio CODEC DAC Data
		AUD_BCLK,						//	Audio CODEC Bit-Stream Clock
		AUD_XCK,						//	Audio CODEC Chip Clock
		////////////////	TV Decoder		////////////////////////
		TD_DATA,    					//	TV Decoder Data bus 8 bits
		TD_HS,							//	TV Decoder H_SYNC
		TD_VS,							//	TV Decoder V_SYNC
		TD_RESET,						//	TV Decoder Reset
		////////////////////	GPIO	////////////////////////////
		GPIO_0,							//	GPIO Connection 0
		GPIO_1,							//	GPIO Connection 1
		
		//---------------------------My inputs/outputs--------------------------
		//in,
		//data_termination,
		//input_data_valid
		out,
		output_data_valid,
		input_data_accept
	);

	////////////////////////	Clock Input	 	////////////////////////
	input			CLOCK_27;				//	27 MHz
	input			CLOCK_50;				//	50 MHz
	input			EXT_CLOCK;				//	External Clock
	////////////////////////	Push Button		////////////////////////
	input	[3:0]	KEY;					//	Pushbutton[3:0]
	////////////////////////	DPDT Switch		////////////////////////
	input	[17:0]	SW;						//	Toggle Switch[17:0]
	////////////////////////	7-SEG Dispaly	////////////////////////
	output	[6:0]	HEX0;					//	Seven Segment Digit 0
	output	[6:0]	HEX1;					//	Seven Segment Digit 1
	output	[6:0]	HEX2;					//	Seven Segment Digit 2
	output	[6:0]	HEX3;					//	Seven Segment Digit 3
	output	[6:0]	HEX4;					//	Seven Segment Digit 4
	output	[6:0]	HEX5;					//	Seven Segment Digit 5
	output	[6:0]	HEX6;					//	Seven Segment Digit 6
	output	[6:0]	HEX7;					//	Seven Segment Digit 7
	////////////////////////////	LED		////////////////////////////
	output	[8:0]	LEDG;					//	LED Green[8:0]
	output	[17:0]	LEDR;					//	LED Red[17:0]
	////////////////////////////	UART	////////////////////////////
	output			UART_TXD;				//	UART Transmitter
	input			UART_RXD;				//	UART Receiver
	////////////////////////////	IRDA	////////////////////////////
	output			IRDA_TXD;				//	IRDA Transmitter
	input			IRDA_RXD;				//	IRDA Receiver
	///////////////////////		SDRAM Interface	////////////////////////
	inout	[15:0]	DRAM_DQ;				//	SDRAM Data bus 16 Bits
	output	[11:0]	DRAM_ADDR;				//	SDRAM Address bus 12 Bits
	output			DRAM_LDQM;				//	SDRAM Low-byte Data Mask 
	output			DRAM_UDQM;				//	SDRAM High-byte Data Mask
	output			DRAM_WE_N;				//	SDRAM Write Enable
	output			DRAM_CAS_N;				//	SDRAM Column Address Strobe
	output			DRAM_RAS_N;				//	SDRAM Row Address Strobe
	output			DRAM_CS_N;				//	SDRAM Chip Select
	output			DRAM_BA_0;				//	SDRAM Bank Address 0
	output			DRAM_BA_1;				//	SDRAM Bank Address 0
	output			DRAM_CLK;				//	SDRAM Clock
	output			DRAM_CKE;				//	SDRAM Clock Enable
	////////////////////////	Flash Interface	////////////////////////
	inout	[7:0]	FL_DQ;					//	FLASH Data bus 8 Bits
	output	[21:0]	FL_ADDR;				//	FLASH Address bus 22 Bits
	output			FL_WE_N;				//	FLASH Write Enable
	output			FL_RST_N;				//	FLASH Reset
	output			FL_OE_N;				//	FLASH Output Enable
	output			FL_CE_N;				//	FLASH Chip Enable
	////////////////////////	SRAM Interface	////////////////////////
	inout	[15:0]	SRAM_DQ;				//	SRAM Data bus 16 Bits
	output	[17:0]	SRAM_ADDR;				//	SRAM Address bus 18 Bits
	output			SRAM_UB_N;				//	SRAM High-byte Data Mask 
	output			SRAM_LB_N;				//	SRAM Low-byte Data Mask 
	output			SRAM_WE_N;				//	SRAM Write Enable
	output			SRAM_CE_N;				//	SRAM Chip Enable
	output			SRAM_OE_N;				//	SRAM Output Enable
	////////////////////	ISP1362 Interface	////////////////////////
	inout	[15:0]	OTG_DATA;				//	ISP1362 Data bus 16 Bits
	output	[1:0]	OTG_ADDR;				//	ISP1362 Address 2 Bits
	output			OTG_CS_N;				//	ISP1362 Chip Select
	output			OTG_RD_N;				//	ISP1362 Write
	output			OTG_WR_N;				//	ISP1362 Read
	output			OTG_RST_N;				//	ISP1362 Reset
	output			OTG_FSPEED;				//	USB Full Speed,	0 = Enable, Z = Disable
	output			OTG_LSPEED;				//	USB Low Speed, 	0 = Enable, Z = Disable
	input			OTG_INT0;				//	ISP1362 Interrupt 0
	input			OTG_INT1;				//	ISP1362 Interrupt 1
	input			OTG_DREQ0;				//	ISP1362 DMA Request 0
	input			OTG_DREQ1;				//	ISP1362 DMA Request 1
	output			OTG_DACK0_N;			//	ISP1362 DMA Acknowledge 0
	output			OTG_DACK1_N;			//	ISP1362 DMA Acknowledge 1
	////////////////////	LCD Module 16X2	////////////////////////////
	inout	[7:0]	LCD_DATA;				//	LCD Data bus 8 bits
	output			LCD_ON;					//	LCD Power ON/OFF
	output			LCD_BLON;				//	LCD Back Light ON/OFF
	output			LCD_RW;					//	LCD Read/Write Select, 0 = Write, 1 = Read
	output			LCD_EN;					//	LCD Enable
	output			LCD_RS;					//	LCD Command/Data Select, 0 = Command, 1 = Data
	////////////////////	SD Card Interface	////////////////////////
	inout			SD_DAT;					//	SD Card Data
	inout			SD_DAT3;				//	SD Card Data 3
	inout			SD_CMD;					//	SD Card Command Signal
	output			SD_CLK;					//	SD Card Clock
	////////////////////////	I2C		////////////////////////////////
	inout			I2C_SDAT;				//	I2C Data
	output			I2C_SCLK;				//	I2C Clock
	////////////////////////	PS2		////////////////////////////////
	input		 	PS2_DAT;				//	PS2 Data
	input			PS2_CLK;				//	PS2 Clock
	////////////////////	USB JTAG link	////////////////////////////
	input  			TDI;					// CPLD -> FPGA (data in)
	input  			TCK;					// CPLD -> FPGA (clk)
	input  			TCS;					// CPLD -> FPGA (CS)
	output 			TDO;					// FPGA -> CPLD (data out)
	////////////////////////	VGA			////////////////////////////
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	////////////////	Ethernet Interface	////////////////////////////
	inout	[15:0]	ENET_DATA;				//	DM9000A DATA bus 16Bits
	output			ENET_CMD;				//	DM9000A Command/Data Select, 0 = Command, 1 = Data
	output			ENET_CS_N;				//	DM9000A Chip Select
	output			ENET_WR_N;				//	DM9000A Write
	output			ENET_RD_N;				//	DM9000A Read
	output			ENET_RST_N;				//	DM9000A Reset
	input			ENET_INT;				//	DM9000A Interrupt
	output			ENET_CLK;				//	DM9000A Clock 25 MHz
	////////////////////	Audio CODEC		////////////////////////////
	inout			AUD_ADCLRCK;			//	Audio CODEC ADC LR Clock
	input			AUD_ADCDAT;				//	Audio CODEC ADC Data
	inout			AUD_DACLRCK;			//	Audio CODEC DAC LR Clock
	output			AUD_DACDAT;				//	Audio CODEC DAC Data
	inout			AUD_BCLK;				//	Audio CODEC Bit-Stream Clock
	output			AUD_XCK;				//	Audio CODEC Chip Clock
	////////////////////	TV Devoder		////////////////////////////
	input	[7:0]	TD_DATA;    			//	TV Decoder Data bus 8 bits
	input			TD_HS;					//	TV Decoder H_SYNC
	input			TD_VS;					//	TV Decoder V_SYNC
	output			TD_RESET;				//	TV Decoder Reset
	////////////////////////	GPIO	////////////////////////////////
	inout	[35:0]	GPIO_0;					//	GPIO Connection 0
	inout	[35:0]	GPIO_1;					//	GPIO Connection 1

	//	Turn on all display
	assign	HEX0		=	7'h00;
	assign	HEX1		=	7'h00;
	assign	HEX2		=	7'h00;
	assign	HEX3		=	7'h00;
	assign	HEX4		=	7'h00;
	assign	HEX5		=	7'h00;
	assign	HEX6		=	7'h00;
	assign	HEX7		=	7'h00;
	assign	LEDG	=	9'h1FF;
	assign	LEDR		=	18'h3FFFF;
	assign	LCD_ON		=	1'b1;
	assign	LCD_BLON	=	1'b1;

	//	All inout port turn to tri-state
	assign	DRAM_DQ		=	16'hzzzz;
	assign	FL_DQ		=	8'hzz;
	assign	SRAM_DQ		=	16'hzzzz;
	assign	OTG_DATA	=	16'hzzzz;
	assign	LCD_DATA	=	8'hzz;
	assign	SD_DAT		=	1'bz;
	assign	I2C_SDAT	=	1'bz;
	assign	ENET_DATA	=	16'hzzzz;
	assign	AUD_ADCLRCK	=	1'bz;
	assign	AUD_DACLRCK	=	1'bz;
	assign	AUD_BCLK	=	1'bz;
	assign	GPIO_0		=	36'hzzzzzzzzz;
	assign	GPIO_1		=	36'hzzzzzzzzz;

	//----------------------------------------------------------------------
	//----------------------------------------------------------------------
	//----------------------------------------------------------------------

	//input [7:0]in;//The next 8 bits of data to be compressed
	//input input_data_valid;
	//input data_termination;//high when end of data to be compressed
	reg [7:0]in;//The next 8 bits of data to be compressed
	reg input_data_valid;//should be an input, but the sender is built internally
	reg data_termination;//high when end of data to be compressed

	output reg [11:0]out;//to send compressed data
	output reg output_data_valid;//data is being sent
	output reg input_data_accept;//requesting the data to be compressed

	reg [48:0]dictionary[3999:0];//will hold 4000 entries (48 bits + 1 because there is a leading 1 say where sequence begins)
	reg [11:0]entry_num;//to help with finding the correct value in memory
	reg [11:0]new_entry;//to help with adding a leading 1
	reg [11:0]new_entry2;//this changes the first '1' (not the leading '1') of the new_entry and adds it in the next spot in the initial dictioanry
	reg [2:0]count;//for counting through the 8 bit input
	reg [3:0]create_bit;//to help finding the leading '1' while creating an entry
	reg [11:0]create_counter;
	reg [2:0]pause;
	reg [11:0]spot;//to help when searching through the dictionary
	reg [48:0]curr_string;//string being searched for
	reg [11:0]curr_compression;//temporary compression value, updated until the next character isn't found then it is output
	reg search_last;//a flag that tells the search state that it is searching the last bit and then it should encode.
	
	reg [31:0]test_count;
	reg [15:0]test_count2;
	reg [11:0]clear_ram;

	parameter MAX_SIZE = 12'b111110100000;//The dictionary has a max size of 4000 entries and then it will reset

	//states
	reg [3:0]s;//current state
	parameter make_zeros = 4'b0000,
			  initialize_dictionary = 4'b0001,
			  create_loop = 4'b0010,
			  get_next_bit = 4'b0011,
			  search = 4'b0100,
			  search_loop = 4'b0101,
			  encode = 4'b0110,
			  create_item = 4'b0111,
			  done = 4'b1000;
	

	always @(posedge CLOCK_50 or negedge KEY[0])
	begin
		if(KEY[0] == 1'b0)
		begin
			s <= make_zeros;
			in <= 8'b0;
			out <= 12'b0;
			output_data_valid <= 1'b0;
			input_data_accept <= 1'b0;
			data_termination <= 1'b0;
			entry_num <= 12'b0;
			new_entry <= 12'b0;
			new_entry2 <= 12'b0;
			pause <= 3'b0;
			spot <= 12'b0;
			curr_string <= 49'b0;
			curr_compression <= 12'b0;
			count <= 3'b111;
			test_count <= 32'b0;
			test_count2 <= 16'b0;
			create_bit <= 4'b1111;
			create_counter <= 12'b0;
			clear_ram <= 12'b0;
			search_last <= 1'b0;
			
			input_data_valid <= 1'b1;//always high right now to make for easy testing
		end
		else
		begin
			
			//TEST
			if(input_data_accept == 1'b1)
			begin
				
				/*//to get a random input, I used a hash function
				//HashValue = key*2654435761 mod 2^32
				in <= (test_count * 32'b10011110001101110111100110110001) % 33'b100000000000000000000000000000000;
				
				test_count <= test_count + 1'b1;*/
				
				
				if(test_count == 5'b00000)
				begin
					in <= 8'b11101100;//E C
				end
				else if(test_count == 5'b00001)
				begin
					in <= 8'b00101011;//2 B
				end
				else if(test_count == 5'b00010)
				begin
					in <= 8'b01000000;//4 0
				end
				else if(test_count == 5'b00011)
				begin
					in <= 8'b10101010;//A A
				end
				else if(test_count == 5'b00100)
				begin
					in <= 8'b00110111;//3 7
				end
				else if(test_count == 5'b00101)
				begin
					in <= 8'b00001010;//0 A
				end				
				else if(test_count == 5'b00110)
				begin
					in <= 8'b11011101;//D D
				end
				else if(test_count == 5'b00111)
				begin
					in <= 8'b01010110;//5 6
				end
				else if(test_count == 5'b01000)
				begin
					in <= 8'b01100110;//6 6
				end
				else if(test_count == 5'b01001)
				begin
					in <= 8'b10010110;//9 6
				end
				else if(test_count == 5'b01010)
				begin
					in <= 8'b01101001;//6 9
				end
				else if(test_count == 5'b01011)
				begin
					in <= 8'b00011110;//1 E
				end
				else if(test_count == 5'b01100)
				begin
					in <= 8'b00110010;//3 2
				end
				else if(test_count == 5'b01101)
				begin
					in <= 8'b10111101;//B D
				end
				else if(test_count == 5'b01110)
				begin
					in <= 8'b01010000;//5 0
				end
				else if(test_count == 5'b01111)
				begin
					in <= 8'b00101010;//2 A
				end
				else if(test_count == 5'b10000)
				begin
					in <= 8'b10110101;//B 5
				end
				else if(test_count == 5'b10001)
				begin
					in <= 8'b01101010;//6 A
				end
				else if(test_count == 5'b10010)
				begin
					in <= 8'b01011001;//5 9
				end
				else if(test_count == 5'b10011)
				begin
					in <= 8'b00110100;//3 4
				end
				else if(test_count == 5'b10100)
				begin
					in <= 8'b11110111;//F 7
				end
				else if(test_count == 5'b10101)
				begin
					in <= 8'b01100100;//6 4
				end
				else if(test_count == 5'b10110)
				begin
					in <= 8'b10010010;//9 2
				end
				else if(test_count == 5'b10111)
				begin
					in <= 8'b01100011;//6 3
				end
				else if(test_count == 5'b11000)
				begin
					in <= 8'b00110100;//3 4
				end
				else if(test_count == 5'b11001)
				begin
					in <= 8'b11101010;//E A
				end
				else if(test_count == 5'b11010)
				begin
					in <= 8'b01111110;//7 E
				end
				else if(test_count == 5'b11011)
				begin
					in <= 8'b01110101;//7 5
				end
				else if(test_count == 5'b11100)
				begin
					in <= 8'b01101110;//6 E
				end
				else if(test_count == 5'b11101)
				begin
					in <= 8'b00111101;//3 D
				end
				else if(test_count == 5'b11110)
				begin
					in <= 8'b10101010;//A A
				end
				else
				begin
					in <= 8'b01010101;//5 5
				end
					
											
				if(test_count < 5'b11111)
				begin
					test_count <= test_count + 1'b1;
				end
				else
				begin
					test_count <= 5'b0;
				end
				
				
				if(test_count2 < 16'b1111111111111111)
				begin
					test_count2 <= test_count2 + 1'b1;
				end
				else
				begin
					data_termination <= 1'b1;
					input_data_valid <= 1'b0;
				end
				
			end
			//END TEST
			
			
			case(s)
			
				//Initialize all of the memory locations to zero
				make_zeros:
				begin
					if(clear_ram < MAX_SIZE)
					begin
						dictionary[clear_ram] <= 49'b0;
						clear_ram <= clear_ram + 1'b1;
					end
					else
					begin
						dictionary[clear_ram] <= 49'b0;
						input_data_accept <= 1'b1;
						s <= initialize_dictionary;
					end
				end
			
				
				/*Initialize the dictionary with the values 0-128.  In addition, initialize a value which changes the first
				  one in the current value to zero.  A leading '1' will be placed before each value to help with searching for
				  sequences that begin with one or multiple zeros.*/
				initialize_dictionary:
				begin
					if(create_counter < 12'b11111110)
					begin
						input_data_accept <= 1'b0;
						create_bit <= 4'b1111;
						s <= create_loop;
					end
					else
					begin
						curr_string <= 49'b1;//leading 1 to tell where the sequence starts if it begins with a zero
						s <= get_next_bit;
					end
				end
					
					
				//This loop helps during the initialize dictionary state
				create_loop:
				begin
					if(create_counter == 12'b0)
					begin
						dictionary[create_counter] <= 2'b10;
						entry_num <= entry_num + 1'b1;
						create_counter <= create_counter + 1'b1;
						s <= initialize_dictionary;
					end
					else if(create_counter == 12'b1)
					begin
						dictionary[create_counter] <= 2'b11;
						entry_num <= entry_num + 1'b1;
						create_counter <= create_counter + 1'b1;
						s <= initialize_dictionary;
					end
					else if(entry_num[create_bit] == 1'b1)
					begin
						if(pause == 3'b000)
						begin
							new_entry <= entry_num;
							pause <= pause + 1'b1;
						end
						else if(pause == 3'b001)
						begin
							new_entry[create_bit + 1'b1] <= 1'b1;
							pause <= pause + 1'b1;
						end
						else if(pause == 3'b010)
						begin
							dictionary[create_counter] <= new_entry;
							create_counter <= create_counter + 1'b1;
							new_entry2 <= new_entry;
							pause <= pause + 1'b1;
						
						end
						else if(pause == 3'b011)
						begin
							new_entry2[create_bit] <= 1'b0;
							pause <= pause + 1'b1;
						end
						else
						begin
							dictionary[create_counter] <= new_entry2;
							create_counter <= create_counter + 1'b1;
							entry_num <= entry_num + 1'b1;
							pause <= 3'b000;
							s <= initialize_dictionary;	
						end
					end
					else
					begin
						create_bit <= create_bit - 1'b1;
					end
				end					
				
				
				//request the next bit from the sender
				get_next_bit:
				begin
					if(input_data_valid == 1'b1)
					begin
						if(count > 3'b000)
						begin
							curr_string <= {curr_string[47:0],in[count]};
							input_data_accept <= 1'b0;
							count <= count - 1'b1;
							s <= search;
						end
						else
						begin
							curr_string <= {curr_string[47:0],in[count]};
							input_data_accept <= 1'b1;
							count <= 3'b111;
							s <= search;
						end						
					end
					else
					begin
						if(count == 3'b0)
						begin
							curr_string <= {curr_string[47:0],in[count]};
							input_data_accept <= 1'b0;
							search_last <= 1'b1;
							s <= search;
						end
						else
						begin
							curr_string <= {curr_string[47:0],in[count]};
							input_data_accept <= 1'b0;
							count <= count - 1'b1;
							s <= search;
						end
					end
				end
				
				
				/*Search to see if there is a match. If there is, see if the next bit matches as well.
				  If not, add what matches plus the next bit to the dictionary and return the entry number
				  where the last match was found.*/
				search:
				begin				
					input_data_accept <= 1'b0;		
					
					if(dictionary[spot] == curr_string)
					begin
						curr_compression <= spot;
						if(search_last == 1'b1)
						begin
							spot <= 12'b0;
							s <= encode;
						end
						else
						begin
							spot <= 12'b0;							
							s <= get_next_bit;							
						end
					end
					else if(spot < create_counter)
					begin
						spot <= spot + 1'b1;
					end
					else
					begin
						spot <= 12'b0;
						s <= encode;
					end
				end
					
					
				//Send the current compression
				encode:
				begin
					out <= curr_compression;
					output_data_valid <= 1'b1;
					
					if((data_termination == 1'b1) && (count == 3'b0))
					begin
						s <= done;
					end
					else
					begin						
						s <= create_item;
					end
				end
				
				
				//Add the new entry to the dictionary in the next available spot
				create_item:
				begin
					output_data_valid <= 1'b0;
					
					if((data_termination == 1'b1) && (count == 3'b0))
					begin
						s <= done;
					end
					else
					begin
						curr_string <= {48'b1,curr_string[0]};
						curr_compression <= 12'b0;
						
						/*When I run out of space in the dictionary (currently size 4000), I will
						  clear the dictionary and reinitialize it.  I will do this rather than maintaining
						  the current dictionary and just not adding any new entries.  The way I do it is
						  more efficient for a file that has a random sequence and the latter way would be
						  more efficient for a file that has a lot of recurring sequences.*/
						if(create_counter == MAX_SIZE)
						begin
							create_counter <= 12'b0;
							clear_ram <= 12'b0;
							entry_num <= 12'b0;
							s <= make_zeros;
						end
						else
						begin
							create_counter <= create_counter + 1'b1;
							dictionary[create_counter] <= curr_string;
							s <= search;
						end
					end					
				end
			
				
				done:
				begin
					s <= done;
				end
				
				
				//Something went wrong
				default:
				begin
					s <= done;
				end
			
			endcase
			
		end		
	end
	
endmodule
