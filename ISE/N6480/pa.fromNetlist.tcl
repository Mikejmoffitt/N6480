
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name N6480 -dir "C:/Users/Julian/Development/N6480/ISE/N6480/planAhead_run_3" -part xc6slx4cpg196-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/Julian/Development/N6480/ISE/N6480/n6480.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/Julian/Development/N6480/ISE/N6480} }
set_property target_constrs_file "n6480.ucf" [current_fileset -constrset]
add_files [list {n6480.ucf}] -fileset [get_property constrset [current_run]]
link_design
