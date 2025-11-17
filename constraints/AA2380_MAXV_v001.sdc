## Generated SDC file "AA2380_MAXV_v001.sdc"

## Copyright (C) 2023  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 23.1std.0 Build 991 11/28/2023 SC Lite Edition"

## DATE    "Tue Apr  2 13:45:49 2024"

##
## DEVICE  "5M570ZT100C5"
##
#**************************************************************
# Time Information
#**************************************************************
set_time_format -unit ns -decimal_places 3

#**************************************************************
# Create Clock
#**************************************************************
# create_clock -name {F7_ReadyII:inst10|CLKSLOW} -period 1.000 -waveform { 0.000 0.500 } [get_registers {F7_ReadyII:inst10|CLKSLOW}]
# create_clock -name {F0_ClockEnable_BETA2:inst4|Fso} -period 1.000 -waveform { 0.000 0.500 } [get_registers {F0_ClockEnable_BETA2:inst4|Fso}]
# create_clock -name {F0_ctrl_encoder_B:inst1|Rotate} -period 1.000 -waveform { 0.000 0.500 } [get_registers {F0_ctrl_encoder_B:inst1|Rotate}]
# create_clock -name {CLK100M} -period 10.000 -waveform { 0.000 5.000 } [get_ports { CLK100M }]
# create_clock -name {F0_ctrl_encoder_B:inst1|pushf} -period 1.000 -waveform { 0.000 0.500 } [get_registers {F0_ctrl_encoder_B:inst1|pushf}]
# create_clock -name {F0_ClockEnable_BETA2:inst4|nFS} -period 1.000 -waveform { 0.000 0.500 } [get_registers {F0_ClockEnable_BETA2:inst4|nFS}]
# create_clock -name {F0_ClockEnable_BETA2:inst4|Fso128} -period 1.000 -waveform { 0.000 0.500 } [get_registers {F0_ClockEnable_BETA2:inst4|Fso128}]
# create_clock -name {F0_ClockEnable_BETA2:inst4|clockDIV[3]} -period 1.000 -waveform { 0.000 0.500 } [get_registers {F0_ClockEnable_BETA2:inst4|clockDIV[3]}]



# ==========================================
# Nouveau le 17/11/2025 pour AA2380_MAXV
# Fichier : AA2380_MAXV.sdc
# Top-level : AA2380_MAXV
# ==========================================
# Horloges externes :
# - MCLK        : 98.304 MHz (horloge principale, sur GCLK)
# - I2S4L_8FS   : 0.384 MHz .. 12.288 MHz (synchrone de MCLK)
# - MASTER_LRCK : 48 kHz .. 1.536 MHz     (synchrone de MCLK)
# - SPI_CLOCK   : 10 MHz (asynchrone du reste)
#
# CLK100M et CLKEXT ne sont pas utilisés → pas de clock dessus.
# ==========================================


# -------- 1) Horloge principale MCLK (98.304 MHz) --------
# Période = 1 / 98.304e6 ≈ 10.172 ns
create_clock -name {MCLK} -period 10.172 [get_ports {MCLK}]


# -------- 2) Horloge I2S4L_8FS --------
# On contraint à la fréquence MAX (12.288 MHz) pour être pessimiste.
# Période = 1 / 12.288e6 ≈ 81.38 ns
create_clock -name {I2S4L_8F} -period 81.38 [get_ports {I2S4L_8F}]


# -------- 3) Horloge MASTER_LRCK --------
# On contraint à la fréquence MAX (1.536 MHz).
# Période ≈ 651 ns
create_clock -name {MASTER_LRCK} -period 651.0 [get_ports {MASTER_LRCK}]


# -------- 4) Horloge SPI_CLOCK (10 MHz) --------
# Horloge SPI asynchrone du reste du système.
# Période = 100 ns
create_clock -name {SPI_CLOCK} -period 100.0 [get_ports {SPI_CLOCK}]

# -------- 4) Chip select SPI (0.1 MHz)  --------
# Horloge SPI asynchrone du reste du système.
# Période = 1000 ns
create_clock -name {SPI_nCS} -period 10000.0 [get_ports {SPI_nCS}]

# -------- 5) Groupes d'horloges --------
# Tu m'as indiqué que MCLK, I2S4L_8FS et MASTER_LRCK sont synchrones entre eux
# (viennent de la même "famille" de clocks sur une autre carte).
# => on les garde dans le même groupe (TimeQuest analysera les chemins entre eux).
#
# SPI_CLOCK, lui, vient d'un domaine différent → on le déclare ASYNCHRONE
# par rapport au groupe principal pour éviter des warnings sur des chemins
# que tu gères logiquement (par ex. FSM SPI).
 
set_clock_groups -asynchronous \
    -group {SPI_CLOCK SPI_nCS} \
    -group {MCLK I2S4L_8F MASTER_LRCK}


# -------- 6) (Optionnel) Préparation pour les contraintes d'I/O ADC --------
# Signaux ADC connectés au CPLD :
#   ADCL_CNV, ADCR_CNV, ADCL_SCK, ADCR_SCK  : sorties vers ADC
#   ADCL_SDO, ADCR_SDO, ADCL_BUSY, ADCR_BUSY: entrées depuis ADC
#
# Dans un premier temps, on peut laisser TimeQuest sans set_input_delay/set_output_delay,
# l'objectif étant surtout de vérifier que la logique interne tient bien 98.304 MHz.
#
# Plus tard, quand on voudra être rigoureux vis-à-vis de la datasheet du LTC2380-24
# ET des délais de la carte (longueur de pistes, etc.), on ajoutera :
#
# Exemple de squelette (A COMPLETER AVEC LES BONNES VALEURS) :
#
#   # Entrées depuis l'ADC (BUSY/SDO), en ns par rapport à MCLK
#   # set_input_delay -clock [get_clocks {MCLK}] <val_max_ns> [get_ports {ADCL_SDO ADCR_SDO ADCL_BUSY ADCR_BUSY}]
#
#   # Sorties vers l'ADC (CNV/SCK), en ns par rapport à MCLK
#   # set_output_delay -clock [get_clocks {MCLK}] <val_max_ns> [get_ports {ADCL_CNV ADCR_CNV ADCL_SCK ADCR_SCK}]
#
# Pour l’instant, on les laisse commentées pour ne pas mettre de valeurs au hasard.
