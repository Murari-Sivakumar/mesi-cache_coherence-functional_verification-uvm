//=====================================================================
// Project:    4 core MESI cache design
// File Name:  random_stress.sv
// Description: Random stress test for simultaneous read/write
// Designers:  Venky & Suru
//=====================================================================


class random_stress extends base_test;

  `uvm_component_utils(random_stress)

  function new(string name = "random_stress", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    // point default_sequence to our random stress sequence
    uvm_config_wrapper::set(this,
      "tb.vsequencer.run_phase", "default_sequence",
      random_stress_seq::type_id::get());
    super.build_phase(phase);
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Starting random stress test", UVM_LOW)
  endtask : run_phase

endclass : random_stress


class random_stress_seq extends base_vseq;
  `uvm_object_utils(random_stress_seq)

  // single transaction object reused for each request
  cpu_transaction_c trans;

  function new(string name = "random_stress_seq");
    super.new(name);
  endfunction : new

   bit rw;
   bit [3:0] addr_sel; 
  virtual task body();
    // choose from 10 addresses mapping to same D-cache index
    bit [31:0] addr_list[10] = '{
      32'h0AAA_1234, 32'h1BBB_1234, 32'h2CCC_1234, 32'h3DDD_1234,
      32'h4EEE_1234, 32'h5FFF_1234, 32'h6ABC_1234, 32'h7DEF_1234,
      32'h8FED_1234, 32'h9CBA_1234
    };

    trans = cpu_transaction_c::type_id::create("trans");

    rw = $urandom_range(0,1);
    addr_sel = $urandom_range(0,9);

    // stress loop: 100 iterations of simultaneous requests
    for (int iter = 0; iter < 1000; iter++) begin
      fork
        // each core issues one random read/write to a random addr
        for (int cid = 0; cid < 4; cid++) begin : per_core
          // small skew to vary overlaps
          `uvm_do_on_with(trans, p_sequencer.cpu_seqr[cid], {
            request_type      == ( rw == 1 ? READ_REQ : WRITE_REQ);
            access_cache_type == DCACHE_ACC;
            address           == addr_list[addr_sel];
            data              == 32'hDEAD_BEEF;
          })
        end
      join
      // optional pause
      #1ns;
    end
  endtask : body

endclass : random_stress_seq


