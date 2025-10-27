`timescale 1ns/1ps

module ssqa #(
                   parameter integer WIDTH     = 4,
                                     TEM_WIDTH = 8,
                                     N         = 800,
                                     NN        = 800
)

(   // output
    output sigma_d2, //層間の相互作用に使用（出力）
    output sigma_result, //σを出力
    
    // input
    // signal
    input clk,
    input en_read, //BRAM用のenable
    input en_mult, //積和演算用のenable
    input en_upd, //スピン状態の更新用のenable
    input rst_ini, //1番最初にreset
    input rst_iter, //イタレーションごとにreset
    input wea,

    // hyper parameter
    input signed [WIDTH-1:0] J,
    input prn,
    input signed [WIDTH-1:0] h,
    input signed [WIDTH-1:0] nrnd,
    input signed [TEM_WIDTH-1:0] I0,
    input signed [TEM_WIDTH-1:0] Q,

    input sigma_above, //層間の相互作用に使用（入力）

    input [$clog2(NN)-1:0] count_spin, //状態更新するスピン番号を選択(BRAM読出しアドレス)
    input [$clog2(NN)-1:0] count_bit, //積和演算するスピン番号を選択(BRAM読出しアドレス)
    input [15:0] count_iter //現在のイタレーション番号(どちらのBRAMを使うか選択)
);

    reg signed [TEM_WIDTH-1:0] sum_Jsigma;
    wire sigma_d1;
    wire signed [$clog2(N+3)+TEM_WIDTH-1:0] Ii;
    wire signed [TEM_WIDTH-1:0] Itanhi_d1;
    wire signed [TEM_WIDTH-1:0] Qsigma;
    wire signed [TEM_WIDTH-1:0] Itanhi;
    wire ena2;
    wire ena3;
    wire [$clog2(NN)-1:0] addra2; //書き込みアドレス
    wire [$clog2(NN)-1:0] addra3;
    wire dina2; //書き込みの値
    wire dina3;
    wire [$clog2(NN)-1:0] addrb2; //読出しアドレス(2clk前に入力)
    wire [$clog2(NN)-1:0] addrb3;
    wire doutb2; //読出しの値
    wire doutb3;

    //積和演算(bit calculation)
    always_ff @(posedge clk) begin
        if (rst_ini || en_upd) begin
            sum_Jsigma <= 0;
        end else if (en_mult) begin
            sum_Jsigma <= (sigma_d1 == 1) ? sum_Jsigma + J : sum_Jsigma - J; //assign文
        end else begin
            sum_Jsigma <= sum_Jsigma;
        end
    end

    //パラメータの加算・saturated counterの計算・sgn関数の計算
    assign Ii = (prn == 1) ? (sum_Jsigma + h + $signed(nrnd) + Itanhi_d1 + Qsigma) : (sum_Jsigma + h - $signed(nrnd) + Itanhi_d1 + Qsigma);
    assign Itanhi = (Ii >= I0 - 1) ? (I0 - 1) : ((Ii < -I0) ? (-I0) : Ii);
    assign sigma_result = (Ii >= 0) ? 1'b1 : 1'b0;
    assign Qsigma = (sigma_above == 1) ? Q : -Q;

    //Stanhiを1イタレーション遅延
    blk_mem_gen_1 #()
        blk_mem_gen_1_inst (
            .clka  (clk),
            .ena   (en_upd),
            .wea   (wea),
            .addra (count_spin),
            .dina  (Itanhi),
            .clkb  (clk),
            .enb   (en_read),
            .addrb (count_spin),
            .doutb (Itanhi_d1)
        );

    //偶奇でどちらのBRAMを選択するか決定
    assign ena2 = (count_iter & 1'b1) ? 0 : en_upd;
    assign addra2 = (count_iter & 1'b1) ? 0 : count_spin;
    assign dina2 = (count_iter & 1'b1) ? 0 : sigma_result;
    assign addrb2 = (count_iter & 1'b1) ? count_bit : count_spin;
    assign ena3 = (count_iter & 1'b1) ? en_upd : 0;
    assign addra3 = (count_iter & 1'b1) ? count_spin : 0;
    assign dina3 = (count_iter & 1'b1) ? sigma_result : 0;
    assign addrb3 = (count_iter & 1'b1) ? count_spin : count_bit;
    assign sigma_d1 = (count_iter & 1'b1) ? doutb2 : doutb3;
    assign sigma_d2 = (count_iter & 1'b1) ? doutb3 : doutb2;


    // ２つのBRAMを交互に使用しσを遅延
    blk_mem_gen_2 #()
        blk_mem_gen_2_inst (
            .clka  (clk),
            .ena   (ena2),
            .wea   (wea),
            .addra (addra2),
            .dina  (dina2),
            .clkb  (clk),
            .enb   (en_read),
            .addrb (addrb2),
            .doutb (doutb2)
        );
    
    blk_mem_gen_3 #()
        blk_mem_gen_3_inst (
            .clka  (clk),
            .ena   (ena3),
            .wea   (wea),
            .addra (addra3),
            .dina  (dina3),
            .clkb  (clk),
            .enb   (en_read),
            .addrb (addrb3),
            .doutb (doutb3)
        );

endmodule