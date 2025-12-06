module alu(
    input  wire        clk,
    input  wire        reset,
    input  wire [7:0]  A,
    input  wire [7:0]  B,
    input  wire [2:0]  ALU_Sel,
    output reg  [7:0]  ALU_Out,
    output reg         CarryOut
);

    // Internal combinational signals
    reg  [7:0]  result;
    reg         carry;
    wire [8:0]  add_res  = {1'b0, A} + {1'b0, B};
    wire [8:0]  sub_res  = {1'b0, A} - {1'b0, B};

    // Combinational ALU logic
    always @(*) begin
        case (ALU_Sel)
            3'b000: begin result = add_res[7:0]; carry = add_res[8]; end  // ADD
            3'b001: begin result = sub_res[7:0]; carry = sub_res[8]; end  // SUB
            3'b010: begin result = A & B;        carry = 0;            end // AND
            3'b011: begin result = A | B;        carry = 0;            end // OR
            3'b100: begin result = A ^ B;        carry = 0;            end // XOR
            3'b101: begin result = ~(A | B);     carry = 0;            end // NOR
            3'b110: begin result = A << 1;       carry = A[7];         end // SHIFT LEFT
            3'b111: begin result = A >> 1;       carry = A[0];         end // SHIFT RIGHT
            default: begin result = 8'd0;        carry = 0;            end
        endcase
    end

    // Sequential output registers (clocked ALU)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ALU_Out  <= 8'd0;
            CarryOut <= 1'b0;
        end else begin
            ALU_Out  <= result;
            CarryOut <= carry;
        end
    end

endmodule
