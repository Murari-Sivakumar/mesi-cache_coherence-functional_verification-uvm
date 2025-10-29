//=====================================================================
// Project: 4 core MESI cache design
// File Name: lv2_lru_replacement_test.sv
// Description: Test for read-miss to I-cache
//=====================================================================

class lv2_lru_replacement_test extends base_test;

    //component macro
    `uvm_component_utils(lv2_lru_replacement_test)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", lv2_lru_replacement_test_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing lv2_lru_replacement_test test" , UVM_LOW)
    endtask: run_phase

endclass : lv2_lru_replacement_test


// Sequence for a read-miss on I-cache
class lv2_lru_replacement_test_seq extends base_vseq;
    //object macro
    `uvm_object_utils(lv2_lru_replacement_test_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="lv2_lru_replacement_test_seq");
        super.new(name);
    endfunction : new

    virtual task body();
    int unsigned index_value = 18'h00020;       // Set index bits [19:2]
    int unsigned offset = 2'b00;                // Aligned
    int unsigned base_tag = 12'h100;            // Tag [31:20] → 0x100 → address[31:30] = 2'b01

    int unsigned addr;
    int unsigned repl_tag;

    // -------------------------
    // Step 1: Fill all 8 ways
    // -------------------------
    for (int tag = 0; tag < 8; tag++) begin
      addr = ((base_tag + tag) << 20) | (index_value << 2) | offset;

      `uvm_info(get_type_name(), $sformatf("Filling way %0d with address: 0x%08h", tag, addr), UVM_MEDIUM)

      `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
        request_type         == READ_REQ;
        access_cache_type    == ICACHE_ACC;
        address              == addr;
      })
    end

    // -------------------------
    // Step 2: Trigger replacement (9th access)
    // -------------------------
    repl_tag = base_tag + 8;
    addr = (repl_tag << 20) | (index_value << 2) | offset;

    `uvm_info(get_type_name(), $sformatf("Triggering L2 replacement with address: 0x%08h", addr), UVM_MEDIUM)

    `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
      request_type         == READ_REQ;
      access_cache_type    == ICACHE_ACC;
      address              == addr;
    })
    endtask

endclass : lv2_lru_replacement_test_seq
