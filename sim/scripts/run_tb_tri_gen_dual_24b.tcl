# ======================================================================
# run_tb_readadc.tcl  —  Script ModelSim/Questa 2020.1
# - Compile le RTL F1_ReadADCFullSpeed.vhd (VHDL-2008)
# - Compile le testbench tb_tri_gen_dual_24b.vhd (VHDL-2008)
# - Lance la simulation, ouvre la fenêtre de waves et ajoute les signaux clés
# - Zoom auto et run -all (le TB stoppe lui-même à ~10 ms)
# ======================================================================
# F1_ReadADCFullSpeed
# tb_tri_gen_dual_24b

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
set RTL_FILE [file join $RTL_DIR tri_gen_dual_24b.vhd]
set TB_FILE  [file join $TB_DIR  tb_tri_gen_dual_24b.vhd]

if {![file exists $RTL_FILE]} { puts "!! RTL file not found: $RTL_FILE"; quit -f }
if {![file exists $TB_FILE]}  { puts "!! TB file not found: $TB_FILE"; quit -f }

# # --- Compile ---
# vcom -2008 -lint "$RTL_FILE"
# vcom -2008 -lint "$TB_FILE"

# --- Compile ---
vcom -2008 -work work $RTL_FILE
vcom -2008 -work work $TB_FILE

# ----------------------------------------------------------------------
# Option: si tu as ajouté des GENERICS au TB (ex: G_LRCK_HZ/G_AMPL_PCT),
# tu peux les passer ici, p.ex. :
# vsim -t ps work.tb_tri_gen_dual_24b -gG_LRCK_HZ=192000 -gG_AMPL_PCT=90.0
# Sinon lance simplement sans -g :
# ----------------------------------------------------------------------

# --- Elaborate & Simulate ---
# L'option -t ps définit la résolution temporelle à 1 ps
vsim -t ps work.tb_tri_gen_dual_24b

# restore 
do wave.do

# --- Signaux TOP TB ---
add wave -divider "CLKS"
add wave -label MCLK   -radix binary  /tb_tri_gen_dual_24b/MCLK
add wave -label LRCK   -radix binary  /tb_tri_gen_dual_24b/LRCK

add wave -divider "PAR outs =="
# Ces signaux existent si ton TB mappe DOUTL/DOUTR. Sinon commente ces 2 lignes.
add wave -label DATAOL   -radix decimal  /tb_tri_gen_dual_24b/DATAOL
add wave -label DATAOR   -radix decimal  /tb_tri_gen_dual_24b/DATAOR

# --- Quelques internes utiles du DUT (si noms identiques) ---
# Ajuste/Commente si les noms diffèrent dans F1_ReadADCFullSpeed.vhd
catch { add wave -divider "internals" }
catch { add wave -label lrck_cnt   -radix natural   /tb_tri_gen_dual_24b/dut/lrck_cnt }

view wave
run 10 ms
# Zoom full (optional)
wave zoomfull
