`include "defines.sv"
`include "alu_pkg.sv"
`include "alu_design.v"
`include "alu_if.sv"
`include "alu_assertions.sv"
module top;

  import alu_pkg::*;

  bit CLK;

  initial begin
    forever #5 CLK = ~CLK;
  end

  alu_if intf(CLK);

  //Instantiate duv
  ALU_DESIGN #(.DW(`WIDTH), .CW(`CMD_WIDTH)) DUV(
        .CLK(CLK),
        .RST(intf.RST),
        .CE(intf.CE),
        .MODE(intf.MODE),
        .CMD(intf.CMD),
        .INP_VALID(intf.INP_VALID),
        .CIN(intf.CIN),
        .OPA(intf.OPA),
        .OPB(intf.OPB),
        .RES(intf.RES),
        .COUT(intf.COUT),
        .OFLOW(intf.OFLOW),
        .G(intf.G),
        .L(intf.L),
        .E(intf.E),
        .ERR(intf.ERR)
  );

  //Bind assertions
  bind ALU_DESIGN alu_assertions alu_ass(
        .CLK(CLK),
        .RST(intf.RST),
        .CE(intf.CE),
        .MODE(intf.MODE),
        .CMD(intf.CMD),
        .INP_VALID(intf.INP_VALID),
        .CIN(intf.CIN),
        .OPA(intf.OPA),
        .OPB(intf.OPB),
        .RES(intf.RES),
        .COUT(intf.COUT),
        .OFLOW(intf.OFLOW),
        .G(intf.G),
        .L(intf.L),
        .E(intf.E),
        .ERR(intf.ERR)
  );


  //alu_test tb;

  // Regression test
  test_regression tb_reg = new(intf.DRV, intf.MON, intf.REF_SB);

  initial begin
    //tb = new(intf.DRV, intf.MON, intf.REF_SB);
    //tb.run();
    tb_reg.run();
    $finish;
  end

endmodule
