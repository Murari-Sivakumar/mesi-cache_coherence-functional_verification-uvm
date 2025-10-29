//=====================================================================
// Project: 4 core MESI cache design
// File Name: mesi_shared_invalidation.sv
// Description: Test for read-miss to I-cache
//=====================================================================

class mesi_shared_invalidation extends base_test;

    //component macro
    `uvm_component_utils(mesi_shared_invalidation)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", mesi_shared_invalidation_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing mesi_shared_invalidation test" , UVM_LOW)
    endtask: run_phase

endclass : mesi_shared_invalidation


// Sequence for a read-miss on I-cache
class mesi_shared_invalidation_seq extends base_vseq;
    //object macro
    `uvm_object_utils(mesi_shared_invalidation_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="mesi_shared_invalidation_seq");
        super.new(name);
    endfunction : new

    virtual task body();
      bit [31:0] shared_addr = 32'h0004_1000;

    // Core 0: READ → I → E or I → S
    `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
      request_type == READ_REQ;
      address == shared_addr;
      access_cache_type == DCACHE_ACC;
    })

    // Core 1: READ → I → S (shared read) → S
    `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {
      request_type == READ_REQ;
      address == shared_addr;
      access_cache_type == DCACHE_ACC;
    })

    // Core 2: WRITE → S → M
    `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {
      request_type == WRITE_REQ;
      address == shared_addr;
      data == 32'hFEEDFACE;
      access_cache_type == DCACHE_ACC;
    })

    // Core 0: write to different address → eviction → S → I or M → I
    `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
      request_type == READ_REQ;
      address == 32'h0004_2000; // New address triggers eviction
      access_cache_type == DCACHE_ACC;
    })
    endtask

endclass : mesi_shared_invalidation_seq
