//=====================================================================
// Project: 4 core MESI cache design
// File Name: cpu_lv1_interface.sv
// Description: Basic CPU-LV1 interface with assertions
//=====================================================================

`define CPU_RD_RESP_TIME    100
`define CPU_WR_RESP_TIME    100

interface cpu_lv1_interface(input clk);

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    parameter DATA_WID_LV1           = `DATA_WID_LV1       ;
    parameter ADDR_WID_LV1           = `ADDR_WID_LV1       ;

    reg   [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1_reg = 32'hz ;

    wire  [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1        ;
    logic [ADDR_WID_LV1 - 1   : 0] addr_bus_cpu_lv1        ;
    logic                          cpu_rd                  ;
    logic                          cpu_wr                  ;
    logic                          cpu_rden                ;
    logic                          cpu_wren                ;
    logic                          cpu_wr_done             ;
    logic                          data_in_bus_cpu_lv1     ;

    assign data_bus_cpu_lv1 = data_bus_cpu_lv1_reg ;

    // initialization
    initial begin
      cpu_rd   = 1'b0;
      cpu_wr   = 1'b0;
      cpu_rden = 1'b0;
      cpu_wren = 1'b0;
    end

    //Assertions  TO-DO:  ADD MORE!!

    // cpu_wr and cpu_rd should not be asserted at the same clock cycle
    property prop_simult_cpu_wr_rd;
        @(posedge clk)
          not(cpu_rd && cpu_wr);
    endproperty

    assert_simult_cpu_wr_rd: assert property (prop_simult_cpu_wr_rd)
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_simult_cpu_wr_rd Failed: cpu_wr and cpu_rd asserted simultaneously"))

    // property that checks that signal_1 is asserted in the previous cycle of signal_2 assertion
    property prop_sig1_before_sig2(signal_1,signal_2);
    @(posedge clk)
        signal_2 |-> $past(signal_1);
    endproperty

    // cpu_wr_done should not be asserted without cpu_wr being asserted in previous cycle
    assert_cpu_wr_done: assert property (prop_sig1_before_sig2(cpu_wr,cpu_wr_done))
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_cpu_wr_done Failed: cpu_wr_done asserted without cpu_wr_done"))

    // data_in_bus_cpu_lv1 should not be asserted without cpu_rd being asserted in previous cycle
    assert_data_in_bus_cpu_rd: assert property (prop_sig1_before_sig2(cpu_rd,data_in_bus_cpu_lv1))
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_data_in_bus_cpu_rd Failed: data_in_bus_cpu_lv1 asserted without cpu_rd"))


    //Can I do the same above for cpu_wr

    // property that checks that signal_2 needs to be legal(should not have x's or z's) when signal_1 is asserted
    property prop_legal(signal_1,signal_2);
    @(posedge clk)
        signal_1  |-> not($isunknown(signal_2));
    endproperty

    assert_data_bus_legal: assert property (prop_legal({cpu_wr | data_in_bus_cpu_lv1},data_bus_cpu_lv1))
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_data_bus_legal Failed: data_bus_cpu_lv1 not legal when either cpu_wr or data_in_bus_cpu_lv1 are high"))

    assert_addr_bus_legal: assert property (prop_legal({cpu_rd | cpu_wr},addr_bus_cpu_lv1))
    else
        `uvm_error("cpu_lv1_interface",$sformatf("Assertion assert_addr_bus_legal Failed: addr_bus_cpu_lv1 is not legal value when either cpu_rd or cpu_wr is high"))


    // Data bus should be driven only when data_in_bus_cpu_lv1 is high
    // property data_bus_only_when_valid;
    // @(posedge clk)
    //     !$isunknown(data_bus_cpu_lv1) |=> data_in_bus_cpu_lv1;
    // endproperty

    // assert_data_bus_only_when_valid: assert property (data_bus_only_when_valid) 
    //     else `uvm_error("cpu_lv1_interface", "Data bus driven without data_in_bus_cpu_lv1 being high");



//Added

// Read hit must produce valid data response to CPU
property read_hit_produces_data;
  @(posedge clk)
  (cpu_rd && data_in_bus_cpu_lv1) |-> !($isunknown(data_bus_cpu_lv1));
endproperty

assert_read_hit_produces_data: assert property (read_hit_produces_data)
else
  `uvm_error("cpu_lv1_interface", "Read hit: data_in_bus_cpu_lv1 asserted but data_bus_cpu_lv1 is invalid")


endinterface
