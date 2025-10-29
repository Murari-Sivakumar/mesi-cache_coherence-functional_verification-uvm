
//=====================================================================
// Project: 4 core MESI cache design
// File Name: modified_to_shared.sv
// Description: Test for read-miss to I-cache
//=====================================================================

class modified_to_shared extends base_test;

    //component macro
    `uvm_component_utils(modified_to_shared)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", modified_to_shared_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing modified_to_shared test" , UVM_LOW)
    endtask: run_phase

endclass : modified_to_shared


class modified_to_shared_seq extends base_vseq;
    `uvm_object_utils(modified_to_shared_seq)

    cpu_transaction_c trans;

    function new (string name = "modified_to_shared_seq");
        super.new(name);
    endfunction : new

    virtual task body();

        bit [31:0] test_addr;
        bit [31:0] test_addr2;
        test_addr = 32'h9000_0000; // Choose any D-cache address (> `IL_DL_ADDR_BOUND`)
        test_addr2 = 32'h9000_1234; // Choose any D-cache address (> `IL_DL_ADDR_BOUND`)

        // Step 1: Initial read to bring line into Exclusive (E) state
        // `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {
        //     request_type         == WRITE_REQ;
        //     access_cache_type    == DCACHE_ACC;
        //     address              == test_addr;
        //     data                 == 32'hDEAD_BEEF;
        // })

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == READ_REQ;
            access_cache_type    == DCACHE_ACC;
            address              == test_addr;
        })

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {
            request_type         == READ_REQ;
            access_cache_type    == DCACHE_ACC;
            address              == test_addr;
            // data                 == 32'hCAFE_BABE;
        })

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {
            request_type         == READ_REQ;
            access_cache_type    == DCACHE_ACC;
            address              == test_addr;
            // data                 == 32'hCAFE_BABE;
        })
  
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {
            request_type         == WRITE_REQ;
            access_cache_type    == DCACHE_ACC;
            address              == test_addr;
            data                 == 32'hCAFE_BABE;
        })


        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == READ_REQ;
            access_cache_type    == DCACHE_ACC;
            address              == test_addr;
        })
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {
            request_type         == READ_REQ;
            access_cache_type    == DCACHE_ACC;
            address              == test_addr;
        })
        // `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
        //     request_type         == READ_REQ;
        //     access_cache_type    == DCACHE_ACC;
        //     address              == test_addr;
        // })
        // end

    endtask : body

endclass : modified_to_shared_seq

