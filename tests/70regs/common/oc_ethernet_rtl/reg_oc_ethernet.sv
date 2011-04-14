//
//------------------------------------------------------------------------------
//   Copyright 2011 (Authors)
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------------------------

`ifndef REG_OC_ETHERNET
`define REG_OC_ETHERNET

import uvm_pkg::*;

class reg_reg_MODER extends uvm_reg;
    rand uvm_reg_field RECSMALL;
    rand uvm_reg_field PAD;
    rand uvm_reg_field HUGEN;
    rand uvm_reg_field CRCEN;
    rand uvm_reg_field DLYCRCEN;
    rand uvm_reg_field undocumented;
    rand uvm_reg_field FULLD;
    rand uvm_reg_field EXDFREN;
    rand uvm_reg_field NOBCKOF;
    rand uvm_reg_field LOOPBCK;
    rand uvm_reg_field IFG;
    rand uvm_reg_field PRO;
    rand uvm_reg_field IAM;
    rand uvm_reg_field BRO;
    rand uvm_reg_field NOPRE;
    rand uvm_reg_field TXEN;
    rand uvm_reg_field RXEN;

    function new(string name = "MODER");
        super.new(name, 24, UVM_NO_COVERAGE);
    endfunction: new

    virtual function void build();
        this.RECSMALL = uvm_reg_field::type_id::create("RECSMALL",,get_full_name());
        this.RECSMALL.configure(this, 1, 16, "RW", 0, 1'h0, 1, 0, 1);
        this.PAD = uvm_reg_field::type_id::create("PAD",,get_full_name());
        this.PAD.configure(this, 1, 15, "RW", 0, 1, 1, 0, 0);
        this.HUGEN = uvm_reg_field::type_id::create("HUGEN",,get_full_name());
        this.HUGEN.configure(this, 1, 14, "RW", 0, 1'h0, 1, 0, 0);
        this.CRCEN = uvm_reg_field::type_id::create("CRCEN",,get_full_name());
        this.CRCEN.configure(this, 1, 13, "RW", 0, 1, 1, 0, 0);
        this.DLYCRCEN = uvm_reg_field::type_id::create("DLYCRCEN",,get_full_name());
        this.DLYCRCEN.configure(this, 1, 12, "RW", 0, 1'h0, 1, 0, 0);
        this.undocumented = uvm_reg_field::type_id::create("undocumented",,get_full_name());
        this.undocumented.configure(this, 1, 11, "RW", 0, 1'h0, 1, 0, 0);
        this.undocumented.set_compare(UVM_NO_CHECK);
        this.FULLD = uvm_reg_field::type_id::create("FULLD",,get_full_name());
        this.FULLD.configure(this, 1, 10, "RW", 0, 1'h0, 1, 0, 0);
        this.EXDFREN = uvm_reg_field::type_id::create("EXDFREN",,get_full_name());
        this.EXDFREN.configure(this, 1, 9, "RW", 0, 1'h0, 1, 0, 0);
        this.NOBCKOF = uvm_reg_field::type_id::create("NOBCKOF",,get_full_name());
        this.NOBCKOF.configure(this, 1, 8, "RW", 0, 1'h0, 1, 0, 0);
        this.LOOPBCK = uvm_reg_field::type_id::create("LOOPBCK",,get_full_name());
        this.LOOPBCK.configure(this, 1, 7, "RW", 0, 1'h0, 1, 0, 0);
        this.IFG = uvm_reg_field::type_id::create("IFG",,get_full_name());
        this.IFG.configure(this, 1, 6, "RW", 0, 1'h0, 1, 0, 0);
        this.PRO = uvm_reg_field::type_id::create("PRO",,get_full_name());
        this.PRO.configure(this, 1, 5, "RW", 0, 1'h0, 1, 0, 0);
        this.IAM = uvm_reg_field::type_id::create("IAM",,get_full_name());
        this.IAM.configure(this, 1, 4, "RW", 0, 1'h0, 1, 0, 0);
        this.BRO = uvm_reg_field::type_id::create("BRO",,get_full_name());
        this.BRO.configure(this, 1, 3, "RW", 0, 1'h0, 1, 0, 0);
        this.NOPRE = uvm_reg_field::type_id::create("NOPRE",,get_full_name());
        this.NOPRE.configure(this, 1, 2, "RW", 0, 1'h0, 1, 0, 0);
        this.TXEN = uvm_reg_field::type_id::create("TXEN",,get_full_name());
        this.TXEN.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
        this.RXEN = uvm_reg_field::type_id::create("RXEN",,get_full_name());
        this.RXEN.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
    endfunction: build

    `uvm_object_utils(reg_reg_MODER)

endclass : reg_reg_MODER


class reg_reg_oc_ethernet_INT_SOURCE extends uvm_reg;
    rand uvm_reg_field RXC;
    rand uvm_reg_field TXC;
    rand uvm_reg_field BUSY;
    rand uvm_reg_field RXE;
    rand uvm_reg_field RXB;
    rand uvm_reg_field TXE;
    rand uvm_reg_field TXB;

    function new(string name = "oc_ethernet_INT_SOURCE");
        super.new(name, 8, UVM_NO_COVERAGE);
    endfunction: new

    virtual function void build();
        this.RXC = uvm_reg_field::type_id::create("RXC",,get_full_name());
        this.RXC.configure(this, 1, 6, "W1C", 1, 1'h0, 1, 0, 0);
        this.TXC = uvm_reg_field::type_id::create("TXC",,get_full_name());
        this.TXC.configure(this, 1, 5, "W1C", 1, 1'h0, 1, 0, 0);
        this.BUSY = uvm_reg_field::type_id::create("BUSY",,get_full_name());
        this.BUSY.configure(this, 1, 4, "W1C", 1, 1'h0, 1, 0, 0);
        this.RXE = uvm_reg_field::type_id::create("RXE",,get_full_name());
        this.RXE.configure(this, 1, 3, "W1C", 1, 1'h0, 1, 0, 0);
        this.RXB = uvm_reg_field::type_id::create("RXB",,get_full_name());
        this.RXB.configure(this, 1, 2, "W1C", 1, 1'h0, 1, 0, 0);
        this.TXE = uvm_reg_field::type_id::create("TXE",,get_full_name());
        this.TXE.configure(this, 1, 1, "W1C", 1, 1'h0, 1, 0, 0);
        this.TXB = uvm_reg_field::type_id::create("TXB",,get_full_name());
        this.TXB.configure(this, 1, 0, "W1C", 1, 1'h0, 1, 0, 0);
    endfunction: build

    `uvm_object_utils(reg_reg_oc_ethernet_INT_SOURCE)

endclass : reg_reg_oc_ethernet_INT_SOURCE


class reg_reg_oc_ethernet_INT_MASK extends uvm_reg;
    rand uvm_reg_field RXC_M;
    rand uvm_reg_field TXC_M;
    rand uvm_reg_field BUSY_M;
    rand uvm_reg_field RXE_M;
    rand uvm_reg_field RXB_M;
    rand uvm_reg_field TXE_M;
    rand uvm_reg_field TXB_M;

    function new(string name = "oc_ethernet_INT_MASK");
        super.new(name, 8, UVM_NO_COVERAGE);
    endfunction: new

    virtual function void build();
        this.RXC_M = uvm_reg_field::type_id::create("RXC_M",,get_full_name());
        this.RXC_M.configure(this, 1, 6, "RW", 0, 1'h0, 1, 0, 0);
        this.TXC_M = uvm_reg_field::type_id::create("TXC_M",,get_full_name());
        this.TXC_M.configure(this, 1, 5, "RW", 0, 1'h0, 1, 0, 0);
        this.BUSY_M = uvm_reg_field::type_id::create("BUSY_M",,get_full_name());
        this.BUSY_M.configure(this, 1, 4, "RW", 0, 1'h0, 1, 0, 0);
        this.RXE_M = uvm_reg_field::type_id::create("RXE_M",,get_full_name());
        this.RXE_M.configure(this, 1, 3, "RW", 0, 1'h0, 1, 0, 0);
        this.RXB_M = uvm_reg_field::type_id::create("RXB_M",,get_full_name());
        this.RXB_M.configure(this, 1, 2, "RW", 0, 1'h0, 1, 0, 0);
        this.TXE_M = uvm_reg_field::type_id::create("TXE_M",,get_full_name());
        this.TXE_M.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
        this.TXB_M = uvm_reg_field::type_id::create("TXB_M",,get_full_name());
        this.TXB_M.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
    endfunction: build

    `uvm_object_utils(reg_reg_oc_ethernet_INT_MASK)

endclass : reg_reg_oc_ethernet_INT_MASK


class reg_reg_IPGT extends uvm_reg;
    rand uvm_reg_field IPGT;

    function new(string name = "IPGT");
        super.new(name, 8, UVM_NO_COVERAGE);
    endfunction: new

    virtual function void build();
        this.IPGT = uvm_reg_field::type_id::create("IPGT",,get_full_name());
        this.IPGT.configure(this, 7, 0, "RW", 0, 7'h12, 1, 0, 1);
    endfunction: build

    `uvm_object_utils(reg_reg_IPGT)

endclass : reg_reg_IPGT


class reg_reg_IPGR1 extends uvm_reg;
    rand uvm_reg_field IPGR1;

    function new(string name = "IPGR1");
        super.new(name, 8, UVM_NO_COVERAGE);
    endfunction: new

    virtual function void build();
        this.IPGR1 = uvm_reg_field::type_id::create("IPGR1",,get_full_name());
        this.IPGR1.configure(this, 7, 0, "RW", 0, 7'h0C, 1, 0, 1);
    endfunction: build

    `uvm_object_utils(reg_reg_IPGR1)

endclass : reg_reg_IPGR1


class reg_reg_IPGR2 extends uvm_reg;
    rand uvm_reg_field IPGR2;

    function new(string name = "IPGR2");
        super.new(name, 8, UVM_NO_COVERAGE);
    endfunction: new

    virtual function void build();
        this.IPGR2 = uvm_reg_field::type_id::create("IPGR2",,get_full_name());
        this.IPGR2.configure(this, 7, 0, "RW", 0, 7'h12, 1, 0, 1);
    endfunction: build

    `uvm_object_utils(reg_reg_IPGR2)

endclass : reg_reg_IPGR2


class reg_reg_PACKETLEN extends uvm_reg;
   rand uvm_reg_field MINFL;
   rand uvm_reg_field MAXFL;

   constraint MINFL_spec {
      MINFL.value == 'h40;
   }
   constraint MAXFL_spec {
      MAXFL.value == 'h600;
   }

   function new(string name = "PACKETLEN");
      super.new(name, 32, UVM_NO_COVERAGE);
   endfunction: new

   virtual function void build();
      this.MINFL = uvm_reg_field::type_id::create("MINFL",,get_full_name());
      this.MINFL.configure(this, 16, 16, "RW", 0, 16'h0040, 1, 1, 1);
      this.MAXFL = uvm_reg_field::type_id::create("MAXFL",,get_full_name());
      this.MAXFL.configure(this, 16, 0, "RW", 0, 16'h0600, 1, 1, 1);
   endfunction: build

   `uvm_object_utils(reg_reg_PACKETLEN)

endclass : reg_reg_PACKETLEN


class reg_reg_COLLCONF extends uvm_reg;
    rand uvm_reg_field MAXRET;
    rand uvm_reg_field COLLVALID;

    function new(string name = "COLLCONF");
        super.new(name, 24, UVM_NO_COVERAGE);
    endfunction: new

    virtual function void build();
        this.MAXRET = uvm_reg_field::type_id::create("MAXRET",,get_full_name());
        this.MAXRET.configure(this, 4, 16, "RW", 0, 4'hF, 1, 0, 1);
        this.COLLVALID = uvm_reg_field::type_id::create("COLLVALID",,get_full_name());
        this.COLLVALID.configure(this, 6, 0, "RW", 0, 6'h3F, 1, 0, 1);
    endfunction: build

    `uvm_object_utils(reg_reg_COLLCONF)

endclass : reg_reg_COLLCONF


class reg_reg_TX_BD_NUM extends uvm_reg;
    rand uvm_reg_field TX_BD_NUM;

    constraint TX_BD_NUM_hardware {
        TX_BD_NUM.value <= 'h80;
    }

   function new(string name = "TX_BD_NUM");
      super.new(name, 8, UVM_NO_COVERAGE);
   endfunction: new

    virtual function void build();
       this.TX_BD_NUM = uvm_reg_field::type_id::create("TX_BD_NUM",,get_full_name());
       this.TX_BD_NUM.configure(this, 8, 0, "RW", 0, 8'h40, 1, 1, 1);
       uvm_resource_db#(bit)::set({"REG::",get_full_name()},
                                  "NO_REG_TESTS", 1);
    endfunction: build

    `uvm_object_utils(reg_reg_TX_BD_NUM)

endclass : reg_reg_TX_BD_NUM


class reg_reg_CTRLMODER extends uvm_reg;
    rand uvm_reg_field TXFLOW;
    rand uvm_reg_field RXFLOW;
    rand uvm_reg_field PASSALL;

    function new(string name = "CTRLMODER");
        super.new(name, 8, UVM_NO_COVERAGE);
    endfunction: new

    virtual function void build();
        this.TXFLOW = uvm_reg_field::type_id::create("TXFLOW",,get_full_name());
        this.TXFLOW.configure(this, 1, 2, "RW", 0, 1'h0, 1, 0, 0);
        this.RXFLOW = uvm_reg_field::type_id::create("RXFLOW",,get_full_name());
        this.RXFLOW.configure(this, 1, 1, "RW", 0, 1'h0, 1, 0, 0);
        this.PASSALL = uvm_reg_field::type_id::create("PASSALL",,get_full_name());
        this.PASSALL.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
    endfunction: build

    `uvm_object_utils(reg_reg_CTRLMODER)

endclass : reg_reg_CTRLMODER


class reg_reg_MIIMODER extends uvm_reg;
    rand uvm_reg_field MIINOPRE;
    rand uvm_reg_field CLKDIV;

    function new(string name = "MIIMODER");
        super.new(name, 16, UVM_NO_COVERAGE);
    endfunction: new

    virtual function void build();
        this.MIINOPRE = uvm_reg_field::type_id::create("MIINOPRE",,get_full_name());
        this.MIINOPRE.configure(this, 1, 8, "RW", 0, 1'h0, 1, 0, 1);
        this.CLKDIV = uvm_reg_field::type_id::create("CLKDIV",,get_full_name());
        this.CLKDIV.configure(this, 8, 0, "RW", 0, 8'h64, 1, 0, 1);
    endfunction: build

    `uvm_object_utils(reg_reg_MIIMODER)

endclass : reg_reg_MIIMODER


class reg_reg_MIICOMMAND extends uvm_reg;
    rand uvm_reg_field WCTRLDATA;
    rand uvm_reg_field RSTAT;
    rand uvm_reg_field SCANSTAT;

    function new(string name = "MIICOMMAND");
        super.new(name, 8, UVM_NO_COVERAGE);
    endfunction: new

    virtual function void build();
        this.WCTRLDATA = uvm_reg_field::type_id::create("WCTRLDATA",,get_full_name());
        this.WCTRLDATA.configure(this, 1, 2, "RW", 1, 1'h0, 1, 0, 0);
        this.WCTRLDATA.set_compare(UVM_NO_CHECK);
        this.RSTAT = uvm_reg_field::type_id::create("RSTAT",,get_full_name());
        this.RSTAT.configure(this, 1, 1, "RW", 1, 1'h0, 1, 0, 0);
        this.RSTAT.set_compare(UVM_NO_CHECK);
        this.SCANSTAT = uvm_reg_field::type_id::create("SCANSTAT",,get_full_name());
        this.SCANSTAT.configure(this, 1, 0, "RW", 1, 1'h0, 1, 0, 0);
        this.SCANSTAT.set_compare(UVM_NO_CHECK);
    endfunction: build

    `uvm_object_utils(reg_reg_MIICOMMAND)

endclass : reg_reg_MIICOMMAND


class reg_reg_MIIADDRESS extends uvm_reg;
    rand uvm_reg_field RGAD;
    rand uvm_reg_field FIAD;

    function new(string name = "MIIADDRESS");
        super.new(name, 16, UVM_NO_COVERAGE);
    endfunction: new

    virtual function void build();
        this.RGAD = uvm_reg_field::type_id::create("RGAD",,get_full_name());
        this.RGAD.configure(this, 5, 8, "RW", 0, 5'h0, 1, 0, 1);
        this.FIAD = uvm_reg_field::type_id::create("FIAD",,get_full_name());
        this.FIAD.configure(this, 5, 0, "RW", 0, 5'h0, 1, 0, 1);
    endfunction: build

    `uvm_object_utils(reg_reg_MIIADDRESS)

endclass : reg_reg_MIIADDRESS


class reg_reg_MIITX_DATA extends uvm_reg;
    rand uvm_reg_field CTRLDATA;

    function new(string name = "MIITX_DATA");
        super.new(name, 16, UVM_NO_COVERAGE);
    endfunction: new

    virtual function void build();
        this.CTRLDATA = uvm_reg_field::type_id::create("CTRLDATA",,get_full_name());
        this.CTRLDATA.configure(this, 16, 0, "RW", 0, 16'h0, 1, 0, 1);
    endfunction: build

    `uvm_object_utils(reg_reg_MIITX_DATA)

endclass : reg_reg_MIITX_DATA


class reg_reg_MIIRX_DATA extends uvm_reg;
    rand uvm_reg_field PRSD;

    function new(string name = "MIIRX_DATA");
        super.new(name, 16, UVM_NO_COVERAGE);
    endfunction: new

    virtual function void build();
        this.PRSD = uvm_reg_field::type_id::create("PRSD",,get_full_name());
        this.PRSD.configure(this, 16, 0, "RO", 1, 16'h0, 1, 0, 1);
    endfunction: build

    `uvm_object_utils(reg_reg_MIIRX_DATA)

endclass : reg_reg_MIIRX_DATA


class reg_reg_MIISTATUS extends uvm_reg;
    uvm_reg_field NVALID;
    uvm_reg_field BUSY_N;
    uvm_reg_field LINKFAIL;

    function new(string name = "MIISTATUS");
        super.new(name, 8, UVM_NO_COVERAGE);
    endfunction: new

    virtual function void build();
        this.NVALID = uvm_reg_field::type_id::create("NVALID",,get_full_name());
        this.NVALID.configure(this, 1, 2, "RO", 1, 1'h0, 1, 0, 0);
        this.BUSY_N = uvm_reg_field::type_id::create("BUSY_N",,get_full_name());
        this.BUSY_N.configure(this, 1, 1, "RO", 1, 1'h0, 1, 0, 0);
        this.LINKFAIL = uvm_reg_field::type_id::create("LINKFAIL",,get_full_name());
        this.LINKFAIL.configure(this, 1, 0, "RO", 1, 1'h0, 1, 0, 0);
    endfunction: build

    `uvm_object_utils(reg_reg_MIISTATUS)

endclass : reg_reg_MIISTATUS


class reg_reg_MAC_ADDR extends uvm_reg;
    rand uvm_reg_field MAC_ADDR;

    function new(string name = "MAC_ADDR");
        super.new(name, 48, UVM_NO_COVERAGE);
    endfunction: new

    virtual function void build();
        this.MAC_ADDR = uvm_reg_field::type_id::create("MAC_ADDR",,get_full_name());
        this.MAC_ADDR.configure(this, 48, 0, "RW", 0, 48'h0, 1, 0, 1);
    endfunction: build

    `uvm_object_utils(reg_reg_MAC_ADDR)

endclass : reg_reg_MAC_ADDR


class reg_reg_HASH0 extends uvm_reg;
    rand uvm_reg_field HASH0;

    function new(string name = "HASH0");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction: new

    virtual function void build();
        this.HASH0 = uvm_reg_field::type_id::create("HASH0",,get_full_name());
        this.HASH0.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
    endfunction: build

    `uvm_object_utils(reg_reg_HASH0)

endclass : reg_reg_HASH0


class reg_reg_HASH1 extends uvm_reg;
    rand uvm_reg_field HASH1;

    function new(string name = "HASH1");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction: new

    virtual function void build();
        this.HASH1 = uvm_reg_field::type_id::create("HASH1",,get_full_name());
        this.HASH1.configure(this, 32, 0, "RW", 0, 32'h0, 1, 0, 1);
    endfunction: build

    `uvm_object_utils(reg_reg_HASH1)

endclass : reg_reg_HASH1


class reg_reg_TXCTRL extends uvm_reg;
    rand uvm_reg_field TXPAUSEREQ;
    rand uvm_reg_field TXPAUSETV;

    function new(string name = "TXCTRL");
        super.new(name, 24, UVM_NO_COVERAGE);
    endfunction: new

    virtual function void build();
        this.TXPAUSEREQ = uvm_reg_field::type_id::create("TXPAUSEREQ",,get_full_name());
        this.TXPAUSEREQ.configure(this, 1, 16, "RW", 0, 1'h0, 1, 0, 1);
        this.TXPAUSETV = uvm_reg_field::type_id::create("TXPAUSETV",,get_full_name());
        this.TXPAUSETV.configure(this, 16, 0, "RW", 0, 16'h0, 1, 0, 1);
    endfunction: build

    `uvm_object_utils(reg_reg_TXCTRL)

endclass : reg_reg_TXCTRL


class reg_mem_BD extends uvm_mem;
    function new(string name = "BD");
        super.new(name, `UVM_REG_ADDR_WIDTH'h80, 64, "RW", UVM_NO_COVERAGE);
    endfunction: new

    virtual function void build();
    endfunction: build

    `uvm_object_utils(reg_mem_BD)

endclass : reg_mem_BD


class reg_block_oc_ethernet extends uvm_reg_block;

    rand reg_reg_MODER MODER;
    rand reg_reg_oc_ethernet_INT_SOURCE INT_SOURCE;
    rand reg_reg_oc_ethernet_INT_MASK INT_MASK;
    rand reg_reg_IPGT IPGT;
    rand reg_reg_IPGR1 IPGR1;
    rand reg_reg_IPGR2 IPGR2;
    rand reg_reg_PACKETLEN PACKETLEN;
    rand reg_reg_COLLCONF COLLCONF;
    rand reg_reg_TX_BD_NUM TX_BD_NUM;
    rand reg_reg_CTRLMODER CTRLMODER;
    rand reg_reg_MIIMODER MIIMODER;
    rand reg_reg_MIICOMMAND MIICOMMAND;
    rand reg_reg_MIIADDRESS MIIADDRESS;
    rand reg_reg_MIITX_DATA MIITX_DATA;
    rand reg_reg_MIIRX_DATA MIIRX_DATA;
    rand reg_reg_MIISTATUS MIISTATUS;
    rand reg_reg_MAC_ADDR MAC_ADDR;
    rand reg_reg_HASH0 HASH0;
    rand reg_reg_HASH1 HASH1;
    rand reg_reg_TXCTRL TXCTRL;
    rand reg_mem_BD BD;
    rand uvm_reg_field RECSMALL;
    rand uvm_reg_field PAD;
    rand uvm_reg_field HUGEN;
    rand uvm_reg_field CRCEN;
    rand uvm_reg_field DLYCRCEN;
    rand uvm_reg_field undocumented;
    rand uvm_reg_field FULLD;
    rand uvm_reg_field EXDFREN;
    rand uvm_reg_field NOBCKOF;
    rand uvm_reg_field LOOPBCK;
    rand uvm_reg_field IFG;
    rand uvm_reg_field PRO;
    rand uvm_reg_field IAM;
    rand uvm_reg_field BRO;
    rand uvm_reg_field NOPRE;
    rand uvm_reg_field TXEN;
    rand uvm_reg_field RXEN;
    rand uvm_reg_field RXC;
    rand uvm_reg_field TXC;
    rand uvm_reg_field BUSY;
    rand uvm_reg_field RXE;
    rand uvm_reg_field RXB;
    rand uvm_reg_field TXE;
    rand uvm_reg_field TXB;
    rand uvm_reg_field RXC_M;
    rand uvm_reg_field TXC_M;
    rand uvm_reg_field BUSY_M;
    rand uvm_reg_field RXE_M;
    rand uvm_reg_field RXB_M;
    rand uvm_reg_field TXE_M;
    rand uvm_reg_field TXB_M;
    rand uvm_reg_field MINFL;
    rand uvm_reg_field MAXFL;
    rand uvm_reg_field MAXRET;
    rand uvm_reg_field COLLVALID;
    rand uvm_reg_field TXFLOW;
    rand uvm_reg_field RXFLOW;
    rand uvm_reg_field PASSALL;
    rand uvm_reg_field MIINOPRE;
    rand uvm_reg_field CLKDIV;
    rand uvm_reg_field WCTRLDATA;
    rand uvm_reg_field RSTAT;
    rand uvm_reg_field SCANSTAT;
    rand uvm_reg_field RGAD;
    rand uvm_reg_field FIAD;
    rand uvm_reg_field CTRLDATA;
    rand uvm_reg_field PRSD;
    uvm_reg_field NVALID;
    uvm_reg_field BUSY_N;
    uvm_reg_field LINKFAIL;
    rand uvm_reg_field TXPAUSEREQ;
    rand uvm_reg_field TXPAUSETV;

    function new(string name = "oc_ethernet");
        super.new(name, UVM_NO_COVERAGE);
    endfunction: new

    virtual function void build();
        this.default_map = create_map("", 0, 4, UVM_LITTLE_ENDIAN, 0);
        this.MODER = reg_reg_MODER::type_id::create("MODER",,get_full_name());
        this.MODER.configure(this, null, "");

`ifdef USE_SLICE_API
        this.MODER.add_hdl_path_slice("ethreg1.MODER_2.DataOut", 16, 1,1);
        this.MODER.add_hdl_path_slice("ethreg1.MODER_1.DataOut", 8, 8);
        this.MODER.add_hdl_path_slice("ethreg1.MODER_0.DataOut", 0, 8);
`else
        this.MODER.add_hdl_path('{
                '{"ethreg1.MODER_2.DataOut", 16, 1},
                '{"ethreg1.MODER_1.DataOut", 8, 8},
                '{"ethreg1.MODER_0.DataOut", 0, 8}
            });
`endif

         
        this.default_map.add_reg(this.MODER, `UVM_REG_ADDR_WIDTH'h0, "RW", 0);
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
        this.INT_SOURCE = reg_reg_oc_ethernet_INT_SOURCE::type_id::create("INT_SOURCE",,get_full_name());
        this.INT_SOURCE.configure(this, null, "");
`ifdef USE_SLICE_API
        this.INT_SOURCE.add_hdl_path_slice("ethreg1.irq_rxc", 6, 1,1);
        this.INT_SOURCE.add_hdl_path_slice("ethreg1.irq_txc", 5, 1);
        this.INT_SOURCE.add_hdl_path_slice("ethreg1.irq_busy", 4, 1);
        this.INT_SOURCE.add_hdl_path_slice("ethreg1.irq_rxe", 3, 1);
        this.INT_SOURCE.add_hdl_path_slice("ethreg1.irq_rxb", 2, 1);
        this.INT_SOURCE.add_hdl_path_slice("ethreg1.irq_txe", 1, 1);
        this.INT_SOURCE.add_hdl_path_slice("ethreg1.irq_txb", 0, 1);
`else
         	
        this.INT_SOURCE.add_hdl_path('{
                '{"ethreg1.irq_rxc", 6, 1},
                '{"ethreg1.irq_txc", 5, 1},
                '{"ethreg1.irq_busy", 4, 1},
                '{"ethreg1.irq_rxe", 3, 1},
                '{"ethreg1.irq_rxb", 2, 1},
                '{"ethreg1.irq_txe", 1, 1},
                '{"ethreg1.irq_txb", 0, 1}
            });
`endif

        this.default_map.add_reg(this.INT_SOURCE, `UVM_REG_ADDR_WIDTH'h1, "RW", 0);
        this.INT_SOURCE.build();
        this.RXC = this.INT_SOURCE.RXC;
        this.TXC = this.INT_SOURCE.TXC;
        this.BUSY = this.INT_SOURCE.BUSY;
        this.RXE = this.INT_SOURCE.RXE;
        this.RXB = this.INT_SOURCE.RXB;
        this.TXE = this.INT_SOURCE.TXE;
        this.TXB = this.INT_SOURCE.TXB;
        this.INT_MASK = reg_reg_oc_ethernet_INT_MASK::type_id::create("INT_MASK",,get_full_name());
        this.INT_MASK.configure(this, null, "");
`ifdef USE_SLICE_API
        this.INT_MASK.add_hdl_path_slice("ethreg1.INT_MASK_0.DataOut", -1, -1,1);
`else
        this.INT_MASK.add_hdl_path('{
                '{"ethreg1.INT_MASK_0.DataOut", -1, -1}
            });
`endif

        this.default_map.add_reg(this.INT_MASK, `UVM_REG_ADDR_WIDTH'h2, "RW", 0);
        this.INT_MASK.build();
        this.RXC_M = this.INT_MASK.RXC_M;
        this.TXC_M = this.INT_MASK.TXC_M;
        this.BUSY_M = this.INT_MASK.BUSY_M;
        this.RXE_M = this.INT_MASK.RXE_M;
        this.RXB_M = this.INT_MASK.RXB_M;
        this.TXE_M = this.INT_MASK.TXE_M;
        this.TXB_M = this.INT_MASK.TXB_M;
        this.IPGT = reg_reg_IPGT::type_id::create("IPGT",,get_full_name());
        this.IPGT.configure(this, null, "");
`ifdef USE_SLICE_API
        this.IPGT.add_hdl_path_slice("ethreg1.IPGT_0.DataOut", -1, -1,1);
`else
        this.IPGT.add_hdl_path('{
                '{"ethreg1.IPGT_0.DataOut", -1, -1}
            });
`endif

        this.default_map.add_reg(this.IPGT, `UVM_REG_ADDR_WIDTH'h3, "RW", 0);
        this.IPGT.build();
        this.IPGR1 = reg_reg_IPGR1::type_id::create("IPGR1",,get_full_name());
        this.IPGR1.configure(this, null, "");
`ifdef USE_SLICE_API
        this.IPGR1.add_hdl_path_slice("ethreg1.IPGR1_0.DataOut", -1, -1,1);
`else
        this.IPGR1.add_hdl_path('{
                '{"ethreg1.IPGR1_0.DataOut", -1, -1}
            });
`endif

        this.default_map.add_reg(this.IPGR1, `UVM_REG_ADDR_WIDTH'h4, "RW", 0);
        this.IPGR1.build();
        this.IPGR2 = reg_reg_IPGR2::type_id::create("IPGR2",,get_full_name());
        this.IPGR2.configure(this, null, "");
`ifdef USE_SLICE_API
        this.IPGR2.add_hdl_path_slice("ethreg1.IPGR2_0.DataOut", -1, -1,1);
`else
        this.IPGR2.add_hdl_path('{
                '{"ethreg1.IPGR2_0.DataOut", -1, -1}
            });
`endif

        this.default_map.add_reg(this.IPGR2, `UVM_REG_ADDR_WIDTH'h5, "RW", 0);
        this.IPGR2.build();
        this.PACKETLEN = reg_reg_PACKETLEN::type_id::create("PACKETLEN",,get_full_name());
        this.PACKETLEN.configure(this, null, "");
`ifdef USE_SLICE_API
        this.PACKETLEN.add_hdl_path_slice("ethreg1.PACKETLEN_3.DataOut", 24, 8,1);
        this.PACKETLEN.add_hdl_path_slice("ethreg1.PACKETLEN_2.DataOut", 16, 8);
        this.PACKETLEN.add_hdl_path_slice("ethreg1.PACKETLEN_1.DataOut", 8, 8);
        this.PACKETLEN.add_hdl_path_slice("ethreg1.PACKETLEN_0.DataOut", 0, 8);
`else
        this.PACKETLEN.add_hdl_path('{
                '{"ethreg1.PACKETLEN_3.DataOut", 24, 8},
                '{"ethreg1.PACKETLEN_2.DataOut", 16, 8},
                '{"ethreg1.PACKETLEN_1.DataOut", 8, 8},
                '{"ethreg1.PACKETLEN_0.DataOut", 0, 8}
            });
`endif

        this.default_map.add_reg(this.PACKETLEN, `UVM_REG_ADDR_WIDTH'h6, "RW", 0);
        this.PACKETLEN.build();
        this.MINFL = this.PACKETLEN.MINFL;
        this.MAXFL = this.PACKETLEN.MAXFL;
        this.COLLCONF = reg_reg_COLLCONF::type_id::create("COLLCONF",,get_full_name());
        this.COLLCONF.configure(this, null, "");
        this.default_map.add_reg(this.COLLCONF, `UVM_REG_ADDR_WIDTH'h7, "RW", 0);
        this.COLLCONF.build();
        this.MAXRET = this.COLLCONF.MAXRET;
        this.COLLVALID = this.COLLCONF.COLLVALID;
        this.TX_BD_NUM = reg_reg_TX_BD_NUM::type_id::create("TX_BD_NUM",,get_full_name());
        this.TX_BD_NUM.configure(this, null, "");
`ifdef USE_SLICE_API
        this.TX_BD_NUM.add_hdl_path_slice("ethreg1.TX_BD_NUM_0.DataOut", -1, -1,1);
`else
        this.TX_BD_NUM.add_hdl_path('{
                '{"ethreg1.TX_BD_NUM_0.DataOut", -1, -1}
            });
`endif

        this.default_map.add_reg(this.TX_BD_NUM, `UVM_REG_ADDR_WIDTH'h8, "RW", 0);
        this.TX_BD_NUM.build();
        this.CTRLMODER = reg_reg_CTRLMODER::type_id::create("CTRLMODER",,get_full_name());
        this.CTRLMODER.configure(this, null, "");
`ifdef USE_SLICE_API
        this.CTRLMODER.add_hdl_path_slice("ethreg1.CTRLMODER_0.DataOut", -1, -1,1);
`else
        this.CTRLMODER.add_hdl_path('{
                '{"ethreg1.CTRLMODER_0.DataOut", -1, -1}
            });
`endif

        this.default_map.add_reg(this.CTRLMODER, `UVM_REG_ADDR_WIDTH'h9, "RW", 0);
        this.CTRLMODER.build();
        this.TXFLOW = this.CTRLMODER.TXFLOW;
        this.RXFLOW = this.CTRLMODER.RXFLOW;
        this.PASSALL = this.CTRLMODER.PASSALL;
        this.MIIMODER = reg_reg_MIIMODER::type_id::create("MIIMODER",,get_full_name());
        this.MIIMODER.configure(this, null, "");
`ifdef USE_SLICE_API
        this.MIIMODER.add_hdl_path_slice("ethreg1.MIIMODER_1.DataOut", 8, 1,1);
        this.MIIMODER.add_hdl_path_slice("ethreg1.MIIMODER_0.DataOut", 0, 8);
`else
        this.MIIMODER.add_hdl_path('{
                '{"ethreg1.MIIMODER_1.DataOut", 8, 1},
                '{"ethreg1.MIIMODER_0.DataOut", 0, 8}
            });
`endif
 
        this.default_map.add_reg(this.MIIMODER, `UVM_REG_ADDR_WIDTH'hA, "RW", 0);
        this.MIIMODER.build();
        this.MIINOPRE = this.MIIMODER.MIINOPRE;
        this.CLKDIV = this.MIIMODER.CLKDIV;
        this.MIICOMMAND = reg_reg_MIICOMMAND::type_id::create("MIICOMMAND",,get_full_name());
        this.MIICOMMAND.configure(this, null, "");
`ifdef USE_SLICE_API
        this.MIICOMMAND.add_hdl_path_slice("ethreg1.MIICOMMAND2.DataOut", 2, 1,1);
        this.MIICOMMAND.add_hdl_path_slice("ethreg1.MIICOMMAND1.DataOut", 1, 1);
        this.MIICOMMAND.add_hdl_path_slice("ethreg1.MIICOMMAND0.DataOut", 0, 1);
`else
        this.MIICOMMAND.add_hdl_path('{
                '{"ethreg1.MIICOMMAND2.DataOut", 2, 1},
                '{"ethreg1.MIICOMMAND1.DataOut", 1, 1},
                '{"ethreg1.MIICOMMAND0.DataOut", 0, 1}
            });
`endif

        this.default_map.add_reg(this.MIICOMMAND, `UVM_REG_ADDR_WIDTH'hB, "RW", 0);
        this.MIICOMMAND.build();
        this.WCTRLDATA = this.MIICOMMAND.WCTRLDATA;
        this.RSTAT = this.MIICOMMAND.RSTAT;
        this.SCANSTAT = this.MIICOMMAND.SCANSTAT;
        this.MIIADDRESS = reg_reg_MIIADDRESS::type_id::create("MIIADDRESS",,get_full_name());
        this.MIIADDRESS.configure(this, null, "");
        this.default_map.add_reg(this.MIIADDRESS, `UVM_REG_ADDR_WIDTH'hC, "RW", 0);
        this.MIIADDRESS.build();
        this.RGAD = this.MIIADDRESS.RGAD;
        this.FIAD = this.MIIADDRESS.FIAD;
        this.MIITX_DATA = reg_reg_MIITX_DATA::type_id::create("MIITX_DATA",,get_full_name());
        this.MIITX_DATA.configure(this, null, "");
`ifdef USE_SLICE_API
        this.MIITX_DATA.add_hdl_path_slice("ethreg1.MIITX_DATA_1.DataOut", 8, 8,1);
        this.MIITX_DATA.add_hdl_path_slice("ethreg1.MIITX_DATA_0.DataOut", 0, 8);
`else
        this.MIITX_DATA.add_hdl_path('{
                '{"ethreg1.MIITX_DATA_1.DataOut", 8, 8},
                '{"ethreg1.MIITX_DATA_0.DataOut", 0, 8}
            });
`endif

        this.default_map.add_reg(this.MIITX_DATA, `UVM_REG_ADDR_WIDTH'hD, "RW", 0);
        this.MIITX_DATA.build();
        this.CTRLDATA = this.MIITX_DATA.CTRLDATA;
        this.MIIRX_DATA = reg_reg_MIIRX_DATA::type_id::create("MIIRX_DATA",,get_full_name());
        this.MIIRX_DATA.configure(this, null, "");
`ifdef USE_SLICE_API
        this.MIIRX_DATA.add_hdl_path_slice("ethreg1.MIIRX_DATA.DataOut", -1, -1,1);
`else
        this.MIIRX_DATA.add_hdl_path('{
                '{"ethreg1.MIIRX_DATA.DataOut", -1, -1}
            });
`endif

        this.default_map.add_reg(this.MIIRX_DATA, `UVM_REG_ADDR_WIDTH'hE, "RW", 0);
        this.MIIRX_DATA.build();
        this.PRSD = this.MIIRX_DATA.PRSD;
        this.MIISTATUS = reg_reg_MIISTATUS::type_id::create("MIISTATUS",,get_full_name());
        this.MIISTATUS.configure(this, null, "");
`ifdef USE_SLICE_API
        this.MIISTATUS.add_hdl_path_slice("ethreg1.NValid_stat", 2, 1,1);
        this.MIISTATUS.add_hdl_path_slice("ethreg1.Busy_stat", 1, 1);
        this.MIISTATUS.add_hdl_path_slice("ethreg1.LinkFail", 0, 1);
`else
        this.MIISTATUS.add_hdl_path('{
                '{"ethreg1.NValid_stat", 2, 1},
                '{"ethreg1.Busy_stat", 1, 1},
                '{"ethreg1.LinkFail", 0, 1}
            });
`endif

        this.default_map.add_reg(this.MIISTATUS, `UVM_REG_ADDR_WIDTH'hF, "RW", 0);
        this.MIISTATUS.build();
        this.NVALID = this.MIISTATUS.NVALID;
        this.BUSY_N = this.MIISTATUS.BUSY_N;
        this.LINKFAIL = this.MIISTATUS.LINKFAIL;
        this.MAC_ADDR = reg_reg_MAC_ADDR::type_id::create("MAC_ADDR",,get_full_name());
        this.MAC_ADDR.configure(this, null, "");
`ifdef USE_SLICE_API
        this.MAC_ADDR.add_hdl_path_slice("ethreg1.MAC_ADDR1_1.DataOut", 40, 8,1);
        this.MAC_ADDR.add_hdl_path_slice("ethreg1.MAC_ADDR1_0.DataOut", 32, 8);
        this.MAC_ADDR.add_hdl_path_slice("ethreg1.MAC_ADDR0_3.DataOut", 24, 8);
        this.MAC_ADDR.add_hdl_path_slice("ethreg1.MAC_ADDR0_2.DataOut", 16, 8);
        this.MAC_ADDR.add_hdl_path_slice("ethreg1.MAC_ADDR0_1.DataOut", 8, 8);
        this.MAC_ADDR.add_hdl_path_slice("ethreg1.MAC_ADDR0_0.DataOut", 0, 8);
`else
        this.MAC_ADDR.add_hdl_path('{
                '{"ethreg1.MAC_ADDR1_1.DataOut", 40, 8},
                '{"ethreg1.MAC_ADDR1_0.DataOut", 32, 8},
                '{"ethreg1.MAC_ADDR0_3.DataOut", 24, 8},
                '{"ethreg1.MAC_ADDR0_2.DataOut", 16, 8},
                '{"ethreg1.MAC_ADDR0_1.DataOut", 8, 8},
                '{"ethreg1.MAC_ADDR0_0.DataOut", 0, 8}
            });
`endif

        this.default_map.add_reg(this.MAC_ADDR, `UVM_REG_ADDR_WIDTH'h10, "RW", 0);
        this.MAC_ADDR.build();
        this.HASH0 = reg_reg_HASH0::type_id::create("HASH0",,get_full_name());
        this.HASH0.configure(this, null, "");
`ifdef USE_SLICE_API
        this.HASH0.add_hdl_path_slice("ethreg1.RXHASH0_3.DataOut", 24, 8,1);
        this.HASH0.add_hdl_path_slice("ethreg1.RXHASH0_2.DataOut", 16, 8);
        this.HASH0.add_hdl_path_slice("ethreg1.RXHASH0_1.DataOut", 8, 8);
        this.HASH0.add_hdl_path_slice("ethreg1.RXHASH0_0.DataOut", 0, 8);
`else
        this.HASH0.add_hdl_path('{
                '{"ethreg1.RXHASH0_3.DataOut", 24, 8},
                '{"ethreg1.RXHASH0_2.DataOut", 16, 8},
                '{"ethreg1.RXHASH0_1.DataOut", 8, 8},
                '{"ethreg1.RXHASH0_0.DataOut", 0, 8}
            });
`endif

        this.default_map.add_reg(this.HASH0, `UVM_REG_ADDR_WIDTH'h12, "RW", 0);
        this.HASH0.build();
        this.HASH1 = reg_reg_HASH1::type_id::create("HASH1",,get_full_name());
        this.HASH1.configure(this, null, "");
`ifdef USE_SLICE_API
        this.HASH1.add_hdl_path_slice("ethreg1.RXHASH1_3.DataOut", 24, 8,1);
        this.HASH1.add_hdl_path_slice("ethreg1.RXHASH1_2.DataOut", 16, 8);
        this.HASH1.add_hdl_path_slice("ethreg1.RXHASH1_1.DataOut", 8, 8);
        this.HASH1.add_hdl_path_slice("ethreg1.RXHASH1_0.DataOut", 0, 8);
`else
        this.HASH1.add_hdl_path('{
                '{"ethreg1.RXHASH1_3.DataOut", 24, 8},
                '{"ethreg1.RXHASH1_2.DataOut", 16, 8},
                '{"ethreg1.RXHASH1_1.DataOut", 8, 8},
                '{"ethreg1.RXHASH1_0.DataOut", 0, 8}
            });
`endif

        this.default_map.add_reg(this.HASH1, `UVM_REG_ADDR_WIDTH'h13, "RW", 0);
        this.HASH1.build();
        this.TXCTRL = reg_reg_TXCTRL::type_id::create("TXCTRL",,get_full_name());
        this.TXCTRL.configure(this, null, "");
`ifdef USE_SLICE_API
        this.TXCTRL.add_hdl_path_slice("ethreg1.TXCTRL_2.DataOut", 16, 1,1);
        this.TXCTRL.add_hdl_path_slice("ethreg1.TXCTRL_1.DataOut", 8, 8);
        this.TXCTRL.add_hdl_path_slice("ethreg1.TXCTRL_0.DataOut", 0, 8);
`else
        this.TXCTRL.add_hdl_path('{
                '{"ethreg1.TXCTRL_2.DataOut", 16, 1},
                '{"ethreg1.TXCTRL_1.DataOut", 8, 8},
                '{"ethreg1.TXCTRL_0.DataOut", 0, 8}
            });
`endif

        this.default_map.add_reg(this.TXCTRL, `UVM_REG_ADDR_WIDTH'h14, "RW", 0);
        this.TXCTRL.build();
        this.TXPAUSEREQ = this.TXCTRL.TXPAUSEREQ;
        this.TXPAUSETV = this.TXCTRL.TXPAUSETV;
        this.BD = reg_mem_BD::type_id::create("BD",,get_full_name());
        this.BD.configure(this, "wishbone.bd_ram.mem");
        this.default_map.add_mem(this.BD, `UVM_REG_ADDR_WIDTH'h100, "RW", 0);
        this.BD.build();
    endfunction : build

    `uvm_object_utils(reg_block_oc_ethernet)

endclass : reg_block_oc_ethernet



`endif
