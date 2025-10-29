//=====================================================================
// Project: 4 core MESI cache design
// File Name: multicore_stress_test.sv
// Description: Test for read-miss to I-cache
//=====================================================================

class multicore_stress_test extends base_test;

    //component macro
    `uvm_component_utils(multicore_stress_test)

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    //UVM build phase
    function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.vsequencer.run_phase", "default_sequence", multicore_stress_test_seq::type_id::get());
        super.build_phase(phase);
    endfunction : build_phase

    //UVM run phase()
    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Executing multicore_stress_test test" , UVM_LOW)
    endtask: run_phase

endclass : multicore_stress_test


// Sequence for a read-miss on I-cache
class multicore_stress_test_seq extends base_vseq;
    //object macro
    `uvm_object_utils(multicore_stress_test_seq)

    cpu_transaction_c trans[0:3];
    bit [2:0] p,q;


    //constructor
    function new (string name="multicore_stress_test_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        logic [31:0] common_address;
        repeat(50)begin
            p=$urandom_range(0,3);
            q=$urandom_range(0,3);
            `uvm_do_on_with(trans[p], p_sequencer.cpu_seqr[p], {request_type == WRITE_REQ;})
            `uvm_do_on_with(trans[q], p_sequencer.cpu_seqr[q], {request_type == READ_REQ;})

            common_address = 32'h40000004;
            for(int z=0;z<4;z++)
            begin
                `uvm_do_on_with(trans[0], p_sequencer.cpu_seqr[z], {request_type == WRITE_REQ; access_cache_type == DCACHE_ACC; address ==common_address;})
            end
            for(int z=0;z<4;z++)
            begin
                `uvm_do_on_with(trans[1], p_sequencer.cpu_seqr[z], {request_type == READ_REQ; access_cache_type == DCACHE_ACC;address ==common_address;})
            end
            fork
                begin
                    `uvm_do_on_with(trans[0], p_sequencer.cpu_seqr[0], {
                    request_type == WRITE_REQ;
                    access_cache_type == DCACHE_ACC;
                    address == common_address;
                })
                end 
                begin
                    `uvm_do_on_with(trans[1], p_sequencer.cpu_seqr[1], {
                    request_type == WRITE_REQ;
                    access_cache_type == DCACHE_ACC;
                    address == common_address;
                })
                end
                begin
                    `uvm_do_on_with(trans[2], p_sequencer.cpu_seqr[2], {
                    request_type == READ_REQ;
                    access_cache_type == DCACHE_ACC;
                    address == common_address;
                })
                end
                begin
                    `uvm_do_on_with(trans[3], p_sequencer.cpu_seqr[3], {
                    request_type == READ_REQ;
                    access_cache_type == DCACHE_ACC;
                    address == common_address;
                })
                end
            join
        end
    endtask

endclass : multicore_stress_test_seq
