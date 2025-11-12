# ======================================================================
# run_tb_readadc.tcl  —  Script ModelSim/Questa 2020.1
# - Compile le RTL F1_ReadADCFullSpeed.vhd (VHDL-2008)
# - Compile le testbench tb_F1_ReadADCFullSpeed.vhd (VHDL-2008)
# - Lance la simulation, ouvre la fenêtre de waves et ajoute les signaux clés
# - Zoom auto et run -all (le TB stoppe lui-même à ~10 ms)
# ======================================================================
# F1_ReadADCFullSpeed
# tb_F1_ReadADCFullSpeed

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
set RTL_FILE [file join $RTL_DIR F1_ReadADCFullSpeed.vhd]
set TB_FILE  [file join $TB_DIR  tb_F1_ReadADCFullSpeed.vhd]

if {![file exists $RTL_FILE]} { puts "!! RTL file not found: $RTL_FILE"; quit -f }
if {![file exists $TB_FILE]}  { puts "!! TB file not found: $TB_FILE"; quit -f }

# # --- Compile ---
# vcom -2008 -lint "$RTL_FILE"
# vcom -2008 -lint "$TB_FILE"

# --- Compile ---
vcom -2008 -work work $RTL_FILE
vcom -2008 -work work $TB_FILE

# ----------------------------------------------------------------------
# Option: si tu as ajouté des GENERICS au TB (ex: G_CLKFS_HZ/G_AMPL_PCT),
# tu peux les passer ici, p.ex. :
# vsim -t ps work.tb_F1_ReadADCFullSpeed -gG_CLKFS_HZ=192000 -gG_AMPL_PCT=90.0
# Sinon lance simplement sans -g :
# ----------------------------------------------------------------------

# --- Elaborate & Simulate ---
# L'option -t ps définit la résolution temporelle à 1 ps
vsim -t ps work.tb_F1_ReadADCFullSpeed

# restore 
do wave.do

# --- Signaux TOP TB ---
add wave -divider "CLK & RAZ"
add wave -label MCLK    -radix binary  /tb_F1_ReadADCFullSpeed/MCLK
add wave -label CLKFS   -radix binary  /tb_F1_ReadADCFullSpeed/CLKFS
add wave -label RESETn  -radix binary  /tb_F1_ReadADCFullSpeed/RESETn

add wave -divider "ADC SPI"
add wave -label SCKL    -radix binary  /tb_F1_ReadADCFullSpeed/SCKL
add wave -label SCKR    -radix binary  /tb_F1_ReadADCFullSpeed/SCKR
add wave -label nCNVL   -radix binary  /tb_F1_ReadADCFullSpeed/nCNVL
add wave -label nCNVR   -radix binary  /tb_F1_ReadADCFullSpeed/nCNVR
add wave -label BUSYL   -radix binary  /tb_F1_ReadADCFullSpeed/BUSYL
add wave -label BUSYR   -radix binary  /tb_F1_ReadADCFullSpeed/BUSYR
add wave -label SDOL    -radix binary  /tb_F1_ReadADCFullSpeed/SDOL
add wave -label SDOR    -radix binary  /tb_F1_ReadADCFullSpeed/SDOR

add wave -divider "PAR outs =="
# Ces signaux existent si ton TB mappe DOUTL/DOUTR. Sinon commente ces 2 lignes.
add wave -label DOUTL   -radix hex  /tb_F1_ReadADCFullSpeed/DOUTL
add wave -label DOUTR   -radix hex  /tb_F1_ReadADCFullSpeed/DOUTR

# --- Quelques internes utiles du DUT (si noms identiques) ---
# Ajuste/Commente si les noms diffèrent dans F1_ReadADCFullSpeed.vhd
catch { add wave -divider "internals" }
catch { add wave -label CNVen_SCK   -radix binary   /tb_F1_ReadADCFullSpeed/dut/CNVen_SCK }
catch { add wave -label ADC_CLK     -radix binary   /tb_F1_ReadADCFullSpeed/dut/ADC_CLK }
catch { add wave -label TCLK23      -radix unsigned /tb_F1_ReadADCFullSpeed/dut/TCLK23 }
catch { add wave -label CNVclk_cnt  -radix unsigned /tb_F1_ReadADCFullSpeed/dut/CNVclk_cnt }
catch { add wave -label r_DATAL     -radix hex      /tb_F1_ReadADCFullSpeed/dut/r_DATAL }
catch { add wave -label r_DATAR     -radix hex      /tb_F1_ReadADCFullSpeed/dut/r_DATAR }

view wave
run -all
# Zoom full (optional)
wave zoomfull
