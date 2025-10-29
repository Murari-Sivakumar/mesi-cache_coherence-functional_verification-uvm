//=====================================================================
// Project: 4 core MESI cache design
// File Name: system_bus_interface.sv
// Description: Basic system bus interface including arbiter
//=====================================================================

`define LV2_WR_RESP_TIME        10
`define BUS_RD_RDX_RESP_TIME    15
`define INVALID_RESP_TIME       1

interface system_bus_interface(input clk);

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    parameter DATA_WID_LV1        = `DATA_WID_LV1       ;
    parameter ADDR_WID_LV1        = `ADDR_WID_LV1       ;
`ifdef ONE_CORE // check this def
    parameter NUM_CORE            = 1;
`elsif DUAL_CORE // ONE_CORE
    parameter NUM_CORE            = 2;
`else // TWO_CORE
    parameter NUM_CORE            = 4;
`endif // FOUR_CORE


    wire [DATA_WID_LV1 - 1 : 0] data_bus_lv1_lv2     ;
    wire [ADDR_WID_LV1 - 1 : 0] addr_bus_lv1_lv2     ;
    wire                        bus_rd               ;
    wire                        bus_rdx              ;
    wire                        lv2_rd               ;
    wire                        lv2_wr               ;
    wire                        lv2_wr_done          ;
    wire                        cp_in_cache          ;
    wire                        data_in_bus_lv1_lv2  ;

    wire                        shared               ;
    wire                        all_invalidation_done;
    wire                        invalidate           ;

    logic [NUM_CORE - 1  : 0]   bus_lv1_lv2_gnt_proc ;
    logic [NUM_CORE - 1  : 0]   bus_lv1_lv2_req_proc ;
    logic [NUM_CORE - 1  : 0]   bus_lv1_lv2_gnt_snoop;
    logic [NUM_CORE - 1  : 0]   bus_lv1_lv2_req_snoop;
    logic                       bus_lv1_lv2_gnt_lv2  ;
    logic                       bus_lv1_lv2_req_lv2  ;

//Assertions  TO-DO: ADD MORE!!

    //Checks if invalidation is done after proc invalidate req
    property invalidation_after_invalidate;
    @(posedge clk)
        $rose(invalidate) |=> all_invalidation_done;
    endproperty

    assert_invalidation_done_after_invalidate: assert property (invalidation_after_invalidate)
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_invalidation_done_after_invalidate Failed: all_invalidation_done does not go high after invalidate"))


    property invalidate_on_shared_write_hit;
    @(posedge clk)
        (bus_rd === 1'b0) && lv2_rd && shared |-> (invalidate ||bus_rdx);
    endproperty

    assert_invalidate_on_shared_write_hit: assert property (invalidate_on_shared_write_hit)
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_invalidate_on_shared_write_hit Failed: invalidate does not go high on a shared write hit"))







    //property that checks that signal_1 is asserted in the previous cycle of signal_2 assertion
    property prop_sig1_before_sig2(signal_1,signal_2);
    @(posedge clk)
        signal_2 |-> $past(signal_1);
    endproperty
    

    //lv2_wr_done should not be asserted without lv2_wr being asserted in previous cycle
    assert_lv2_wr_done: assert property (prop_sig1_before_sig2(lv2_wr,lv2_wr_done))
    else
    `uvm_error("system_bus_interface",$sformatf("Assertion assert_lv2_wr_done Failed: lv2_wr not asserted before lv2_wr_done goes high"))


    //data_in_bus_lv1_lv2 and cp_in_cache should not be asserted without lv2_rd being asserted in previous cycle
    assert_read_response: assert property (prop_sig1_before_sig2(lv2_rd,{data_in_bus_lv1_lv2|cp_in_cache}))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_read_response Failed: lv2_rd not asserted before either data_in_bus_lv1_lv2 or cp_in_cache goes high "))

    // Proc side: gnt should not be asserted without corresponding req
    generate
        for (genvar i = 0; i < NUM_CORE; i++)
        begin : assert_proc_req_before_gnt
            assert property (prop_sig1_before_sig2(bus_lv1_lv2_req_proc[i],bus_lv1_lv2_gnt_proc[i]))
            else
            `uvm_error("system_bus_interface",$sformatf("Assertion assert_proc_req_before_gnt Failed: proc_req not asserted before proc_gnt goes high"))
        end
    endgenerate

    // Snoop side: gnt should not be asserted without corresponding req
    generate
        for (genvar i = 0; i < NUM_CORE; i++)
        begin : assert_snoop_req_before_gnt
            assert property (prop_sig1_before_sig2(bus_lv1_lv2_req_snoop[i],bus_lv1_lv2_gnt_snoop[i]))
            else
            `uvm_error("system_bus_interface",$sformatf("Assertion assert_snoop_req_before_gnt Failed: snoop_req not asserted before snoop_gnt goes high"))
        end
    endgenerate

    // Lv2: gnt should not be asserted without corresponding req for proc side
    assert_lv2_req_before_gnt: assert property (prop_sig1_before_sig2(bus_lv1_lv2_req_lv2,bus_lv1_lv2_gnt_lv2))
    else
        `uvm_error("system_bus_interface",$sformatf("Assertion assert_lv2_req_before_gnt Failed: lv2_req not asserted before lv2_gnt goes high"))


//Added extra


//Checking for behavior for Processor Read Miss and free block is available
generate
  for (genvar i = 0; i < NUM_CORE; i++) begin : assert_bus_req_for_lv2_rd
    property lv2_read_requires_proc_request;
      @(posedge clk)
      (lv2_rd && bus_lv1_lv2_gnt_proc[i]) |-> $past(bus_lv1_lv2_req_proc[i]);
    endproperty

    assert_bus_req_for_lv2_rd: assert property (lv2_read_requires_proc_request)
    else
      `uvm_error("system_bus_interface", $sformatf("Core %0d: Grant for lv2_rd happened without matching bus request", i))
  end
endgenerate


//Checking for Snooping behavior

//Assertion 1: If data comes from snoop cache it musr set shared or lv2_wr based on MESI state

property snoop_response_must_set_shared_or_writeback;
  @(posedge clk)
  (cp_in_cache && data_in_bus_lv1_lv2) |-> (shared || lv2_wr);
endproperty

assert_snoop_response_must_set_shared_or_writeback: assert property (snoop_response_must_set_shared_or_writeback)
else
  `uvm_error("system_bus_interface", "Snoop responded with data, but MESI state not reflected via shared or lv2_wr")



//LV2 

property lv2_write_hit_completion;
  @(posedge clk)
  lv2_wr |-> ##[1:5] lv2_wr_done;
endproperty

assert_lv2_write_hit_completion: assert property (lv2_write_hit_completion)
else
  `uvm_error("system_bus_interface", "L2 write was initiated but never completed (lv2_wr_done missing)")




property lv2_write_data_validity;
  @(posedge clk)
  lv2_wr |-> !($isunknown(data_bus_lv1_lv2)) && !($isunknown(addr_bus_lv1_lv2));
endproperty

assert_lv2_write_data_validity: assert property (lv2_write_data_validity)
else
  `uvm_error("system_bus_interface", "L2 write triggered with unknown data/address")



endinterface


//Write miss validation check
