
//This package includes all the files in the testbench architecture
//which will be imported in the top module
package alu_pkg;
  `include "alu_transaction.sv"
  `include "alu_generator.sv"
  `include "alu_driver.sv"
  `include "alu_monitor.sv"
  `include "alu_reference_model.sv"
  `include "alu_scoreboard.sv"
  `include "alu_environment.sv"
  `include "alu_test.sv"
endpackage
