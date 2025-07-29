`include "defines.sv"

class alu_generator;

  alu_transaction blueprint;

  mailbox #(alu_transaction) mbx_gen2drv;

  virtual alu_if vif;

  function new(mailbox #(alu_transaction) mbx_gen2drv);
    this.mbx_gen2drv = mbx_gen2drv;
    blueprint = new();
  endfunction

  //Task to generate the random stimuli
  task start();

    for(int i = 0; i < `no_of_trans; i++) begin
        void'(blueprint.randomize());
        mbx_gen2drv.put(blueprint.copy());

        $display("GENERATOR Randomized transaction:");
        $display("RST = %0d | CE = %0d | MODE = %0d | INP_VALID = %0d | CMD = %0d | OPA = %0d | OPB = %0d | CIN = %0d", blueprint.RST, blueprint.CE, blueprint.MODE, blueprint.INP_VALID, blueprint.CMD, blueprint.OPA, blueprint.OPB, blueprint.CIN, $time);
        $display("");
    end
  endtask
endclass
