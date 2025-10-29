//=====================================================================
// Project: 4 core MESI cache design
// File Name: cpu_apb_interface.sv
// Description: Basic CPU-LV1 APB interface with assertions
//=====================================================================

interface cpu_apb_interface(input pclk);

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    parameter DATA_WID_LV1           = `DATA_WID_LV1       ;
    parameter ADDR_WID_LV1           = `ADDR_WID_LV1       ;

    logic                          presetn                 ;
    logic [ADDR_WID_LV1 - 1   : 0] paddr                   ;
    logic                          psel                    ;
    logic                          penable                 ;
    logic                          pwrite                  ;
    logic [DATA_WID_LV1 - 1   : 0] pwdata                  ;
    logic                          pready                  ;
    logic [DATA_WID_LV1 - 1   : 0] prdata                  ;
    logic                          pslverr                 ;

    // presetn generation
    //initial begin
    //    presetn = 1'b0;
    //    #10 presetn = 1'b1;
    //end

    // Assertions
    // property that checks that signal_1 is asserted in the previous cycle of signal_2 assertion
    property prop_sig1_before_sig2(signal_1,signal_2);
    @(posedge pclk)
        signal_2 |-> $past(signal_1);
    endproperty

    // penable should not be asserted without psel being asserted in previous cycle
    assert_psel_before_penable: assert property (prop_sig1_before_sig2(psel,penable))
    else
        `uvm_error("cpu_apb_interface",$sformatf("Assertion assert_psel_before_penable Failed: psel not asserted before penable"))

    // property that checks that signal_1 is asserted in the same cycle of signal_2 assertion
    property prop_sig1_same_sig2(signal_1,signal_2);
    @(posedge pclk)
        signal_2 |-> signal_1;
    endproperty

    // penable should not be asserted without psel being asserted in same cycle
    assert_psel_with_penable: assert property (prop_sig1_same_sig2(psel,penable))
    else
        `uvm_error("cpu_apb_interface",$sformatf("Assertion assert_psel_with_penable Failed: penable asserted without psel"))

    // property that checks that signal_2 needs to be legal(should not have x's or z's) when signal_1 is asserted
    property prop_legal(signal_1,signal_2);
    @(posedge pclk)
        signal_1  |-> not($isunknown(signal_2));
    endproperty

    assert_pwdata_legal: assert property (prop_legal({psel & pwrite},pwdata))
    else
        `uvm_error("cpu_apb_interface",$sformatf("Assertion assert_pwdata_legal Failed: pwdata is not legal during APB Write"))

    assert_addr_legal: assert property (prop_legal(psel,paddr))
    else
        `uvm_error("cpu_apb_interface",$sformatf("Assertion assert_paddr_legal Failed: paddr is not legal during APB transfer"))

    assert_prdata_legal: assert property (prop_legal({psel & !pwrite & pready},prdata))
    else
        `uvm_error("cpu_apb_interface",$sformatf("Assertion assert_prdata_legal Failed: prdata is not legal during APB Read"))

    // property that checks that signal_2 needs to be stable when signal_1 is asserted
    property prop_stable(signal_1,signal_2);
    @(posedge pclk)
        $rose(signal_1)  |=> $stable(signal_2) until $fell(signal_1);
    endproperty

    assert_pwdata_stable: assert property (prop_stable({psel & pwrite},pwdata))
    else
        `uvm_error("cpu_apb_interface",$sformatf("Assertion assert_pwdata_stable Failed: pwdata is not stable during APB Write"))

    assert_paddr_stable: assert property (prop_stable(psel,paddr))
    else
        `uvm_error("cpu_apb_interface",$sformatf("Assertion assert_paddr_stable Failed: paddr is not stable during APB transfer"))

    assert_prdata_stable: assert property (prop_stable({psel & !pwrite & pready},prdata))
    else
        `uvm_error("cpu_apb_interface",$sformatf("Assertion assert_prdata_stable Failed: prdata is not stable during APB Read"))

    // the following is from Cadence VIPCAT apb_monitor.sv

    //int  PSEL_N = 1;   // Number of slaves present, i.e. width of psel signal;

    //____________________________________________________Out of Reset logic

    reg out_of_reset;
    always_ff @(posedge pclk or negedge presetn) begin : flops
      if (!presetn) begin
        out_of_reset <= 1'b1;
      end
      else if (presetn && out_of_reset) begin
        out_of_reset <= 1'b0;
      end
      else begin
        out_of_reset <= out_of_reset;
      end
    end

    //____________________________________________________previous psel logic

    reg psel_prev;
    always @ (posedge pclk or negedge presetn) begin
      if (~presetn) psel_prev <= 0;
      else psel_prev <= psel;
    end

    //Current APB bus state
    typedef enum bit[1:0] {IDLE, SETUP, ACCESS, ERROR} apb_states_e;
    apb_states_e state;

    assign state = (~|(psel) && ~penable) ? IDLE   :
                   (|(psel) && ~penable)  ? SETUP  :
                   (|(psel) &&  penable) ? ACCESS :
                                ERROR ;

    //____________________________________________________RESET CHECKS

    // Default clocking block for all properties defined from here on
    clocking apb_clk @(posedge pclk);
    endclocking
    default clocking apb_clk;

    wire idle_state   = (~|psel && !penable);
    wire setup_state  = ( |psel && !penable);
    wire access_state = ( |psel &&  penable);

    // Reset Checks
    //default disable iff 1'b0;

    // APB Spec v1.0    : Section 3.1 on page 3-2
    // Description      : The default state for APB bus is IDLE
    // Critical Signals : psel, penable, presetn
    //master_idle_during_reset: assert property (
    // !presetn |-> idle_state);

    // APB Spec v1.0    : Section 3.1 on page 3-2
    // Description      : The default state for APB bus is IDLE
    // Critical Signals : psel, penable, presetn
    //master_idle_after_reset_released: assert property (
    // out_of_reset |-> idle_state);

    // Default disable iff reset goes low
    default disable iff !presetn;

    //____________________________________________________APB XCHECKS

    // APB Spec v1.0    : Section 2.1.1 on page 2-2
    // Description      : The address PADDR, write data PWDATA, and control signals
    //                    all remain valid until the transfer completes at the
    //                    end of the enable cycle
    // Critical Signals : psel, penable, pwrite, pwdata
    master_access_paddr_xcheck: assert property (
     setup_state |-> !$isunknown(paddr));

    master_access_pwrite_xcheck: assert property (
     setup_state |-> !$isunknown(pwrite));

    master_access_pwdata_xcheck : assert property (
     (setup_state && pwrite) |-> !$isunknown(pwdata));

    //slave_access_pslverr_xcheck : assert property (
    // (|psel && penable && pready) |-> !$isunknown(pslverr));

    // APB Spec v1.0    : Section 2.2.1 on page 2-4
    // Description      : A slave must provide valid data for READ transfers
    //                    in final transfer of ACCESS state
    // Critical Signals : prdata, penable, psel, pwrit, pready
    slave_access_prdata_xcheck : assert property (
     (access_state && pready && !pwrite) |-> !$isunknown(prdata));

    //____________________________________________________STABILITY ASSERTIONS

    // APB Spec v1.0    : Section 2.1.2 on page 2-3
    // Description      : It is recommended that the address and write signals are
    //                    not changed immediately after a transfer, but remain stable
    //                    until another access occurs. This reduces power consumption
    // Critical Signals : psel, penable, paddr
    //master_idle_paddr_stable: assert property (
    // (!out_of_reset && idle_state) |-> $stable(paddr));

    //master_idle_pwrite_stable: assert property (
    // (!out_of_reset && idle_state) |-> $stable(pwrite));

    // APB Spec v1.0    : Section 3.1 on page 3-2
    // Description      : The address, write and select signals all remain stable
    //                    during the transition from SETUP to ACCESS state
    // Critical Signals : psel, penable, pwrite, paddr, pwdata
    master_setup_psel_stable: assert property (
     setup_state |=> $stable(psel));

    master_setup_paddr_stable: assert property (
     setup_state |=> $stable(paddr));

    master_setup_pwrite_stable: assert property (
     setup_state |=> $stable(pwrite));

    master_setup_pwdata_stable: assert property (
     (setup_state && pwrite) |=> $stable(pwdata));

    // APB Spec v1.0   : Section 3.1 on page 3-2
    // Description     : If PREADY is held low by slave then the peripheral bus
    //                   remains in the ACCESS state and all signals have to be stable
    // Critical Signals: psel, penable, pready, paddr, pwrite, pwdata
    //if (!NO_WAIT_STATES) begin: stable_checks
    master_access_penable_stable: assert property (
     (access_state && !pready) |=> penable);

    master_access_psel_stable: assert property (
     (access_state && !pready) |=> $stable(psel));

    master_access_paddr_stable: assert property (
     (access_state && !pready) |=> $stable(paddr));

    master_access_pwrite_stable: assert property (
     (access_state && !pready) |=> $stable(pwrite));

    master_access_pwdata_stable: assert property (
     (access_state && !pready && pwrite) |=> $stable(pwdata));
    //end: stable_checks

    //____________________________________________________APB TRANSITION ASSERTIONS

    // APB Spec v2.0   : Section 2.1
    // Description     : Penable can only be asserted one clock after psel for that transfer
    // Critical Signals: psel, penable
    master_never_penable_first_clock : assert property (
     ~|psel_prev |-> !penable);

    // APB Spec v1.0    : Section 3.1 on page 3-2
    // Description      : Master cannot transition directly from IDLE state to ACCESS state
    // Critical Signals : psel, penable
    master_never_idle_to_enable: assert property (
     idle_state |=> !penable);

    // APB Spec v1.0    : Section 3.1 on page 3-2
    // Description      : The bus only remains in the SETUP state for one clock cycle
    //                    and always moves to the ACCESS state on the next
    //                    rising edge of the clock
    // Critical Signals : psel, penable
    master_setup_to_access: assert property (
     setup_state |=> access_state);

    // APB Spec v1.0    : Section 3.1 on page 3-3
    // Description      : If PREADY is driven HIGH by the slave then the ACCESS
    //                    is exited
    // Critical Signals : psel, penable
    master_exit_access: assert property (
     (access_state && pready) |=> !penable);

    // APB Spec v1.0    : Section 3.1 on page 3-2
    // Description      : PENABLE can not go high while PSEL is low
    //                    is exited
    // Critical Signals : psel, penable
    master_never_penable_without_psel: assert property (
     !((psel !== 1) && (penable === 1)));

    // psel is slave select signal. Master selects at most one slave at a time.
    //if (PSEL_N > 1) begin: onehot
    // master_select_at_most_one_slave: assert property (
    //  |psel |-> $onehot(psel));
    //end: onehot

    // if (NO_WAIT_STATES) begin: nowaitstates

    // APB Spec v1.0   : Section 2.1.1 on page 2-2
    // Description     : If MAX_WAIT_CYCLES_ON = 1 and MAX_WAIT_CYCLES = 0,
    //                   then there are no wait states, and pready must
    //                   always be high when (psel & penable).
    // Critical Signals: penable, psel, pready
    //slave_pready_no_wait_cycles : assert property (
    // access_state |-> pready);

    // end: nowaitstates

    // if (MAX_WAIT_CYCLES_ON && (MAX_WAIT_CYCLES != 0)) begin: genWaitChks

    // APB Spec v1.0   : Section 2.1.2 on page 2-2
    // Description     : The maximum number of cycles for which PREADY
    //                   remains low after entering ACCESS state must not
    //                   exceed the MAX_WAIT_CYCLES specified
    // Critical Signals: penable, psel, pready
    //slave_pready_wait_cycles : assert property (
    // (access_state && !pready)  |-> (!pready[*1:MAX_WAIT_CYCLES] ##1 pready));

    // end: genWaitChks

    // if (!MAX_WAIT_CYCLES_ON) begin: genLiveChks

    // APB Spec v1.0   : Section 2.1.2 on page 2-2
    // Description     : PREADY must eventually go high
    // Critical Signals: penable, psel, pready
    slave_pready_eventually : assert property (
     (access_state && !pready)  |-> (##[0:$] pready));

    // end: genLiveChks

    //____________________________________________________COVERAGE_ON

    //____________________________________________________APB TRANSITION COVERS

      cover_idle_state              : cover property (idle_state);
      cover_setup_state             : cover property (setup_state);
      cover_access_state            : cover property (access_state);
      cover_setup_after_idle_state  : cover property (idle_state ##1 setup_state);
      cover_access_after_setup_state: cover property (setup_state ##1 access_state);
      cover_setup_after_access_state: cover property (access_state ##1 setup_state);
      cover_idle_after_access_state : cover property (access_state ##1 idle_state);
      cover_idle_after_idle_state   : cover property (idle_state ##1 idle_state);

    //____________________________________________________READ & WRITE COVERS

      cover_write_transfer          : cover property  ((pwrite && setup_state) ##1
                                                       (pwrite && access_state));
      cover_read_transfer           : cover property ((!pwrite && setup_state) ##1
                                                      (!pwrite && access_state));

      //if (!NO_WAIT_STATES) begin: nnw
      cover_write_transfer_with_wait_states: cover property (
                                                    (pwrite && access_state && !pready)[*1:$] ##1
                                                    (pwrite && access_state &&  pready));
      cover_read_transfer_with_wait_states : cover property (
                                                    (!pwrite && access_state && !pready)[*1:$] ##1
                                                    (!pwrite && access_state &&  pready));
      //end: nnw

      cover_burst_of_write_transfers       : cover property (
                                                    ((pwrite && setup_state) ##1
                                                    ( pwrite && access_state && !pready)[*0:$] ##1
                                                    ( pwrite && access_state && pready))[*2]);
      cover_burst_of_read_transfers        : cover property (
                                                   ((!pwrite && setup_state) ##1
                                                    (!pwrite && access_state && !pready)[*0:$] ##1
                                                    (!pwrite && access_state && pready))[*2]);

      cover_read_after_write_transfer      : cover property (
                                                     (pwrite && setup_state) ##1
                                                     (pwrite && access_state)[*1:$] ##1
                                                    (!pwrite && setup_state) ##1
                                                    (!pwrite && access_state));
      cover_write_after_read_transfer      : cover property (
                                                    (!pwrite && setup_state) ##1
                                                    (!pwrite && access_state)[*1:$] ##1
                                                     (pwrite && setup_state) ##1
                                                     (pwrite && access_state));

    //____________________________________________________
    //Covergroups

    covergroup signal_values_cg @(posedge pclk);
       option.per_instance = 1;
       option.name = "cover_cpu_apb";

       cp_paddr : coverpoint paddr {
         bins eight_bit = {8'h00, 8'h0f, 8'h10, 8'hf0, 8'hff};
         bins sixteen_bit = {16'h01ff, 16'h0f00, 16'h1f00, 16'hff00, 16'hffff};
         bins thirty2_bit = {32'h0001ffff, 32'h00ff00ff, 32'h55555555, 32'haaaaaaaa, 32'hffffffff, 32'hffff0000};
       }

       //cp_psel : coverpoint which_psel {
       //   ignore_bins unwanted = {[PSEL_N : $]};
       //}

       cp_pwrite : coverpoint pwrite iff (state==ACCESS);

       cp_state_transition : coverpoint state {
         bins tran_idle_setup = (IDLE => SETUP);
         bins tran_setup_access = (SETUP => ACCESS);
         bins tran_access_idle = (ACCESS => IDLE);
         bins tran_access_setup = (ACCESS => SETUP);
         bins tran_idle_setup_access = (IDLE => SETUP => ACCESS);
         bins tran_access_wait = (SETUP => ACCESS => ACCESS => ACCESS);
       }

       //cp_wait_states : coverpoint pready iff (state==ACCESS && !NO_WAIT_STATES) {
       cp_wait_states : coverpoint pready iff (state==ACCESS) {
         bins wait_state = (0=>0=>1);
       }

    endgroup

    signal_values_cg signal_values_cg_inst = new();


endinterface
