//Mark Stratis, Summer 2010

module conv_2D_SRAM_VGA_RS232(
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
		
		//-------------------------------------------------------------------
		
		//input_data_valid,//data is ready to be sent
		out,//to send convolved matrix back to user
		output_data_valid,//result is ready to be sent
		input_data_accept//Requesting the next value to be sent
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
	output	reg [17:0]	LEDR;					//	LED Red[17:0]
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
	inout   [15:0]	SRAM_DQ;				//	SRAM Data bus 16 Bits
	output  [17:0]	SRAM_ADDR;				//	SRAM Address bus 18 Bits
	output 			SRAM_UB_N;				//	SRAM High-byte Data Mask 
	output 			SRAM_LB_N;				//	SRAM Low-byte Data Mask 
	output 			SRAM_WE_N;				//	SRAM Write Enable
	output 			SRAM_CE_N;				//	SRAM Chip Enable
	output 			SRAM_OE_N;				//	SRAM Output Enable
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
	output	 [9:0]	VGA_R;   				//	VGA Red[9:0]
	output	 [9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	 [9:0]	VGA_B;   				//	VGA Blue[9:0]
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
	//assign	HEX0		=	7'h00;
	//assign	HEX1		=	7'h00;
	//assign	HEX2		=	7'h00;
	//assign	HEX3		=	7'h00;
	//assign	HEX4		=	7'h00;
	//assign	HEX5		=	7'h00;
	//assign	HEX6		=	7'h00;
	//assign	HEX7		=	7'h00;
	//assign	LEDG		=	9'h1FF;
	//assign	LEDR		=	18'h3FFFF;
	assign	LCD_ON		=	1'b1;
	assign	LCD_BLON	=	1'b1;

	//	All inout port turn to tri-state
	assign	DRAM_DQ		=	16'hzzzz;
	assign	FL_DQ		=	8'hzz;
	//assign	SRAM_DQ		=	16'hzzzz;
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
	
	
	//--------------------------------------------------------------			
	
	//signals that are defined in the benchmark
	reg [15:0]in;//input from user
	output reg [15:0]out;//to send convolved matrix back to user
	output reg output_data_valid;//result is ready to be sent
	output reg input_data_accept;//requesting the data	
	reg input_data_valid;//should be an input, but the sender is built internally
	reg convolution_matrix;//should be an input, but the sender is built internally
	
	//input from the different kernels that are defined
	wire [15:0]in_normal;//normal kernel
	wire [15:0]in_blur;//blur kernel
	wire [15:0]in_motion;//motion kernel
	
	reg [24:0]kernel;
	reg [15:0]flipped_kernel[24:0];//must flip the kernel vertically and horizontally before convolution
	reg [17:0]spot;//to help with memory location of orig_matrix
	reg [17:0]count;//general counter
	reg [17:0]test_count;//used for sending values to be convolved
	reg [4:0]sum_count;//counts steps during the convolve stage
	reg [1:0]pause;//slow down in certain steps to help with reading/writing to the SRAM
	reg [15:0]sum;//The sum of all of the products, after all calculations it is the new value. 4 to help with overflow	
	reg [8:0]row;//current row, col in orig matrix, 9 bit to help with overflow in convolution phase
	reg [8:0]col;
	
	//states
	reg input_kernel;
	reg input_orig_matrix;
	reg convolve;
	
	parameter
	COUNT_RESET = 18'b0,//0
	SUM_RESET = 16'b0,//0
	KERNEL_SIZE = 18'b11000,//24 (0-24)
	ORIG_SIZE = 18'b100101100000000,//19,200
	FULL_SIZE = 18'b100111101110000,//20,336 (matrix has a border of zeros of with 2 to help with convolution)
	FIRST_SPOT = 18'b1100101010,//810 (first spot in the actual matrix with the size of 404x404)
	FIRST_ROW = 9'b10,//2
	FIRST_COL = 9'b10,//2
	ORIG_ROW_LENGTH = 9'b10100000,//160
	ORIG_COL_LENGTH = 9'b1111000,//120
	ORIG_ROW_END = 9'b10100010,//162
	ORIG_COL_END = 9'b1111010,//122
	FULL_ROW_LENGTH = 9'b10100100,//164
	FULL_COL_LENGTH = 9'b1111100;//124	

	
	//------------------------------Control SRAM---------------------------
	//need to read or write to SRAM
	reg write;
	reg read;
	wire [15:0]mem_in;
	reg [15:0]mem_out;
	
	assign SRAM_ADDR = spot;
	// All enabled when signal low
	assign SRAM_WE_N = !write;			// SRAM Write Enable
	assign SRAM_UB_N = 1'b0;        	// SRAM High-byte Data Mask
	assign SRAM_LB_N = 1'b0;        	// SRAM Low-byte Data Mask 
	assign SRAM_CE_N = 1'b0;       		// SRAM Chip Enable
	assign SRAM_OE_N = !read;   		// SRAM Output Enable

	assign SRAM_DQ = (write) ? mem_out : 16'hzzzz;	 //output assignment of inout port to the sram
	assign mem_in = SRAM_DQ;   //input assignment of inout port from the sram
	
	//--------------------------RAM to store the bitmap-------------------------
	wire [14:0] readAddr;
	wire [3:0] readData;
	reg [14:0]pic_spot;
	
	assign readAddr = pic_spot;
	
	pic_rom my_rom(
		.address(readAddr),
		.clock(CLOCK_50),
		.q(readData));
	
	
	//-------------------------------VGA-----------------------------	
	wire [8:0]color;
	wire [7:0] x; //0-159
	wire [6:0] y; //0-119
	reg [7:0] xReg;
	reg [6:0] yReg;
	wire writeEn;
	wire tenMHz_clk;
	
	assign writeEn = 1'b1;
	assign x = xReg;
	assign y = yReg;
	assign color = sum;
		
	// Instantiate the vga adapter
	// x 0-159, y 0-119
	VgaAdapter inst(KEY[0],tenMHz_clk,color,x,y,writeEn,VGA_R,VGA_G,VGA_B,VGA_HS,VGA_VS,VGA_BLANK,VGA_SYNC,VGA_CLK);
	
	// clock sent to the VGA is 10 MHz
	VGA_clk tenMhzvlovk(CLOCK_50, tenMHz_clk, VGA_CLK);
	
	
	//------------------------KERNELS-------------------------------	
	KERNEL_NORMAL normal(test_count,CLOCK_50,in_normal);	
	KERNEL_BLUR blur(test_count,CLOCK_50,in_blur);	
	KERNEL_MOTION motion(test_count,CLOCK_50,in_motion);
	
	
	
	always @(posedge CLOCK_50 or negedge KEY[0])
	begin
		if(KEY[0] == 1'b0)
		begin
			input_kernel <= 1'b1;
			input_orig_matrix <= 1'b0;
			convolve <= 1'b0;
			read <= 1'b0;
			write <= 1'b0;
			mem_out <= 16'b0;
			count <= (KERNEL_SIZE + 3'b100);//When inputting kernel, count down to 0 from KERNEL_SIZE + 4, 4 because of timing issues
			sum_count <= 4'b0000;
			sum <= SUM_RESET;
			spot <= 18'b0;
			pic_spot <= 15'b0;
			row <= 9'b0;
			col <= 9'b0;
			out <= SUM_RESET;
			output_data_valid <= 1'b0;//set high when output bus contains value
			input_data_accept <= 1'b0;
			input_data_valid <= 1'b1;//should be an input, but the sender is built internally		
			convolution_matrix <= 1'b1;//should be an input, but the sender is built internally
			test_count <= 18'b0;
			pause <= 2'b00;
			xReg <= 8'b0;
			yReg <= 7'b0;			
		end
		else
		begin
				
			//SENDER.  inputs the correct kernel and picture
			if((input_kernel == 1'b1) && (input_data_accept == 1'b1) && (convolution_matrix == 1'b1))
			begin
				if(SW == 17'b1)
				begin
					in <= in_blur;
				end
				else if(SW == 17'b10)
				begin
					in <= in_motion;
				end
				else
				begin
					in <= in_normal;
				end
				
				test_count <= test_count + 1'b1;

			end
			
			if((input_orig_matrix == 1'b1) && (input_data_accept == 1'b1) && (convolution_matrix == 1'b0))
			begin
			
				in <= readData;
				
			end
			//END SENDER
		
		
			/*Store the convolution matrix (kernel) into on-chip registers.  By counting down to zero,
			  it automatcally flips the kernel so it doesn't have to be done in another step*/
			if((input_kernel == 1'b1) && (input_data_valid == 1'b1) && (convolution_matrix == 1'b1))
			begin
				//after the kernel is stored and flipped, input the original matrix
				if(count == COUNT_RESET)
				begin
					flipped_kernel[count] <= in;
					count <= COUNT_RESET;
					input_orig_matrix <= 1'b1;
					input_kernel <= 1'b0;
					write <= 1'b1;
					test_count <= 18'b0;
					in <= 16'b0;
					
					convolution_matrix <= 1'b0;//should be an input, but the sender is built internally
					input_data_accept <= 1'b0;//should be an input, but the sender is built internally
				end
				else if(count > KERNEL_SIZE)//For timing issues
				begin
					input_data_accept <= 1'b1;
					count <= count - 1'b1;
				end
				else
				begin
					flipped_kernel[count] <= in;
					count <= count - 1'b1;
					input_data_accept <= 1'b1;
				end			
			end			
			
			/*Store the input into the SRAM at memory location "spot."  There is a pause 
			  to help with reading and writing to the SRAM because it is slow*/
			if((input_orig_matrix == 1'b1) && (input_data_valid == 1'b1) && (convolution_matrix == 1'b0))
			begin
				//after finished storing the matrix, move on to convolution
				if(count == (FULL_SIZE + 1'b1))
				begin
					count <= 9'b000000000;
					convolve <= 1'b1;
					input_orig_matrix <= 1'b0;
					write <= 1'b0;
					read <= 1'b1;
					input_data_accept <= 1'b0;
					spot <= 18'b0;
					row <= FIRST_ROW;
					col <= FIRST_COL;					
				end
				else
				begin				
					if(count == 18'b0)
					begin
						/*If it is outside these boundaries, store a blank pixel.  This is to help in the convolution
						state when on the borders of the matrix.  For a 5x5 kernel, there will be a blank border
						of width 2.*/
						if((col < (FIRST_COL - 1'b1)) || (col > ORIG_ROW_LENGTH) || (row < (FIRST_ROW)) || (row > ORIG_COL_LENGTH))
						begin
							input_data_accept <= 1'b0;
						end
						else
						begin
							input_data_accept <= 1'b1;
							pic_spot <= pic_spot + 1'b1;							
						end
						
						if(col < (FULL_ROW_LENGTH - 1'b1))
						begin
							col <= col + 1'b1;
							spot <= spot + 1'b1;
						end
						else
						begin
							col <= 9'b0;
							row <= row + 1'b1;
							spot <= spot + 1'b1;
						end
						
						count <= count + 1'b1;
				
					end
					else
					begin
					
						//write through to SRAM, knows to put it at mem location "spot"
						if(pause > 2'b00)
						begin
							if((col < (FIRST_COL)) || (col > ORIG_ROW_LENGTH) || (row < (FIRST_ROW)) || (row > ORIG_COL_LENGTH))
							begin
								mem_out <= 16'b0;
							end
							else
							begin
								mem_out <= in;
							end
						end
						
						/*The first clock cycle write the upper bits of a 32 bit number, the second
						  write the lower bits.  In this case I'm only working with 16 bits so I have
						  write it on the second clock cycle*/
						if(pause == 2'b11)
						begin
							pause <= 2'b00;						
							count <= count + 1'b1;
							
							if((col < (FIRST_COL - 1'b1)) || (col > ORIG_ROW_LENGTH) || (row < (FIRST_ROW)) || (row > ORIG_COL_LENGTH))
							begin						
								input_data_accept <= 1'b0;
							end
							else
							begin
								input_data_accept <= 1'b1;
								pic_spot <= pic_spot + 1'b1;
							end
							
							if(col < (FULL_ROW_LENGTH - 1'b1))
							begin
								col <= col + 1'b1;
								spot <= spot + 1'b1;
							end
							else
							begin
								col <= 9'b0;
								row <= row + 1'b1;
								spot <= spot + 1'b1;
							end
						end
						else
						begin
							pause <= pause + 1'b1;
							input_data_accept <= 1'b0;							
						end
					end					
				end
			end
			
			
			/*Go through all items and convolve them with the kernel.  Output the result of each and
			  it will also be sent to the VGA to display the resulting image.  Once again, the pause 
			  is used to help with reading from the SRAM*/
			if(convolve == 1'b1)
			begin
				if(count == ORIG_SIZE)//Finished
				begin
					count <= 9'b000000000;
					convolve <= 1'b0;
					input_orig_matrix <= 1'b0;
					write <= 1'b0;
					read <= 1'b0;
					input_data_accept <= 1'b0;
					spot <= 18'b0;
					row <= FIRST_ROW;
					col <= FIRST_COL;
				end
				else
				begin
					
					if(pause == 2'b11)
					begin
						pause <= 2'b00;
						if(sum_count == 5'b11011)
						begin
							sum_count <= 5'b0;
						end
						else
						begin
							sum_count <= sum_count + 1'b1;
						end
					end
					else
					begin
						pause <= pause + 1'b1;
					end
					
					//Summing
					if(sum_count < 5'b11010)
					begin
						if(pause == 2'b10)
						begin
							sum <= sum + (flipped_kernel[sum_count] * mem_in);
						end
					end
					
					//do the summing over 25 clock cycles then output it
					if(sum_count == 5'b00000)
					begin
						spot <= ((col-2'b10)+((row-2'b10)*(FULL_ROW_LENGTH)));		
					end
					else if(sum_count == 5'b00001)
					begin
						spot <= ((col-1'b1)+((row-2'b10)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b00010)
					begin
						spot <= ((col)+((row-2'b10)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b00011)
					begin
						spot <= ((col+1'b1)+((row-2'b10)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b00100)
					begin
						spot <= ((col+2'b10)+((row-2'b10)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b00101)
					begin
						spot <= ((col-2'b10)+((row-1'b1)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b00110)
					begin
						spot <= ((col-1'b1)+((row-1'b1)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b00111)
					begin
						spot <= ((col)+((row-1'b1)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b01000)
					begin
						spot <= ((col+1'b1)+((row-1'b1)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b01001)
					begin
						spot <= ((col+2'b10)+((row-1'b1)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b01010)
					begin
						spot <= ((col-2'b10)+((row)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b01011)
					begin
						spot <= ((col-1'b1)+((row)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b01100)
					begin
						spot <= ((col)+((row)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b01101)
					begin
						spot <= ((col+1'b1)+((row)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b01110)
					begin
						spot <= ((col+2'b10)+((row)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b01111)
					begin
						spot <= ((col-2'b10)+((row+1'b1)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b10000)
					begin
						spot <= ((col-1'b1)+((row+1'b1)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b10001)
					begin
						spot <= ((col)+((row+1'b1)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b10010)
					begin
						spot <= ((col+1'b1)+((row+1'b1)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b10011)
					begin
						spot <= ((col+2'b10)+((row+1'b1)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b10100)
					begin
						spot <= ((col-2'b10)+((row+2'b10)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b10101)
					begin
						spot <= ((col-1'b1)+((row+2'b10)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b10110)
					begin
						spot <= ((col)+((row+2'b10)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b10111)
					begin
						spot <= ((col+1'b1)+((row+2'b10)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b11000)
					begin
						spot <= ((col+2'b10)+((row+2'b10)*(FULL_ROW_LENGTH)));
					end
					else if(sum_count == 5'b11001)
					begin
						//wait for summing to finish
					end
					else if(sum_count == 5'b11010)
					begin
						if(pause == 2'b10)
						begin
							out <= sum;
							output_data_valid <= 1'b1;
						end
						else
						begin
							output_data_valid <= 1'b0;
						end
					end
					else
					begin
						if(pause == 2'b10)
						begin
							sum <= 16'b0;
							count <= count + 1'b1;
							output_data_valid <= 1'b0;
						
							/*update the row/col of the matrix being convolved as well
							as the x and y coordinates sent to the VGA.*/
							if(col < (ORIG_ROW_LENGTH + 1'b1))
							begin
								col <= col + 1'b1;								
								xReg <= xReg + 1'b1;
							end
							else
							begin
								col <= FIRST_COL;
								row <= row + 1'b1;								
								xReg <= 8'b0;
								yReg <= yReg + 1'b1;
							end
						end
					end	
				end
			end
		end
	end	
endmodule
