# --- Set directories ---
set PROJ_DIR [pwd]
set SIM_DIR  [file join $PROJ_DIR sim]
set WORK_DIR [file join $SIM_DIR work]
set RTL_DIR  [file join $PROJ_DIR rtl]
set TB_DIR   [file join $SIM_DIR tb]

# Debug
puts "PROJ_DIR = $PROJ_DIR"
puts "WORK_DIR = $WORK_DIR"
puts "RTL_DIR  = $RTL_DIR"
puts "TB_DIR   = $TB_DIR"

# --- Create work library ---
if {![file exists $WORK_DIR]} { file mkdir $WORK_DIR }
vlib $WORK_DIR
vmap work $WORK_DIR

# --- Source files ---
set RTL_FILE [file join $RTL_DIR F15_Par2I2S_2S4P.vhd]
set TB_FILE  [file join $TB_DIR  tb_F15_Par2I2S_2S4P.vhd]

if {![file exists $RTL_FILE]} { puts "!! RTL file not found: $RTL_FILE"; quit -f }
if {![file exists $TB_FILE]}  { puts "!! TB file not found: $TB_FILE"; quit -f }

# --- Compile ---
vcom -2008 -lint "$RTL_FILE"
vcom -2008 -lint "$TB_FILE"

# --- Load simulation without +acc (Starter Edition friendly) ---
vsim work.tb_F15_Par2I2S_2S4P
# restore 
do wave.do

# ===============================
# Horloge et reset
# ===============================
add wave -divider {Horloges}
#===============================
add wave -label MCLKI      -position end {sim:/tb_F15_Par2I2S_2S4P/dut/MCLKI  }
add wave -label CLK8FS     -position end {sim:/tb_F15_Par2I2S_2S4P/dut/CLK8FS }
add wave -label LRCK       -position end {sim:/tb_F15_Par2I2S_2S4P/dut/LRCK   }
add wave -divider {DATA in} 
##===============================
add wave -label DATAL      -radix hexadecimal -position end {sim:/tb_F15_Par2I2S_2S4P/dut/DATAL  }
add wave -label DATAR      -radix hexadecimal -position end {sim:/tb_F15_Par2I2S_2S4P/dut/DATAR  }
add wave -divider {Test mode} 
#===============================
add wave -label TSTMODE    -position end {sim:/tb_F15_Par2I2S_2S4P/dut/TSTMODE} 
# ===============================
# Generated DAata and load clocks
# ===============================
add wave -divider {DATA OUT} 
add wave -label I2S4L_SDATAL -radix hexadecimal -position end {sim:/tb_F15_Par2I2S_2S4P/dut/I2S4L_SDATAL} 
add wave -label I2S4L_SDATAR -radix hexadecimal -position end {sim:/tb_F15_Par2I2S_2S4P/dut/I2S4L_SDATAR}
add wave -label PARI2S_LOAD  -position end {sim:/tb_F15_Par2I2S_2S4P/dut/PARI2S_LOAD } 


# --- Add wave signals ---
# add wave -r /*

# --- Run simulation ---
run 100 us

# S'assurer que la fenêtre Wave existe et qu'un pane est actif
view wave
quietly WaveActivateNextPane {} 0
# Zoom sur toute la durée simulée
wave zoomfull