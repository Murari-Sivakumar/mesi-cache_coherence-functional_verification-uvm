//=====================================================================
// Project: 4 core MESI cache design
// File Name: test_lib.svh
// Description: Base test class and list of tests
// Designers: Venky & Suru
//=====================================================================
//add your testcase files in here

`include "base_test.sv"
`include "five_trans_test.sv"  //pass
`include "read_miss_icache.sv" //pass
`include "read_miss_dcache.sv" //pass
`include "write_miss_dcache.sv" //pass
`include "write_miss_icache.sv" //pass
`include "read_hit_shared.sv" //pass
`include "write_hit_me_dcache.sv" //MtoE PASS
`include "write_hit_shared.sv" //invalidate not high  - Different proc replacement. Shared on different proc.
`include "write_hit_shared_pass.sv" //shared not high - Last accessed same proc replacement.
`include "sequential_rw_dcache.sv" 
`include "read_miss_copy_modified.sv" 
`include "write_shared_mod.sv" //bus activity error
`include "write_miss_new.sv"

`include "fill_cache_way.sv" // LRU Error

`include "cover_mesi_transistions.sv"
`include "cover_mesi_lru_random_read.sv"
`include "cover_mesi_lru_eviction.sv"
`include "cover_mesi_lru_shared_conflict.sv"

`include "mesi_downgrade.sv"
`include "mesi_shared_invalidation.sv"
`include "fill_cache_way_all_core.sv"
`include "lv2_lru_replacement_test.sv"

`include "lv2_read_hit.sv"
`include "fill_cache_set_il.sv"
`include "modified_to_shared.sv"


// `include "simultaneous_req.sv"
`include "write_hit_lv2_eviction.sv"
`include "multicore_stress_test.sv"
`include "random_stress.sv"



