class write_hit_lv2_eviction extends base_test;

  `uvm_component_utils(write_hit_lv2_eviction)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", write_hit_lv2_eviction_seq::type_id::get());
    super.build_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Executing write_hit_lv2_eviction test (v2)", UVM_LOW)
  endtask

endclass : write_hit_lv2_eviction



class write_hit_lv2_eviction_seq extends base_vseq;

  `uvm_object_utils(write_hit_lv2_eviction_seq)

  cpu_transaction_c trans;

  function new(string name = "write_hit_lv2_eviction_seq");
    super.new(name);
  endfunction

virtual task body();
  begin
    `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
      request_type == WRITE_REQ;
      access_cache_type == DCACHE_ACC;
      address == 32'ha000_0000;
    });

    `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
      request_type == READ_REQ;
      access_cache_type == DCACHE_ACC;
      address == 32'hb000_0000;
    });

    // Evicting 3 in L1 writing to 4 and 7
    `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
      request_type == READ_REQ;
      access_cache_type == DCACHE_ACC;
      address == 32'hc000_0000;
    });

    // Evicting 1 in L1 writing to 7 and 5
    `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
      request_type == READ_REQ;
      access_cache_type == DCACHE_ACC;
      address == 32'hd000_0000;
    });

    // Reading from L2 (index 7)
    `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
      request_type == READ_REQ;
      access_cache_type == DCACHE_ACC;
      address == 32'h8000_0000;
    });

    // Core 1 triggers eviction of modified block
    `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {
      request_type == WRITE_REQ;
      access_cache_type == DCACHE_ACC;
      address == 32'hd000_0000;
    });
  end
endtask


endclass : write_hit_lv2_eviction_seq
