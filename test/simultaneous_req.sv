//=====================================================================
// Project: 4 core MESI cache design
// File Name: simultaneous_req.sv
// Description: Test for read-miss to I-cache
//=====================================================================

class simultaneous_req extends base_test;

    //component macro
    `uvm_component_utils(simultaneous_req)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", simultaneous_req_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing simultaneous_req test" , UVM_LOW)
    endtask: run_phase

endclass : simultaneous_req


class simultaneous_req_seq extends base_vseq;
    `uvm_object_utils(simultaneous_req_seq)

    cpu_transaction_c trans;

    function new (string name = "simultaneous_req_seq");
        super.new(name);
    endfunction : new

    virtual task body();

        bit [31:0] test_addr;
        test_addr = 32'h9000_1234; // Choose any D-cache address (> `IL_DL_ADDR_BOUND`)

    // 1) CPU0 reads → MESI goes Exclusive
    `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
      request_type      == READ_REQ;
      access_cache_type == DCACHE_ACC;
      address           == test_addr;
    })

    // 2) CPU1 reads → both CPU0 & CPU1 go Shared
    `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {
      request_type      == READ_REQ;
      access_cache_type == DCACHE_ACC;
      address           == test_addr;
    })

    // 3+4) in parallel:
    //    • CPU2 does a WRITE  → triggers invalidate on CPU1’s snoop side
    //    • CPU1 immediately does a READ → must see the new data
    fork
      begin : write_path
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {
          request_type      == WRITE_REQ;
          access_cache_type == DCACHE_ACC;
          address           == test_addr;
          data              == 32'hDEAD_BEEF;
        })
      end
      begin : read_path
        // #1ns;  // small skew so bus_rd & bus_rdx overlap
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {
          request_type      == READ_REQ;
          access_cache_type == DCACHE_ACC;
          address           == test_addr;
        })
      end
    join


    endtask : body

endclass : simultaneous_req_seq

