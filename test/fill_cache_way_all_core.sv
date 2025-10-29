//=====================================================================
// Project: 4 core MESI cache design
// File Name: fill_cache_way_all_core.sv
// Description: Test for read-miss to I-cache
//=====================================================================

class fill_cache_way_all_core extends base_test;

    //component macro
    `uvm_component_utils(fill_cache_way_all_core)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", fill_cache_way_all_core_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing fill_cache_way_all_core test" , UVM_LOW)
    endtask: run_phase

endclass : fill_cache_way_all_core



class fill_cache_way_all_core_seq extends base_vseq;
    `uvm_object_utils(fill_cache_way_all_core_seq)

    cpu_transaction_c trans;

    function new(string name = "fill_cache_way_all_core_seq");
        super.new(name);
    endfunction

    virtual task body();
        for (int core_count = 0; core_count < 4; core_count++) begin
            for (int i = 0; i < 13; i++) begin
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core_count], {
                request_type         == WRITE_REQ;
                access_cache_type    == DCACHE_ACC;
                address              == 32'h4000_0000 + (i * 32'h0001_0000) + (core_count << 16);
            })
            end
        end

    endtask

endclass : fill_cache_way_all_core_seq
