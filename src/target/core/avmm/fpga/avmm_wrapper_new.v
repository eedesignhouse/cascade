`include "src/target/core/avmm/fpga/program_logic.v"

integer ifd = $fopen("src/target/core/avmm/fpga/input.buf", "r");
integer ofd = $fopen("src/target/core/avmm/fpga/output.buf", "w");

reg read = 0;
reg write = 0;
reg[15:0] addr = 0;
reg[31:0] data_in = 0;
wire[31:0] data_out;
wire waitreq;
reg[7:0] temp = 0;
reg nextRead = 0;
reg nextWrite = 0;
reg[3:0] state = 0;

program_logic pl (
	.clk(clock.val),
	.reset(0),
	.s0_address(addr),
	.s0_read(read),
	.s0_write(write),
	.s0_readdata(data_out),
	.s0_writedata(data_in),
	.s0_waitrequest(waitreq)
);

always @(posedge clock.val) begin
	if (state == 4'd4) begin
		if (!waitreq) begin
			if (read) begin
				//$display("r %h:%h", addr, data_out);
				$fwrite(ofd, "%c%c%c%c", data_out[31:24], data_out[23:16], data_out[15:8], data_out[7:0]);
				$fflush(ofd);
			end else begin
				//$display("w %h:%h", addr, data_in);
			end
			read <= 0;
			write <= 0;
			state <= 4'd0;
		end else begin
			//$display("waiting...");
		end
	end
	if ($feof(ifd)) begin
		$fflush(ifd);
	end else begin
		if (state == 4'd0) begin
			$fscanf(ifd, "%c", temp);
			if ($feof(ifd)) begin
			end else begin
				//$display("byte %h", temp);
				if ((temp != 1) && (temp != 2)) begin
					//$display("done");
					$finish(0);
				end
				nextRead = temp[1];
				nextWrite = temp[0];
				state = 4'd1;
			end
		end
		if ($feof(ifd)) $fflush(ifd);
		if (state == 4'd1) begin
			$fscanf(ifd, "%c", temp);
			if ($feof(ifd)) begin
			end else begin
				//$display("byte %h", temp);
				addr[15:8] <= temp;
				state = 4'd2;
			end
		end
		if ($feof(ifd)) $fflush(ifd);
		if (state == 4'd2) begin
			$fscanf(ifd, "%c", temp);
			if ($feof(ifd)) begin
			end else begin
				//$display("byte %h", temp);
				addr[7:0] <= temp;
				state = 4'd3;
			end
		end
	end
	if (state == 4'd3) begin
		if (nextRead) begin
			read <= 1;
			nextRead <= 0;
			state <= 4'd4;
		end else begin
			state = 4'd5;
		end
	end
	if ($feof(ifd)) begin
		$fflush(ifd);
	end else begin
		if (state == 4'd5) begin
			$fscanf(ifd, "%c", temp);
			if ($feof(ifd)) begin
			end else begin
				//$display("byte %h", temp);
				data_in[31:24] <= temp;
				state = 4'd6;
			end
		end
		if ($feof(ifd)) $fflush(ifd);
		if (state == 4'd6) begin
			$fscanf(ifd, "%c", temp);
			if ($feof(ifd)) begin
			end else begin
				//$display("byte %h", temp);
				data_in[23:16] <= temp;
				state = 4'd7;
			end
		end
		if ($feof(ifd)) $fflush(ifd);
		if (state == 4'd7) begin
			$fscanf(ifd, "%c", temp);
			if ($feof(ifd)) begin
			end else begin
				//$display("byte %h", temp);
				data_in[15:8] <= temp;
				state = 4'd8;
			end
		end
		if ($feof(ifd)) $fflush(ifd);
		if (state == 4'd8) begin
			$fscanf(ifd, "%c", temp);
			if ($feof(ifd)) begin
			end else begin
				//$display("byte %h", temp);
				data_in[7:0] <= temp;
				state = 4'd9;
			end
		end
	end
	if (state == 4'd9) begin
		write <= 1;
		nextWrite <= 0;
		state <= 4'd4;
	end
end

