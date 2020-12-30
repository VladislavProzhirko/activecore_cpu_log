# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
namespace eval ::optrace {
  variable script "F:/Vivado/Downloads/activecore/designs/rtl/sigma/syn/syn_1stage/NEXYS4-DDR/NEXYS4_DDR.runs/synth_1/NEXYS4_DDR.tcl"
  variable category "vivado_synth"
}

# Try to connect to running dispatch if we haven't done so already.
# This code assumes that the Tcl interpreter is not using threads,
# since the ::dispatch::connected variable isn't mutex protected.
if {![info exists ::dispatch::connected]} {
  namespace eval ::dispatch {
    variable connected false
    if {[llength [array get env XILINX_CD_CONNECT_ID]] > 0} {
      set result "true"
      if {[catch {
        if {[lsearch -exact [package names] DispatchTcl] < 0} {
          set result [load librdi_cd_clienttcl[info sharedlibextension]] 
        }
        if {$result eq "false"} {
          puts "WARNING: Could not load dispatch client library"
        }
        set connect_id [ ::dispatch::init_client -mode EXISTING_SERVER ]
        if { $connect_id eq "" } {
          puts "WARNING: Could not initialize dispatch client"
        } else {
          puts "INFO: Dispatch client connection id - $connect_id"
          set connected true
        }
      } catch_res]} {
        puts "WARNING: failed to connect to dispatch server - $catch_res"
      }
    }
  }
}
if {$::dispatch::connected} {
  # Remove the dummy proc if it exists.
  if { [expr {[llength [info procs ::OPTRACE]] > 0}] } {
    rename ::OPTRACE ""
  }
  proc ::OPTRACE { task action {tags {} } } {
    ::vitis_log::op_trace "$task" $action -tags $tags -script $::optrace::script -category $::optrace::category
  }
  # dispatch is generic. We specifically want to attach logging.
  ::vitis_log::connect_client
} else {
  # Add dummy proc if it doesn't exist.
  if { [expr {[llength [info procs ::OPTRACE]] == 0}] } {
    proc ::OPTRACE {{arg1 \"\" } {arg2 \"\"} {arg3 \"\" } {arg4 \"\"} {arg5 \"\" } {arg6 \"\"}} {
        # Do nothing
    }
  }
}

proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
OPTRACE "synth_1" START { ROLLUP_AUTO }
set_msg_config -id {Common 17-41} -limit 10000000
OPTRACE "Creating in-memory project" START { }
create_project -in_memory -part xc7a100tcsg324-3

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir F:/Vivado/Downloads/activecore/designs/rtl/sigma/syn/syn_1stage/NEXYS4-DDR/NEXYS4_DDR.cache/wt [current_project]
set_property parent.project_path F:/Vivado/Downloads/activecore/designs/rtl/sigma/syn/syn_1stage/NEXYS4-DDR/NEXYS4_DDR.xpr [current_project]
set_property XPM_LIBRARIES XPM_CDC [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_cache_permissions disable [current_project]
OPTRACE "Creating in-memory project" END { }
OPTRACE "Adding files" START { }
read_verilog {
  F:/Vivado/Downloads/activecore/designs/rtl/sigma_tile/hw/sigma_tile.svh
  F:/Vivado/Downloads/activecore/designs/rtl/sigma_tile/hw/riscv/coregen/riscv_1stage/sverilog/riscv_1stage.svh
  F:/Vivado/Downloads/activecore/designs/rtl/sigma_tile/hw/riscv/coregen/riscv_5stage/sverilog/riscv_5stage.svh
  F:/Vivado/Downloads/activecore/designs/rtl/sigma_tile/hw/riscv/coregen/riscv_6stage/sverilog/riscv_6stage.svh
  F:/Vivado/Downloads/activecore/designs/rtl/sigma_tile/hw/riscv/coregen/riscv_2stage/sverilog/riscv_2stage.svh
  F:/Vivado/Downloads/activecore/designs/rtl/sigma_tile/hw/riscv/coregen/riscv_3stage/sverilog/riscv_3stage.svh
  F:/Vivado/Downloads/activecore/designs/rtl/sigma_tile/hw/riscv/coregen/riscv_4stage/sverilog/riscv_4stage.svh
}
set_property file_type "Verilog Header" [get_files F:/Vivado/Downloads/activecore/designs/rtl/sigma_tile/hw/sigma_tile.svh]
set_property file_type "Verilog Header" [get_files F:/Vivado/Downloads/activecore/designs/rtl/sigma_tile/hw/riscv/coregen/riscv_1stage/sverilog/riscv_1stage.svh]
set_property file_type "Verilog Header" [get_files F:/Vivado/Downloads/activecore/designs/rtl/sigma_tile/hw/riscv/coregen/riscv_5stage/sverilog/riscv_5stage.svh]
set_property file_type "Verilog Header" [get_files F:/Vivado/Downloads/activecore/designs/rtl/sigma_tile/hw/riscv/coregen/riscv_6stage/sverilog/riscv_6stage.svh]
set_property file_type "Verilog Header" [get_files F:/Vivado/Downloads/activecore/designs/rtl/sigma_tile/hw/riscv/coregen/riscv_2stage/sverilog/riscv_2stage.svh]
set_property file_type "Verilog Header" [get_files F:/Vivado/Downloads/activecore/designs/rtl/sigma_tile/hw/riscv/coregen/riscv_3stage/sverilog/riscv_3stage.svh]
set_property file_type "Verilog Header" [get_files F:/Vivado/Downloads/activecore/designs/rtl/sigma_tile/hw/riscv/coregen/riscv_4stage/sverilog/riscv_4stage.svh]
read_verilog -library xil_defaultlib -sv {
  F:/Vivado/Downloads/activecore/designs/rtl/sigma_tile/hw/arb_1m2s.sv
  F:/Vivado/Downloads/activecore/designs/rtl/sigma_tile/hw/arb_2m1s.sv
  F:/Vivado/Downloads/activecore/designs/rtl/sigma_tile/hw/arb_2m3s.sv
  F:/Vivado/Downloads/activecore/designs/rtl/sigma_tile/hw/cpu_stub.sv
  F:/Vivado/Downloads/activecore/designs/rtl/sigma_tile/hw/irq_adapter.sv
  F:/Vivado/Downloads/activecore/designs/rtl/sigma_tile/hw/riscv/coregen/riscv_1stage/sverilog/riscv_1stage.sv
  F:/Vivado/Downloads/activecore/designs/rtl/sigma_tile/hw/sfr.sv
  F:/Vivado/Downloads/activecore/designs/rtl/sigma/hw/sigma.sv
  F:/Vivado/Downloads/activecore/designs/rtl/sigma_tile/hw/sigma_tile.sv
  F:/Vivado/Downloads/activecore/designs/rtl/sigma/syn/syn_1stage/NEXYS4-DDR/NEXYS4_DDR.sv
}
read_verilog -library xil_defaultlib {
  F:/Vivado/Downloads/activecore/designs/rtl/debouncer/debouncer.v
  F:/Vivado/Downloads/activecore/designs/rtl/ram/ram_dual.v
  F:/Vivado/Downloads/activecore/designs/rtl/ram/ram_dual_memsplit.v
  F:/Vivado/Downloads/activecore/designs/rtl/reset_sync/reset_sync.v
  F:/Vivado/Downloads/activecore/designs/rtl/udm/hdl/uart_rx.v
  F:/Vivado/Downloads/activecore/designs/rtl/udm/hdl/uart_tx.v
  F:/Vivado/Downloads/activecore/designs/rtl/udm/hdl/udm.v
  F:/Vivado/Downloads/activecore/designs/rtl/udm/hdl/udm_controller.v
}
read_ip -quiet F:/Vivado/Downloads/activecore/designs/rtl/sigma/syn/syn_1stage/NEXYS4-DDR/NEXYS4_DDR.srcs/sources_1/ip/sys_clk/sys_clk.xci
set_property used_in_implementation false [get_files -all f:/Vivado/Downloads/activecore/designs/rtl/sigma/syn/syn_1stage/NEXYS4-DDR/NEXYS4_DDR.srcs/sources_1/ip/sys_clk/sys_clk_board.xdc]
set_property used_in_implementation false [get_files -all f:/Vivado/Downloads/activecore/designs/rtl/sigma/syn/syn_1stage/NEXYS4-DDR/NEXYS4_DDR.srcs/sources_1/ip/sys_clk/sys_clk.xdc]
set_property used_in_implementation false [get_files -all f:/Vivado/Downloads/activecore/designs/rtl/sigma/syn/syn_1stage/NEXYS4-DDR/NEXYS4_DDR.srcs/sources_1/ip/sys_clk/sys_clk_ooc.xdc]

OPTRACE "Adding files" END { }
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc F:/Vivado/Downloads/activecore/designs/rtl/sigma/syn/syn_1stage/NEXYS4-DDR/NEXYS4_DDR.xdc
set_property used_in_implementation false [get_files F:/Vivado/Downloads/activecore/designs/rtl/sigma/syn/syn_1stage/NEXYS4-DDR/NEXYS4_DDR.xdc]

set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

OPTRACE "synth_design" START { }
synth_design -top NEXYS4_DDR -part xc7a100tcsg324-3
OPTRACE "synth_design" END { }


OPTRACE "write_checkpoint" START { CHECKPOINT }
# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef NEXYS4_DDR.dcp
OPTRACE "write_checkpoint" END { }
OPTRACE "synth reports" START { REPORT }
create_report "synth_1_synth_report_utilization_0" "report_utilization -file NEXYS4_DDR_utilization_synth.rpt -pb NEXYS4_DDR_utilization_synth.pb"
OPTRACE "synth reports" END { }
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
OPTRACE "synth_1" END { }