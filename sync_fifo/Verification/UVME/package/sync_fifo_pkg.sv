package sync_fifo_pkg;

 import uvm_pkg::*;
`include "uvm_macros.svh"

// sync_fifo_seq_item, seqcr
`include "./../UVME/sequence/sync_fifo_seq_item.sv"
`include "./../UVME/agent/sync_fifo_sequencer.sv"

//sequences

`include "./../UVME/sequence/sync_fifo_base_sequence.sv"
`include "./../UVME/sequence/sync_fifo_reset_sequence.sv"
`include "./../UVME/sequence/sync_fifo_write_sequence.sv"
`include "./../UVME/sequence/sync_fifo_read_sequence.sv"
`include "./../UVME/sequence/sync_fifo_write_read_sequence.sv"
`include "./../UVME/sequence/sync_fifo_af_sequence.sv"
`include "./../UVME/sequence/sync_fifo_ae_sequence.sv"
//`include "./../UVME/sequence/sync_fifo_rand_sequence.sv"
`include "./../UVME/sequence/sync_fifo_exm_full_sequence.sv"
`include "./../UVME/sequence/sync_fifo_exm_empty_sequence.sv"
`include "./../UVME/sequence/sync_fifo_of_sequence.sv"
`include "./../UVME/sequence/sync_fifo_uf_sequence.sv"


//syn_fifo_syn_fifo_agent: syn_fifo_driver , syn_fifo_monitor, syn_fifo_agent
`include "./../UVME/agent/sync_fifo_driver.sv"
`include "./../UVME/agent/sync_fifo_monitor.sv"
`include "./../UVME/env/sync_fifo_scoreboard.sv"
`include "./../UVME/agent/sync_fifo_agent.sv"

//syn_fifo_env
`include "./../UVME/env/sync_fifo_env.sv"

//test
`include "./../UVME/test/sync_fifo_test.sv"
`include "./../UVME/test/sync_fifo_reset_test.sv"
`include "./../UVME/test/sync_fifo_write_test.sv"
`include "./../UVME/test/sync_fifo_read_test.sv"
`include "./../UVME/test/sync_fifo_write_read_test.sv"
`include "./../UVME/test/sync_fifo_af_test.sv"
`include "./../UVME/test/sync_fifo_ae_test.sv"
//`include "./../UVME/test/sync_fifo_rand_test.sv"
`include "./../UVME/test/sync_fifo_exm_full_test.sv"
`include "./../UVME/test/sync_fifo_exm_empty_test.sv"
`include "./../UVME/test/sync_fifo_of_test.sv"
`include "./../UVME/test/sync_fifo_uf_test.sv"


endpackage
