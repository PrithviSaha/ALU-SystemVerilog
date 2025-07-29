`include "defines.sv"

interface alu_if(input bit CLK);
  //Declaring signals with width
  logic CE, RST;
  logic MODE, CIN;
  logic [1:0] INP_VALID;
  logic [`CMD_WIDTH-1:0] CMD;
  logic [`WIDTH-1:0] OPA, OPB;
  logic [2*`WIDTH-1:0] RES;
  logic COUT, OFLOW, G, L, E, ERR;

  //Clocking block for generator
/*
  clocking gen_cb@(posedge clk);
    default input #0 output #0;
  endclocking
*/

  //Clocking block for driver
  clocking drv_cb@(posedge CLK);

    default input #0 output #0;

    //output RES, COUT, OFLOW, G, L, E, ERR;
    output RST, CE, MODE, CIN, INP_VALID, CMD, OPA, OPB;

  endclocking

  //Clocking block for monitor
  clocking mon_cb@(posedge CLK);

    default input #0 output #0;

    input RST, RES, COUT, OFLOW, G, L, E, ERR,OPA,OPB, INP_VALID, CMD, MODE;

  endclocking

  //Clocking block for reference model
  clocking ref_cb@(posedge CLK);

    default input #0 output #0;

    // input RST, CE, INP_VALID, MODE, CMD, OPA, OPB, CIN;
    // output RES, COUT, OFLOW, G, L, E, ERR;

  endclocking

  //Modports
  modport DRV(clocking drv_cb);
  modport MON(clocking mon_cb);
  modport REF_SB(clocking ref_cb);

endinterface
