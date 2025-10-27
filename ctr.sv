`timescale 1ns/1ps

module ctr (
	input wire start,
	input wire clk,
	input wire rst_sys,
    input wire [3:0] state_signal,
	output wire finish,
	output wire comp_enable
);

	reg [1:0] state;
    reg [1:0] next_state;
	parameter READY = 2'b00;
    parameter START = 2'b01;
    parameter FINISH = 2'b10;

	always @(posedge clk) begin
		if (~rst_sys)
			state <= READY;
		else
			state <= next_state;
	end

	always @* begin
		case (state)
			READY:
				if (start)
					next_state <= START;
				else
					next_state <= READY;
			START:
				if (state_signal == 4'd10)
					next_state <= FINISH;
				else
					next_state <= START;
			FINISH:
				next_state <= FINISH;
			default:
				next_state <= READY;
		endcase // state
	end

	assign comp_enable = (state == START) ? 1'b1 : 1'b0;
	assign finish = (state == FINISH) ? 1'b1 : 1'b0;

endmodule