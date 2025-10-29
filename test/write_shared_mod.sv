//=====================================================================
// Project: 4 core MESI cache design
// File Name: write_shared_mod.sv
// Description: Test for read-miss to I-cache
//=====================================================================

class write_shared_mod extends base_test;

    //component macro
    `uvm_component_utils(write_shared_mod)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", write_shared_mod_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing write_shared_mod test" , UVM_LOW)
    endtask: run_phase

endclass : write_shared_mod


// Sequence for a read-miss on I-cache
class write_shared_mod_seq extends base_vseq;
    `uvm_object_utils(write_shared_mod_seq)

    cpu_transaction_c trans;

    function new(string name = "write_shared_mod_seq");
        super.new(name);
    endfunction

    virtual task body();

        bit [31:0] test_addr = 32'h9000_4321; // Some address in D-cache space

                // CPU1 writes to the same block → MESI hit in S → expect invalidate
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == WRITE_REQ;
            access_cache_type    == DCACHE_ACC;
            address              == test_addr;
            data                 == 32'hCAFEBABE;
        })

        // CPU0 reads the block → MESI = E
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == READ_REQ;
            access_cache_type    == DCACHE_ACC;
            address              == test_addr;
        })

        // CPU1 reads the block → MESI = S in both
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {
            request_type         == READ_REQ;
            access_cache_type    == DCACHE_ACC;
            address              == test_addr;
        })
        // Shared state in this too
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[2], {
            request_type         == READ_REQ;
            access_cache_type    == DCACHE_ACC;
            address              == test_addr;
        })

                // Shared state in this too
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[3], {
            request_type         == READ_REQ;
            access_cache_type    == DCACHE_ACC;
            address              == test_addr;
        })

        
        // CPU1 writes to the same block → MESI hit in S → expect invalidate
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == WRITE_REQ;
            access_cache_type    == DCACHE_ACC;
            address              == test_addr;
            data                 == 32'hCAFEBABE;
            wait_cycles == 40;
        })

        // //READ AGAIN to verify data
        // `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {
        //     request_type         == READ_REQ;
        //     access_cache_type    == DCACHE_ACC;
        //     address              == test_addr;
        // })
        // // should have same data
        // `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
        //     request_type         == READ_REQ;
        //     access_cache_type    == DCACHE_ACC;
        //     address              == test_addr;
        // })

        

    endtask

endclass : write_shared_mod_seq
