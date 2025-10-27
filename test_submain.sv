`timescale 1ns/1ps

module test_submain ();
    parameter WIDTH     = 4;
    parameter TEM_WIDTH = 8;
    parameter N         = 800;
    parameter NN        = 800;
    parameter M         = 20;

    //Hyper parameter
    reg [7:0] tau;
    reg [3:0] beta;
    reg [TEM_WIDTH-1:0] Qmax;
    reg signed [WIDTH-1:0] nrnd;
    reg signed [WIDTH-1:0] h;
    reg signed [TEM_WIDTH-1:0] I0;

    //spin direction
    wire sigma_result [M-1:0] ;

    //state
    wire [3:0] state;
    wire comp_enable;

    //calculation signal
    // wire en_mult;
    // wire en_update;
    // wire rst_iteration;
    // wire rst_initial;
    // wire en_read;

    //FPGA signal
    reg clk;
    reg rst_sys;

    reg start;
    reg finish;

    //BRAM signal
    reg ena;
    reg wea;
    reg [19:0] addra;

    //BRAM setting
    reg [WIDTH-1:0] dina;

    initial begin
        clk <= 1'b1;
        forever begin
            #5 clk <= ~clk;
        end
    end

    submain #(
        .WIDTH    (WIDTH),
        .TEM_WIDTH(TEM_WIDTH),
        .N        (N),
        .NN       (NN),
        .M        (M)
    )
        submain_inst (
            .clk               (clk),
            .rst_sys           (rst_sys),
            .tau               (tau),
            .beta              (beta),
            .Qmax              (Qmax),
            .nrnd              (nrnd),
            .I0                (I0),
            .h                 (h),
            .comp_en           (comp_enable),
            .ena               (ena),
            .wea               (wea),
            .addra             (addra),
            .dina              (dina),
            .sigma_result      (sigma_result),
            .state             (state)
        );

    ctr #()
        ctr_inst (
            .clk          (clk),
            .rst_sys      (rst_sys),
            .state_signal (state),
            .start        (start),
            .finish       (finish),
            .comp_enable  (comp_enable)
        ); 

    initial begin
        #0;
            rst_sys    <= 1'b1;
            start      <= 1'b0;
            tau        <= 8'd10;
            beta       <= 4'd2;
            Qmax       <= 8'd10;
            nrnd       <= 4'd1;
            I0         <= 8'd1;
            h          <= 4'd0;
            ena        <= 1'b0;
            wea        <= 1'b1;
            addra      <= 4'b0000;
        
        #1000;
        #10;
            rst_sys    <= 0;

        #10;
            rst_sys    <= 1;
            start      <= 1;

        #10;
            start      <= 0;

        #10;
            dina       <= 4'b0000;

        #5000;
        $finish;
    end
endmodule