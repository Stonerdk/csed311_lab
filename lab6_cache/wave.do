onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cpu_TB/UUT/main/clk
add wave -noupdate /cpu_TB/UUT/main/reset_n
add wave -noupdate -radix unsigned /cpu_TB/UUT/main/PRE_PC
add wave -noupdate -radix unsigned /cpu_TB/UUT/main/IFID_PC
add wave -noupdate -radix hexadecimal /cpu_TB/UUT/main/IFID_INSTR
add wave -noupdate -radix hexadecimal /cpu_TB/UUT/main/IDEX_INSTR
add wave -noupdate -radix hexadecimal /cpu_TB/UUT/main/EXMEM_INSTR
add wave -noupdate -radix hexadecimal /cpu_TB/UUT/main/MEMWB_INSTR
add wave -noupdate -radix decimal /cpu_TB/UUT/main/num_inst
add wave -noupdate -radix decimal -childformat {{{/cpu_TB/UUT/main/unit_register/register[3]} -radix hexadecimal} {{/cpu_TB/UUT/main/unit_register/register[2]} -radix unsigned} {{/cpu_TB/UUT/main/unit_register/register[1]} -radix decimal} {{/cpu_TB/UUT/main/unit_register/register[0]} -radix hexadecimal}} -expand -subitemconfig {{/cpu_TB/UUT/main/unit_register/register[3]} {-height 15 -radix hexadecimal} {/cpu_TB/UUT/main/unit_register/register[2]} {-height 15 -radix unsigned} {/cpu_TB/UUT/main/unit_register/register[1]} {-height 15 -radix decimal} {/cpu_TB/UUT/main/unit_register/register[0]} {-height 15 -radix hexadecimal}} /cpu_TB/UUT/main/unit_register/register
add wave -noupdate /cpu_TB/UUT/cache/cpu_read_m1
add wave -noupdate /cpu_TB/UUT/cache/cpu_read_m2
add wave -noupdate /cpu_TB/UUT/cache/cpu_write_m2
add wave -noupdate /cpu_TB/UUT/cache/mem_read_m1
add wave -noupdate /cpu_TB/UUT/cache/mem_read_m2
add wave -noupdate /cpu_TB/UUT/cache/mem_write_m2
add wave -noupdate /cpu_TB/UUT/cache/addr1_hit
add wave -noupdate /cpu_TB/UUT/cache/addr2_hit
add wave -noupdate /cpu_TB/UUT/cache/mem_signal
add wave -noupdate /cpu_TB/UUT/cache/stall
add wave -noupdate -radix hexadecimal /cpu_TB/UUT/cache/wb_data1
add wave -noupdate -radix decimal /cpu_TB/UUT/cache/wb_data2
add wave -noupdate -radix decimal /cpu_TB/UUT/cache/mem_write_data
add wave -noupdate -radix binary /cpu_TB/NUUT/address1
add wave -noupdate -radix hexadecimal -childformat {{{/cpu_TB/NUUT/data1_out[63]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[62]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[61]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[60]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[59]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[58]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[57]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[56]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[55]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[54]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[53]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[52]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[51]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[50]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[49]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[48]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[47]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[46]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[45]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[44]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[43]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[42]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[41]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[40]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[39]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[38]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[37]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[36]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[35]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[34]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[33]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[32]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[31]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[30]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[29]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[28]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[27]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[26]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[25]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[24]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[23]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[22]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[21]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[20]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[19]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[18]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[17]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[16]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[15]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[14]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[13]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[12]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[11]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[10]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[9]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[8]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[7]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[6]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[5]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[4]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[3]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[2]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[1]} -radix hexadecimal} {{/cpu_TB/NUUT/data1_out[0]} -radix hexadecimal}} -subitemconfig {{/cpu_TB/NUUT/data1_out[63]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[62]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[61]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[60]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[59]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[58]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[57]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[56]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[55]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[54]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[53]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[52]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[51]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[50]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[49]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[48]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[47]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[46]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[45]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[44]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[43]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[42]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[41]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[40]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[39]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[38]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[37]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[36]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[35]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[34]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[33]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[32]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[31]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[30]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[29]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[28]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[27]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[26]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[25]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[24]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[23]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[22]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[21]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[20]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[19]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[18]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[17]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[16]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[15]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[14]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[13]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[12]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[11]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[10]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[9]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[8]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[7]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[6]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[5]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[4]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[3]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[2]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[1]} {-height 15 -radix hexadecimal} {/cpu_TB/NUUT/data1_out[0]} {-height 15 -radix hexadecimal}} /cpu_TB/NUUT/data1_out
add wave -noupdate -radix unsigned /cpu_TB/UUT/cache/address1
add wave -noupdate -radix unsigned /cpu_TB/UUT/cache/address2
add wave -noupdate -radix unsigned /cpu_TB/UUT/cpu_address1
add wave -noupdate -radix unsigned /cpu_TB/UUT/cpu_address2
add wave -noupdate /cpu_TB/UUT/cache/address1_offset
add wave -noupdate /cpu_TB/UUT/cache/address2_offset
add wave -noupdate -radix hexadecimal /cpu_TB/UUT/cache/mem_data1
add wave -noupdate /cpu_TB/UUT/cache/mem_data2
add wave -noupdate /cpu_TB/UUT/cache/addr1_mem_data
add wave -noupdate /cpu_TB/UUT/cache/addr2_mem_data
add wave -noupdate /cpu_TB/UUT/cache/set1_valid
add wave -noupdate -expand /cpu_TB/UUT/cache/set1_tag
add wave -noupdate -radix hexadecimal /cpu_TB/UUT/cache/set1_data
add wave -noupdate /cpu_TB/UUT/cache/set1_lru
add wave -noupdate /cpu_TB/UUT/cache/set2_valid
add wave -noupdate /cpu_TB/UUT/cache/set2_tag
add wave -noupdate -radix hexadecimal /cpu_TB/UUT/cache/set2_data
add wave -noupdate /cpu_TB/UUT/cache/set2_lru
add wave -noupdate /cpu_TB/UUT/main/unit_control/jrl
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {115650 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 249
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {41699 ns} {238435 ns}
