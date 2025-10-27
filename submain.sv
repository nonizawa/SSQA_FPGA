`timescale 1ns/1ps

module submain #(
    parameter integer WIDTH     = 4,
                      TEM_WIDTH = 8,
                      N         = 800,
                      NN        = 800,
                      M         = 20,
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
    //FPGA signal
    input clk,
    input rst_sys,
    input comp_en,

    //Hyper parameter
    input [7:0] tau,
    input [3:0] beta,
    input [TEM_WIDTH-1:0] Qmax,
    input signed [WIDTH-1:0] nrnd,
    input signed [WIDTH-1:0] h,
    input signed [TEM_WIDTH-1:0] I0,

    //BRAM signal
    input ena,
    input wea,
    input [19:0] addra,

    //BRAM setting
    input reg [WIDTH-1:0] dina,

    //state
    output [3:0] state,
    output sigma_result [M-1:0]
);

    wire [WIDTH-1:0] J;
    wire signed [TEM_WIDTH-1:0] Q;

    wire en_mult;
    wire en_upd;
    wire en_read;
    wire rst_iter;
    wire rst_ini;

    wire [19:0] count_addr;
    wire [7:0] count_comp;
    wire [$clog2(NN)-1:0] count_spin;
    wire [$clog2(NN)-1:0] count_mult;
    wire [$clog2(NN)-1:0] count_bit;
    wire [15:0] count_iter;

    scheduler_count #(
        .TEM_WIDTH         (TEM_WIDTH),
        .NN                (NN),
        .IDLE              (IDLE),
        .RESET             (RESET),
        .MULT              (MULT),
        .LMULT             (LMULT),
        .LLMULT            (LLMULT),
        .LLLMULT           (LLLMULT),
        .UPDATE            (UPDATE),
        .LUPDATE           (LUPDATE),
        .IRESET            (IRESET),
        .FIN               (FIN)
    )
     scheduler_count_inst (
        //FPGA signal
        .clk               (clk),
        .rst_sys           (rst_sys),

        //Hyper parameter
        .tau               (tau),
        .beta              (beta),
        .Q                 (Q),

        //counter
        .count_addr        (count_addr),
        .count_comp        (count_comp),
        .count_spin        (count_spin),
        .count_mult        (count_mult),
        .count_bit         (count_bit),
        .count_iter        (count_iter),

        //state
        .state             (state)
    );

    scheduler_state #(
        .TEM_WIDTH         (TEM_WIDTH),
        .NN                (NN),
        .IDLE              (IDLE),
        .RESET             (RESET),
        .MULT              (MULT),
        .LMULT             (LMULT),
        .LLMULT            (LLMULT),
        .LLLMULT           (LLLMULT),
        .UPDATE            (UPDATE),
        .LUPDATE           (LUPDATE),
        .IRESET            (IRESET),
        .FIN               (FIN)
    )
     scheduler_state_inst (
        //FPGA signal
        .clk               (clk),
        .rst_sys           (rst_sys),
        .comp_en           (comp_en),

        //Hyper parameter
        .tau               (tau),
        .Qmax              (Qmax),
        .Q                 (Q),

        //calculation signal
        .en_mult           (en_mult),
        .en_read           (en_read),
        .en_upd            (en_upd),
        .rst_iter          (rst_iter),
        .rst_ini           (rst_ini),

        //counter
        .count_comp        (count_comp),
        .count_spin        (count_spin),
        .count_mult        (count_mult),

        //state
        .state             (state)
    );

    bram #(
        .WIDTH             (WIDTH)
    )
     bram_inst (
        //FPGA signal
        .clk               (clk),

        //Hyper parameter
        .J                 (J),

        //counter
        .count_addr        (count_addr),

        //BRAM signal
        .ena               (ena),
        .wea               (wea),
        .addra             (addra),

        //BRAM setting
        .dina              (dina),

        //calculation signal
        .en_read           (en_read)
    );

    array #(
        .WIDTH          (WIDTH),
        .TEM_WIDTH      (TEM_WIDTH),
        .N              (N),
        .NN             (NN),
        .M              (M)
    )
     array_inst (
        //FPGA signal
        .clk            (clk),

        //Hyper parameter
        .J              (J),
        .nrnd           (nrnd),
        .h              (h),
        .I0             (I0),
        .Q              (Q),
        .sigma_result   (sigma_result),

        //calculation signal
        .en_read        (en_read),
        .en_mult        (en_mult),
        .en_upd         (en_upd),
        .rst_iter       (rst_iter),
        .rst_ini        (rst_ini),
        .count_bit      (count_bit),
        .count_spin     (count_spin),
        .count_iter     (count_iter),
        .wea            (wea)
    );

endmodule