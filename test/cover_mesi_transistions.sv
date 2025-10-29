//=====================================================================
// Project: 4 core MESI cache design
// File Name: cover_mesi_transistions.sv
// Description: Test for read-miss to I-cache
//=====================================================================

class cover_mesi_transistions extends base_test;

    //component macro
    `uvm_component_utils(cover_mesi_transistions)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", cover_mesi_transistions_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing cover_mesi_transistions test" , UVM_LOW)
    endtask: run_phase

endclass : cover_mesi_transistions


// Sequence for a read-miss on I-cache
class cover_mesi_transistions_seq extends base_vseq;
    //object macro
    `uvm_object_utils(cover_mesi_transistions_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="cover_mesi_transistions_seq");
        super.new(name);
    endfunction : new

    virtual task body();
      int unsigned dcache_base;
      int unsigned addr_set[4];
         
         // Example address set: 4 blocks in a set (different indices or tags)
      for (int core_count = 0; core_count < 4; core_count++) begin

        dcache_base = 32'h0004_0000 + (core_count << 12);

        addr_set[0] = dcache_base;
        addr_set[1] = dcache_base + 32'h40;
        addr_set[2] = dcache_base + 32'h80;
        addr_set[3] = dcache_base + 32'hC0;

      // -----------------------------
      // Step 1: I → E transition
      // -----------------------------
      `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core_count], {
        request_type == READ_REQ;
        address == addr_set[0];
        access_cache_type == DCACHE_ACC;
      })

      // -----------------------------
      // Step 2: E → M transition
      // -----------------------------
      `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core_count], {
        request_type == WRITE_REQ;
        address == addr_set[0];
        data == 32'hABCD1234;
        access_cache_type == DCACHE_ACC;
      })

      // -----------------------------
      // Step 3: Access other blocks to set LRU
      // -----------------------------
      for (int i = 1; i < 4; i++) begin
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core_count], {
          request_type == READ_REQ;
          address == addr_set[i];
          access_cache_type == DCACHE_ACC;
        })
      end

      // -----------------------------
      // Step 4: Cause a miss to replace LRU block
      // -----------------------------
      `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core_count], {
        request_type == READ_REQ;
        address == 32'h0004_8000 + (core_count << 12); // DCACHE-miss address (still >= 0x0004_0000)
        access_cache_type == DCACHE_ACC;
      })

      // -----------------------------
      // Step 5: Write to shared block (simulate S→M)
      // -----------------------------
      `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core_count], {
        request_type == WRITE_REQ;
        address == addr_set[1];
        access_cache_type == DCACHE_ACC;
        data == 32'hDEADBEEF;
      })

    end // for each core
    endtask

endclass : cover_mesi_transistions_seq
