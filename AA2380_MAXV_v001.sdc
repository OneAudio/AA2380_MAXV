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

create_clock -name {F7_ReadyII:inst10|CLKSLOW} -period 1.000 -waveform { 0.000 0.500 } [get_registers {F7_ReadyII:inst10|CLKSLOW}]
create_clock -name {F0_ClockEnable_BETA2:inst4|Fso} -period 1.000 -waveform { 0.000 0.500 } [get_registers {F0_ClockEnable_BETA2:inst4|Fso}]
create_clock -name {F0_ctrl_encoder_B:inst1|Rotate} -period 1.000 -waveform { 0.000 0.500 } [get_registers {F0_ctrl_encoder_B:inst1|Rotate}]
create_clock -name {CLK100M} -period 10.000 -waveform { 0.000 5.000 } [get_ports { CLK100M }]
create_clock -name {F0_ctrl_encoder_B:inst1|pushf} -period 1.000 -waveform { 0.000 0.500 } [get_registers {F0_ctrl_encoder_B:inst1|pushf}]
create_clock -name {F0_ClockEnable_BETA2:inst4|nFS} -period 1.000 -waveform { 0.000 0.500 } [get_registers {F0_ClockEnable_BETA2:inst4|nFS}]
create_clock -name {F0_ClockEnable_BETA2:inst4|Fso128} -period 1.000 -waveform { 0.000 0.500 } [get_registers {F0_ClockEnable_BETA2:inst4|Fso128}]
create_clock -name {F0_ClockEnable_BETA2:inst4|clockDIV[3]} -period 1.000 -waveform { 0.000 0.500 } [get_registers {F0_ClockEnable_BETA2:inst4|clockDIV[3]}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

