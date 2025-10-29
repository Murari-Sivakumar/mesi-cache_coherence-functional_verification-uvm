//=====================================================================
// Project: 4 core MESI cache design
// File Name: cover_mesi_lru_random_read.sv
// Description: Test for read-miss to I-cache
//=====================================================================

class cover_mesi_lru_random_read extends base_test;

    //component macro
    `uvm_component_utils(cover_mesi_lru_random_read)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", cover_mesi_lru_random_read_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing cover_mesi_lru_random_read test" , UVM_LOW)
    endtask: run_phase

endclass : cover_mesi_lru_random_read


// Sequence for a read-miss on I-cache
class cover_mesi_lru_random_read_seq extends base_vseq;
    //object macro
    `uvm_object_utils(cover_mesi_lru_random_read_seq)

    cpu_transaction_c trans;

    //constructor
    function new (string name="cover_mesi_lru_random_read_seq");
        super.new(name);
    endfunction : new

    virtual task body();

    bit [31:0] addr_set [4] = {
        32'h0005_0000 + (0 << 12),
        32'h0005_0040 + (1 << 12),
        32'h0005_0080 + (2 << 12),
        32'h0005_00C0 + (3 << 12)
        };
        
    for (int core_count = 0; core_count < 4; core_count++) begin

        // Define per-core address set (DCACHE address space >= 0x0004_0000)
        repeat (10) begin
        `uvm_do_on_with(trans, p_sequencer.cpu_seqr[core_count], {
            request_type == READ_REQ;
            access_cache_type == DCACHE_ACC;
            address inside {addr_set[0], addr_set[1], addr_set[2], addr_set[3]};
        })
        end

    end // for core_count

    endtask

endclass : cover_mesi_lru_random_read_seq
