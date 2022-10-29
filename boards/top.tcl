# CHANGE DESIGN NAME HERE
variable design_name
set design_name [lindex [split [file tail [info script]] "."] 0]

set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
    set origin_dir $::origin_dir_loc
}

set str_bd_folder [file normalize ${origin_dir}/boards]
set str_bd_filepath ${str_bd_folder}/${design_name}/${design_name}.bd

# Check if remote design exists on disk
if { [file exists $str_bd_filepath ] == 1 } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2030 -severity "ERROR" "The remote BD file path <$str_bd_filepath> already exists!"}
    common::send_gid_msg -ssname BD::TCL -id 2031 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0>."
    common::send_gid_msg -ssname BD::TCL -id 2032 -severity "INFO" "Also make sure there is no design <$design_name> existing in your current project."

    return 1
}

# Check if design exists in memory
set list_existing_designs [get_bd_designs -quiet $design_name]
if { $list_existing_designs ne "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2033 -severity "ERROR" "The design <$design_name> already exists in this project! Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

    common::send_gid_msg -ssname BD::TCL -id 2034 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

    return 1
}

# Check if design exists on disk within project
set list_existing_designs [get_files -quiet */${design_name}.bd]
if { $list_existing_designs ne "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2035 -severity "ERROR" "The design <$design_name> already exists in this project at location:
    $list_existing_designs"}
    catch {common::send_gid_msg -ssname BD::TCL -id 2036 -severity "ERROR" "Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

    common::send_gid_msg -ssname BD::TCL -id 2037 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

    return 1
}

# Now can create the remote BD
# NOTE - usage of <-dir> will create <$str_bd_folder/$design_name/$design_name.bd>
create_bd_design -dir $str_bd_folder $design_name
current_bd_design $design_name


##################################################################
# DESIGN PROCs
##################################################################
# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj



  # -------------------------------------------------------------
  #  USER INPUT: Paste the core of the exported .tcl board
  # -------------------------------------------------------------
  # Create interface ports

  # Create ports
  set clk_in1_0 [ create_bd_port -dir I -type clk clk_in1_0 ]
  set clk_out1_0 [ create_bd_port -dir O -type clk clk_out1_0 ]

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]

  # Create port connections
  connect_bd_net -net clk_in1_0_1 [get_bd_ports clk_in1_0] [get_bd_pins clk_wiz_0/clk_in1]
  connect_bd_net -net clk_wiz_0_clk_out1 [get_bd_ports clk_out1_0] [get_bd_pins clk_wiz_0/clk_out1]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design

  # -------------------------------------------------------------
  #  End of copying
  # -------------------------------------------------------------
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################
proc readd_found_file {abs_path_to_file} {
    set file_full_name [file tail $abs_path_to_file]
    puts "TCL: file_full_name = $file_full_name"

        puts "TCL: Sorting source file to fileset \"sources_1\": ${abs_path_to_file}"
        add_files -force -norecurse -fileset [get_filesets "sources_1"] ${abs_path_to_file}

        if { [string first ".vhd" ${file_full_name}] != -1} {
            read_vhdl -library "xil_defaultlib" ${abs_path_to_file}
            # puts "TCL: VHDL HERE '[string first ".vhd" ${file_full_name}]'"
        } elseif { [string first ".sv" ${file_full_name}] != -1} {
            read_verilog -library "xil_defaultlib" -sv ${abs_path_to_file}
        } elseif { [string first ".v" ${file_full_name}] != -1} {
            read_verilog -library "xil_defaultlib" ${abs_path_to_file}
        }

        set_property "library" "xil_defaultlib" [get_files ${abs_path_to_file}]
        set_property "used_in" {simulation synthesis out_of_context} [get_files ${abs_path_to_file}]

}


create_root_design ""

make_wrapper -files [get_files "[file normalize ./boards/${design_name}/${design_name}.bd]"] -top

set boardWrapperFound [glob ./boards/${design_name}/hdl/*{_wrapper.}*]
readd_found_file "[file normalize $boardWrapperFound]"

set_property top ${design_name}_wrapper [current_fileset]