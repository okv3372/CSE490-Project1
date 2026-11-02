# run on metallica: vivado -mode batch -source SourceCode/build_vivado.tcl
set source_dir [file dirname [file normalize [info script]]]
set build_dir [file join $source_dir build]
file mkdir $build_dir

# make a project for the basys 3 and add the verilog and pin assignments
create_project cse490_basys3 [file join $build_dir vivado] -part xc7a35tcpg236-1 -force
import_files -fileset sources_1 [glob -directory [file join $source_dir rtl] *.v]
import_files -fileset constrs_1 [file join $source_dir constraints cse490.xdc]
set_property top board_top [get_filesets sources_1]
update_compile_order -fileset sources_1

# build the circuit and make the bitstream
launch_runs synth_1 -jobs 4
wait_on_run synth_1
if {![string match "*Complete*" [get_property STATUS [get_runs synth_1]]]} {error "Synthesis failed"}
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
if {![string match "*Complete*" [get_property STATUS [get_runs impl_1]]]} {error "Implementation failed"}

# copy the bitstream to a short path so it is easy to transfer
set bit_file [lindex [glob -directory [file join $build_dir vivado cse490_basys3.runs impl_1] *.bit] 0]
file copy -force $bit_file [file join $build_dir cse490_basys3.bit]
puts "Bitstream: [file join $build_dir cse490_basys3.bit]"
