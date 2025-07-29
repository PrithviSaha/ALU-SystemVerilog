
class alu_test;

  virtual alu_if drv_vif;
  virtual alu_if mon_vif;
  virtual alu_if ref_vif;

  alu_environment env;

  function new(virtual alu_if drv_vif,
               virtual alu_if mon_vif,
               virtual alu_if ref_vif);
    this.drv_vif = drv_vif;
    this.mon_vif = mon_vif;
    this.ref_vif = ref_vif;
  endfunction

  task run();
    env = new(drv_vif,
                mon_vif,
                ref_vif);
    env.build();
    env.start();
  endtask
endclass

/////////////////////////////////////////////////////////////////////

class test extends alu_test;
  alu_transaction trans;

  function new(virtual alu_if drv_vif,
                virtual alu_if mon_vif,
                virtual alu_if ref_vif);
    super.new(drv_vif,
                mon_vif,
                ref_vif);
  endfunction

  task run();
    env = new(drv_vif,
                mon_vif,
                ref_vif);
    env.build;
    begin
      trans = new();
      env.gen.blueprint = trans;
    end
    env.start;
  endtask
endclass

////////////////////////////////////////////////////////////////////
