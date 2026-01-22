`timescale 1ns/1ps

module tb_systolic_2x2;

  logic clk;
  logic rst;
  logic start;
  logic done;

  logic signed [7:0] act_in0, act_in1;
  logic signed [7:0] wgt_in0, wgt_in1;

  logic signed [31:0] c00, c01, c10, c11;

  // DUT
  systolic_2x2 dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .done(done),
    .act_in0(act_in0),
    .act_in1(act_in1),
    .wgt_in0(wgt_in0),
    .wgt_in1(wgt_in1),
    .c00(c00),
    .c01(c01),
    .c10(c10),
    .c11(c11)
  );

  // Clock
  always #5 clk = ~clk;

  task tick;
    @(posedge clk);
  endtask

  initial begin
    // ---------------- INIT ----------------
    clk = 0;
    rst = 1;
    start = 0;

    act_in0 = 0;
    act_in1 = 0;
    wgt_in0 = 0;
    wgt_in1 = 0;

    // Reset
    repeat (2) tick;
    rst = 0;
    tick;

    // Start pulse
    start = 1;
    tick;
    start = 0;

    // --------------------------------------------------
    // Matrix:
    // A = [1 2]
    //     [3 4]
    //
    // B = [5 6]
    //     [7 8]
    //
    // Expected:
    // C = [19 22]
    //     [43 50]
    // --------------------------------------------------

    // Cycle 0 (negedge before first MAC)
    @(negedge clk);
    act_in0 = 1;   // a00
    act_in1 = 0;
    wgt_in0 = 5;   // b00
    wgt_in1 = 0;

    // Cycle 1
    @(negedge clk);
    act_in0 = 2;   // a01
    act_in1 = 3;   // a10
    wgt_in0 = 7;   // b10
    wgt_in1 = 6;   // b01

    // Cycle 2
    @(negedge clk);
    act_in0 = 0;
    act_in1 = 4;   // a11
    wgt_in0 = 0;
    wgt_in1 = 8;   // b11

    // Stop driving
    @(negedge clk);
    act_in0 = 0;
    act_in1 = 0;
    wgt_in0 = 0;
    wgt_in1 = 0;

    // Wait for done
    wait (done);
    tick;

    // ---------------- CHECK ----------------
    $display("DUT RESULT:");
    $display("c00 = %0d  c01 = %0d", c00, c01);
    $display("c10 = %0d  c11 = %0d", c10, c11);

    assert(c00 == 19) else $fatal("c00 wrong");
    assert(c01 == 22) else $fatal("c01 wrong");
    assert(c10 == 43) else $fatal("c10 wrong");
    assert(c11 == 50) else $fatal("c11 wrong");

    $display("\n2x2 SYSTOLIC ARRAY TEST PASSED ✅");
    $finish;
  end

endmodule
