//=====================================================================
// Project: 4 core MESI cache design
// File Name: lv2_read_hit.sv
// Description: Test for read-miss to I-cache
//=====================================================================

class lv2_read_hit extends base_test;

    //component macro
    `uvm_component_utils(lv2_read_hit)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", lv2_read_hit_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing lv2_read_hit test" , UVM_LOW)
    endtask: run_phase

endclass : lv2_read_hit


// Sequence for a read-miss on I-cache
class lv2_read_hit_seq extends base_vseq;
    //object macro
    `uvm_object_utils(lv2_read_hit_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="lv2_read_hit_seq");
        super.new(name);
    endfunction : new

    virtual task body();
     int unsigned addr = 32'h4000_1000;

    // Step 1: Core 0 loads the block (fills L1 + L2)
    `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
      request_type == READ_REQ;
      access_cache_type == DCACHE_ACC;
      address == addr;
    })

    // Step 2: Core 1 accesses the same block
    // → L1 miss (private), L2 hit (shared)
    `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {
      request_type == READ_REQ;
      access_cache_type == DCACHE_ACC;
      address == addr;
    })
    endtask

endclass : lv2_read_hit_seq
