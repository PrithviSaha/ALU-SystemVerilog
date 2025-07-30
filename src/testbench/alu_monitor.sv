`include "defines.sv"

class alu_monitor;

  alu_transaction mon_trans;

  mailbox #(alu_transaction) mbx_mon2scb;

  virtual alu_if.MON vif;
  // Event to start capturing (triggered by ref model)
  event e;

  // DUV Output coverage
  covergroup mon_cg;
    COUT_CHECK  : coverpoint vif.mon_cb.COUT { bins cout_bins[] = {0,1}; }
    ERR_CHECK   : coverpoint vif.mon_cb.ERR { bins err_bins[] = {0,1}; }
    OFLOW_CHECK : coverpoint vif.mon_cb.OFLOW { bins oflow_bins[] = {0,1}; }
/*
    GLE_CHECK   : coverpoint {vif.mon_cb.G,vif.mon_cb.L,vif.mon_cb.E} {
                          wildcard bins gle_bins = {3'b1zz,3'bz1z,3'bzz1};
                          ignore_bins i_zero1 = {0};
                    }
*/
    G_CHECK     : coverpoint vif.mon_cb.G {
                        wildcard bins g_bins = {'z,1};
                        ignore_bins i_zero1 = {0};
                  }
    L_CHECK     : coverpoint vif.mon_cb.L {
                        wildcard bins l_bins = {'z,1};
                        ignore_bins i_zero2 = {0};
                  }
/*
    E_CHECK     : coverpoint vif.mon_cb.E {
                        wildcard bins e_bins = {'z,1};
                        ignore_bins i_zero3 = {0};
                  }
*/
    RES_CHECK   : coverpoint vif.mon_cb.RES {
                        bins res1 = {0};
                        bins res2 = { {(`WIDTH){1'b1}} };
                        bins res3 = default;
                  }
  endgroup

  function new (virtual alu_if.MON vif, mailbox #(alu_transaction) mbx_mon2scb, event e);
    this.vif = vif;
    this.mbx_mon2scb = mbx_mon2scb;
    this.e = e;

    mon_cg = new();
  endfunction

  task start();
    repeat(4) @(vif.mon_cb);
    for(int i = 0; i < `no_of_trans; i++) begin // OUTER_FOR
      mon_trans = new();
      @(e);
        begin
          mon_trans.RES = vif.mon_cb.RES;
          mon_trans.COUT = vif.mon_cb.COUT;
          mon_trans.OFLOW = vif.mon_cb.OFLOW;
          mon_trans.G = vif.mon_cb.G;
          mon_trans.L = vif.mon_cb.L;
          mon_trans.E = vif.mon_cb.E;
          mon_trans.ERR = vif.mon_cb.ERR;
        end
      mon_cg.sample();
      //repeat(1)@(vif.mon_cb);
      $display(" opa =%0d and opb =%0d vif.mon_cb.RES = %0d | ERR = %0d",vif.mon_cb.OPA,vif.mon_cb.OPB, vif.mon_cb.RES, vif.mon_cb.ERR);
      $display("[%0t] MONITOR PASSING DATA TO SCOREBOARD RES = %0d | ERR = %0d", $time, mon_trans.RES, mon_trans.ERR);
      $display("");
      //repeat(1) @(vif.mon_cb);
      mbx_mon2scb.put(mon_trans);
      repeat(1) @(vif.mon_cb);
    end // OUTER_FOR
  endtask

endclass
