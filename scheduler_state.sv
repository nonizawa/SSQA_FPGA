`timescale 1ns/1ps

module scheduler_state #(
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
    input [7:0] tau,
    input [TEM_WIDTH-1:0] Qmax,

    // Control signals
    input comp_en,

    // Noise and temperature
    input signed [TEM_WIDTH-1:0] Q,

    input [$clog2(NN)-1:0] count_spin,
    input [$clog2(NN)-1:0] count_mult,
    input [7:0] count_comp,

    // Process control signals
    output reg en_mult,
    output reg en_read,
    output reg en_upd,
    output reg rst_iter,
    output reg rst_ini,

    output reg [3:0] state
);

    reg [3:0] n_state;

    // FSM state transition
    always @(posedge clk) begin
        if(~rst_sys) begin
            state <= IDLE;
        end else begin
            state <= n_state;
        end
    end

    always_comb begin
        case (state)
            IDLE : begin
                if (comp_en)
                    n_state = RESET;
                else
                    n_state = state;
            end

            RESET : n_state = STMULT;

            STMULT : n_state = MULT;

            MULT : begin
                if (count_mult == NN - 3) begin
                    n_state = LMULT;
                end else begin
                    n_state = MULT;
                end
            end

            LMULT : begin
                if (count_spin == NN - 1) begin
                    n_state = LLLMULT;
                end else begin
                    n_state = LLMULT;
                end
            end

            LLMULT :  n_state = UPDATE;

            LLLMULT : n_state = LUPDATE;
                
            UPDATE : n_state = MULT;

            LUPDATE : n_state = IRESET;
            
            IRESET : begin
                if (count_comp == tau - 1) begin
                    if (Q >= $signed(Qmax)) begin
                        n_state = FIN;
                    end else begin
                        n_state = STMULT;
                    end
                end else
                    n_state = STMULT;
            end

            FIN : n_state = IDLE;

            default : n_state = IDLE;
        endcase
    end
    
    // FSM output signals
    always @(state) begin
        case (state)
            IDLE : begin
                en_read       = 1'b0;
                en_mult       = 1'b0;
                en_upd        = 1'b0;
                rst_iter      = 1'b0;
                rst_ini       = 1'b0;
            end

            RESET : begin
                en_read       = 1'b1;
                en_mult       = 1'b0;
                en_upd        = 1'b0;
                rst_iter      = 1'b1;
                rst_ini       = 1'b1;
            end

            STMULT : begin
                en_read       = 1'b1;
                en_mult       = 1'b0;
                en_upd        = 1'b0;
                rst_iter      = 1'b0;
                rst_ini       = 1'b0;
            end

            MULT : begin
                en_read       = 1'b1;
                en_mult       = 1'b1;
                en_upd        = 1'b0;
                rst_iter      = 1'b0;
                rst_ini       = 1'b0;
            end

            LMULT : begin
                en_read       = 1'b1;
                en_mult       = 1'b1;
                en_upd        = 1'b0;
                rst_iter      = 1'b0;
                rst_ini       = 1'b0;
            end

            LLMULT : begin
                en_read       = 1'b1;
                en_mult       = 1'b1;
                en_upd        = 1'b0;
                rst_iter      = 1'b0;
                rst_ini       = 1'b0;
            end

            LLLMULT : begin
                en_read       = 1'b1;
                en_mult       = 1'b1;
                en_upd        = 1'b0;
                rst_iter      = 1'b0;
                rst_ini       = 1'b0;
            end

            UPDATE : begin
                en_read       = 1'b1;
                en_mult       = 1'b0;
                en_upd        = 1'b1;
                rst_iter      = 1'b0;
                rst_ini       = 1'b0;
            end

            LUPDATE : begin
                en_read       = 1'b1;
                en_mult       = 1'b0;
                en_upd        = 1'b1;
                rst_iter      = 1'b0;
                rst_ini       = 1'b0;
            end

            IRESET : begin
                en_read       = 1'b1;
                en_mult       = 1'b0;
                en_upd        = 1'b0;
                rst_iter      = 1'b1;
                rst_ini       = 1'b0;
            end

            FIN : begin
                en_read       = 1'b0;
                en_mult       = 1'b0;
                en_upd        = 1'b0;
                rst_iter      = 1'b0;
                rst_ini       = 1'b0;
            end

            default : begin
                en_read       = 1'b0;
                en_mult       = 1'b0;
                en_upd        = 1'b0;
                rst_iter      = 1'b0;
                rst_ini       = 1'b0;
            end
        endcase
    end
endmodule