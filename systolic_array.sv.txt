module systolic_2x2 (
  input  logic clk,
  input  logic rst,
  input  logic start,
  output logic done,

  input  logic signed [7:0] act_in0,
  input  logic signed [7:0] act_in1,

  input  logic signed [7:0] wgt_in0,
  input  logic signed [7:0] wgt_in1,

  output logic signed [31:0] c00,
  output logic signed [31:0] c01,
  output logic signed [31:0] c10,
  output logic signed [31:0] c11
);

  // Controller (correct timing)
  logic clear, en;
  logic [2:0] cnt;

  always_ff @(posedge clk) begin
    if (rst) begin
      cnt   <= 0;
      clear <= 0;
      en    <= 0;
      done  <= 0;
    end else begin
      done <= 0;

      case (cnt)
        // wait for start
        0: begin
             clear <= 0; en <= 0;
             if (start) cnt <= 1;
           end

        // clear accumulators
        1: begin
             clear <= 1; en <= 0;
             cnt <= 2;
           end

        // en cycles (4 total): warm-up + 3 diagonals
        2: begin clear <= 0; en <= 1; cnt <= 3; end // warm-up
        3: begin en <= 1; cnt <= 4; end              // diag 0
        4: begin en <= 1; cnt <= 5; end              // diag 1
        5: begin en <= 1; cnt <= 6; end              // diag 2

        // done
        6: begin
             en   <= 0;
             done <= 1;
             cnt  <= 6;
           end
      endcase
    end
  end

  logic signed [7:0] a01, a11;
  logic signed [7:0] w10, w11;

  // PE array

  // (0,0)
  pe pe00 (
    .clk(clk), .rst(rst), .clear(clear), .en(en),
    .act_in(act_in0),
    .wgt_in(wgt_in0),
    .act_out(a01),
    .wgt_out(w10),
    .psum_out(c00)
  );

  // (0,1)
  pe pe01 (
    .clk(clk), .rst(rst), .clear(clear), .en(en),
    .act_in(a01),
    .wgt_in(wgt_in1),
    .act_out(),
    .wgt_out(w11),
    .psum_out(c01)
  );

  // (1,0)
  pe pe10 (
    .clk(clk), .rst(rst), .clear(clear), .en(en),
    .act_in(act_in1),
    .wgt_in(w10),
    .act_out(a11),
    .wgt_out(),
    .psum_out(c10)
  );

  // (1,1)
  pe pe11 (
    .clk(clk), .rst(rst), .clear(clear), .en(en),
    .act_in(a11),
    .wgt_in(w11),
    .act_out(),
    .wgt_out(),
    .psum_out(c11)
  );

endmodule
