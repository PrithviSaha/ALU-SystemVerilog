`include "defines.sv"

module alu_assertions(
  input logic CLK,
  input logic RST, CE, CIN, COUT, OFLOW, G, L, E, ERR, MODE,
  input logic [`CMD_WIDTH-1:0] CMD,
  input logic [`WIDTH:0] RES,
  input logic [`WIDTH-1:0] OPA, OPB,
  input logic [1:0] INP_VALID
);

  property RST_CHECK;
    @(posedge CLK) RST |=> ({RES, COUT, OFLOW, G, L, E, ERR} === 'z);
  endproperty

  property GLE_CHECK;
    @(posedge CLK) disable iff (RST || !CE)
    (MODE && (CMD == 8) && (INP_VALID == 3)) |=>
      (OPA > OPB) ? {G,L,E} === 3'b1zz :
      (OPA < OPB) ? {G,L,E} === 3'bz1z : 3'bzz1;
  endproperty

  assert property (GLE_CHECK)
    $info("GLE_CHECK PASSED");
  else
    $error("GLE_CHECK FAILED");

  property UNKNOWN_INP_CHECK;
    @(posedge CLK) disable iff (RST)
    CE |-> not($isunknown({OPA, OPB, INP_VALID, CIN, MODE, CMD}));
  endproperty


  sequence mode_and_cmd;
    (
      (MODE && !(CMD inside {[4:7]})) ||
      (!MODE && !(CMD inside {[6:11]}))
    )
    && (INP_VALID inside {1,2});
  endsequence

  property CMD_MODE_STABLE_CHECK;
    @(posedge CLK) disable iff (RST || !CE)
    mode_and_cmd |=> (CMD == $past(CMD) && MODE == $past(MODE)) throughout (##[0:15] INP_VALID == 3);
  endproperty


  sequence mul;
    MODE && (CMD inside {9,10}) && (INP_VALID == 3);
  endsequence

  property MUL_DELAY_CHECK;
    @(posedge CLK) disable iff (RST || !CE)
    mul |=> ##1 (RES !== $past(RES,3));
  endproperty


  property CE_CHECK;
    @(posedge CLK) !CE |-> ##[1:$] CE;
  endproperty

  assert property (CE_CHECK)
    $info("CE_CHECK PASSED");
  else
    $error("CE_CHECK FAILED");

  assert property (RST_CHECK)
    $info("RST CONDITION PASSED");
  else
    $error("RST FAILED | RES = %b", RES);

  assert property (CMD_MODE_STABLE_CHECK)
    $info("CMD_MODE_STABLE_CHECK PASSED");
  else
    $error("CMD_MODE_STABLE_CHECK FAILED");

  assert property (UNKNOWN_INP_CHECK)
    $info("UNKNOWN_INP_CHECK PASSED");
  else
    $error("UNKNOWN_INP_CHECK FAILED");

  assert property (MUL_DELAY_CHECK)
    $info("MUL_DELAY_CHECK PASSED");
  else
    $error("MUL_DELAY_CHECK FAILED");


endmodule
