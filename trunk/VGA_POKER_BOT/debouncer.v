module debouncer (rst, live_clock, noisy, clean);
	input rst, live_clock, noisy;
	output clean;
   
	reg [19:0] count;
	reg xnew, clean;

	always @(posedge live_clock or negedge rst)
	begin
		if (rst == 1'b0) 
		begin 
			xnew <= 1'b0; 
			clean <= 1'b0; 
			count <= 19'd1000; 
		end
		else
		begin
			/* detects when the input and the current version differ and starts
			counter to see if it stays constant long enough*/
			if (noisy != xnew) 
			begin 
				xnew <= noisy; 
				count <= 19'd0; 
			end
			/* if the counter is up for long enough then clean gets the new 
			value.  In other words the value has stayed high long enough
			to be the debounced value ... stable. Change number to make longer or
			shorter. */
			//else if (count == 19'd2) 
			else if (count == 19'd1000) 
			begin
				clean <= xnew;
			end
			/* continue counting */
			else
			begin
				count <= count+1'b1;
			end
		end
	end
endmodule
