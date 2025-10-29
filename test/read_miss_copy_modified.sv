//=====================================================================
// Project: 4 core MESI cache design
// File Name: read_miss_copy_modified.sv
// Description: Test for read-miss to I-cache
//=====================================================================

class read_miss_copy_modified extends base_test;

    //component macro
    `uvm_component_utils(read_miss_copy_modified)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", read_miss_copy_modified_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing read_miss_copy_modified test" , UVM_LOW)
    endtask: run_phase

endclass : read_miss_copy_modified


class read_miss_copy_modified_seq extends base_vseq;
    `uvm_object_utils(read_miss_copy_modified_seq)

    cpu_transaction_c trans;

    function new (string name = "read_miss_copy_modified_seq");
        super.new(name);
    endfunction : new

    virtual task body();

        bit [31:0] test_addr;
        test_addr = 32'h9000_1234; // Choose any D-cache address (> `IL_DL_ADDR_BOUND`)

        // Step 1: Initial write to bring line into M state

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[0], {
            request_type         == WRITE_REQ;
            access_cache_type    == DCACHE_ACC;
            address              == test_addr;
            data                 inside {32'hDEAD_BEEF, 32'h1234_5678};
        })
        
        // Step 2: Read to the same address to shift to S state - Read Miss

        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[1], {
            request_type         == READ_REQ;
            access_cache_type    == DCACHE_ACC;
            address              == test_addr;
        })



    endtask : body

endclass : read_miss_copy_modified_seq

