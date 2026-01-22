module pe #(
  parameter int ACT_W = 8,
  parameter int WGT_W = 8,
  parameter int SUM_W = 32
) (
  input  logic             clk,
  input  logic             rst,
  input  logic             clear,
  input  logic             en,

  input  logic signed [ACT_W-1:0] act_in,
  input  logic signed [WGT_W-1:0] wgt_in,

  output logic signed [ACT_W-1:0] act_out,
  output logic signed [WGT_W-1:0] wgt_out,
  output logic signed [SUM_W-1:0] psum_out
);

  logic signed [SUM_W-1:0] acc;

  always_ff @(posedge clk) begin
    if (rst) begin
      acc     <= '0;
      act_out <= '0;
      wgt_out <= '0;
    end
    else begin
      act_out <= act_in;
      wgt_out <= wgt_in;

      // Accumulator control
      if (clear) begin
        acc <= '0;
      end
      else if (en) begin
        logic signed [SUM_W-1:0] product;
        logic signed [SUM_W-1:0] sum_tmp;

        product = act_in * wgt_in;
        sum_tmp = acc + product;

        // Saturation
        if ((acc[SUM_W-1] == 0) && (product[SUM_W-1] == 0) && (sum_tmp[SUM_W-1] == 1))
          acc <= {1'b0, {(SUM_W-1){1'b1}}};
        else if ((acc[SUM_W-1] == 1) && (product[SUM_W-1] == 1) && (sum_tmp[SUM_W-1] == 0))
          acc <= {1'b1, {(SUM_W-1){1'b0}}};
        else
          acc <= sum_tmp;
      end
    end
  end

  assign psum_out = acc;

endmodule
