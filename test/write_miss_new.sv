//=====================================================================
// Project: 4 core MESI cache design
// File Name: write_miss_new.sv
// Description: Test for read-miss to I-cache
//=====================================================================

class write_miss_new extends base_test;

    //component macro
    `uvm_component_utils(write_miss_new)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", write_miss_new_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing write_miss_new test" , UVM_LOW)
    endtask: run_phase

endclass : write_miss_new


// Sequence for a read-miss on I-cache
class write_miss_new_seq extends base_vseq;
    `uvm_object_utils(write_miss_new_seq)

    cpu_transaction_c trans;

    function new(string name = "write_miss_new_seq");
        super.new(name);
    endfunction

    virtual task body();

        bit [31:0] test_addr = 32'h9000_4321; // Some address in D-cache space

        

        // CPU0 reads the block → MESI = E
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == READ_REQ;
            access_cache_type    == DCACHE_ACC;
            address              == test_addr;
        })

        //  CPU1 reads the block → MESI = S in both
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {
            request_type         == READ_REQ;
            access_cache_type    == DCACHE_ACC;
            address              == test_addr;
        })

        //  CPU1 writes to the same block → MESI hit in S → expect invalidate
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == WRITE_REQ;
            access_cache_type    == DCACHE_ACC;
            address              == 32'h9000_8321;
            data                 == 32'hCAFEBABE;
        })

        

    endtask

endclass : write_miss_new_seq
