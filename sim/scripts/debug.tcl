# ================================================================
# debug_tb_readadc.tcl — Exécution pas-à-pas avec contrôles/erreurs
# ================================================================

# --- CONFIG: adapte les chemins si nécessaire ---
# Essaie d'abord à la racine, sinon dans rtl/ et sim/tb/
proc resolve_file {candidate fallbacks} {
    if {[file exists $candidate]} { return $candidate }
    foreach f $fallbacks {
        if {[file exists $f]} { return $f }
    }
    return ""
}

set PROJ_DIR [pwd]
set RTL_FILE   [resolve_file [file join $PROJ_DIR F1_ReadADCFullSpeed.vhd] \
                           [list [file join $PROJ_DIR rtl F1_ReadADCFullSpeed.vhd]]]
set TB_FILE    [resolve_file [file join $PROJ_DIR tb_F1_ReadADCFullSpeed.vhd] \
                           [list [file join $PROJ_DIR sim tb tb_F1_ReadADCFullSpeed.vhd]]]

# --- Helper pour exécuter une étape et stopper proprement en cas d'erreur ---
proc step {label cmd} {
    puts "\n=== [clock format [clock seconds] -format {%H:%M:%S}] :: $label ==="
    puts "CMD: $cmd"
    if {[catch {uplevel #0 $cmd} msg]} {
        puts ">>> ERREUR à l'étape: $label"
        puts ">>> Message: $msg"
        puts "\n(Le simulateur va s'arrêter pour conserver le transcript à cet endroit.)"
        quit -code 1
    } else {
        puts "OK: $label"
    }
}

# --- Affichage des chemins détectés ---
puts "PROJ_DIR = $PROJ_DIR"
puts "RTL_FILE = $RTL_FILE"
puts "TB_FILE  = $TB_FILE"

if {$RTL_FILE eq ""} {
    puts ">>> ERREUR: F1_ReadADCFullSpeed.vhd introuvable. Ajuste RTL_FILE en haut du script."
    quit -code 1
}
if {$TB_FILE eq ""} {
    puts ">>> ERREUR: tb_F1_ReadADCFullSpeed.vhd introuvable. Ajuste TB_FILE en haut du script."
    quit -code 1
}

# --- Enregistrer un log transcript pour post-mortem ---
# (le fichier vsim_debug.log sera créé à côté du script)
transcript file vsim_debug.log

# --- Créer / mapper la librairie work ---
set WORK_DIR [file join $PROJ_DIR sim work]
if {![file exists $WORK_DIR]} { file mkdir $WORK_DIR }

step "Créer la lib work" {vlib $WORK_DIR}
step "Mapper la lib work" {vmap work $WORK_DIR}

# --- Lint rapide (optionnel, mais utile pour voir des warnings tôt) ---
step "Lint RTL" "vcom -2008 -lint \"$RTL_FILE\""
step "Lint TB"  "vcom -2008 -lint \"$TB_FILE\""

# --- Compilation réelle dans work ---
step "Compile RTL" "vcom -2008 -work work \"$RTL_FILE\""
step "Compile TB"  "vcom -2008 -work work \"$TB_FILE\""

# --- Elaboration / lancement de la simu (résolution en ps) ---
# Si tu veux passer des generics au TB, ajoute ici des -gG_*=...
step "Elaboration vsim" {vsim -t ps work.tb_F1_ReadADCFullSpeed}

# --- Ouvrir les waves (si GUI) et ajouter quelques signaux utiles ---
if {[catch {view wave}]} {
    puts "Note: En mode console (-c), la fenêtre 'wave' n'est pas ouverte (normal)."
} else {
    wave delete *
    add wave -divider "TB clocks & reset"
    add wave sim:/tb_F1_ReadADCFullSpeed/MCLK
    add wave sim:/tb_F1_ReadADCFullSpeed/CLKFS
    add wave sim:/tb_F1_ReadADCFullSpeed/RESETn

    add wave -divider "ADC IF"
    add wave sim:/tb_F1_ReadADCFullSpeed/SCKL
    add wave sim:/tb_F1_ReadADCFullSpeed/SCKR
    add wave sim:/tb_F1_ReadADCFullSpeed/nCNVL
    add wave sim:/tb_F1_ReadADCFullSpeed/nCNVR
    add wave sim:/tb_F1_ReadADCFullSpeed/BUSYL
    add wave sim:/tb_F1_ReadADCFullSpeed/BUSYR
    add wave sim:/tb_F1_ReadADCFullSpeed/SDOL
    add wave sim:/tb_F1_ReadADCFullSpeed/SDOR

    # Internes du DUT si les noms correspondent
    catch { add wave -divider "DUT internals" }
    catch { add wave sim:/tb_F1_ReadADCFullSpeed/dut/CNVen_SCK }
    catch { add wave sim:/tb_F1_ReadADCFullSpeed/dut/ADC_CLK }
    catch { add wave sim:/tb_F1_ReadADCFullSpeed/dut/TCLK23 }
    catch { add wave sim:/tb_F1_ReadADCFullSpeed/dut/CNVclk_cnt }
}

# --- Petit run d'essai pour voir si ça plante tout de suite ---
step "Run 10 us" {run 10 us}

puts "\nTout est OK jusque-là. Tu peux maintenant faire 'run -all' manuellement."
