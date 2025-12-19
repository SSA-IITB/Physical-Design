// =======================================================
// 32x32 wallace multiplier
// =======================================================

module kpg_init (
    output reg out1, out0,
    input a, b
);
    always @* begin
        case ({a, b})
            2'b00: begin out0 = 1'b0; out1 = 1'b0; end  // Kill
            2'b11: begin out0 = 1'b1; out1 = 1'b1; end  // Generate
            default: begin out0 = 1'b0; out1 = 1'b1; end // Propagate
        endcase
    end
endmodule


module kpg (
    input cur_bit_1, cur_bit_0,
    input prev_bit_1, prev_bit_0,
    output reg out_bit_1, out_bit_0
);
    always @(*) begin
        if ({cur_bit_1, cur_bit_0} == 2'b00)
            {out_bit_1, out_bit_0} = 2'b00;  // Kill
        else if ({cur_bit_1, cur_bit_0} == 2'b11)
            {out_bit_1, out_bit_0} = 2'b11;  // Generate
        else if ({cur_bit_1, cur_bit_0} == 2'b10)
            {out_bit_1, out_bit_0} = {prev_bit_1, prev_bit_0}; // Propagate
    end
endmodule


module rdcla (
    output reg [31:0] sum,
    output reg cout,
    input [31:0] a,
    input [31:0] b,
    input cin
);

    wire [32:0] carry0, carry1;
    wire [32:0] carry0_1, carry1_1;
    wire [32:0] carry0_2, carry1_2;
    wire [32:0] carry0_4, carry1_4;
    wire [32:0] carry0_8, carry1_8;
    wire [32:0] carry0_16, carry1_16;

    assign carry0[0] = cin;
    assign carry1[0] = cin;

    always @(*) begin
        sum = a ^ b;
        sum = sum ^ carry0_16[31:0];
        cout = carry0_16[32];
    end

    kpg_init init [32:1] (
        carry1[32:1], carry0[32:1],
        a[31:0], b[31:0]
    );

    assign carry1_1[0] = cin;
    assign carry0_1[0] = cin;

    assign carry1_2[1:0] = carry1_1[1:0];
    assign carry0_2[1:0] = carry0_1[1:0];

    assign carry1_4[3:0] = carry1_2[3:0];
    assign carry0_4[3:0] = carry0_2[3:0];

    assign carry1_8[7:0] = carry1_4[7:0];
    assign carry0_8[7:0] = carry0_4[7:0];

    assign carry1_16[15:0] = carry1_8[15:0];
    assign carry0_16[15:0] = carry0_8[15:0];

    kpg itr_1  [32:1] (carry1[32:1],   carry0[32:1],   carry1[31:0],   carry0[31:0],   carry1_1[32:1],  carry0_1[32:1]);
    kpg itr_2  [32:2] (carry1_1[32:2], carry0_1[32:2], carry1_1[30:0], carry0_1[30:0], carry1_2[32:2],  carry0_2[32:2]);
    kpg itr_4  [32:4] (carry1_2[32:4], carry0_2[32:4], carry1_2[28:0], carry0_2[28:0], carry1_4[32:4],  carry0_4[32:4]);
    kpg itr_8  [32:8] (carry1_4[32:8], carry0_4[32:8], carry1_4[24:0], carry0_4[24:0], carry1_8[32:8],  carry0_8[32:8]);
    kpg itr_16 [32:16](carry1_8[32:16],carry0_8[32:16],carry1_8[16:0], carry0_8[16:0], carry1_16[32:16], carry0_16[32:16]);

endmodule


// =======================================================
// Carry-Save "Full Adder" (vector CSA)
// =======================================================

module FA (
    input  [63:0] x,
    input  [63:0] y,
    input  [63:0] z,
    output [63:0] u,
    output [63:0] v
);
    assign u = x ^ y ^ z;
    assign v[0] = 1'b0;
    assign v[63:1] = (x & y) | (y & z) | (z & x);
endmodule


// =======================================================
// Partial Products Generator (flattened bus)
// p_prods = 32 × 64 = 2048 bits
// =======================================================

module partial_products (
    input  [31:0] a,
    input  [31:0] b,
    output [2047:0] p_prods
);
    integer i;
    reg [2047:0] p_prods_reg;

    assign p_prods = p_prods_reg;

    always @(*) begin
        p_prods_reg = {2048{1'b0}};
        for (i = 0; i < 32; i = i + 1) begin
            if (b[i])
                p_prods_reg[i*64 +: 64] = a << i;
        end
    end
endmodule


// =======================================================
// Top-Level 32×32 Wallace Multiplier (clocked output)
// =======================================================

module wallace (
    input  clk,
    input  [31:0] a,
    input  [31:0] b,
    output reg [63:0] out
);

    wire [2047:0] p_prods;
    partial_products pp (a, b, p_prods);

    // ---------------------------
    // Level 1 FA reduction
    // ---------------------------
    wire [63:0]
        u_l11, v_l11, u_l12, v_l12, u_l13, v_l13, u_l14, v_l14,
        u_l15, v_l15, u_l16, v_l16, u_l17, v_l17, u_l18, v_l18,
        u_l19, v_l19, u_l110, v_l110;

    FA l11  (p_prods[0*64 +: 64],  p_prods[1*64 +: 64],  p_prods[2*64 +: 64],  u_l11,  v_l11);
    FA l12  (p_prods[3*64 +: 64],  p_prods[4*64 +: 64],  p_prods[5*64 +: 64],  u_l12,  v_l12);
    FA l13  (p_prods[6*64 +: 64],  p_prods[7*64 +: 64],  p_prods[8*64 +: 64],  u_l13,  v_l13);
    FA l14  (p_prods[9*64 +: 64],  p_prods[10*64 +: 64], p_prods[11*64 +: 64], u_l14,  v_l14);
    FA l15  (p_prods[12*64 +: 64], p_prods[13*64 +: 64], p_prods[14*64 +: 64], u_l15,  v_l15);
    FA l16  (p_prods[15*64 +: 64], p_prods[16*64 +: 64], p_prods[17*64 +: 64], u_l16,  v_l16);
    FA l17  (p_prods[18*64 +: 64], p_prods[19*64 +: 64], p_prods[20*64 +: 64], u_l17,  v_l17);
    FA l18  (p_prods[21*64 +: 64], p_prods[22*64 +: 64], p_prods[23*64 +: 64], u_l18,  v_l18);
    FA l19  (p_prods[24*64 +: 64], p_prods[25*64 +: 64], p_prods[26*64 +: 64], u_l19,  v_l19);
    FA l110 (p_prods[27*64 +: 64], p_prods[28*64 +: 64], p_prods[29*64 +: 64], u_l110, v_l110);

    // ---------------------------
    // Level 2
    // ---------------------------
    wire [63:0]
        u_l21, v_l21, u_l22, v_l22, u_l23, v_l23,
        u_l24, v_l24, u_l25, v_l25, u_l26, v_l26,
        u_l27, v_l27;

    FA l21 (u_l11,  v_l11,  u_l12,  u_l21, v_l21);
    FA l22 (v_l12,  u_l13,  v_l13,  u_l22, v_l22);
    FA l23 (u_l14,  v_l14,  u_l15,  u_l23, v_l23);
    FA l24 (v_l15,  u_l16,  v_l16,  u_l24, v_l24);
    FA l25 (u_l17,  v_l17,  u_l18,  u_l25, v_l25);
    FA l26 (v_l18,  u_l19,  v_l19,  u_l26, v_l26);
    FA l27 (u_l110, v_l110, p_prods[30*64 +: 64], u_l27, v_l27);

    // ---------------------------
    // Level 3
    // ---------------------------
    wire [63:0] u_l31, v_l31, u_l32, v_l32, u_l33, v_l33, u_l34, v_l34, u_l35, v_l35;

    FA l31 (u_l21, v_l21, u_l22, u_l31, v_l31);
    FA l32 (v_l22, u_l23, v_l23, u_l32, v_l32);
    FA l33 (u_l24, v_l24, u_l25, u_l33, v_l33);
    FA l34 (v_l25, u_l26, v_l26, u_l34, v_l34);
    FA l35 (u_l27, v_l27, p_prods[31*64 +: 64], u_l35, v_l35);

    // ---------------------------
    // Level 4
    // ---------------------------
    wire [63:0] u_l41, v_l41, u_l42, v_l42, u_l43, v_l43;

    FA l41 (u_l31, v_l31, u_l32, u_l41, v_l41);
    FA l42 (v_l32, u_l33, v_l33, u_l42, v_l42);
    FA l43 (u_l34, v_l34, u_l35, u_l43, v_l43);

    // ---------------------------
    // Level 5
    // ---------------------------
    wire [63:0] u_l51, v_l51, u_l52, v_l52;

    FA l51 (u_l41, v_l41, u_l42, u_l51, v_l51);
    FA l52 (v_l42, u_l43, v_l43, u_l52, v_l52);

    // ---------------------------
    // Level 6
    // ---------------------------
    wire [63:0] u_l61, v_l61;

    FA l61 (u_l51, v_l51, u_l52, u_l61, v_l61);

    // ---------------------------
    // Level 7
    // ---------------------------
    wire [63:0] u_l71, v_l71;

    FA l71 (u_l61, v_l61, v_l52, u_l71, v_l71);

    // ---------------------------
    // Level 8
    // ---------------------------
    wire [63:0] u_l81, v_l81;

    FA l81 (u_l71, v_l71, v_l35, u_l81, v_l81);

    // ---------------------------
    // Level 9 – Final Adder (CLA)
    // ---------------------------
    wire [63:0] sum_comb;
    wire c_lower, c_upper;

    rdcla l91 (sum_comb[31:0],  c_lower, u_l81[31:0],  v_l81[31:0],  1'b0);
    rdcla l92 (sum_comb[63:32], c_upper, u_l81[63:32], v_l81[63:32], c_lower);

    always @(posedge clk) begin
        out <= sum_comb;
    end

endmodule
