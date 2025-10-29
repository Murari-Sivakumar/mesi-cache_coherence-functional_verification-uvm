//=====================================================================
// Project: 4 core MESI cache design
// File Name: cpu_mesi_lru_interface.sv
// Description: Basic interface for CPU MESI state and LRU replacement
//              signals of both I/D-cache
//=====================================================================

interface cpu_mesi_lru_interface(input clk);

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    parameter MESI_WID_LV1  = `MESI_WID_LV1;
    parameter ASSOC_WID_LV1 = `ASSOC_WID_LV1;

    // Proc and Snoop side MESI state for the cache set accessed
    wire [MESI_WID_LV1 - 1 : 0] current_mesi_proc;
    wire [MESI_WID_LV1 - 1 : 0] current_mesi_snoop;
    wire [MESI_WID_LV1 - 1 : 0] updated_mesi_proc;
    wire [MESI_WID_LV1 - 1 : 0] updated_mesi_snoop;

    wire cpu_rd;
    wire cpu_wr;
    wire bus_rd;
    wire bus_rdx;
    wire invalidate;

    wire [ASSOC_WID_LV1 - 1 : 0] lru_replacement_proc_dl;
    wire [ASSOC_WID_LV1 - 1 : 0] lru_replacement_proc_il;

    wire [ASSOC_WID_LV1 - 1 : 0] blk_accessed_main_dl;
    wire [ASSOC_WID_LV1 - 1 : 0] blk_accessed_main_il;

    wire lru_update_dl;
    wire lru_update_il;

    parameter INVALID   = 2'b00;
    parameter SHARED    = 2'b01;
    parameter EXCLUSIVE = 2'b10;
    parameter MODIFIED  = 2'b11;
    
   // TO-DO add coverage

    covergroup mesi_lru_cg @(posedge clk);

        option.per_instance = 1;
        option.name = "cover_mesi_lru";

    // Cover MESI states
        mesi_current_proc_cp: coverpoint current_mesi_proc {
            bins I = {2'b00};
            bins S = {2'b01};
            bins E = {2'b10};
            bins M = {2'b11};
        }

        mesi_updated_proc_cp: coverpoint updated_mesi_proc {
            bins I = {2'b00};
            bins S = {2'b01};
            bins E = {2'b10};
            bins M = {2'b11};
        }

        // Cover transitions: current → updated MESI state
        mesi_state_transition_cp: cross mesi_current_proc_cp, mesi_updated_proc_cp {
            // Illegal transitions
            illegal_bins invalid_ME = binsof(mesi_current_proc_cp.M) && binsof(mesi_updated_proc_cp.E);
            illegal_bins invalid_SE = binsof(mesi_current_proc_cp.S) && binsof(mesi_updated_proc_cp.E);
            }

        // Cover LRU replacement block
        lru_replacement_cp: coverpoint lru_replacement_proc_dl {
            bins blk0 = {2'b00};
            bins blk1 = {2'b01};
            bins blk2 = {2'b10};
            bins blk3 = {2'b11};
        }

        // Cover accessed block
        blk_accessed_cp: coverpoint blk_accessed_main_dl {
            bins blk0 = {3'b000};
            bins blk1 = {3'b001};
            bins blk2 = {3'b010};
            bins blk3 = {3'b011};
        }



    endgroup

    mesi_lru_cg mesi_lru_cg_inst = new();





    //Assertions 

    // This property checks that the MRU block is not replaced when it is accessed again    
    property no_replacement_of_mru;
    @(posedge clk)
        lru_update_dl |-> !(lru_replacement_proc_dl == blk_accessed_main_dl);
    endproperty

    assert_no_replacement_of_mru: assert property (no_replacement_of_mru);
    // else
    // `uvm_error("cpu_mesi_lru_interface",$sformatf("Assertion assert_no_replacement_of_mru Failed: MRU is being replaced"))

    // Blk0 LRU valid transition check
    property blk0_access_next_cycle_check;
    @(posedge clk)
        (lru_update_dl && blk_accessed_main_dl == 3'b000) |=> 
        (lru_replacement_proc_dl != 2'b00 && lru_replacement_proc_dl != 2'b01);
    endproperty

    assert_blk0_access_next_cycle_check: assert property (blk0_access_next_cycle_check);
    // else
    // `uvm_error("cpu_mesi_lru_interface",$sformatf("Assertion assert_blk0_access_next_cycle_check Failed: Blk0 replacement block is invalid"))


    // Blk1 LRU valid transition check
    property blk1_access_next_cycle_check;
    @(posedge clk)
        (lru_update_dl && blk_accessed_main_dl == 3'b001) |=> 
        (lru_replacement_proc_dl != 2'b00 && lru_replacement_proc_dl != 2'b01);
    endproperty

    assert_blk1_access_next_cycle_check: assert property (blk1_access_next_cycle_check);
    // else
    // `uvm_error("cpu_mesi_lru_interface",$sformatf("Assertion assert_blk1_access_next_cycle_check Failed: Blk1 replacement block is invalid"))


    // Blk2 LRU valid transition check
    property blk2_access_next_cycle_check;
    @(posedge clk)
        (lru_update_dl && blk_accessed_main_dl == 3'b010) |=> 
        (lru_replacement_proc_dl != 2'b10 && lru_replacement_proc_dl != 2'b11);
    endproperty

    assert_blk2_access_next_cycle_check: assert property (blk2_access_next_cycle_check);
    // else
    // `uvm_error("cpu_mesi_lru_interface",$sformatf("Assertion assert_blk2_access_next_cycle_check Failed: Blk2 replacement block is invalid"))

    // Blk3 LRU valid transition check
    property blk3_access_next_cycle_check;
    @(posedge clk)
        (lru_update_dl && blk_accessed_main_dl == 3'b011) |=> 
        (lru_replacement_proc_dl != 2'b10 && lru_replacement_proc_dl != 2'b11);
    endproperty

    assert_blk3_access_next_cycle_check: assert property (blk3_access_next_cycle_check);
    // else
    // `uvm_error("cpu_mesi_lru_interface",$sformatf("Assertion assert_blk3_access_next_cycle_check Failed: Blk3 replacement block is invalid"))

endinterface
