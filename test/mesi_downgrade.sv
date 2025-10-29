//=====================================================================
// Project: 4 core MESI cache design
// File Name: mesi_downgrade.sv
// Description: Test for read-miss to I-cache
//=====================================================================

class mesi_downgrade extends base_test;

    //component macro
    `uvm_component_utils(mesi_downgrade)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", mesi_downgrade_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing mesi_downgrade test" , UVM_LOW)
    endtask: run_phase

endclass : mesi_downgrade


// Sequence for a read-miss on I-cache
class mesi_downgrade_seq extends base_vseq;
    //object macro
    `uvm_object_utils(mesi_downgrade_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="mesi_downgrade_seq");
        super.new(name);
    endfunction : new

    virtual task body();
         bit [31:0] addr = 32'h0004_3000;

    // Core 0: read → I → E
    `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
      request_type == READ_REQ;
      address == addr;
      access_cache_type == DCACHE_ACC;
    })

    // Core 0: write → E → M
    `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
      request_type == WRITE_REQ;
      address == addr;
      data == 32'hBEEFCAFE;
      access_cache_type == DCACHE_ACC;
    })

    // Core 1: read → M → S (core 0 downgrades)
    `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {
      request_type == READ_REQ;
      address == addr;
      access_cache_type == DCACHE_ACC;
    })

    // Core 2: read again → S → S
    `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {
      request_type == READ_REQ;
      address == addr;
      access_cache_type == DCACHE_ACC;
    })

    // Core 1: access new line → eviction → S → I
    `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {
      request_type == READ_REQ;
      address == 32'h0004_4000;
      access_cache_type == DCACHE_ACC;
    })
    endtask

endclass : mesi_downgrade_seq
