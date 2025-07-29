`include "defines.sv"

module alu_assertions(
  input logic CLK,
  input logic RST, CE, CIN, COUT, OFLOW, G, L, E, ERR, MODE,
  input logic [`CMD_WIDTH-1:0] CMD,
  input logic [`WIDTH:0] RES,
  input logic [`WIDTH-1:0] OPA, OPB,
  input logic [1:0] INP_VALID
);

  property norst;
    RST |-> {RES, COUT, OFLOW, G, L, E, ERR} === {(`WIDTH+7){1'bz}};
  endproperty

  assert property (@(posedge CLK) norst)
    $info("RST CONDITION PASSED");
  else
    $error("RST FAILED | RES = %b", RES);

endmodule
