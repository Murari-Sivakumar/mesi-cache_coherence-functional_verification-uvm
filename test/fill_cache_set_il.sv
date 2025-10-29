//=====================================================================
// Project: 4 core MESI cache design
// File Name: fill_cache_set_il.sv
// Description: Test for read-miss to I-cache
//=====================================================================

class fill_cache_set_il extends base_test;

    //component macro
    `uvm_component_utils(fill_cache_set_il)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", fill_cache_set_il_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing fill_cache_set_il test" , UVM_LOW)
    endtask: run_phase

endclass : fill_cache_set_il


// Sequence for a read-miss on I-cache
class fill_cache_set_il_seq extends base_vseq;
    `uvm_object_utils(fill_cache_set_il_seq)

    cpu_transaction_c trans;

    function new(string name = "fill_cache_set_il_seq");
        super.new(name);
    endfunction

    virtual task body();

        // CPU0 reads the block → MESI = E
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == READ_REQ;
            access_cache_type    == ICACHE_ACC;
            address              ==  32'h0000_0001;
        })

        //  CPU1 reads the block → MESI = S in both
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == READ_REQ;
            access_cache_type    == ICACHE_ACC;
            address              ==  32'h0001_0001;
        })

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == READ_REQ;
            access_cache_type    == ICACHE_ACC;
            address              ==  32'h0002_0001;
        })

        //  CPU1 reads the block → MESI = S in both
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == READ_REQ;
            access_cache_type    == ICACHE_ACC;
            address              ==  32'h0003_0001;
        })

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == READ_REQ;
            access_cache_type    == ICACHE_ACC;
            address              ==  32'h0004_0001;
        })
        
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == READ_REQ;
            access_cache_type    == ICACHE_ACC;
            address              ==  32'h0005_0001;
        })

        

    endtask

endclass : fill_cache_set_il_seq
