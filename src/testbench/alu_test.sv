
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

class ar_single_op_test extends alu_test;
  alu_transaction1 trans;

  function new(virtual alu_if drv_vif,
                virtual alu_if mon_vif,
                virtual alu_if ref_vif);
    super.new(drv_vif,
                mon_vif,
                ref_vif);
  endfunction

  task run();
    $display("Arithetic Single Operand Tests\n");
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

class ar_both_op_test extends alu_test;
  alu_transaction2 trans;

  function new(virtual alu_if drv_vif,
                virtual alu_if mon_vif,
                virtual alu_if ref_vif);
    super.new(drv_vif,
                mon_vif,
                ref_vif);
  endfunction

  task run();
    $display("Arithmetic Both operand Tests\n");
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

class log_single_op_test extends alu_test;
  alu_transaction trans;

  function new(virtual alu_if drv_vif,
                virtual alu_if mon_vif,
                virtual alu_if ref_vif);
    super.new(drv_vif,
                mon_vif,
                ref_vif);
  endfunction

  task run();
    $display("Logical Single operand Tests\n");
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

class log_both_op_test extends alu_test;
  alu_transaction4 trans;

  function new(virtual alu_if drv_vif,
                virtual alu_if mon_vif,
                virtual alu_if ref_vif);
    super.new(drv_vif,
                mon_vif,
                ref_vif);
  endfunction

  task run();
    $display("Logical Both Operand Tests\n");
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

class test_regression extends alu_test;
  alu_transaction trans;
  alu_transaction1 trans1;
  alu_transaction2 trans2;
  alu_transaction3 trans3;
  alu_transaction4 trans4;

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
      trans1 = new();                   //Arithmetic Single Operand Tests
      env.gen.blueprint = trans1;
    end
    env.start;

    begin
      trans2 = new();                   //Arithetic Both Operand Tests
      env.gen.blueprint = trans2;
    end
    env.start;

    begin
      trans3 = new();                   //Logical Single Operand Tests
      env.gen.blueprint = trans3;
    end
    env.start;

    begin
      trans = new();
      env.gen.blueprint = trans;
    end
    env.start;

    begin
      trans4 = new();                   //Logical Both Operands Tests
      env.gen.blueprint = trans4;
    end
     //$display("LAST PACKET HAS STARTED");
    env.start;

  endtask
endclass

////////////////////////////////////////////////////////////////////

