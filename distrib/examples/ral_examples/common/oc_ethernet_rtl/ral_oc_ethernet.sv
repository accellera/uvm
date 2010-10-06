`ifndef RAL_OC_ETHERNET
`define RAL_OC_ETHERNET

import uvm_pkg::*;

class ral_reg_MODER extends uvm_ral_reg;
   rand uvm_ral_field RECSMALL;
   rand uvm_ral_field PAD;
   rand uvm_ral_field HUGEN;
   rand uvm_ral_field CRCEN;
   rand uvm_ral_field DLYCRCEN;
   rand uvm_ral_field undocumented;
   rand uvm_ral_field FULLD;
   rand uvm_ral_field EXDFREN;
   rand uvm_ral_field NOBCKOF;
   rand uvm_ral_field LOOPBCK;
   rand uvm_ral_field IFG;
   rand uvm_ral_field PRO;
   rand uvm_ral_field IAM;
   rand uvm_ral_field BRO;
   rand uvm_ral_field NOPRE;
   rand uvm_ral_field TXEN;
   rand uvm_ral_field RXEN;

   function new(string name = "MODER");
      super.new(name, 24, uvm_ral::NO_COVERAGE);
   endfunction: new

   virtual function void build();
      this.RECSMALL = uvm_ral_field::type_id::create("RECSMALL",,get_full_name());
      this.RECSMALL.configure(this, 1, 16, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
      this.PAD = uvm_ral_field::type_id::create("PAD",,get_full_name());
      this.PAD.configure(this, 1, 15, "RW", 1, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.HUGEN = uvm_ral_field::type_id::create("HUGEN",,get_full_name());
      this.HUGEN.configure(this, 1, 14, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.CRCEN = uvm_ral_field::type_id::create("CRCEN",,get_full_name());
      this.CRCEN.configure(this, 1, 13, "RW", 1, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.DLYCRCEN = uvm_ral_field::type_id::create("DLYCRCEN",,get_full_name());
      this.DLYCRCEN.configure(this, 1, 12, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.undocumented = uvm_ral_field::type_id::create("undocumented",,get_full_name());
      this.undocumented.configure(this, 1, 11, "OTHER", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.FULLD = uvm_ral_field::type_id::create("FULLD",,get_full_name());
      this.FULLD.configure(this, 1, 10, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.EXDFREN = uvm_ral_field::type_id::create("EXDFREN",,get_full_name());
      this.EXDFREN.configure(this, 1, 9, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.NOBCKOF = uvm_ral_field::type_id::create("NOBCKOF",,get_full_name());
      this.NOBCKOF.configure(this, 1, 8, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.LOOPBCK = uvm_ral_field::type_id::create("LOOPBCK",,get_full_name());
      this.LOOPBCK.configure(this, 1, 7, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.IFG = uvm_ral_field::type_id::create("IFG",,get_full_name());
      this.IFG.configure(this, 1, 6, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.PRO = uvm_ral_field::type_id::create("PRO",,get_full_name());
      this.PRO.configure(this, 1, 5, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.IAM = uvm_ral_field::type_id::create("IAM",,get_full_name());
      this.IAM.configure(this, 1, 4, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.BRO = uvm_ral_field::type_id::create("BRO",,get_full_name());
      this.BRO.configure(this, 1, 3, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.NOPRE = uvm_ral_field::type_id::create("NOPRE",,get_full_name());
      this.NOPRE.configure(this, 1, 2, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.TXEN = uvm_ral_field::type_id::create("TXEN",,get_full_name());
      this.TXEN.configure(this, 1, 1, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.RXEN = uvm_ral_field::type_id::create("RXEN",,get_full_name());
      this.RXEN.configure(this, 1, 0, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
   endfunction: build

   `uvm_object_utils(ral_reg_MODER)

endclass : ral_reg_MODER


class ral_reg_oc_ethernet_INT_SOURCE extends uvm_ral_reg;
   rand uvm_ral_field RXC;
   rand uvm_ral_field TXC;
   rand uvm_ral_field BUSY;
   rand uvm_ral_field RXE;
   rand uvm_ral_field RXB;
   rand uvm_ral_field TXE;
   rand uvm_ral_field TXB;

   function new(string name = "oc_ethernet_INT_SOURCE");
      super.new(name, 8, uvm_ral::NO_COVERAGE);
   endfunction: new

   virtual function void build();
      this.RXC = uvm_ral_field::type_id::create("RXC",,get_full_name());
      this.RXC.configure(this, 1, 6, "W1C", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.TXC = uvm_ral_field::type_id::create("TXC",,get_full_name());
      this.TXC.configure(this, 1, 5, "W1C", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.BUSY = uvm_ral_field::type_id::create("BUSY",,get_full_name());
      this.BUSY.configure(this, 1, 4, "W1C", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.RXE = uvm_ral_field::type_id::create("RXE",,get_full_name());
      this.RXE.configure(this, 1, 3, "W1C", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.RXB = uvm_ral_field::type_id::create("RXB",,get_full_name());
      this.RXB.configure(this, 1, 2, "W1C", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.TXE = uvm_ral_field::type_id::create("TXE",,get_full_name());
      this.TXE.configure(this, 1, 1, "W1C", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.TXB = uvm_ral_field::type_id::create("TXB",,get_full_name());
      this.TXB.configure(this, 1, 0, "W1C", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
   endfunction: build

   `uvm_object_utils(ral_reg_oc_ethernet_INT_SOURCE)

endclass : ral_reg_oc_ethernet_INT_SOURCE


class ral_reg_oc_ethernet_INT_MASK extends uvm_ral_reg;
   rand uvm_ral_field RXC_M;
   rand uvm_ral_field TXC_M;
   rand uvm_ral_field BUSY_M;
   rand uvm_ral_field RXE_M;
   rand uvm_ral_field RXB_M;
   rand uvm_ral_field TXE_M;
   rand uvm_ral_field TXB_M;

   function new(string name = "oc_ethernet_INT_MASK");
      super.new(name, 8, uvm_ral::NO_COVERAGE);
   endfunction: new

   virtual function void build();
      this.RXC_M = uvm_ral_field::type_id::create("RXC_M",,get_full_name());
      this.RXC_M.configure(this, 1, 6, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.TXC_M = uvm_ral_field::type_id::create("TXC_M",,get_full_name());
      this.TXC_M.configure(this, 1, 5, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.BUSY_M = uvm_ral_field::type_id::create("BUSY_M",,get_full_name());
      this.BUSY_M.configure(this, 1, 4, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.RXE_M = uvm_ral_field::type_id::create("RXE_M",,get_full_name());
      this.RXE_M.configure(this, 1, 3, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.RXB_M = uvm_ral_field::type_id::create("RXB_M",,get_full_name());
      this.RXB_M.configure(this, 1, 2, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.TXE_M = uvm_ral_field::type_id::create("TXE_M",,get_full_name());
      this.TXE_M.configure(this, 1, 1, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.TXB_M = uvm_ral_field::type_id::create("TXB_M",,get_full_name());
      this.TXB_M.configure(this, 1, 0, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
   endfunction: build

   `uvm_object_utils(ral_reg_oc_ethernet_INT_MASK)

endclass : ral_reg_oc_ethernet_INT_MASK


class ral_reg_IPGT extends uvm_ral_reg;
   rand uvm_ral_field IPGT;

   function new(string name = "IPGT");
      super.new(name, 8, uvm_ral::NO_COVERAGE);
   endfunction: new

   virtual function void build();
      this.IPGT = uvm_ral_field::type_id::create("IPGT",,get_full_name());
      this.IPGT.configure(this, 7, 0, "RW", 7'h12, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
   endfunction: build

   `uvm_object_utils(ral_reg_IPGT)

endclass : ral_reg_IPGT


class ral_reg_IPGR1 extends uvm_ral_reg;
   rand uvm_ral_field IPGR1;

   function new(string name = "IPGR1");
      super.new(name, 8, uvm_ral::NO_COVERAGE);
   endfunction: new

   virtual function void build();
      this.IPGR1 = uvm_ral_field::type_id::create("IPGR1",,get_full_name());
      this.IPGR1.configure(this, 7, 0, "RW", 7'h0C, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
   endfunction: build

   `uvm_object_utils(ral_reg_IPGR1)

endclass : ral_reg_IPGR1


class ral_reg_IPGR2 extends uvm_ral_reg;
   rand uvm_ral_field IPGR2;

   function new(string name = "IPGR2");
      super.new(name, 8, uvm_ral::NO_COVERAGE);
   endfunction: new

   virtual function void build();
      this.IPGR2 = uvm_ral_field::type_id::create("IPGR2",,get_full_name());
      this.IPGR2.configure(this, 7, 0, "RW", 7'h12, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
   endfunction: build

   `uvm_object_utils(ral_reg_IPGR2)

endclass : ral_reg_IPGR2


class ral_reg_PACKETLEN extends uvm_ral_reg;
   rand uvm_ral_field MINFL;
   rand uvm_ral_field MAXFL;

   constraint MINFL_spec {
      MINFL.value == 'h40;
   }
   constraint MAXFL_spec {
      MAXFL.value == 'h600;
   }

   function new(string name = "PACKETLEN");
      super.new(name, 32, uvm_ral::NO_COVERAGE);
      Xadd_constraintsX("MINFL_spec");
      Xadd_constraintsX("MAXFL_spec");
   endfunction: new

   virtual function void build();
      this.MINFL = uvm_ral_field::type_id::create("MINFL",,get_full_name());
      this.MINFL.configure(this, 16, 16, "RW", 16'h0040, `UVM_RAL_DATA_WIDTH'hx, 1, 1);
      this.MAXFL = uvm_ral_field::type_id::create("MAXFL",,get_full_name());
      this.MAXFL.configure(this, 16, 0, "RW", 16'h0600, `UVM_RAL_DATA_WIDTH'hx, 1, 1);
   endfunction: build

   `uvm_object_utils(ral_reg_PACKETLEN)

endclass : ral_reg_PACKETLEN


class ral_reg_COLLCONF extends uvm_ral_reg;
   rand uvm_ral_field MAXRET;
   rand uvm_ral_field COLLVALID;

   function new(string name = "COLLCONF");
      super.new(name, 24, uvm_ral::NO_COVERAGE);
   endfunction: new

   virtual function void build();
      this.MAXRET = uvm_ral_field::type_id::create("MAXRET",,get_full_name());
      this.MAXRET.configure(this, 4, 16, "RW", 4'hF, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
      this.COLLVALID = uvm_ral_field::type_id::create("COLLVALID",,get_full_name());
      this.COLLVALID.configure(this, 6, 0, "RW", 6'h3F, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
   endfunction: build

   `uvm_object_utils(ral_reg_COLLCONF)

endclass : ral_reg_COLLCONF


class ral_reg_TX_BD_NUM extends uvm_ral_reg;
   rand uvm_ral_field TX_BD_NUM;

   constraint TX_BD_NUM_hardware {
      TX_BD_NUM.value <= 'h80;
   }

   function new(string name = "TX_BD_NUM");
      super.new(name, 8, uvm_ral::NO_COVERAGE);
      Xadd_constraintsX("TX_BD_NUM_hardware");
   endfunction: new

   virtual function void build();
      this.TX_BD_NUM = uvm_ral_field::type_id::create("TX_BD_NUM",,get_full_name());
      this.TX_BD_NUM.configure(this, 8, 0, "OTHER", 8'h40, `UVM_RAL_DATA_WIDTH'hx, 1, 1);
   endfunction: build

   `uvm_object_utils(ral_reg_TX_BD_NUM)

endclass : ral_reg_TX_BD_NUM


class ral_reg_CTRLMODER extends uvm_ral_reg;
   rand uvm_ral_field TXFLOW;
   rand uvm_ral_field RXFLOW;
   rand uvm_ral_field PASSALL;

   function new(string name = "CTRLMODER");
      super.new(name, 8, uvm_ral::NO_COVERAGE);
   endfunction: new

   virtual function void build();
      this.TXFLOW = uvm_ral_field::type_id::create("TXFLOW",,get_full_name());
      this.TXFLOW.configure(this, 1, 2, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.RXFLOW = uvm_ral_field::type_id::create("RXFLOW",,get_full_name());
      this.RXFLOW.configure(this, 1, 1, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.PASSALL = uvm_ral_field::type_id::create("PASSALL",,get_full_name());
      this.PASSALL.configure(this, 1, 0, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
   endfunction: build

   `uvm_object_utils(ral_reg_CTRLMODER)

endclass : ral_reg_CTRLMODER


class ral_reg_MIIMODER extends uvm_ral_reg;
   rand uvm_ral_field MIINOPRE;
   rand uvm_ral_field CLKDIV;

   function new(string name = "MIIMODER");
      super.new(name, 16, uvm_ral::NO_COVERAGE);
   endfunction: new

   virtual function void build();
      this.MIINOPRE = uvm_ral_field::type_id::create("MIINOPRE",,get_full_name());
      this.MIINOPRE.configure(this, 1, 8, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
      this.CLKDIV = uvm_ral_field::type_id::create("CLKDIV",,get_full_name());
      this.CLKDIV.configure(this, 8, 0, "RW", 8'h64, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
   endfunction: build

   `uvm_object_utils(ral_reg_MIIMODER)

endclass : ral_reg_MIIMODER


class ral_reg_MIICOMMAND extends uvm_ral_reg;
   rand uvm_ral_field WCTRLDATA;
   rand uvm_ral_field RSTAT;
   rand uvm_ral_field SCANSTAT;

   function new(string name = "MIICOMMAND");
      super.new(name, 8, uvm_ral::NO_COVERAGE);
   endfunction: new

   virtual function void build();
      this.WCTRLDATA = uvm_ral_field::type_id::create("WCTRLDATA",,get_full_name());
      this.WCTRLDATA.configure(this, 1, 2, "OTHER", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.RSTAT = uvm_ral_field::type_id::create("RSTAT",,get_full_name());
      this.RSTAT.configure(this, 1, 1, "OTHER", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.SCANSTAT = uvm_ral_field::type_id::create("SCANSTAT",,get_full_name());
      this.SCANSTAT.configure(this, 1, 0, "OTHER", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
   endfunction: build

   `uvm_object_utils(ral_reg_MIICOMMAND)

endclass : ral_reg_MIICOMMAND


class ral_reg_MIIADDRESS extends uvm_ral_reg;
   rand uvm_ral_field RGAD;
   rand uvm_ral_field FIAD;

   function new(string name = "MIIADDRESS");
      super.new(name, 16, uvm_ral::NO_COVERAGE);
   endfunction: new

   virtual function void build();
      this.RGAD = uvm_ral_field::type_id::create("RGAD",,get_full_name());
      this.RGAD.configure(this, 5, 8, "RW", 5'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
      this.FIAD = uvm_ral_field::type_id::create("FIAD",,get_full_name());
      this.FIAD.configure(this, 5, 0, "RW", 5'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
   endfunction: build

   `uvm_object_utils(ral_reg_MIIADDRESS)

endclass : ral_reg_MIIADDRESS


class ral_reg_MIITX_DATA extends uvm_ral_reg;
   rand uvm_ral_field CTRLDATA;

   function new(string name = "MIITX_DATA");
      super.new(name, 16, uvm_ral::NO_COVERAGE);
   endfunction: new

   virtual function void build();
      this.CTRLDATA = uvm_ral_field::type_id::create("CTRLDATA",,get_full_name());
      this.CTRLDATA.configure(this, 16, 0, "RW", 16'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
   endfunction: build

   `uvm_object_utils(ral_reg_MIITX_DATA)

endclass : ral_reg_MIITX_DATA


class ral_reg_MIIRX_DATA extends uvm_ral_reg;
   rand uvm_ral_field PRSD;

   function new(string name = "MIIRX_DATA");
      super.new(name, 16, uvm_ral::NO_COVERAGE);
   endfunction: new

   virtual function void build();
      this.PRSD = uvm_ral_field::type_id::create("PRSD",,get_full_name());
      this.PRSD.configure(this, 16, 0, "RU", 16'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
   endfunction: build

   `uvm_object_utils(ral_reg_MIIRX_DATA)

endclass : ral_reg_MIIRX_DATA


class ral_reg_MIISTATUS extends uvm_ral_reg;
   uvm_ral_field NVALID;
   uvm_ral_field BUSY_N;
   uvm_ral_field LINKFAIL;

   function new(string name = "MIISTATUS");
      super.new(name, 8, uvm_ral::NO_COVERAGE);
   endfunction: new

   virtual function void build();
      this.NVALID = uvm_ral_field::type_id::create("NVALID",,get_full_name());
      this.NVALID.configure(this, 1, 2, "RO", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.BUSY_N = uvm_ral_field::type_id::create("BUSY_N",,get_full_name());
      this.BUSY_N.configure(this, 1, 1, "RO", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
      this.LINKFAIL = uvm_ral_field::type_id::create("LINKFAIL",,get_full_name());
      this.LINKFAIL.configure(this, 1, 0, "RO", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 0);
   endfunction: build

   `uvm_object_utils(ral_reg_MIISTATUS)

endclass : ral_reg_MIISTATUS


class ral_reg_MAC_ADDR extends uvm_ral_reg;
   rand uvm_ral_field MAC_ADDR;

   function new(string name = "MAC_ADDR");
      super.new(name, 48, uvm_ral::NO_COVERAGE);
   endfunction: new

   virtual function void build();
      this.MAC_ADDR = uvm_ral_field::type_id::create("MAC_ADDR",,get_full_name());
      this.MAC_ADDR.configure(this, 48, 0, "RW", 48'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
   endfunction: build

   `uvm_object_utils(ral_reg_MAC_ADDR)

endclass : ral_reg_MAC_ADDR


class ral_reg_HASH0 extends uvm_ral_reg;
   rand uvm_ral_field HASH0;

   function new(string name = "HASH0");
      super.new(name, 32, uvm_ral::NO_COVERAGE);
   endfunction: new

   virtual function void build();
      this.HASH0 = uvm_ral_field::type_id::create("HASH0",,get_full_name());
      this.HASH0.configure(this, 32, 0, "RW", 32'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
   endfunction: build

   `uvm_object_utils(ral_reg_HASH0)

endclass : ral_reg_HASH0


class ral_reg_HASH1 extends uvm_ral_reg;
   rand uvm_ral_field HASH1;

   function new(string name = "HASH1");
      super.new(name, 32, uvm_ral::NO_COVERAGE);
   endfunction: new

   virtual function void build();
      this.HASH1 = uvm_ral_field::type_id::create("HASH1",,get_full_name());
      this.HASH1.configure(this, 32, 0, "RW", 32'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
   endfunction: build

   `uvm_object_utils(ral_reg_HASH1)

endclass : ral_reg_HASH1


class ral_reg_TXCTRL extends uvm_ral_reg;
   rand uvm_ral_field TXPAUSEREQ;
   rand uvm_ral_field TXPAUSETV;

   function new(string name = "TXCTRL");
      super.new(name, 24, uvm_ral::NO_COVERAGE);
   endfunction: new

   virtual function void build();
      this.TXPAUSEREQ = uvm_ral_field::type_id::create("TXPAUSEREQ",,get_full_name());
      this.TXPAUSEREQ.configure(this, 1, 16, "RW", 1'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
      this.TXPAUSETV = uvm_ral_field::type_id::create("TXPAUSETV",,get_full_name());
      this.TXPAUSETV.configure(this, 16, 0, "RW", 16'h0, `UVM_RAL_DATA_WIDTH'hx, 0, 1);
   endfunction: build

   `uvm_object_utils(ral_reg_TXCTRL)

endclass : ral_reg_TXCTRL


class ral_mem_BD extends uvm_ral_mem;
   function new(string name = "BD");
      super.new(name, `UVM_RAL_ADDR_WIDTH'h80, 64, "RW", uvm_ral::NO_COVERAGE);
   endfunction: new

   virtual function void build();
   endfunction: build

   `uvm_object_utils(ral_mem_BD)

endclass : ral_mem_BD


class ral_block_oc_ethernet extends uvm_ral_block;

   rand ral_reg_MODER MODER;
   rand ral_reg_oc_ethernet_INT_SOURCE INT_SOURCE;
   rand ral_reg_oc_ethernet_INT_MASK INT_MASK;
   rand ral_reg_IPGT IPGT;
   rand ral_reg_IPGR1 IPGR1;
   rand ral_reg_IPGR2 IPGR2;
   rand ral_reg_PACKETLEN PACKETLEN;
   rand ral_reg_COLLCONF COLLCONF;
   rand ral_reg_TX_BD_NUM TX_BD_NUM;
   rand ral_reg_CTRLMODER CTRLMODER;
   rand ral_reg_MIIMODER MIIMODER;
   rand ral_reg_MIICOMMAND MIICOMMAND;
   rand ral_reg_MIIADDRESS MIIADDRESS;
   rand ral_reg_MIITX_DATA MIITX_DATA;
   rand ral_reg_MIIRX_DATA MIIRX_DATA;
   rand ral_reg_MIISTATUS MIISTATUS;
   rand ral_reg_MAC_ADDR MAC_ADDR;
   rand ral_reg_HASH0 HASH0;
   rand ral_reg_HASH1 HASH1;
   rand ral_reg_TXCTRL TXCTRL;
   rand ral_mem_BD BD;
   rand uvm_ral_field RECSMALL;
   rand uvm_ral_field PAD;
   rand uvm_ral_field HUGEN;
   rand uvm_ral_field CRCEN;
   rand uvm_ral_field DLYCRCEN;
   rand uvm_ral_field undocumented;
   rand uvm_ral_field FULLD;
   rand uvm_ral_field EXDFREN;
   rand uvm_ral_field NOBCKOF;
   rand uvm_ral_field LOOPBCK;
   rand uvm_ral_field IFG;
   rand uvm_ral_field PRO;
   rand uvm_ral_field IAM;
   rand uvm_ral_field BRO;
   rand uvm_ral_field NOPRE;
   rand uvm_ral_field TXEN;
   rand uvm_ral_field RXEN;
   rand uvm_ral_field RXC;
   rand uvm_ral_field TXC;
   rand uvm_ral_field BUSY;
   rand uvm_ral_field RXE;
   rand uvm_ral_field RXB;
   rand uvm_ral_field TXE;
   rand uvm_ral_field TXB;
   rand uvm_ral_field RXC_M;
   rand uvm_ral_field TXC_M;
   rand uvm_ral_field BUSY_M;
   rand uvm_ral_field RXE_M;
   rand uvm_ral_field RXB_M;
   rand uvm_ral_field TXE_M;
   rand uvm_ral_field TXB_M;
   rand uvm_ral_field MINFL;
   rand uvm_ral_field MAXFL;
   rand uvm_ral_field MAXRET;
   rand uvm_ral_field COLLVALID;
   rand uvm_ral_field TXFLOW;
   rand uvm_ral_field RXFLOW;
   rand uvm_ral_field PASSALL;
   rand uvm_ral_field MIINOPRE;
   rand uvm_ral_field CLKDIV;
   rand uvm_ral_field WCTRLDATA;
   rand uvm_ral_field RSTAT;
   rand uvm_ral_field SCANSTAT;
   rand uvm_ral_field RGAD;
   rand uvm_ral_field FIAD;
   rand uvm_ral_field CTRLDATA;
   rand uvm_ral_field PRSD;
   uvm_ral_field NVALID;
   uvm_ral_field BUSY_N;
   uvm_ral_field LINKFAIL;
   rand uvm_ral_field TXPAUSEREQ;
   rand uvm_ral_field TXPAUSETV;

   function new(string name = "oc_ethernet");
      super.new(name, uvm_ral::NO_COVERAGE);
   endfunction: new

   virtual function void build();
      this.default_map = create_map("", 0, 4, uvm_ral::LITTLE_ENDIAN);
      this.MODER = ral_reg_MODER::type_id::create("MODER",,get_full_name());
      this.MODER.configure(this, null, "");
         this.MODER.add_hdl_path('{
            '{"ethreg1.MODER_2.DataOut", 16, 1},
            '{"ethreg1.MODER_1.DataOut", 8, 8},
            '{"ethreg1.MODER_0.DataOut", 0, 8}
         });
      this.default_map.add_reg(this.MODER, `UVM_RAL_ADDR_WIDTH'h0, "RW", 0);
      this.MODER.build();
      this.RECSMALL = this.MODER.RECSMALL;
      this.PAD = this.MODER.PAD;
      this.HUGEN = this.MODER.HUGEN;
      this.CRCEN = this.MODER.CRCEN;
      this.DLYCRCEN = this.MODER.DLYCRCEN;
      this.undocumented = this.MODER.undocumented;
      this.FULLD = this.MODER.FULLD;
      this.EXDFREN = this.MODER.EXDFREN;
      this.NOBCKOF = this.MODER.NOBCKOF;
      this.LOOPBCK = this.MODER.LOOPBCK;
      this.IFG = this.MODER.IFG;
      this.PRO = this.MODER.PRO;
      this.IAM = this.MODER.IAM;
      this.BRO = this.MODER.BRO;
      this.NOPRE = this.MODER.NOPRE;
      this.TXEN = this.MODER.TXEN;
      this.RXEN = this.MODER.RXEN;
      this.INT_SOURCE = ral_reg_oc_ethernet_INT_SOURCE::type_id::create("INT_SOURCE",,get_full_name());
      this.INT_SOURCE.configure(this, null, "");
         this.INT_SOURCE.add_hdl_path('{
            '{"ethreg1.irq_rxc", 6, 1},
            '{"ethreg1.irq_txc", 5, 1},
            '{"ethreg1.irq_busy", 4, 1},
            '{"ethreg1.irq_rxe", 3, 1},
            '{"ethreg1.irq_rxb", 2, 1},
            '{"ethreg1.irq_txe", 1, 1},
            '{"ethreg1.irq_txb", 0, 1}
         });
      this.default_map.add_reg(this.INT_SOURCE, `UVM_RAL_ADDR_WIDTH'h1, "RW", 0);
      this.INT_SOURCE.build();
      this.RXC = this.INT_SOURCE.RXC;
      this.TXC = this.INT_SOURCE.TXC;
      this.BUSY = this.INT_SOURCE.BUSY;
      this.RXE = this.INT_SOURCE.RXE;
      this.RXB = this.INT_SOURCE.RXB;
      this.TXE = this.INT_SOURCE.TXE;
      this.TXB = this.INT_SOURCE.TXB;
      this.INT_MASK = ral_reg_oc_ethernet_INT_MASK::type_id::create("INT_MASK",,get_full_name());
      this.INT_MASK.configure(this, null, "");
         this.INT_MASK.add_hdl_path('{
            '{"ethreg1.INT_MASK_0.DataOut", -1, -1}
         });
      this.default_map.add_reg(this.INT_MASK, `UVM_RAL_ADDR_WIDTH'h2, "RW", 0);
      this.INT_MASK.build();
      this.RXC_M = this.INT_MASK.RXC_M;
      this.TXC_M = this.INT_MASK.TXC_M;
      this.BUSY_M = this.INT_MASK.BUSY_M;
      this.RXE_M = this.INT_MASK.RXE_M;
      this.RXB_M = this.INT_MASK.RXB_M;
      this.TXE_M = this.INT_MASK.TXE_M;
      this.TXB_M = this.INT_MASK.TXB_M;
      this.IPGT = ral_reg_IPGT::type_id::create("IPGT",,get_full_name());
      this.IPGT.configure(this, null, "");
         this.IPGT.add_hdl_path('{
            '{"ethreg1.IPGT_0.DataOut", -1, -1}
         });
      this.default_map.add_reg(this.IPGT, `UVM_RAL_ADDR_WIDTH'h3, "RW", 0);
      this.IPGT.build();
      this.IPGR1 = ral_reg_IPGR1::type_id::create("IPGR1",,get_full_name());
      this.IPGR1.configure(this, null, "");
         this.IPGR1.add_hdl_path('{
            '{"ethreg1.IPGR1_0.DataOut", -1, -1}
         });
      this.default_map.add_reg(this.IPGR1, `UVM_RAL_ADDR_WIDTH'h4, "RW", 0);
      this.IPGR1.build();
      this.IPGR2 = ral_reg_IPGR2::type_id::create("IPGR2",,get_full_name());
      this.IPGR2.configure(this, null, "");
         this.IPGR2.add_hdl_path('{
            '{"ethreg1.IPGR2_0.DataOut", -1, -1}
         });
      this.default_map.add_reg(this.IPGR2, `UVM_RAL_ADDR_WIDTH'h5, "RW", 0);
      this.IPGR2.build();
      this.PACKETLEN = ral_reg_PACKETLEN::type_id::create("PACKETLEN",,get_full_name());
      this.PACKETLEN.configure(this, null, "");
         this.PACKETLEN.add_hdl_path('{
            '{"ethreg1.PACKETLEN_3.DataOut", 24, 8},
            '{"ethreg1.PACKETLEN_2.DataOut", 16, 8},
            '{"ethreg1.PACKETLEN_1.DataOut", 8, 8},
            '{"ethreg1.PACKETLEN_0.DataOut", 0, 8}
         });
      this.default_map.add_reg(this.PACKETLEN, `UVM_RAL_ADDR_WIDTH'h6, "RW", 0);
      this.PACKETLEN.build();
      this.MINFL = this.PACKETLEN.MINFL;
      this.MAXFL = this.PACKETLEN.MAXFL;
      this.COLLCONF = ral_reg_COLLCONF::type_id::create("COLLCONF",,get_full_name());
      this.COLLCONF.configure(this, null, "");
      this.default_map.add_reg(this.COLLCONF, `UVM_RAL_ADDR_WIDTH'h7, "RW", 0);
      this.COLLCONF.build();
      this.MAXRET = this.COLLCONF.MAXRET;
      this.COLLVALID = this.COLLCONF.COLLVALID;
      this.TX_BD_NUM = ral_reg_TX_BD_NUM::type_id::create("TX_BD_NUM",,get_full_name());
      this.TX_BD_NUM.configure(this, null, "");
         this.TX_BD_NUM.add_hdl_path('{
            '{"ethreg1.TX_BD_NUM_0.DataOut", -1, -1}
         });
      this.default_map.add_reg(this.TX_BD_NUM, `UVM_RAL_ADDR_WIDTH'h8, "RW", 0);
      this.TX_BD_NUM.build();
      this.CTRLMODER = ral_reg_CTRLMODER::type_id::create("CTRLMODER",,get_full_name());
      this.CTRLMODER.configure(this, null, "");
         this.CTRLMODER.add_hdl_path('{
            '{"ethreg1.CTRLMODER_0.DataOut", -1, -1}
         });
      this.default_map.add_reg(this.CTRLMODER, `UVM_RAL_ADDR_WIDTH'h9, "RW", 0);
      this.CTRLMODER.build();
      this.TXFLOW = this.CTRLMODER.TXFLOW;
      this.RXFLOW = this.CTRLMODER.RXFLOW;
      this.PASSALL = this.CTRLMODER.PASSALL;
      this.MIIMODER = ral_reg_MIIMODER::type_id::create("MIIMODER",,get_full_name());
      this.MIIMODER.configure(this, null, "");
         this.MIIMODER.add_hdl_path('{
            '{"ethreg1.MIIMODER_1.DataOut", 8, 1},
            '{"ethreg1.MIIMODER_0.DataOut", 0, 8}
         });
      this.default_map.add_reg(this.MIIMODER, `UVM_RAL_ADDR_WIDTH'hA, "RW", 0);
      this.MIIMODER.build();
      this.MIINOPRE = this.MIIMODER.MIINOPRE;
      this.CLKDIV = this.MIIMODER.CLKDIV;
      this.MIICOMMAND = ral_reg_MIICOMMAND::type_id::create("MIICOMMAND",,get_full_name());
      this.MIICOMMAND.configure(this, null, "");
         this.MIICOMMAND.add_hdl_path('{
            '{"ethreg1.MIICOMMAND2.DataOut", 2, 1},
            '{"ethreg1.MIICOMMAND1.DataOut", 1, 1},
            '{"ethreg1.MIICOMMAND0.DataOut", 0, 1}
         });
      this.default_map.add_reg(this.MIICOMMAND, `UVM_RAL_ADDR_WIDTH'hB, "RW", 0);
      this.MIICOMMAND.build();
      this.WCTRLDATA = this.MIICOMMAND.WCTRLDATA;
      this.RSTAT = this.MIICOMMAND.RSTAT;
      this.SCANSTAT = this.MIICOMMAND.SCANSTAT;
      this.MIIADDRESS = ral_reg_MIIADDRESS::type_id::create("MIIADDRESS",,get_full_name());
      this.MIIADDRESS.configure(this, null, "");
      this.default_map.add_reg(this.MIIADDRESS, `UVM_RAL_ADDR_WIDTH'hC, "RW", 0);
      this.MIIADDRESS.build();
      this.RGAD = this.MIIADDRESS.RGAD;
      this.FIAD = this.MIIADDRESS.FIAD;
      this.MIITX_DATA = ral_reg_MIITX_DATA::type_id::create("MIITX_DATA",,get_full_name());
      this.MIITX_DATA.configure(this, null, "");
         this.MIITX_DATA.add_hdl_path('{
            '{"ethreg1.MIITX_DATA_1.DataOut", 8, 8},
            '{"ethreg1.MIITX_DATA_0.DataOut", 0, 8}
         });
      this.default_map.add_reg(this.MIITX_DATA, `UVM_RAL_ADDR_WIDTH'hD, "RW", 0);
      this.MIITX_DATA.build();
      this.CTRLDATA = this.MIITX_DATA.CTRLDATA;
      this.MIIRX_DATA = ral_reg_MIIRX_DATA::type_id::create("MIIRX_DATA",,get_full_name());
      this.MIIRX_DATA.configure(this, null, "");
         this.MIIRX_DATA.add_hdl_path('{
            '{"ethreg1.MIIRX_DATA.DataOut", -1, -1}
         });
      this.default_map.add_reg(this.MIIRX_DATA, `UVM_RAL_ADDR_WIDTH'hE, "RW", 0);
      this.MIIRX_DATA.build();
      this.PRSD = this.MIIRX_DATA.PRSD;
      this.MIISTATUS = ral_reg_MIISTATUS::type_id::create("MIISTATUS",,get_full_name());
      this.MIISTATUS.configure(this, null, "");
         this.MIISTATUS.add_hdl_path('{
            '{"ethreg1.NValid_stat", 2, 1},
            '{"ethreg1.Busy_stat", 1, 1},
            '{"ethreg1.LinkFail", 0, 1}
         });
      this.default_map.add_reg(this.MIISTATUS, `UVM_RAL_ADDR_WIDTH'hF, "RW", 0);
      this.MIISTATUS.build();
      this.NVALID = this.MIISTATUS.NVALID;
      this.BUSY_N = this.MIISTATUS.BUSY_N;
      this.LINKFAIL = this.MIISTATUS.LINKFAIL;
      this.MAC_ADDR = ral_reg_MAC_ADDR::type_id::create("MAC_ADDR",,get_full_name());
      this.MAC_ADDR.configure(this, null, "");
         this.MAC_ADDR.add_hdl_path('{
            '{"ethreg1.MAC_ADDR1_1.DataOut", 40, 8},
            '{"ethreg1.MAC_ADDR1_0.DataOut", 32, 8},
            '{"ethreg1.MAC_ADDR0_3.DataOut", 24, 8},
            '{"ethreg1.MAC_ADDR0_2.DataOut", 16, 8},
            '{"ethreg1.MAC_ADDR0_1.DataOut",  8, 8},
            '{"ethreg1.MAC_ADDR0_0.DataOut",  0, 8}
         });
      this.default_map.add_reg(this.MAC_ADDR, `UVM_RAL_ADDR_WIDTH'h10, "RW", 0);
      this.MAC_ADDR.build();
      this.HASH0 = ral_reg_HASH0::type_id::create("HASH0",,get_full_name());
      this.HASH0.configure(this, null, "");
         this.HASH0.add_hdl_path('{
            '{"ethreg1.RXHASH0_3.DataOut", 24, 8},
            '{"ethreg1.RXHASH0_2.DataOut", 16, 8},
            '{"ethreg1.RXHASH0_1.DataOut",  8, 8},
            '{"ethreg1.RXHASH0_0.DataOut",  0, 8}
         });
      this.default_map.add_reg(this.HASH0, `UVM_RAL_ADDR_WIDTH'h12, "RW", 0);
      this.HASH0.build();
      this.HASH1 = ral_reg_HASH1::type_id::create("HASH1",,get_full_name());
      this.HASH1.configure(this, null, "");
         this.HASH1.add_hdl_path('{
            '{"ethreg1.RXHASH1_3.DataOut", 24, 8},
            '{"ethreg1.RXHASH1_2.DataOut", 16, 8},
            '{"ethreg1.RXHASH1_1.DataOut",  8, 8},
            '{"ethreg1.RXHASH1_0.DataOut",  0, 8}
         });
      this.default_map.add_reg(this.HASH1, `UVM_RAL_ADDR_WIDTH'h13, "RW", 0);
      this.HASH1.build();
      this.TXCTRL = ral_reg_TXCTRL::type_id::create("TXCTRL",,get_full_name());
      this.TXCTRL.configure(this, null, "");
         this.TXCTRL.add_hdl_path('{
            '{"ethreg1.TXCTRL_2.DataOut", 16, 1},
            '{"ethreg1.TXCTRL_1.DataOut",  8, 8},
            '{"ethreg1.TXCTRL_0.DataOut",  0, 8}
         });
      this.default_map.add_reg(this.TXCTRL, `UVM_RAL_ADDR_WIDTH'h14, "RW", 0);
      this.TXCTRL.build();
      this.TXPAUSEREQ = this.TXCTRL.TXPAUSEREQ;
      this.TXPAUSETV = this.TXCTRL.TXPAUSETV;
      this.BD = ral_mem_BD::type_id::create("BD",,get_full_name());
      this.BD.configure(this, "wishbone.bd_ram.mem");
      this.default_map.add_mem(this.BD, `UVM_RAL_ADDR_WIDTH'h100, "RW", 0);
      this.BD.build();
      this.Xlock_modelX();
   endfunction : build

   `uvm_object_utils(ral_block_oc_ethernet)

endclass : ral_block_oc_ethernet



`endif
