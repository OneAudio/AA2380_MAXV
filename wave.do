onerror {resume}
quietly WaveActivateNextPane {} 0
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3255210 ps} 0} {{Cursor 2} {3903673 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 182
configure wave -valuecolwidth 53
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
WaveRestoreZoom {3255210 ps} {3903673 ps}
