`include "defines.sv"

class alu_environment;

  virtual alu_if drv_vif;
  virtual alu_if mon_vif;
  virtual alu_if ref_vif;

  //Mailbox for generator to driver connection
  mailbox #(alu_transaction) mbx_gen2drv;
  //Mailbox for driver to reference model connection
  mailbox #(alu_transaction) mbx_drv2ref;
  //Mailbox for reference model to scoreboard connection
  mailbox #(alu_transaction) mbx_ref2scb;
  //Mailbox for monitor to scoreboard connection
  mailbox #(alu_transaction) mbx_mon2scb;

  event e;

  alu_generator           gen;
  alu_driver              drv;
  alu_monitor             mon;
  alu_reference_model     ref_sb;
  alu_scoreboard          scb;

  function new (virtual alu_if drv_vif,
                virtual alu_if mon_vif,
                virtual alu_if ref_vif);
    this.drv_vif = drv_vif;
    this.mon_vif = mon_vif;
    this.ref_vif = ref_vif;
  endfunction

  task build();
   begin
    mbx_gen2drv = new();
    mbx_drv2ref = new();
    mbx_ref2scb = new();
    mbx_mon2scb = new();

    gen = new(mbx_gen2drv);
    drv = new(mbx_gen2drv, mbx_drv2ref, drv_vif);
    mon = new(mon_vif, mbx_mon2scb, e);
    ref_sb = new(mbx_drv2ref, mbx_ref2scb, ref_vif, e);
    scb = new(mbx_ref2scb, mbx_mon2scb);
   end
  endtask

  task start();
    fork
      gen.start();
      drv.start();
      mon.start();
      scb.start();
      ref_sb.start();
    join
//    scb.compare_report();
  endtask

endclass
