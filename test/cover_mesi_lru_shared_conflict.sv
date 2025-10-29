//=====================================================================
// Project: 4 core_num MESI cache design
// File Name: cover_mesi_lru_shared_conflict.sv
// Description: Test for read-miss to I-cache
//=====================================================================

class cover_mesi_lru_shared_conflict extends base_test;

    //c[core_numonent macro
    `uvm_component_utils(cover_mesi_lru_shared_conflict)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", cover_mesi_lru_shared_conflict_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing cover_mesi_lru_shared_conflict test" , UVM_LOW)
    endtask: run_phase

endclass : cover_mesi_lru_shared_conflict



class cover_mesi_lru_shared_conflict_seq extends base_vseq;
    //object macro
    `uvm_object_utils(cover_mesi_lru_shared_conflict_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="cover_mesi_lru_shared_conflict_seq");
        super.new(name);
    endfunction : new

    virtual task body();
      for (int core_num = 0; core_num < 4; core_num++) begin

      // 1. Shared read from same block
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core_num], {
          request_type == READ_REQ;
          address == 32'h0004_0040;
          access_cache_type == DCACHE_ACC;
        })

        // 2. Another read to the same block (should hit in S)
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core_num], {
          request_type == READ_REQ;
          address == 32'h0004_0040;
          access_cache_type == DCACHE_ACC;
        })

        // 3. Write to same block → should cause S→M
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core_num], {
          request_type == WRITE_REQ;
          address == 32'h0004_0040;
          data == 32'hFEE1DEAD;
          access_cache_type == DCACHE_ACC;
        })

        // 4. Access another block to trigger LRU replacement
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core_num], {
          request_type == READ_REQ;
          address == 32'h0004_0080;
          access_cache_type == DCACHE_ACC;
        })
      end
    endtask

endclass : cover_mesi_lru_shared_conflict_seq
