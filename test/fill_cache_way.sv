//=====================================================================
// Project: 4 core MESI cache design
// File Name: fill_cache_way.sv
// Description: Test for read-miss to I-cache
//=====================================================================

class fill_cache_way extends base_test;

    //component macro
    `uvm_component_utils(fill_cache_way)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", fill_cache_way_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing fill_cache_way test" , UVM_LOW)
    endtask: run_phase

endclass : fill_cache_way


// Sequence for a read-miss on I-cache
class fill_cache_way_seq extends base_vseq;
    `uvm_object_utils(fill_cache_way_seq)

    cpu_transaction_c trans;

    function new(string name = "fill_cache_way_seq");
        super.new(name);
    endfunction

    virtual task body();

        // CPU0 reads the block → MESI = E
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == WRITE_REQ;
            access_cache_type    == DCACHE_ACC;
            address              ==  32'h4000_0000;
        })

        //  CPU1 reads the block → MESI = S in both
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == WRITE_REQ;
            access_cache_type    == DCACHE_ACC;
            address              ==  32'h4001_0000;
        })

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == WRITE_REQ;
            access_cache_type    == DCACHE_ACC;
            address              ==  32'h4002_0000;
        })

        //  CPU1 reads the block → MESI = S in both
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == WRITE_REQ;
            access_cache_type    == DCACHE_ACC;
            address              ==  32'h4003_0000;
        })

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == WRITE_REQ;
            access_cache_type    == DCACHE_ACC;
            address              ==  32'h4004_0000;
        })
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == WRITE_REQ;
            access_cache_type    == DCACHE_ACC;
            address              ==  32'h4005_0000;
        })

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == WRITE_REQ;
            access_cache_type    == DCACHE_ACC;
            address              ==  32'h4006_0000;
        })
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == WRITE_REQ;
            access_cache_type    == DCACHE_ACC;
            address              ==  32'h4007_0000;
        })

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == WRITE_REQ;
            access_cache_type    == DCACHE_ACC;
            address              ==  32'h4008_0000;
        })
                        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == WRITE_REQ;
            access_cache_type    == DCACHE_ACC;
            address              ==  32'h4009_0000;
        })

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == WRITE_REQ;
            access_cache_type    == DCACHE_ACC;
            address              ==  32'h400A_0000;
        })
                `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == WRITE_REQ;
            access_cache_type    == DCACHE_ACC;
            address              ==  32'h400B_0000;
        })

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == WRITE_REQ;
            access_cache_type    == DCACHE_ACC;
            address              ==  32'h400C_0000;
        })



     //Check lru_var[i]

        

    endtask

endclass : fill_cache_way_seq
