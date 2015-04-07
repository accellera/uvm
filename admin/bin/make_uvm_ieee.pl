#!/usr/intel/bin/perl -w

########################################################################
#
# make_uvm_ieee.pl
#
# Convert UVM BCL to IEEE compliance by renaming all 
# 
# Original Author: Thomas R. Alsop
# Original Date  : 02/17/15
#
# One line perl subsitution command: 
# perl -p -e 's/SOURCEFILE\s+"bsl1qs.ifc"/SCANSOURCEFILE "bsl1qs.ifc"/i;'
# perl -p -e 's/SOURCEFILE\s+"bsl1qs.ifc"/SCANSOURCEFILE "bsl1qs.ifc"/i;'
#
# An example of how to do a powerful one line regx greps
# grep MSFF bs*.hdl | perl -p -e 'print if /\d\d\d/;'
#
# Here are some BKM's from JackL's scripts writing techniques:
#
# - Use [] for optional switches, <> around string arguments
# - $usage = "$0 fub <fub> -ward <ward> [-no_sim]"
# - $0 is a magic perl variable with the full path to the program being called
#
# Notes from Miles Perl BKM's
# ---------------------------
# NYTProf - best Perl profiler on the market
#   setenv PERLLIB <path to perl library>
#   perl -d:NYTProf <your program> <args to your program>
#   Dumps results to a file (nytprof.out) in the CWD 
#
#
########################################################################

########################################################################
#
# Libraries/Packages
#
########################################################################

# Save revision info from RCS into a variable so we can easily format
# it in the output file of this script for reference.
#
$program_id = "Description Here";
($rcs_ver = '$Revision:  $ ') =~ s/^\$(.*)\$\s*$/$1/;

## Set output to flush regularly
##
select((select(STDOUT),$| = 1)[0]);
select((select(STDERR),$| = 1)[0]);

#use lib "/p/hdk/rtl/proj_tools/proj_binx/cds/latest/perllib";
#use Util;
# use Time::HiRes

#&Util::parse_opts("h",
#                  "dep",
#                  "--checkout|-f:",
#                  );
if ($opt_dep) {
   $insert_deprecation = 1;
} else {
   $insert_deprecation = 0;
}

if ($opt_h) {
    $opt_help = 1;
    &usage();
}

########################################################################
#
# Global Variables
#
########################################################################

my($path) = `apwd`;
chop($path);

@bcl = (      "uvm.sv",
              "uvm_macros.svh",
              "uvm_pkg.sv",
              "base/uvm_barrier.svh",
              "base/uvm_base.svh",
              "base/uvm_bottomup_phase.svh",
              "base/uvm_callback.svh",
              "base/uvm_cmdline_processor.svh",
              "base/uvm_common_phases.svh",
              "base/uvm_comparer.svh",
              "base/uvm_component.svh",
              "base/uvm_config_db.svh",
              "base/uvm_coreservice.svh",
              "base/uvm_domain.svh",
              "base/uvm_event.svh",
              "base/uvm_event_callback.svh",
              "base/uvm_factory.svh",
              "base/uvm_globals.svh",
              "base/uvm_heartbeat.svh",
              "base/uvm_links.svh",
              "base/uvm_misc.svh",
              "base/uvm_object.svh",
              "base/uvm_object_globals.svh",
              "base/uvm_objection.svh",
              "base/uvm_packer.svh",
              "base/uvm_phase.svh",
              "base/uvm_pool.svh",
              "base/uvm_port_base.svh",
              "base/uvm_printer.svh",
              "base/uvm_queue.svh",
              "base/uvm_recorder.svh",
              "base/uvm_registry.svh",
              "base/uvm_report_catcher.svh",
              "base/uvm_report_handler.svh",
              "base/uvm_report_message.svh",
              "base/uvm_report_object.svh",
              "base/uvm_report_server.svh",
              "base/uvm_resource.svh",
              "base/uvm_resource_db.svh",
              "base/uvm_resource_specializations.svh",
              "base/uvm_root.svh",
              "base/uvm_runtime_phases.svh",
              "base/uvm_spell_chkr.svh",
              "base/uvm_task_phase.svh",
              "base/uvm_topdown_phase.svh",
              "base/uvm_tr_database.svh",
              "base/uvm_tr_stream.svh",
              "base/uvm_transaction.svh",
              "base/uvm_traversal.svh",
              "base/uvm_version.svh",
              "comps/uvm_agent.svh",
              "comps/uvm_algorithmic_comparator.svh",
              "comps/uvm_comps.svh",
              "comps/uvm_driver.svh",
              "comps/uvm_env.svh",
              "comps/uvm_in_order_comparator.svh",
              "comps/uvm_monitor.svh",
              "comps/uvm_pair.svh",
              "comps/uvm_policies.svh",
              "comps/uvm_push_driver.svh",
              "comps/uvm_random_stimulus.svh",
              "comps/uvm_scoreboard.svh",
              "comps/uvm_subscriber.svh",
              "comps/uvm_test.svh",
              "dap/uvm_dap.svh",
              "dap/uvm_get_to_lock_dap.svh",
              "dap/uvm_set_before_get_dap.svh",
              "dap/uvm_set_get_dap_base.svh",
              "dap/uvm_simple_lock_dap.svh",
              "deprecated/readme.important",
              "deprecated/uvm_resource_converter.svh",
              "dpi/uvm_common.c",
              "dpi/uvm_dpi.cc",
              "dpi/uvm_dpi.h",
              "dpi/uvm_dpi.svh",
              "dpi/uvm_hdl.c",
              "dpi/uvm_hdl.svh",
              "dpi/uvm_hdl_inca.c",
              "dpi/uvm_hdl_questa.c",
              "dpi/uvm_hdl_vcs.c",
              "dpi/uvm_regex.cc",
              "dpi/uvm_regex.svh",
              "dpi/uvm_svcmd_dpi.c",
              "dpi/uvm_svcmd_dpi.svh",
              "macros/uvm_callback_defines.svh",
              "macros/uvm_deprecated_defines.svh",
              "macros/uvm_global_defines.svh",
              "macros/uvm_message_defines.svh",
              "macros/uvm_object_defines.svh",
              "macros/uvm_phase_defines.svh",
              "macros/uvm_printer_defines.svh",
              "macros/uvm_reg_defines.svh",
              "macros/uvm_sequence_defines.svh",
              "macros/uvm_tlm_defines.svh",
              "macros/uvm_undefineall.svh",
              "macros/uvm_version_defines.svh",
              "reg/uvm_mem.svh",
              "reg/uvm_mem_mam.svh",
              "reg/uvm_reg.svh",
              "reg/uvm_reg_adapter.svh",
              "reg/uvm_reg_backdoor.svh",
              "reg/uvm_reg_block.svh",
              "reg/uvm_reg_cbs.svh",
              "reg/uvm_reg_field.svh",
              "reg/uvm_reg_fifo.svh",
              "reg/uvm_reg_file.svh",
              "reg/uvm_reg_indirect.svh",
              "reg/uvm_reg_item.svh",
              "reg/uvm_reg_map.svh",
              "reg/uvm_reg_model.svh",
              "reg/uvm_reg_predictor.svh",
              "reg/uvm_reg_sequence.svh",
              "reg/uvm_vreg.svh",
              "reg/uvm_vreg_field.svh",
              "seq/uvm_push_sequencer.svh",
              "seq/uvm_seq.svh",
              "seq/uvm_sequence.svh",
              "seq/uvm_sequence_base.svh",
              "seq/uvm_sequence_builtin.svh",
              "seq/uvm_sequence_item.svh",
              "seq/uvm_sequence_library.svh",
              "seq/uvm_sequencer.svh",
              "seq/uvm_sequencer_analysis_fifo.svh",
              "seq/uvm_sequencer_base.svh",
              "seq/uvm_sequencer_param_base.svh",
              "tlm1/uvm_analysis_port.svh",
              "tlm1/uvm_exports.svh",
              "tlm1/uvm_imps.svh",
              "tlm1/uvm_ports.svh",
              "tlm1/uvm_sqr_connections.svh",
              "tlm1/uvm_sqr_ifs.svh",
              "tlm1/uvm_tlm.svh",
              "tlm1/uvm_tlm_fifo_base.svh",
              "tlm1/uvm_tlm_fifos.svh",
              "tlm1/uvm_tlm_ifs.svh",
              "tlm1/uvm_tlm_imps.svh",
              "tlm1/uvm_tlm_req_rsp.svh",
              "tlm2/uvm_tlm2.svh",
              "tlm2/uvm_tlm2_defines.svh",
              "tlm2/uvm_tlm2_exports.svh",
              "tlm2/uvm_tlm2_generic_payload.svh",
              "tlm2/uvm_tlm2_ifs.svh",
              "tlm2/uvm_tlm2_imps.svh",
              "tlm2/uvm_tlm2_ports.svh",
              "tlm2/uvm_tlm2_sockets.svh",
              "tlm2/uvm_tlm2_sockets_base.svh",
              "tlm2/uvm_tlm2_time.svh",
              "reg/sequences/uvm_mem_access_seq.svh",
              "reg/sequences/uvm_mem_walk_seq.svh",
              "reg/sequences/uvm_reg_access_seq.svh",
              "reg/sequences/uvm_reg_bit_bash_seq.svh",
              "reg/sequences/uvm_reg_hw_reset_seq.svh",
              "reg/sequences/uvm_reg_mem_built_in_seq.svh",
              "reg/sequences/uvm_reg_mem_hdl_paths_seq.svh",
              "reg/sequences/uvm_reg_mem_shared_access_seq.svh");


@non_user_apis = (    "top_levels",                            ## Mantis 5077
# TEST that FAILED: 01report/90Mantis/3550_show_root_knob
# TEST that FAILED: 05components/90Mantis/3314toplevels
# Error-[MFNF] Member not found test.sv, 100 "uvm_top."
# Could not find member 'top_levels' in class 'uvm_root', at 
# test.vs -->  if(uvm_top.top_levels.size() != 3) begin
## AI - 3314 should go away, i.e. remove it from the test list.  3550 - let's
## rewrite this one.  Adiel will look at 3550.
## Notes that 3314 was a ticket to add this back in after it was previously deprecated.

                      "uvm_utils",                             ## Mantis 5075
# TEST that FAILED: 70regs/80examples/02integration/10direct_impl
# 70regs/80examples/10oc_ethernet/tb_env.sv:      seqr = uvm_utils#(wb_sequencer)::find(host);
# 70regs/80examples/10oc_ethernet/tb_env.sv:       seq = uvm_utils #(uvm_reg_sequence)::create_type_by_name(seq_name,"tb");
# Error-[IND] Identifier not declared
# ../common/test.sv, 50
#  Identifier 'uvm_utils' has not been declared yet. If this error is not 
#  expected, please check if you have set `default_nettype to none.
# AI - This is simply an example of a test where we are testing internal
# implementation.  Tom to leave this test as failing.                 


                      #"uvm_top",                               ## Mantis 5078 & 5188 (duplicate) - introduces cross module resolution errors
                      # Committee decided to leave uvm_top alone.  Deprecation path.
                      "uvm_port_component_base",               ## Mantis 5079
                      "get_comp",                              ## Mantis 5081
                      "format_action",                         ## Mantis 5083
                      "uvm_text_tr_stream",                    ## Mantis 5086
                      "uvm_text_recorder",                     ## Mantis 5086/5119 (duplicate)
                      "uvm_text_tr_database",                  ## Mantis 5086

                      "uvm_tlm_if_base",                       ## Mantis 5101 - cannot script as code replacement is already in a macro
# Test that FAILED: 70regs/80examples/02integration/10direct_expl
# Error-[IND] Identifier not declared
# /nfs/site/disks/dts_cds_fe_23/work/talsop/uvm/uvm-1.2-RC8/distrib/src/tlm1/uvm_ports.svh, 82
#   Identifier 'uvm_tlm_if_base_ieee' has not been declared yet. If this error 
#   is not expected, please check if you have set `default_nettype to none.
# Error-[SE] Syntax error
#   Following verilog source has syntax error :
#   "/nfs/site/disks/dts_cds_fe_23/work/talsop/uvm/uvm-1.2-RC8/distrib/src/tlm1/uvm_ports.svh",
#   82: token is '#'
#     extends uvm_port_base #(uvm_tlm_if_base_ieee #(T,T));



                      "UVM_TLM_NB_FW_MASK",                    ## Mantis 5103
                      "UVM_TLM_NB_BW_MASK",                    ## Mantis 5103
                      "UVM_TLM_B_MASK",                        ## Mantis 5103
                      "uvm_string_to_bits",                    ## Mantis 5126
                      "uvm_bits_to_string",                    ## Mantis 5126
                      "format_row",                            ## Mantis 5116
                      "format_header",                         ## Mantis 5116
                      "format_footer",                         ## Mantis 5116
                      "5.adjust_name",                           ## Mantis 5116
                      "events",                                ## Mantis 5184

                      "get_inst_id",                           ## Mantis 5192   - cannot script as code replacement is already in a macro
# Error-[MFNF] Member not found test.sv, 93 "this.build_ph."
# Could not find member 'get_inst_id' in class 'uvm_phase', at 
# test.vs -->  $display("uvm_build_ph id is %0d type=%s",build_ph.get_inst_id(),build_ph.get_phase_type());
# AI - Tom to fix the test to remove this string.  Just replace with a string,
# or remove it. 
                      
                      "get_inst_count",                        ## Mantis 5192 - cannot script as code replacement is already in a macro
                      #"uvm_object_string_pool",                ## Mantis 5205  - elaboration/linking error related to
                      # object_string_pool. Committee decided to take the deprecation path for uvm_object_string_pool
                      "uvm_random_stimulus",                   ## Mantis 5136

                      "uvm_report_message_element_base",       ## Mantis 5228
                      "uvm_report_message_int_element",        ## Mantis 5228
                      "uvm_report_message_string_element",     ## Mantis 5228
                      "uvm_report_message_object_element",     ## Mantis 5228
                      "uvm_report_message_element_container",  ## Mantis 5228
# Test that FAILED: 01report/00message/40del_elements
#  Error-[SE] Syntax error
#  Following verilog source has syntax error :
#  	Token 'uvm_report_message_element_base' not recognized as a type. 
#  Please check whether it is misspelled, not visible/valid in the current 
#  context, or not properly imported/exported. This is occurring in a context 
#  where a variable declaration, a statement, or a sequence expression is 
#  expected. Either the declaration type is not known or this is incorrect 
#  syntax.
#  "test.sv", 41: token is ';'
#      uvm_report_message_element_base elements[$];
# AI - Tom to leave this string into the reduction BCL change.  Leave the test
# as failing.  

                      "record_read_access",                    ## Mantis 5097
                      "record_write_access",                   ## Mantis 5097
                      "print_accessors",                       ## Mantis 5097
                      "init_access_record",                    ## Mantis 5097



# Mantis 5203.  MarkS suggestion "If the library is using a non-0 override
# argument, I think we need to rename set() to set_internal(), make a new
# method set() that calls set_internal without passing override, and make the
# library call use set_internal() instead of set(). ".  My response to him was "Makes sense as we want end users to use the 
# <set_override>, <set_name_override>, or <set_type_override> methods, not set with their own override argument
                      
    );

########################################################################
#
# MAIN
#
########################################################################

## I want to take all the API's specified and wrap them in this code.  This
## utility will identify the API strings and wrap it with the UVM_NO_IEEE define.
##
##  `ifndef UVM_NO_IEEE 
##    uvm_component top_levels[$]; 
##  `else
##    uvm_component top_levels_ieee[$];
##  `endif
##
foreach $file (@bcl) {
   open(CODE, "$file") || die ("ERROR:  Cannot open $file.\n");
   system("rm -f ../src/$file");
   open(NEW, ">../src/$file") || die ("ERROR:  Cannot open $file.\n");
   while (<CODE>) {
       #chomp;
       $api_string_not_found = 1;
       foreach $api (@non_user_apis) {
           
           ## Coding exception for Mantis 5136
           ##
           next if (($api eq "uvm_random_stimulus") && (/include/));

           ## Coding exception for Mantis 5184
           ##
           if ($api eq "events") {
               if (/const uvm_event_pool events/) {
                   print NEW ("  `ifndef UVM_NO_IEEE\n") if $insert_deprecation;
                   print(NEW) if $insert_deprecation;
                   print NEW ("  `else\n") if $insert_deprecation;
                   s/const uvm_event_pool events/local const uvm_event_pool events/g; ## global substitution option provided
                   #print NEW ("  local const uvm_event_pool events = new\;\n");
                   print NEW ("  `endif\n") if $insert_deprecation;
               }
           }
           
           ##
           ## Strings that I want to swap out
           ##  /~uvm_top~/
           ##  /uvm_top./
           ##  /"uvm_top"/
           ##  /uvm_top /
           ##  /uvm_top)/
           ##  /uvm_top,/
           ##
           ## Strings that I do NOT want to swap out
           ##  /uvm_topdown/  - character after the string
           ##  /uvm_top_/     - underscore character after the string
           ##  /m_uvm_top/    - character before the string
           ##
           elsif ((/$api/) && !((/$api[a-zA-Z_]/) || (/[a-zA-Z_]$api/))) {
               #print("DEBUG: String Found -> $_");
               print NEW ("  `ifndef UVM_NO_IEEE\n") if $insert_deprecation;
               print(NEW) if $insert_deprecation;
               print NEW ("  `else\n") if $insert_deprecation;
               $api_ieee = $api . "_ieee";
               s/$api/$api_ieee/g; ## global substitution option provided
               #print(NEW);
               print NEW ("  `endif\n") if $insert_deprecation;
               $api_string_not_found = 0;
           }# elsif ((/$api[a-zA-Z_]/) || (/[a-zA-Z_]$api/)) {
           #    print("DEBUG: String ignored -> $_");
           #}
       }
       #print(NEW) if $api_string_not_found;
       print(NEW);
   }
   close(NEW);
   close(CODE);   
}


########################################################################
#
# SUB-ROUTINES
#
########################################################################

sub usage {
    print <<END_OF_HELP;

$0 : $program_id
$rcs_ver

    Script description goes here.

Options:

 -h, -help       : Display this help screen
 -c, -checkout   : Another example option

Examples:

     Show how the script is used here.  Example:
     automerge -m <bctl-srtl2-ww07> [-c /fs12/a/talsop/checkout.log]

     Primary Contact: Thomas R. Alsop (thomas.r.alsop\@intel.com)

END_OF_HELP

    exit(1);
}


########################################################################
# RCS LOG
# 
# $Log: $
#
#
########################################################################
