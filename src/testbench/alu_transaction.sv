`include "defines.sv"

class alu_transaction;
//PROPERTIES
  //INPUTS declare as rand variables
  rand bit CLK, RST;
  rand bit CE;
  rand bit [1:0] INP_VALID;
  rand bit MODE;                //1: Arithmetic         0: Logical
  rand bit [`CMD_WIDTH-1:0] CMD;
  rand bit CIN;
  rand bit [`WIDTH-1:0] OPA, OPB;


  //OUTPUTS daclare as non-rand variables
  bit ERR = 1'bz;
  bit OFLOW = 1'bz;
  bit COUT = 1'bz;
  bit G = 1'bz;
  bit L = 1'bz;
  bit E = 1'bz;
  bit [(2 * `WIDTH)-1:0] RES = {(2*`WIDTH){1'bz}};

  //CONSTRAINTS

  constraint mode_cmd_constraint {
    if(MODE == 1)
      CMD inside {[0:10]};
    else
      CMD inside {[0:13]};

    solve MODE before CMD;
  }

  //constraint testing { RST == 1; CE == 1; }//RST == 0; CE == 1; INP_VALID == 3; }

  constraint reset_weight { RST dist { 1 := 1, 0 := 9}; }

  constraint ce_weight { CE dist { 0 := 1, 1 := 9}; }
  //constraint temp_cons { RST == 0; CE == 1; INP_VALID == 3; MODE == 0; CMD == 8; }

//METHODS
  //Deep copying objects for blueprint
  virtual function alu_transaction copy();
    copy = new();
    copy.CE = this.CE;
    copy.RST = this.RST;
    copy.INP_VALID = this.INP_VALID;
    copy.MODE = this.MODE;
    copy.CMD = this.CMD;
    copy.CIN = this.CIN;
    copy.OPA = this.OPA;
    copy.OPB = this.OPB;
    return copy;
  endfunction

endclass

//////////////////////////////////////////////////////////////////////////

class alu_transaction1 extends alu_transaction;
  constraint ar_single_op { MODE == 1; CMD inside {[4:7]}; }

  virtual function alu_transaction1 copy();
    copy = new();
    copy.CE = this.CE;
    copy.RST = this.RST;
    copy.INP_VALID = this.INP_VALID;
    copy.MODE = this.MODE;
    copy.CMD = this.CMD;
    copy.CIN = this.CIN;
    copy.OPA = this.OPA;
    copy.OPB = this.OPB;
    return copy;
  endfunction

endclass

//////////////////////////////////////////////////////////////////////////

class alu_transaction2 extends alu_transaction;
  constraint ar_both_op { MODE == 1; CMD inside {0,1,2,3,8,9,10}; }

  virtual function alu_transaction2 copy();
    copy = new();
    copy.CE = this.CE;
    copy.RST = this.RST;
    copy.INP_VALID = this.INP_VALID;
    copy.MODE = this.MODE;
    copy.CMD = this.CMD;
    copy.CIN = this.CIN;
    copy.OPA = this.OPA;
    copy.OPB = this.OPB;
    return copy;
  endfunction

endclass

//////////////////////////////////////////////////////////////////////////

class alu_transaction3 extends alu_transaction;
  constraint log_single_op { MODE == 0; CMD inside {[6:11]}; }

  virtual function alu_transaction3 copy();
    copy = new();
    copy.CE = this.CE;
    copy.RST = this.RST;
    copy.INP_VALID = this.INP_VALID;
    copy.MODE = this.MODE;
    copy.CMD = this.CMD;
    copy.CIN = this.CIN;
    copy.OPA = this.OPA;
    copy.OPB = this.OPB;
    return copy;
  endfunction

endclass

//////////////////////////////////////////////////////////////////////////

class alu_transaction4 extends alu_transaction;
  constraint log_both_ops { MODE == 1; CMD inside {0,1,2,3,4,5,12,13}; }

  virtual function alu_transaction4 copy();
    copy = new();
    copy.CE = this.CE;
    copy.RST = this.RST;
    copy.INP_VALID = this.INP_VALID;
    copy.MODE = this.MODE;
    copy.CMD = this.CMD;
    copy.CIN = this.CIN;
    copy.OPA = this.OPA;
    copy.OPB = this.OPB;
    return copy;
  endfunction

endclass

//////////////////////////////////////////////////////////////////////////
