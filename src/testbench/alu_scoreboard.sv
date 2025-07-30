`include "defines.sv"

class alu_scoreboard;
  alu_transaction ref2scb_trans, mon2scb_trans;

  mailbox #(alu_transaction) mbx_ref2scb;

  mailbox #(alu_transaction) mbx_mon2scb;

  int MATCH, MISMATCH;

  function new(mailbox #(alu_transaction) mbx_ref2scb,
               mailbox #(alu_transaction) mbx_mon2scb);
    this.mbx_ref2scb = mbx_ref2scb;
    this.mbx_mon2scb = mbx_mon2scb;
  endfunction

  task start();
    for(int i = 0; i < `no_of_trans; i++) begin
      //$display("I AM HERE i =%0d",i);
      ref2scb_trans = new();
      mon2scb_trans = new();
      begin
        mbx_ref2scb.get(ref2scb_trans);
        $display("=========================SCOREBOARD=============================");
        $display("[%0t] REF DATA : ", $time);
        $display("\tRESULT = %0d | COUT = %0d | OFLOW = %0d | G = %0d | L = %0d | E = %0d | ERR = %0d", ref2scb_trans.RES, ref2scb_trans.COUT, ref2scb_trans.OFLOW, ref2scb_trans.G, ref2scb_trans.L, ref2scb_trans.E, ref2scb_trans.ERR);
      end
      begin
        mbx_mon2scb.get(mon2scb_trans);
        $display("[%0t] MON DATA : ", $time);
        $display("\tRESULT = %0d | COUT = %0d | OFLOW = %0d | G = %0d | L = %0d | E = %0d | ERR = %0d", mon2scb_trans.RES, mon2scb_trans.COUT, mon2scb_trans.OFLOW, mon2scb_trans.G, mon2scb_trans.L, mon2scb_trans.E, mon2scb_trans.ERR);
      end
      $display("==========================================================");
      compare_report();
      $display("");
    end

    $display("TOTAL PASS = %0d", MATCH);
    $display("TOTAL FAILS = %0d", MISMATCH);
  endtask

  function int pass();
    if(mon2scb_trans.RES == ref2scb_trans.RES &&
       mon2scb_trans.COUT == ref2scb_trans.COUT &&
       mon2scb_trans.OFLOW == ref2scb_trans.OFLOW &&
       mon2scb_trans.G == ref2scb_trans.G &&
       mon2scb_trans.L == ref2scb_trans.L &&
       mon2scb_trans.E == ref2scb_trans.E &&
       mon2scb_trans.ERR == ref2scb_trans.ERR)
         return 1;
    else return 0;
  endfunction

  task compare_report();
    if(pass()) begin
      MATCH++;
      $display("\t\tDATA MATCH SUCCESSFUL = %0d", MATCH);
    end
    else begin
      MISMATCH++;
      $display("\t\tDATA MATCH FAILED = %0d", MISMATCH);
    end
  endtask

endclass
