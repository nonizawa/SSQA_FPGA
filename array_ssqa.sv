`timescale 1ns/1ps

module array #(
    parameter integer WIDTH     = 4,
                      TEM_WIDTH = 8, 
                      N         = 800,
                      NN        = 800,
                      M         = 20
)

(   input signed [WIDTH-1:0] J,
    input signed [WIDTH-1:0] nrnd,
    input signed [WIDTH-1:0] h,
    input signed [TEM_WIDTH-1:0] I0,
    input signed [TEM_WIDTH-1:0] Q,
    input clk,
    input en_read,
    input en_mult,
    input en_upd,
    input rst_iter,
    input rst_ini,
    input wea,
    input [$clog2(NN)-1:0] count_spin, 
    input [$clog2(NN)-1:0] count_bit,
    input [15:0] count_iter, 
    output sigma_result [M-1:0]
);

    wire sigma_d2 [M-1:0];
    wire sigma_above [M-1:0];
    wire [M-1:0] prn;

    xorshift #(
        .WIDTH   (M)
    )
     xorshift_inst (
        .prn     (prn),
        .enable  (en_upd),
        .clock   (clk),
        .reset   (rst_ini)
    );
    
    genvar m;
    for (m = 0; m < M; m++) begin
        ssqa #(
            .WIDTH        (WIDTH),
            .TEM_WIDTH    (TEM_WIDTH),
            .N            (N),
            .NN           (NN)
        )
         ssqa_inst (
            .sigma_d2       (sigma_d2[m]),
            .sigma_above    (sigma_above[m]),
            .sigma_result   (sigma_result[m]),
            .J              (J),
            .nrnd           (nrnd),
            .h              (h),
            .prn            (prn[m]),
            .I0             (I0),
            .Q              (Q),
            .clk            (clk),
            .en_read        (en_read),
            .en_mult        (en_mult),
            .en_upd         (en_upd),
            .rst_iter       (rst_iter),
            .rst_ini        (rst_ini),
            .wea            (wea),
            .count_bit      (count_bit),
            .count_spin     (count_spin),
            .count_iter     (count_iter)
        );
    end

    genvar r;
    for (r = 0; r < M - 1; r++) begin
        assign sigma_above[r] = sigma_d2[r + 1];
    end

    assign sigma_above[M - 1] = sigma_d2[0];

endmodule