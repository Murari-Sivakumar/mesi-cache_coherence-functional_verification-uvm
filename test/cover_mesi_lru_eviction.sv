//=====================================================================
// Project: 4 core MESI cache design
// File Name: cover_mesi_lru_eviction.sv
// Description: Test for read-miss to I-cache
//=====================================================================

class cover_mesi_lru_eviction extends base_test;

    //component macro
    `uvm_component_utils(cover_mesi_lru_eviction)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", cover_mesi_lru_eviction_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing cover_mesi_lru_eviction test" , UVM_LOW)
    endtask: run_phase

endclass : cover_mesi_lru_eviction


// Sequence for a read-miss on I-cache
class cover_mesi_lru_eviction_seq extends base_vseq;
    //object macro
    `uvm_object_utils(cover_mesi_lru_eviction_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="cover_mesi_lru_eviction_seq");
        super.new(name);
    endfunction : new

    virtual task body();
      bit [31:0] icache_base = 32'h0002_0000;

      for (int core_count = 0; core_count < 4; core_count++) begin

        `uvm_info(get_type_name(), $sformatf("=== ICACHE LRU sequence for core %0d ===", core_count), UVM_MEDIUM)

        // Base address in ICACHE region (< 0x0004_0000)
        icache_base = 32'h0002_0000 + (core_count << 12);

        // Step 1: Access 4 sequential blocks to fill set
        for (int i = 0; i < 4; i++) begin
          `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core_count], {
            request_type == READ_REQ;
            address == (icache_base + (i * 64));
            access_cache_type == ICACHE_ACC;
          })
        end

        // Step 2: Access one of them again to make it MRU
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core_count], {
          request_type == READ_REQ;
          address == icache_base; // re-access first block
          access_cache_type == ICACHE_ACC;
        })

        // Step 3: Access new block to force eviction
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core_count], {
          request_type == READ_REQ;
          address == (32'h0003_8000 + (core_count << 12)); // outside original set
          access_cache_type == ICACHE_ACC;
        })

      end // core loop
    endtask

endclass : cover_mesi_lru_eviction_seq
