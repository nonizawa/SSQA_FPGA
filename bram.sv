`timescale 1ns/1ps

module bram #(
    parameter WIDTH = 4
)
(   
    output [WIDTH-1:0] J,
    input [19:0] count_addr,
    input [WIDTH-1:0] dina,
    input clk,
    input ena,
    input wea,
    input [19:0] addra,
    input en_read
);

    blk_mem_gen_0 #()
        blk_mem_gen_0_inst (
            .clka  (clk),
            .ena   (ena),
            .wea   (wea),
            .addra (addra),
            .dina  (dina),
            .clkb  (clk),
            .enb   (en_read),
            .addrb (count_addr),
            .doutb (J)
        );

endmodule