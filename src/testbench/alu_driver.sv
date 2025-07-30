`include "defines.sv"

class alu_driver;
  //Transaction class handle
  alu_transaction drv_trans;

  mailbox #(alu_transaction) mbx_gen2drv;

  mailbox #(alu_transaction) mbx_drv2ref;

  virtual alu_if.DRV vif;
  //Covergroups
  covergroup drv_cg;
    MODE_CP      : coverpoint drv_trans.MODE { bins mode_bins[] = {0,1}; }
    CMD_CP       : coverpoint drv_trans.CMD { bins cmd_bins[] = {[0:13]}; }
    INP_VALID_CP : coverpoint drv_trans.INP_VALID { bins ip_valid_bins[] = {[0:3]}; }
    CIN_CP       : coverpoint drv_trans.CIN { bins cin[] = {0,1}; }
    CE_CP        : coverpoint drv_trans.CE { bins ce_bins[] = {0,1}; }
    RST_CP       : coverpoint drv_trans.RST { bins rst_cp[] = {0,1}; }

    MODE_CP_X_CMD_CP : cross MODE_CP, CMD_CP;
    CMD_CP_X_INP_VALID_CP : cross CMD_CP, INP_VALID_CP;
    MODE_CP_X_INP_VALID_CP : cross MODE_CP, INP_VALID_CP;
    RST_CP_X_CE_CP : cross RST_CP, CE_CP;
  endgroup

//METHODS
  //Explicitly overriding the constructor to make mailbox connection from driver
  //to generator, to make mailbox connection from driver to reference model and
  //to connect the virtual interface from driver to environment
  function new(mailbox #(alu_transaction) mbx_gen2drv,
               mailbox #(alu_transaction) mbx_drv2ref,
               virtual alu_if.DRV vif);
    this.mbx_gen2drv = mbx_gen2drv;
    this.mbx_drv2ref = mbx_drv2ref;
    this.vif = vif;

    drv_cg=new();
  endfunction

  //Task to drive the stimuli to the interface and put packets to mailbox
  task start();
    repeat(3) @(vif.drv_cb);
    for(int i = 0; i < `no_of_trans; i++) begin
      drv_trans = new();
      mbx_gen2drv.get(drv_trans);
      //$display("[%0t] DRIVER DRIVING DATA:", $time);
      if(drv_trans.RST) begin
        repeat(1) @(vif.drv_cb);
        begin
          vif.drv_cb.RST <= drv_trans.RST;
          vif.drv_cb.CE <= drv_trans.CE;
          vif.drv_cb.INP_VALID <= drv_trans.INP_VALID;
          vif.drv_cb.MODE <= 0;
          vif.drv_cb.CMD <= 0;
          vif.drv_cb.OPA <= 0;
          vif.drv_cb.OPB <= 0;
          vif.drv_cb.CIN <= 0;
          mbx_drv2ref.put(drv_trans);
//        $display("[%0t] DRIVER DRIVING DATA:", $time);
//        $display("\tMODE = %0d | RST = %0d | CE = %0d", drv_trans.MODE, drv_trans.RST, drv_trans.CE);
//        $display("\tCMD = %0d | INP_VALID = %0d | OPA = %0d | OPB = %0d | CIN = %0d", drv_trans.CMD, drv_trans.INP_VALID, drv_trans.OPA, drv_trans.OPB, drv_trans.CIN);
//        $display("");
          repeat(1) @(vif.drv_cb);
        end
      end
      else begin
        repeat(1) @(vif.drv_cb);
        if(drv_trans.CE == 0)
          mbx_drv2ref.put(drv_trans);
        else begin
          if(drv_trans.INP_VALID == 2'b11 || drv_trans.INP_VALID == 2'b00) begin
            vif.drv_cb.RST <= drv_trans.RST;
            vif.drv_cb.CE <= drv_trans.CE;
            vif.drv_cb.INP_VALID <= drv_trans.INP_VALID;
            vif.drv_cb.MODE <= drv_trans.MODE;
            vif.drv_cb.CMD <= drv_trans.CMD;
            vif.drv_cb.OPA <= drv_trans.OPA;
            vif.drv_cb.OPB <= drv_trans.OPB;
            vif.drv_cb.CIN <= drv_trans.CIN;
            mbx_drv2ref.put(drv_trans);
//          $display("[%0t] DRIVER DRIVING DATA:", $time);
//          $display("\tMODE = %0d | RST = %0d | CE = %0d", drv_trans.MODE, drv_trans.RST, drv_trans.CE);
//          $display("\tCMD = %0d | INP_VALID = %0d | OPA = %0d | OPB = %0d | CIN = %0d", drv_trans.CMD, drv_trans.INP_VALID, drv_trans.OPA, drv_trans.OPB, drv_trans.CIN);
//          $display("");
            repeat(1) @(vif.drv_cb);
          end
          else begin            //INP_VALID == 01 or 10
            if(((drv_trans.MODE == 1) && (drv_trans.CMD inside {[4:7]})) || ((drv_trans.MODE == 0) && (drv_trans.CMD inside {[6:11]}))) begin
              vif.drv_cb.RST <= drv_trans.RST;
              vif.drv_cb.CE <= drv_trans.CE;
              vif.drv_cb.INP_VALID <= drv_trans.INP_VALID;
              vif.drv_cb.MODE <= drv_trans.MODE;
              vif.drv_cb.CMD <= drv_trans.CMD;
              vif.drv_cb.OPA <= drv_trans.OPA;
              vif.drv_cb.OPB <= drv_trans.OPB;
              vif.drv_cb.CIN <= drv_trans.CIN;
              mbx_drv2ref.put(drv_trans);
//            $display("[%0t] DRIVER DRIVING DATA:", $time);
//            $display("\tMODE = %0d | RST = %0d | CE = %0d", drv_trans.MODE, drv_trans.RST, drv_trans.CE);
//            $display("\tCMD = %0d | INP_VALID = %0d | OPA = %0d | OPB = %0d | CIN = %0d", drv_trans.CMD, drv_trans.INP_VALID, drv_trans.OPA, drv_trans.OPB, drv_trans.CIN);
//            $display("");
              repeat(1) @(vif.drv_cb);
            end
            else begin
             //Drive values once for capturing
/*           vif.drv_cb.MODE <= drv_trans.MODE;
             vif.drv_cb.CMD <= drv_trans.CMD;
             vif.drv_cb.OPA <= drv_trans.OPA;
             vif.drv_cb.OPB <= drv_trans.OPB;
             vif.drv_cb.CIN <= drv_trans.CIN;
             mbx_drv2ref.put(drv_trans);*/
             drv_trans.MODE.rand_mode(0);
             drv_trans.CE.rand_mode(0);
             drv_trans.RST.rand_mode(0);
             drv_trans.CMD.rand_mode(0);
             for(int cycle = 0; cycle < 16; cycle++) begin
               repeat(1) @(vif.drv_cb);
               void'(drv_trans.randomize());
               if(drv_trans.INP_VALID == 2'b11) begin
                 vif.drv_cb.RST <= drv_trans.RST;
                 vif.drv_cb.CE <= drv_trans.CE;
                 vif.drv_cb.INP_VALID <= drv_trans.INP_VALID;
                 vif.drv_cb.MODE <= drv_trans.MODE;
                 vif.drv_cb.CMD <= drv_trans.CMD;
                 vif.drv_cb.OPA <= drv_trans.OPA;
                 vif.drv_cb.OPB <= drv_trans.OPB;
                 vif.drv_cb.CIN <= drv_trans.CIN;
                 mbx_drv2ref.put(drv_trans);
//               $display("[%0t] DRIVER DRIVING DATA:", $time);
//               $display("\tMODE = %0d | RST = %0d | CE = %0d", drv_trans.MODE, drv_trans.RST, drv_trans.CE);
//               $display("\tCMD = %0d | INP_VALID = %0d | OPA = %0d | OPB = %0d | CIN = %0d", drv_trans.CMD, drv_trans.INP_VALID, drv_trans.OPA, drv_trans.OPB, drv_trans.CIN);
//               $display("");
                 repeat(1) @(vif.drv_cb);
                 //mbx_drv2ref.put(drv_trans);
                 drv_trans.CE.rand_mode(1);
                 drv_trans.RST.rand_mode(1);
                 drv_trans.MODE.rand_mode(1);
                 drv_trans.CMD.rand_mode(1);
                 break;
               end
             end
            end
          end
        end
      end
      /*$display("[%0t] DRIVER DRIVING DATA:", $time);
      $display("\tMODE = %0d | RST = %0d | CE = %0d", drv_trans.MODE, drv_trans.RST, drv_trans.CE);
      $display("\tCMD = %0d | INP_VALID = %0d | OPA = %0d | OPB = %0d | CIN = %0d", drv_trans.CMD, drv_trans.INP_VALID, drv_trans.OPA, drv_trans.OPB, drv_trans.CIN);
      $display("\tRES = %0d | COUT = %0d | OFLOW = %0d | G = %0d | L = %0d | E = %0d | ERR = %0d", drv_trans.RES, drv_trans.COUT, drv_trans.OFLOW, drv_trans.G, drv_trans.L, drv_trans.E, drv_trans.ERR);
      $display("");*/
      drv_cg.sample();
      $display("INPUT COVERAGE%% : %.2f%%\n", drv_cg.get_coverage());
      if((drv_trans.CMD == `INC_MUL || drv_trans.CMD == `SHL1_MUL) && (drv_trans.MODE))
        repeat(1) @(vif.drv_cb);
      repeat(1) @(vif.drv_cb);
      //mbx_drv2ref.put(drv_trans);
    end
  endtask
endclass
