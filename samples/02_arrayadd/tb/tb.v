`timescale 1ns/1ps
module tb;

localparam TOTAL_BITS = 24584;

reg clk;
reg run;
wire [31:0] verinject__injector_state;

wire [7:0] real_index;
wire [31:0] real_sum;

wire [7:0] inj_index;
wire [31:0] inj_sum;

top u_top(.clk(clk), .run(run), .index(real_index), .sum(real_sum));
top__injected i_top(.clk(clk), .run(run),
  .index(inj_index), .sum(inj_sum),
  .verinject__injector_state(verinject__injector_state));

verinject_serial_tester #(.TOTAL_BITS(TOTAL_BITS)) u_injector(
  .clock(clk),
  .reset_n(rst_n),
  .verinject__injector_state(verinject__injector_state)
);

wire [47:0] cycle_number;
verinject_sim_monitor #(.TOTAL_BITS(TOTAL_BITS)) u_inject_monitor(
  .clock(clk),
  .verinject__injector_state(verinject__injector_state),
  .cycle_number(cycle_number)
);

initial begin
    $dumpfile("waveform.vcd");
    $dumpvars;
    clk = 1'b0;
    #20 run = 1'b1;
    #10000 $finish();
end

initial forever #10 clk = ~clk;

always @(negedge clk)
begin
  if (real_index != inj_index)
  begin
    $strobe("Index mismatch at cycle %d: real(%d) != injected(%d)", cycle_number, real_index, inj_index);
  end
  if (real_sum != inj_sum)
  begin
    $strobe("Sum mismatch at cycle %d: real(%08x) != injected(%08x)", cycle_number, real_sum, inj_sum);
  end
end

endmodule