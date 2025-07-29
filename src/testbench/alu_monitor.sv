`include "defines.sv"

class alu_monitor;

  alu_transaction mon_trans;

  mailbox #(alu_transaction) mbx_mon2scb;

  virtual alu_if.MON vif;
  // Event to start capturing (triggered by ref model)
  event e;


  function new (virtual alu_if.MON vif, mailbox #(alu_transaction) mbx_mon2scb, event e);
    this.vif = vif;
    this.mbx_mon2scb = mbx_mon2scb;
    this.e = e;
  endfunction

  task start();
    repeat(4) @(vif.mon_cb);
    for(int i = 0; i < `no_of_trans; i++) begin // OUTER_FOR
      mon_trans = new();
      @(e);
      repeat(1) @(vif.mon_cb);
/*
      if(((vif.mon_cb.MODE == 1) && !(vif.mon_cb.CMD inside {[4:7]})) || ((vif.mon_cb.MODE == 0) && !(vif.mon_cb.CMD inside {[6:11]}))) begin // IF_1
        if(vif.mon_cb.INP_VALID inside {[1:2]}) begin // IF_2
          for(int cycle = 0; cycle < 16; cycle++) begin // INNER_FOR
            repeat(1) @(vif.mon_cb);
            if(vif.mon_cb.INP_VALID == 2'b11) begin
              mon_trans.RES = vif.mon_cb.RES;
              mon_trans.COUT = vif.mon_cb.COUT;
              mon_trans.OFLOW = vif.mon_cb.OFLOW;
              mon_trans.G = vif.mon_cb.G;
              mon_trans.L = vif.mon_cb.L;
              mon_trans.E = vif.mon_cb.E;
              mon_trans.ERR = vif.mon_cb.ERR;
              break;
            end
          end // INNER_FOR
        end // IF_2
      end // IF_1
      else
*/
        begin
          mon_trans.RES = vif.mon_cb.RES;
          mon_trans.COUT = vif.mon_cb.COUT;
          mon_trans.OFLOW = vif.mon_cb.OFLOW;
          mon_trans.G = vif.mon_cb.G;
          mon_trans.L = vif.mon_cb.L;
          mon_trans.E = vif.mon_cb.E;
          mon_trans.ERR = vif.mon_cb.ERR;
        end
      //repeat(1)@(vif.mon_cb);
      $display(" opa =%0d and opb =%0d vif.mon_cb.RES = %0d | ERR = %0d",vif.mon_cb.OPA,vif.mon_cb.OPB, vif.mon_cb.RES, vif.mon_cb.ERR);
      $display("[%0t] MONITOR PASSING DATA TO SCOREBOARD RES = %0d | ERR = %0d", $time, mon_trans.RES, mon_trans.ERR);
      $display("");
      //repeat(1) @(vif.mon_cb);
      mbx_mon2scb.put(mon_trans);

    end // OUTER_FOR
  endtask

endclass
