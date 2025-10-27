`timescale 1ns/1ps

module scheduler_count #(
    parameter TEM_WIDTH = 8,
              NN        = 800,
              IDLE      = 4'd0,
              RESET     = 4'd1,
              STMULT    = 4'd2,
              MULT      = 4'd3,
              LMULT     = 4'd4,
              LLMULT    = 4'd5,
              LLLMULT   = 4'd6,
              UPDATE    = 4'd7,
              LUPDATE   = 4'd8,
              IRESET    = 4'd9,
              FIN       = 4'd10
)
(   
    input clk,
    input rst_sys,

    //Hyper parameters
    input [3:0] beta,
    input [7:0] tau,

    // Control signals
    input [3:0] state,

    // Noise and temperature
    output reg signed [TEM_WIDTH-1:0] Q,

    // Process control signals
    output reg [19:0] count_addr,
    output reg [7:0] count_comp,
    output reg [$clog2(NN)-1:0] count_spin,
    output reg [$clog2(NN)-1:0] count_mult,
    output reg [$clog2(NN)-1:0] count_bit,
    output reg [15:0] count_iter
);

    // Counting process
    always @(posedge clk) begin
        if (~rst_sys) begin
            count_comp <= 0;
        end else if (state == IRESET) begin
            count_comp <= count_comp + 1;
        end else if (count_comp == tau) begin
            count_comp <= 0;
        end
    end

    always @(posedge clk) begin
        if (~rst_sys) begin
            count_mult <= 0;
        end else if (state == UPDATE || state == STMULT) begin
            count_mult <= 0;
        end else if (state == MULT || state == LMULT) begin
            count_mult <= count_mult + 1;
        end
    end

    always @(posedge clk) begin
        if (~rst_sys) begin
            count_bit <= 0;
        end else if (state == IDLE || state == LMULT) begin
            count_bit <= 0;
        end else if (state == RESET || state == STMULT || state == LLMULT || state == UPDATE || state == MULT || state == IRESET) begin
            count_bit <= count_bit + 1;
        end
    end

    always @(posedge clk) begin
        if (~rst_sys) begin
            count_spin <= 0;
        end else if (state == IRESET) begin
            count_spin <= 0;
        end else if (state == UPDATE) begin
            count_spin <= count_spin + 1;
        end
    end

    always @(posedge clk) begin
        if(~rst_sys) begin
            count_addr <= 0;
        end else if (state == LUPDATE) begin
            count_addr <= 0;
        end else if (state == RESET || state == STMULT || state == MULT || state == LLMULT || state == UPDATE || state == IRESET) begin
            count_addr <= count_addr + 1;
        end
    end

    always @(posedge clk) begin
        if(~rst_sys) begin
            count_iter <= 0;
        end else if (state == RESET) begin
            count_iter <= 0;
        end else if (state == LUPDATE) begin
            count_iter <= count_iter + 1;
        end
    end

    always @(posedge clk) begin
        if(~rst_sys) begin
            Q <= 0;
        end else if ((state == IRESET) && (count_comp == tau - 1)) begin
            Q <= Q + beta;
        end
    end

endmodule