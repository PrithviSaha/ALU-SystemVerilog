`include "defines.sv"

class alu_reference_model;

  alu_transaction ref_trans;
  //reference model to scoreboard connection
  mailbox #(alu_transaction) mbx_ref2scb;
  //driver to reference model connection
  mailbox #(alu_transaction) mbx_drv2ref;

  virtual alu_if.REF_SB vif;

  event e;

  function new(mailbox #(alu_transaction) mbx_drv2ref,
                mailbox #(alu_transaction) mbx_ref2scb,
                virtual alu_if.REF_SB vif,
                event e);
    this.mbx_drv2ref = mbx_drv2ref;
    this.mbx_ref2scb = mbx_ref2scb;
    this.vif = vif;
    this.e = e;
  endfunction

//  function automatic bit[2*`WIDTH-1:0] add();
//    return (ref_trans.OPA + ref_trans.OPB);
//  endfunction

  // Task for arithmetic operations
  task arithmetic_ops();
        case(ref_trans.CMD)
                          `ADD : begin
                                   ref_trans.RES = ref_trans.OPA + ref_trans.OPB;
                                   ref_trans.COUT = ref_trans.RES[`WIDTH];
                                 end
                          `SUB : begin
                                   ref_trans.RES = ref_trans.OPA - ref_trans.OPB;
                                   ref_trans.OFLOW = (ref_trans.OPA < ref_trans.OPB) ? 1 : 0;
                                 end
                          `ADD_CIN : begin
                                        ref_trans.RES = ref_trans.OPA + ref_trans.OPB + ref_trans.CIN;
                                        ref_trans.COUT = ref_trans.RES[`WIDTH];
                                     end
                          `SUB_CIN : begin
                                   ref_trans.RES = ((ref_trans.OPA - ref_trans.OPB) - ref_trans.CIN) & ((1 << (`WIDTH+1)) - 1);
                                   ref_trans.OFLOW = (ref_trans.OPA < (ref_trans.OPB + ref_trans.CIN)) ? 1 : 0;
                                 end
                          `CMP : begin
                                   if(ref_trans.OPA > ref_trans.OPB) ref_trans.G = 1'b1;
                                   if(ref_trans.OPA < ref_trans.OPB) ref_trans.L = 1'b1;
                                   if(ref_trans.OPA == ref_trans.OPB) ref_trans.E = 1'b1;
                                 end
                          `INC_MUL : begin
                                        repeat(2) @(vif.ref_cb);
                                        if(ref_trans.OPA == {`WIDTH{1'b1}} || ref_trans.OPB == {`WIDTH{1'b1}})
                                          ref_trans.ERR = 1'b1;
                                        else
                                          ref_trans.RES = (ref_trans.OPA + 1) * (ref_trans.OPB + 1);
                                     end
                          `SHL1_MUL : begin
                                        repeat(2) @(vif.ref_cb);
                                        ref_trans.RES = ((ref_trans.OPA << 1) & ((1 << `WIDTH)-1)) * ref_trans.OPB;
                                      end
                          `INC_A : begin
                                     if(ref_trans.OPA == {`WIDTH{1'b1}})
                                        ref_trans.COUT = 1'b1;
                                     ref_trans.RES = ref_trans.OPA + 1;
                                   end
                          `DEC_A : begin
                                     if(ref_trans.OPA == {`WIDTH{1'b0}})
                                        ref_trans.OFLOW = 1'b1;
                                     ref_trans.RES = (ref_trans.OPA - 1) & ((1 << (`WIDTH+1)) - 1);
                                   end
                          `INC_B : begin
                                     if(ref_trans.OPB == {`WIDTH{1'b1}})
                                        ref_trans.COUT = 1'b1;
                                     ref_trans.RES = ref_trans.OPB + 1;
                                   end
                          `DEC_B : begin
                                     if(ref_trans.OPB == {`WIDTH{1'b0}})
                                        ref_trans.OFLOW = 1'b1;
                                     ref_trans.RES = (ref_trans.OPB - 1) & ((1 << (`WIDTH+1)) - 1);
                                   end
                          default : ref_trans.ERR = 1'b1;
        endcase
  endtask

  // Task for logical operations
  task logical_ops();

    bit [$clog2(`WIDTH)-1:0] rot_amt;

    if(ref_trans.CMD == `ROL_A_B || ref_trans.CMD == `ROR_A_B)
      rot_amt = ref_trans.OPB[$clog2(`WIDTH)-1:0];

    case(ref_trans.CMD)
      `AND : ref_trans.RES = ref_trans.OPA && ref_trans.OPB;
      `NAND : ref_trans.RES = {{(2*`WIDTH){1'b0}}, ~((|ref_trans.OPA) && (|ref_trans.OPB))};
      `OR : ref_trans.RES = ref_trans.OPA || ref_trans.OPB;
      `NOR : ref_trans.RES = {{(2*`WIDTH){1'b0}}, ~((|ref_trans.OPA) || (|ref_trans.OPB))};
      `XOR : ref_trans.RES = ref_trans.OPA ^ ref_trans.OPB;
      `XNOR : ref_trans.RES = {{(2*`WIDTH){1'b0}}, ~(ref_trans.OPA ^ ref_trans.OPB)};
      `NOT_A : ref_trans.RES = !ref_trans.OPA;
      `NOT_B : ref_trans.RES = !ref_trans.OPB;
      `SHR1_A : ref_trans.RES = ref_trans.OPA >> 1;
      `SHL1_A : ref_trans.RES = ((ref_trans.OPA << 1) & ((1 << `WIDTH) - 1));
      `SHR1_B : ref_trans.RES = ref_trans.OPB >> 1;
      `SHL1_B : ref_trans.RES = ((ref_trans.OPB << 1) & ((1 << `WIDTH) - 1));
      `ROL_A_B : begin
                   if(|ref_trans.OPB[`WIDTH-1:$clog2(`WIDTH)+1])
                     ref_trans.ERR = 1'b1;
                   ref_trans.RES = ((ref_trans.OPA << rot_amt) | (ref_trans.OPA >> (`WIDTH-rot_amt))) & ((1 << `WIDTH)-1);
                 end
      `ROR_A_B : begin
                   if(|ref_trans.OPB[`WIDTH-1:$clog2(`WIDTH)+1])
                     ref_trans.ERR = 1'b1;
                   ref_trans.RES = ((ref_trans.OPA >> rot_amt) | (ref_trans.OPA << (`WIDTH-rot_amt))) & ((1 << `WIDTH)-1);                                                                               end
    endcase
  endtask


  task start();
    for(int i = 0; i < `no_of_trans; i++) begin
      //repeat(1) @(vif.ref_cb);
      ref_trans = new();
      mbx_drv2ref.get(ref_trans);
      repeat(1) @(vif.ref_cb);
      if(ref_trans.RST) begin
        //repeat(1) @(vif.ref_cb);      //
        mbx_ref2scb.put(ref_trans);
        ->e;
      end
      else begin
        if(ref_trans.CE == 0) begin
          //repeat(1) @(vif.ref_cb);    //
          mbx_ref2scb.put(ref_trans);
          ->e;
        end
        else begin
          if(ref_trans.MODE) begin          //Arithmetic
            //repeat(1) @(vif.ref_cb);  //
            case(ref_trans.INP_VALID)
              2'b00: ref_trans.ERR = 1;
              2'b11: arithmetic_ops();
              2'b10 : begin
                        if(ref_trans.CMD inside {[4:5]}) begin
                          arithmetic_ops();
                        end
                        else if(ref_trans.CMD inside {6,7})
                          ref_trans.ERR = 1'b1;
                        else begin
                          int found = 0;
                          for(int check = 0; check < 16; check++) begin
                            @(vif.ref_cb);
                            if(ref_trans.INP_VALID == 2'b11) begin
                              found = 1;
                              arithmetic_ops();
                              break;
                            end
                          end
                          ref_trans.ERR = (found) ? 0 : 1;
                        end
                      end
              2'b01 : begin
                        if(ref_trans.CMD inside {[6:7]}) begin
                          arithmetic_ops();
                        end
                        else if (ref_trans.CMD inside {4,5})
                          ref_trans.ERR = 1'b1;
                        else begin
                          int found = 0;
                          for(int check = 0; check < 16; check++) begin
                            @(vif.ref_cb);
                            if(ref_trans.INP_VALID == 2'b11) begin
                              found = 1;
                              arithmetic_ops();
                              break;
                            end
                          end
                          ref_trans.ERR = (found) ? 0 : 1;
                        end
                      end
              default: begin
                         ref_trans.ERR = 1;
                       end
            endcase
          end

          else begin                    //Logical
            repeat(1) @(vif.ref_cb);
            case(ref_trans.INP_VALID)
              2'b00 : ref_trans.ERR = 1'b1;
              2'b11 : logical_ops();
              2'b10 : begin
                        if(ref_trans.CMD inside {6,8,9})
                          logical_ops();
                        else if(ref_trans.CMD inside {7,10,11})
                          ref_trans.ERR = 1'b1;
                        else begin
                          int found = 0;
                          for(int check = 0; check < 16; check++) begin
                            @(vif.ref_cb);
                            if(ref_trans.INP_VALID == 2'b11) begin
                              found = 1;
                              logical_ops();
                              break;
                            end
                          end
                          ref_trans.ERR = (found) ? 0 : 1;
                        end
                      end
              2'b01 : begin
                        if(ref_trans.CMD inside {7,10,11})
                          logical_ops();
                        else if(ref_trans.CMD inside {6,8,9})
                          ref_trans.ERR = 1'b1;
                        else begin
                          int found = 0;
                          for(int check = 0; check < 16; check++) begin
                            @(vif.ref_cb);
                            if(ref_trans.INP_VALID == 2'b11) begin
                              found = 1;
                              logical_ops();
                              break;
                            end
                          end
                          ref_trans.ERR = (found) ? 0 : 1;
                        end
                      end
            endcase
          end
          //$display("[%0t] REFERENCE MODEL:", $time);
          //$display("MODE = %0d | RST = %0d | CE ");

          mbx_ref2scb.put(ref_trans);
          ->e;
        end

      end

      $display("[%0t] REFERENCE MODEL:", $time);
      $display("\tMODE = %0d | RST = %0d | CE = %0d", ref_trans.MODE, ref_trans.RST, ref_trans.CE);
      $display("\tCMD = %0d | INP_VALID = %0d | OPA = %0d | OPB = %0d | CIN = %0d", ref_trans.CMD, ref_trans.INP_VALID, ref_trans.OPA, ref_trans.OPB, ref_trans.CIN);
      $display("\tRES = %0d | COUT = %0d | OFLOW = %0d | G = %0d | L = %0d | E = %0d | ERR = %0d", ref_trans.RES, ref_trans.COUT, ref_trans.OFLOW, ref_trans.G, ref_trans.L, ref_trans.E, ref_trans.ERR);
      $display("");
    end
  endtask


endclass
