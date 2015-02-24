
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name N6480 -dir "/home/moffitt/Development/N6480/Xilinx/planAhead_run_3" -part xc6slx4cpg196-2
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "n6480.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {../Source/FD_MXILINX_rgbdac.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../Source/SR4CE_MXILINX_rgbdac.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../Source/FD4_MXILINX_rgbdac.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../Source/rgbdac.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../Source/n6480.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set_property top n6480 $srcset
add_files [list {n6480.ucf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx4cpg196-2
