
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name N6480 -dir "/home/moffitt/Development/N6480/Xilinx/planAhead_run_4" -part xc6slx4cpg196-2
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "/home/moffitt/Development/N6480/Xilinx/n6480.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/moffitt/Development/N6480/Xilinx} }
set_property target_constrs_file "n6480.ucf" [current_fileset -constrset]
add_files [list {n6480.ucf}] -fileset [get_property constrset [current_run]]
link_design
