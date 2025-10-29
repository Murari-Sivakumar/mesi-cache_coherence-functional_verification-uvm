//=====================================================================
// Project: 4 core MESI cache design
// File Name: sequential_rw_dcache.sv
// Description: Test for read-miss to I-cache
//=====================================================================

class sequential_rw_dcache extends base_test;

    //component macro
    `uvm_component_utils(sequential_rw_dcache)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", sequential_rw_dcache_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing sequential_rw_dcache test" , UVM_LOW)
    endtask: run_phase

endclass : sequential_rw_dcache


class sequential_rw_dcache_seq extends base_vseq;
    `uvm_object_utils(sequential_rw_dcache_seq)

    cpu_transaction_c trans;

    function new(string name = "sequential_rw_dcache_seq");
        super.new(name);
    endfunction

    virtual task body();

        bit [31:0] base_addr = 32'h9000_0000; // D-cache base
        bit [31:0] addr;

        for (int i = 0; i < 16; i++) begin
            addr = base_addr | i; // ensures addresses end in 0x0 to 0xF


            // Step 0: Write to address

            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {
                request_type         == WRITE_REQ;
                access_cache_type    == DCACHE_ACC;
                address              == addr;
                data                 inside {32'hAAAA_0000, 32'hDEAD_BEEF, 32'hFACE_FEED};
            })

            // Step 1: Read from the same address
            `uvm_do_on_with(trans, p_sequencer.cpu_seqr[mp], {
                request_type         == READ_REQ;
                access_cache_type    == DCACHE_ACC;
                address              == addr;
            })

        end

    endtask
endclass
