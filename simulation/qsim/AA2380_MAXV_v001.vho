-- Copyright (C) 2023  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details, at
-- https://fpgasoftware.intel.com/eula.

-- VENDOR "Altera"
-- PROGRAM "Quartus Prime"
-- VERSION "Version 23.1std.0 Build 991 11/28/2023 Patches 0.02std SC Lite Edition"

-- DATE "04/04/2025 08:24:09"

-- 
-- Device: Altera 5M570ZT100C5 Package TQFP100
-- 

-- 
-- This VHDL file should be used for Questa Intel FPGA (VHDL) only
-- 

LIBRARY IEEE;
LIBRARY MAXV;
USE IEEE.STD_LOGIC_1164.ALL;
USE MAXV.MAXV_COMPONENTS.ALL;

ENTITY 	F1_readADCmulti_ExtClkII IS
    PORT (
	MCLK : IN std_logic;
	ReadCLK : IN std_logic;
	nFS : IN std_logic;
	Fso : IN std_logic;
	OutOfRange : IN std_logic;
	Clear : IN std_logic;
	SR : IN std_logic_vector(2 DOWNTO 0);
	AVG : IN std_logic_vector(2 DOWNTO 0);
	CLKBypass : IN std_logic;
	AQMODE : IN std_logic;
	DOUTL : BUFFER std_logic_vector(23 DOWNTO 0);
	DOUTR : BUFFER std_logic_vector(23 DOWNTO 0);
	BUSYL : IN std_logic;
	SDOL : IN std_logic;
	nCNVL : BUFFER std_logic;
	SCKL : BUFFER std_logic;
	BUSYR : IN std_logic;
	SDOR : IN std_logic;
	nCNVR : BUFFER std_logic;
	SCKR : BUFFER std_logic;
	Test_CK_cycle : BUFFER std_logic_vector(4 DOWNTO 0);
	Test_ADC_CLK : BUFFER std_logic;
	Test_ADC_SHIFT : BUFFER std_logic;
	Test_AVGen_READ : BUFFER std_logic;
	Test_CNVen_SHFT : BUFFER std_logic;
	Test_AVGen_SCK : BUFFER std_logic;
	Test_CNVen_SCK : BUFFER std_logic;
	Test_CNVclk_cnt : BUFFER std_logic_vector(5 DOWNTO 0);
	Test_AVG_count : BUFFER std_logic_vector(6 DOWNTO 0);
	Test_TCLK23 : BUFFER std_logic_vector(4 DOWNTO 0);
	Test_ReadADCclock : BUFFER std_logic
	);
END F1_readADCmulti_ExtClkII;

ARCHITECTURE structure OF F1_readADCmulti_ExtClkII IS
SIGNAL gnd : std_logic := '0';
SIGNAL vcc : std_logic := '1';
SIGNAL unknown : std_logic := 'X';
SIGNAL devoe : std_logic := '1';
SIGNAL devclrn : std_logic := '1';
SIGNAL devpor : std_logic := '1';
SIGNAL ww_devoe : std_logic;
SIGNAL ww_devclrn : std_logic;
SIGNAL ww_devpor : std_logic;
SIGNAL ww_MCLK : std_logic;
SIGNAL ww_ReadCLK : std_logic;
SIGNAL ww_nFS : std_logic;
SIGNAL ww_Fso : std_logic;
SIGNAL ww_OutOfRange : std_logic;
SIGNAL ww_Clear : std_logic;
SIGNAL ww_SR : std_logic_vector(2 DOWNTO 0);
SIGNAL ww_AVG : std_logic_vector(2 DOWNTO 0);
SIGNAL ww_CLKBypass : std_logic;
SIGNAL ww_AQMODE : std_logic;
SIGNAL ww_DOUTL : std_logic_vector(23 DOWNTO 0);
SIGNAL ww_DOUTR : std_logic_vector(23 DOWNTO 0);
SIGNAL ww_BUSYL : std_logic;
SIGNAL ww_SDOL : std_logic;
SIGNAL ww_nCNVL : std_logic;
SIGNAL ww_SCKL : std_logic;
SIGNAL ww_BUSYR : std_logic;
SIGNAL ww_SDOR : std_logic;
SIGNAL ww_nCNVR : std_logic;
SIGNAL ww_SCKR : std_logic;
SIGNAL ww_Test_CK_cycle : std_logic_vector(4 DOWNTO 0);
SIGNAL ww_Test_ADC_CLK : std_logic;
SIGNAL ww_Test_ADC_SHIFT : std_logic;
SIGNAL ww_Test_AVGen_READ : std_logic;
SIGNAL ww_Test_CNVen_SHFT : std_logic;
SIGNAL ww_Test_AVGen_SCK : std_logic;
SIGNAL ww_Test_CNVen_SCK : std_logic;
SIGNAL ww_Test_CNVclk_cnt : std_logic_vector(5 DOWNTO 0);
SIGNAL ww_Test_AVG_count : std_logic_vector(6 DOWNTO 0);
SIGNAL ww_Test_TCLK23 : std_logic_vector(4 DOWNTO 0);
SIGNAL ww_Test_ReadADCclock : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~5\ : std_logic;
SIGNAL \LessThan3~5\ : std_logic;
SIGNAL \Add1~43\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~10\ : std_logic;
SIGNAL \LessThan3~10\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~15\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~15\ : std_logic;
SIGNAL \LessThan3~15\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~20\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~20\ : std_logic;
SIGNAL \LessThan3~20\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~25\ : std_logic;
SIGNAL \LessThan3~25\ : std_logic;
SIGNAL \LessThan3~30\ : std_logic;
SIGNAL \LessThan3~35\ : std_logic;
SIGNAL \Fso~combout\ : std_logic;
SIGNAL \ReadCLK~combout\ : std_logic;
SIGNAL \Mux5~1_combout\ : std_logic;
SIGNAL \AQMODE~combout\ : std_logic;
SIGNAL \CK_cycle~2_combout\ : std_logic;
SIGNAL \CK_cycle~6_combout\ : std_logic;
SIGNAL \CK_cycle~1_combout\ : std_logic;
SIGNAL \CK_cycle~5_combout\ : std_logic;
SIGNAL \CK_cycle~4_combout\ : std_logic;
SIGNAL \BUSYL~combout\ : std_logic;
SIGNAL \BUSYR~combout\ : std_logic;
SIGNAL \ADC_clocks~0_combout\ : std_logic;
SIGNAL \CNVclk_cnt[1]~1\ : std_logic;
SIGNAL \CNVclk_cnt[2]~3\ : std_logic;
SIGNAL \CNVclk_cnt[3]~5\ : std_logic;
SIGNAL \LessThan1~1_combout\ : std_logic;
SIGNAL \LessThan1~0_combout\ : std_logic;
SIGNAL \CNVclk_cnt[4]~7\ : std_logic;
SIGNAL \CK_cycle~3_combout\ : std_logic;
SIGNAL \LessThan1~2_combout\ : std_logic;
SIGNAL \LessThan1~3_combout\ : std_logic;
SIGNAL \LessThan1~4_combout\ : std_logic;
SIGNAL \LessThan2~0_combout\ : std_logic;
SIGNAL \LessThan2~1_combout\ : std_logic;
SIGNAL \LessThan2~2_combout\ : std_logic;
SIGNAL \LessThan2~3_combout\ : std_logic;
SIGNAL \CNVen_SHFT~regout\ : std_logic;
SIGNAL \nFS~combout\ : std_logic;
SIGNAL \Mux5~8_combout\ : std_logic;
SIGNAL \Mux5~9_combout\ : std_logic;
SIGNAL \Mux5~7_combout\ : std_logic;
SIGNAL \Mux5~6_combout\ : std_logic;
SIGNAL \Mux5~4_combout\ : std_logic;
SIGNAL \Mux5~5_combout\ : std_logic;
SIGNAL \Mux5~2_combout\ : std_logic;
SIGNAL \Mux5~3_combout\ : std_logic;
SIGNAL \Add2~12\ : std_logic;
SIGNAL \Add2~7\ : std_logic;
SIGNAL \Add2~22\ : std_logic;
SIGNAL \Add2~17\ : std_logic;
SIGNAL \Add2~32\ : std_logic;
SIGNAL \Add2~27\ : std_logic;
SIGNAL \Add2~42\ : std_logic;
SIGNAL \Add2~37\ : std_logic;
SIGNAL \Add2~0_combout\ : std_logic;
SIGNAL \OutOfRange~combout\ : std_logic;
SIGNAL \Clear~combout\ : std_logic;
SIGNAL \AVG_cycles~6_combout\ : std_logic;
SIGNAL \Add1~45_cout\ : std_logic;
SIGNAL \Add1~3\ : std_logic;
SIGNAL \Add1~7_combout\ : std_logic;
SIGNAL \Add1~9\ : std_logic;
SIGNAL \Add1~13_combout\ : std_logic;
SIGNAL \Add1~15\ : std_logic;
SIGNAL \Add1~19_combout\ : std_logic;
SIGNAL \Add1~21\ : std_logic;
SIGNAL \Add1~25_combout\ : std_logic;
SIGNAL \Add1~27\ : std_logic;
SIGNAL \Add1~31_combout\ : std_logic;
SIGNAL \Add1~33\ : std_logic;
SIGNAL \Add1~37_combout\ : std_logic;
SIGNAL \LessThan3~37_cout\ : std_logic;
SIGNAL \LessThan3~32_cout\ : std_logic;
SIGNAL \LessThan3~27_cout\ : std_logic;
SIGNAL \LessThan3~22_cout\ : std_logic;
SIGNAL \LessThan3~17_cout\ : std_logic;
SIGNAL \LessThan3~12_cout\ : std_logic;
SIGNAL \LessThan3~7_cout\ : std_logic;
SIGNAL \LessThan3~0_combout\ : std_logic;
SIGNAL \Add1~1_combout\ : std_logic;
SIGNAL \Equal1~0_combout\ : std_logic;
SIGNAL \Equal1~1_combout\ : std_logic;
SIGNAL \Equal1~2_combout\ : std_logic;
SIGNAL \Equal1~3_combout\ : std_logic;
SIGNAL \Equal1~4_combout\ : std_logic;
SIGNAL \Add2~5_combout\ : std_logic;
SIGNAL \Add2~10_combout\ : std_logic;
SIGNAL \Equal0~0_combout\ : std_logic;
SIGNAL \Add2~15_combout\ : std_logic;
SIGNAL \Add2~20_combout\ : std_logic;
SIGNAL \Equal0~1_combout\ : std_logic;
SIGNAL \Add2~25_combout\ : std_logic;
SIGNAL \Add2~30_combout\ : std_logic;
SIGNAL \Equal0~2_combout\ : std_logic;
SIGNAL \Add2~35_combout\ : std_logic;
SIGNAL \Add2~40_combout\ : std_logic;
SIGNAL \Equal0~3_combout\ : std_logic;
SIGNAL \Equal0~4_combout\ : std_logic;
SIGNAL \AVGen_SCK~regout\ : std_logic;
SIGNAL \T_CNVen_SHFT~regout\ : std_logic;
SIGNAL \AVG_cycles~0_combout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[0]~COUT\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~20_combout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~17_cout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~12\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~5_combout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~7\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~0_combout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|StageOut[12]~0_combout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~10_combout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|StageOut[11]~2_combout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|StageOut[10]~4_combout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[0]~COUT\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~25_combout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~22_cout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~17\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~12\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~5_combout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~7\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~0_combout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|StageOut[18]~1_combout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~10_combout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|StageOut[17]~3_combout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~15_combout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|StageOut[16]~5_combout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|StageOut[15]~6_combout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~27_cout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~22_cout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~17_cout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~12_cout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~7_cout\ : std_logic;
SIGNAL \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~0_combout\ : std_logic;
SIGNAL \AVG_cycles~1_combout\ : std_logic;
SIGNAL \AVG_cycles~2_combout\ : std_logic;
SIGNAL \AVG_cycles~3_combout\ : std_logic;
SIGNAL \AVG_cycles~4_combout\ : std_logic;
SIGNAL \AVGen_READ~regout\ : std_logic;
SIGNAL \ADC_SHIFT~0_combout\ : std_logic;
SIGNAL \LessThan0~0_combout\ : std_logic;
SIGNAL \CNVen_SCK~regout\ : std_logic;
SIGNAL \T_CNVen_SCK~regout\ : std_logic;
SIGNAL \ADC_CLK~0_combout\ : std_logic;
SIGNAL \CLKBypass~combout\ : std_logic;
SIGNAL \ReadADCclock~0_combout\ : std_logic;
SIGNAL \SDOL~combout\ : std_logic;
SIGNAL \ResetAVGread~0_combout\ : std_logic;
SIGNAL \TCLK23[1]~1\ : std_logic;
SIGNAL \TCLK23[2]~3\ : std_logic;
SIGNAL \Mux34~0_combout\ : std_logic;
SIGNAL \LessThan5~0_combout\ : std_logic;
SIGNAL \TCLK23[3]~5\ : std_logic;
SIGNAL \Mux34~1_combout\ : std_logic;
SIGNAL \DOUTL[0]~reg0_regout\ : std_logic;
SIGNAL \Mux33~0_combout\ : std_logic;
SIGNAL \DOUTL[1]~reg0_regout\ : std_logic;
SIGNAL \Mux32~0_combout\ : std_logic;
SIGNAL \DOUTL[2]~reg0_regout\ : std_logic;
SIGNAL \Mux31~0_combout\ : std_logic;
SIGNAL \DOUTL[3]~reg0_regout\ : std_logic;
SIGNAL \Mux30~0_combout\ : std_logic;
SIGNAL \DOUTL[4]~reg0_regout\ : std_logic;
SIGNAL \Mux29~0_combout\ : std_logic;
SIGNAL \DOUTL[5]~reg0_regout\ : std_logic;
SIGNAL \Mux28~0_combout\ : std_logic;
SIGNAL \DOUTL[6]~reg0_regout\ : std_logic;
SIGNAL \Mux27~0_combout\ : std_logic;
SIGNAL \DOUTL[7]~reg0_regout\ : std_logic;
SIGNAL \Mux26~0_combout\ : std_logic;
SIGNAL \DOUTL[8]~reg0_regout\ : std_logic;
SIGNAL \Mux25~0_combout\ : std_logic;
SIGNAL \DOUTL[9]~reg0_regout\ : std_logic;
SIGNAL \Mux24~0_combout\ : std_logic;
SIGNAL \DOUTL[10]~reg0_regout\ : std_logic;
SIGNAL \Mux23~0_combout\ : std_logic;
SIGNAL \DOUTL[11]~reg0_regout\ : std_logic;
SIGNAL \Mux22~0_combout\ : std_logic;
SIGNAL \DOUTL[12]~reg0_regout\ : std_logic;
SIGNAL \Mux21~0_combout\ : std_logic;
SIGNAL \DOUTL[13]~reg0_regout\ : std_logic;
SIGNAL \Mux20~0_combout\ : std_logic;
SIGNAL \DOUTL[14]~reg0_regout\ : std_logic;
SIGNAL \Mux19~0_combout\ : std_logic;
SIGNAL \DOUTL[15]~reg0_regout\ : std_logic;
SIGNAL \r_DATAL[19]~4_combout\ : std_logic;
SIGNAL \r_DATAL[16]~10_combout\ : std_logic;
SIGNAL \DOUTL[16]~reg0_regout\ : std_logic;
SIGNAL \r_DATAR[17]~0_combout\ : std_logic;
SIGNAL \DOUTL[17]~reg0_regout\ : std_logic;
SIGNAL \r_DATAL[18]~5_combout\ : std_logic;
SIGNAL \DOUTL[18]~reg0_regout\ : std_logic;
SIGNAL \r_DATAL[19]~6_combout\ : std_logic;
SIGNAL \DOUTL[19]~reg0_regout\ : std_logic;
SIGNAL \r_DATAL[20]~7_combout\ : std_logic;
SIGNAL \DOUTL[20]~reg0_regout\ : std_logic;
SIGNAL \r_DATAL[21]~8_combout\ : std_logic;
SIGNAL \DOUTL[21]~reg0_regout\ : std_logic;
SIGNAL \r_DATAR[22]~1_combout\ : std_logic;
SIGNAL \DOUTL[22]~reg0_regout\ : std_logic;
SIGNAL \r_DATAL[23]~9_combout\ : std_logic;
SIGNAL \DOUTL[23]~reg0_regout\ : std_logic;
SIGNAL \SDOR~combout\ : std_logic;
SIGNAL \DOUTR[0]~reg0_regout\ : std_logic;
SIGNAL \DOUTR[1]~reg0_regout\ : std_logic;
SIGNAL \DOUTR[2]~reg0_regout\ : std_logic;
SIGNAL \DOUTR[3]~reg0_regout\ : std_logic;
SIGNAL \DOUTR[4]~reg0_regout\ : std_logic;
SIGNAL \DOUTR[5]~reg0_regout\ : std_logic;
SIGNAL \DOUTR[6]~reg0_regout\ : std_logic;
SIGNAL \DOUTR[7]~reg0_regout\ : std_logic;
SIGNAL \DOUTR[8]~reg0_regout\ : std_logic;
SIGNAL \DOUTR[9]~reg0_regout\ : std_logic;
SIGNAL \DOUTR[10]~reg0_regout\ : std_logic;
SIGNAL \DOUTR[11]~reg0_regout\ : std_logic;
SIGNAL \DOUTR[12]~reg0_regout\ : std_logic;
SIGNAL \DOUTR[13]~reg0_regout\ : std_logic;
SIGNAL \DOUTR[14]~reg0_regout\ : std_logic;
SIGNAL \DOUTR[15]~reg0_regout\ : std_logic;
SIGNAL \DOUTR[16]~reg0_regout\ : std_logic;
SIGNAL \DOUTR[17]~reg0_regout\ : std_logic;
SIGNAL \DOUTR[18]~reg0_regout\ : std_logic;
SIGNAL \DOUTR[19]~reg0_regout\ : std_logic;
SIGNAL \DOUTR[20]~reg0_regout\ : std_logic;
SIGNAL \DOUTR[21]~reg0_regout\ : std_logic;
SIGNAL \DOUTR[22]~reg0_regout\ : std_logic;
SIGNAL \DOUTR[23]~reg0_regout\ : std_logic;
SIGNAL \AVG~combout\ : std_logic_vector(2 DOWNTO 0);
SIGNAL CNVclk_cnt : std_logic_vector(5 DOWNTO 0);
SIGNAL AVG_count : std_logic_vector(7 DOWNTO 0);
SIGNAL TCLK23 : std_logic_vector(4 DOWNTO 0);
SIGNAL \Div0|auto_generated|divider|divider|StageOut\ : std_logic_vector(24 DOWNTO 0);
SIGNAL r_DATAL : std_logic_vector(23 DOWNTO 0);
SIGNAL \Div0|auto_generated|divider|divider|selnose\ : std_logic_vector(29 DOWNTO 0);
SIGNAL r_DATAR : std_logic_vector(23 DOWNTO 0);
SIGNAL \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella\ : std_logic_vector(2 DOWNTO 0);
SIGNAL \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella\ : std_logic_vector(3 DOWNTO 0);
SIGNAL ALT_INV_AVG_count : std_logic_vector(0 DOWNTO 0);
SIGNAL \ALT_INV_AVGen_SCK~regout\ : std_logic;
SIGNAL \ALT_INV_ReadCLK~combout\ : std_logic;
SIGNAL \ALT_INV_CK_cycle~4_combout\ : std_logic;
SIGNAL \ALT_INV_nFS~combout\ : std_logic;

BEGIN

ww_MCLK <= MCLK;
ww_ReadCLK <= ReadCLK;
ww_nFS <= nFS;
ww_Fso <= Fso;
ww_OutOfRange <= OutOfRange;
ww_Clear <= Clear;
ww_SR <= SR;
ww_AVG <= AVG;
ww_CLKBypass <= CLKBypass;
ww_AQMODE <= AQMODE;
DOUTL <= ww_DOUTL;
DOUTR <= ww_DOUTR;
ww_BUSYL <= BUSYL;
ww_SDOL <= SDOL;
nCNVL <= ww_nCNVL;
SCKL <= ww_SCKL;
ww_BUSYR <= BUSYR;
ww_SDOR <= SDOR;
nCNVR <= ww_nCNVR;
SCKR <= ww_SCKR;
Test_CK_cycle <= ww_Test_CK_cycle;
Test_ADC_CLK <= ww_Test_ADC_CLK;
Test_ADC_SHIFT <= ww_Test_ADC_SHIFT;
Test_AVGen_READ <= ww_Test_AVGen_READ;
Test_CNVen_SHFT <= ww_Test_CNVen_SHFT;
Test_AVGen_SCK <= ww_Test_AVGen_SCK;
Test_CNVen_SCK <= ww_Test_CNVen_SCK;
Test_CNVclk_cnt <= ww_Test_CNVclk_cnt;
Test_AVG_count <= ww_Test_AVG_count;
Test_TCLK23 <= ww_Test_TCLK23;
Test_ReadADCclock <= ww_Test_ReadADCclock;
ww_devoe <= devoe;
ww_devclrn <= devclrn;
ww_devpor <= devpor;
ALT_INV_AVG_count(0) <= NOT AVG_count(0);
\ALT_INV_AVGen_SCK~regout\ <= NOT \AVGen_SCK~regout\;
\ALT_INV_ReadCLK~combout\ <= NOT \ReadCLK~combout\;
\ALT_INV_CK_cycle~4_combout\ <= NOT \CK_cycle~4_combout\;
\ALT_INV_nFS~combout\ <= NOT \nFS~combout\;

\Fso~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_Fso,
	combout => \Fso~combout\);

\ReadCLK~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_ReadCLK,
	combout => \ReadCLK~combout\);

\AVG[0]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_AVG(0),
	combout => \AVG~combout\(0));

\AVG[1]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_AVG(1),
	combout => \AVG~combout\(1));

\Mux5~1\ : maxv_lcell
-- Equation(s):
-- \Mux5~1_combout\ = (((!\AVG~combout\(0) & !\AVG~combout\(1))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "000f",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datac => \AVG~combout\(0),
	datad => \AVG~combout\(1),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux5~1_combout\);

\AQMODE~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_AQMODE,
	combout => \AQMODE~combout\);

\AVG[2]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_AVG(2),
	combout => \AVG~combout\(2));

\CK_cycle~2\ : maxv_lcell
-- Equation(s):
-- \CK_cycle~2_combout\ = (\Mux5~1_combout\ & (\AQMODE~combout\ & (\AVG~combout\(2))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8080",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Mux5~1_combout\,
	datab => \AQMODE~combout\,
	datac => \AVG~combout\(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \CK_cycle~2_combout\);

\CK_cycle~6\ : maxv_lcell
-- Equation(s):
-- \CK_cycle~6_combout\ = (\AQMODE~combout\ & (\AVG~combout\(2)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8888",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \AQMODE~combout\,
	datab => \AVG~combout\(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \CK_cycle~6_combout\);

\CK_cycle~1\ : maxv_lcell
-- Equation(s):
-- \CK_cycle~1_combout\ = (\CK_cycle~6_combout\ & (((!\Mux5~1_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "00aa",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \CK_cycle~6_combout\,
	datad => \Mux5~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \CK_cycle~1_combout\);

\CK_cycle~5\ : maxv_lcell
-- Equation(s):
-- \CK_cycle~5_combout\ = (((!\AVG~combout\(2) & !\AVG~combout\(1))) # (!\AQMODE~combout\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "03ff",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datab => \AVG~combout\(2),
	datac => \AVG~combout\(1),
	datad => \AQMODE~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \CK_cycle~5_combout\);

\CK_cycle~4\ : maxv_lcell
-- Equation(s):
-- \CK_cycle~4_combout\ = (\AQMODE~combout\ & ((\AVG~combout\(2)) # ((\AVG~combout\(0) & \AVG~combout\(1)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "a888",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \AQMODE~combout\,
	datab => \AVG~combout\(2),
	datac => \AVG~combout\(0),
	datad => \AVG~combout\(1),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \CK_cycle~4_combout\);

\BUSYL~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_BUSYL,
	combout => \BUSYL~combout\);

\BUSYR~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_BUSYR,
	combout => \BUSYR~combout\);

\ADC_clocks~0\ : maxv_lcell
-- Equation(s):
-- \ADC_clocks~0_combout\ = (\BUSYL~combout\) # ((\BUSYR~combout\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "eeee",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \BUSYL~combout\,
	datab => \BUSYR~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \ADC_clocks~0_combout\);

\CNVclk_cnt[1]\ : maxv_lcell
-- Equation(s):
-- CNVclk_cnt(1) = DFFEAS(CNVclk_cnt(0) $ ((CNVclk_cnt(1))), \ReadCLK~combout\, !\ADC_clocks~0_combout\, , \LessThan1~4_combout\, , , , )
-- \CNVclk_cnt[1]~1\ = CARRY((CNVclk_cnt(0) & (CNVclk_cnt(1))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "6688",
	operation_mode => "arithmetic",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadCLK~combout\,
	dataa => CNVclk_cnt(0),
	datab => CNVclk_cnt(1),
	aclr => \ADC_clocks~0_combout\,
	ena => \LessThan1~4_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => CNVclk_cnt(1),
	cout => \CNVclk_cnt[1]~1\);

\CNVclk_cnt[2]\ : maxv_lcell
-- Equation(s):
-- CNVclk_cnt(2) = DFFEAS(CNVclk_cnt(2) $ ((((\CNVclk_cnt[1]~1\)))), \ReadCLK~combout\, !\ADC_clocks~0_combout\, , \LessThan1~4_combout\, , , , )
-- \CNVclk_cnt[2]~3\ = CARRY(((!\CNVclk_cnt[1]~1\)) # (!CNVclk_cnt(2)))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "5a5f",
	operation_mode => "arithmetic",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadCLK~combout\,
	dataa => CNVclk_cnt(2),
	aclr => \ADC_clocks~0_combout\,
	ena => \LessThan1~4_combout\,
	cin => \CNVclk_cnt[1]~1\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => CNVclk_cnt(2),
	cout => \CNVclk_cnt[2]~3\);

\CNVclk_cnt[3]\ : maxv_lcell
-- Equation(s):
-- CNVclk_cnt(3) = DFFEAS(CNVclk_cnt(3) $ ((((!\CNVclk_cnt[2]~3\)))), \ReadCLK~combout\, !\ADC_clocks~0_combout\, , \LessThan1~4_combout\, , , , )
-- \CNVclk_cnt[3]~5\ = CARRY((CNVclk_cnt(3) & ((!\CNVclk_cnt[2]~3\))))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "a50a",
	operation_mode => "arithmetic",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadCLK~combout\,
	dataa => CNVclk_cnt(3),
	aclr => \ADC_clocks~0_combout\,
	ena => \LessThan1~4_combout\,
	cin => \CNVclk_cnt[2]~3\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => CNVclk_cnt(3),
	cout => \CNVclk_cnt[3]~5\);

\CNVclk_cnt[4]\ : maxv_lcell
-- Equation(s):
-- CNVclk_cnt(4) = DFFEAS(CNVclk_cnt(4) $ ((((\CNVclk_cnt[3]~5\)))), \ReadCLK~combout\, !\ADC_clocks~0_combout\, , \LessThan1~4_combout\, , , , )
-- \CNVclk_cnt[4]~7\ = CARRY(((!\CNVclk_cnt[3]~5\)) # (!CNVclk_cnt(4)))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "5a5f",
	operation_mode => "arithmetic",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadCLK~combout\,
	dataa => CNVclk_cnt(4),
	aclr => \ADC_clocks~0_combout\,
	ena => \LessThan1~4_combout\,
	cin => \CNVclk_cnt[3]~5\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => CNVclk_cnt(4),
	cout => \CNVclk_cnt[4]~7\);

\LessThan1~1\ : maxv_lcell
-- Equation(s):
-- \LessThan1~1_combout\ = (\CK_cycle~5_combout\ & (((!CNVclk_cnt(4)) # (!CNVclk_cnt(3))) # (!\CK_cycle~4_combout\))) # (!\CK_cycle~5_combout\ & (!CNVclk_cnt(4) & ((!CNVclk_cnt(3)) # (!\CK_cycle~4_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "2abf",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \CK_cycle~5_combout\,
	datab => \CK_cycle~4_combout\,
	datac => CNVclk_cnt(3),
	datad => CNVclk_cnt(4),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \LessThan1~1_combout\);

\LessThan1~0\ : maxv_lcell
-- Equation(s):
-- \LessThan1~0_combout\ = (\CK_cycle~5_combout\ & (CNVclk_cnt(4) & (\CK_cycle~4_combout\ $ (CNVclk_cnt(3))))) # (!\CK_cycle~5_combout\ & (!CNVclk_cnt(4) & (\CK_cycle~4_combout\ $ (CNVclk_cnt(3)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0990",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \CK_cycle~5_combout\,
	datab => CNVclk_cnt(4),
	datac => \CK_cycle~4_combout\,
	datad => CNVclk_cnt(3),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \LessThan1~0_combout\);

\CNVclk_cnt[5]\ : maxv_lcell
-- Equation(s):
-- CNVclk_cnt(5) = DFFEAS(CNVclk_cnt(5) $ ((((!\CNVclk_cnt[4]~7\)))), \ReadCLK~combout\, !\ADC_clocks~0_combout\, , \LessThan1~4_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "a5a5",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadCLK~combout\,
	dataa => CNVclk_cnt(5),
	aclr => \ADC_clocks~0_combout\,
	ena => \LessThan1~4_combout\,
	cin => \CNVclk_cnt[4]~7\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => CNVclk_cnt(5));

\CK_cycle~3\ : maxv_lcell
-- Equation(s):
-- \CK_cycle~3_combout\ = (\AQMODE~combout\ & (\AVG~combout\(0) & (\AVG~combout\(1) & !\AVG~combout\(2))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0080",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \AQMODE~combout\,
	datab => \AVG~combout\(0),
	datac => \AVG~combout\(1),
	datad => \AVG~combout\(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \CK_cycle~3_combout\);

\LessThan1~2\ : maxv_lcell
-- Equation(s):
-- \LessThan1~2_combout\ = (CNVclk_cnt(1) & (((CNVclk_cnt(0) & !\CK_cycle~1_combout\)) # (!\CK_cycle~2_combout\))) # (!CNVclk_cnt(1) & (!\CK_cycle~2_combout\ & (CNVclk_cnt(0) & !\CK_cycle~1_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "22b2",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => CNVclk_cnt(1),
	datab => \CK_cycle~2_combout\,
	datac => CNVclk_cnt(0),
	datad => \CK_cycle~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \LessThan1~2_combout\);

\LessThan1~3\ : maxv_lcell
-- Equation(s):
-- \LessThan1~3_combout\ = (CNVclk_cnt(2) & (((\LessThan1~2_combout\)) # (!\CK_cycle~3_combout\))) # (!CNVclk_cnt(2) & (!\CK_cycle~3_combout\ & (\LessThan1~2_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "b2b2",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => CNVclk_cnt(2),
	datab => \CK_cycle~3_combout\,
	datac => \LessThan1~2_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \LessThan1~3_combout\);

\LessThan1~4\ : maxv_lcell
-- Equation(s):
-- \LessThan1~4_combout\ = (\LessThan1~1_combout\ & (!CNVclk_cnt(5) & ((!\LessThan1~3_combout\) # (!\LessThan1~0_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "020a",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \LessThan1~1_combout\,
	datab => \LessThan1~0_combout\,
	datac => CNVclk_cnt(5),
	datad => \LessThan1~3_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \LessThan1~4_combout\);

\CNVclk_cnt[0]\ : maxv_lcell
-- Equation(s):
-- CNVclk_cnt(0) = DFFEAS(CNVclk_cnt(0) $ ((\LessThan1~4_combout\)), \ReadCLK~combout\, !\ADC_clocks~0_combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "6666",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadCLK~combout\,
	dataa => CNVclk_cnt(0),
	datab => \LessThan1~4_combout\,
	aclr => \ADC_clocks~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => CNVclk_cnt(0));

\LessThan2~0\ : maxv_lcell
-- Equation(s):
-- \LessThan2~0_combout\ = (\CK_cycle~2_combout\ & (((\CK_cycle~1_combout\ & !CNVclk_cnt(0))) # (!CNVclk_cnt(1)))) # (!\CK_cycle~2_combout\ & (\CK_cycle~1_combout\ & (!CNVclk_cnt(0) & !CNVclk_cnt(1))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "08ae",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \CK_cycle~2_combout\,
	datab => \CK_cycle~1_combout\,
	datac => CNVclk_cnt(0),
	datad => CNVclk_cnt(1),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \LessThan2~0_combout\);

\LessThan2~1\ : maxv_lcell
-- Equation(s):
-- \LessThan2~1_combout\ = (\LessThan2~0_combout\ & (\LessThan1~0_combout\ & (\CK_cycle~3_combout\ $ (!CNVclk_cnt(2)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8008",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \LessThan2~0_combout\,
	datab => \LessThan1~0_combout\,
	datac => \CK_cycle~3_combout\,
	datad => CNVclk_cnt(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \LessThan2~1_combout\);

\LessThan2~2\ : maxv_lcell
-- Equation(s):
-- \LessThan2~2_combout\ = (\CK_cycle~4_combout\ & (\CK_cycle~3_combout\ & (!CNVclk_cnt(2) & !CNVclk_cnt(3)))) # (!\CK_cycle~4_combout\ & (((\CK_cycle~3_combout\ & !CNVclk_cnt(2))) # (!CNVclk_cnt(3))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "022f",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \CK_cycle~3_combout\,
	datab => CNVclk_cnt(2),
	datac => \CK_cycle~4_combout\,
	datad => CNVclk_cnt(3),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \LessThan2~2_combout\);

\LessThan2~3\ : maxv_lcell
-- Equation(s):
-- \LessThan2~3_combout\ = (\LessThan2~1_combout\) # ((\CK_cycle~5_combout\ & ((\LessThan2~2_combout\) # (!CNVclk_cnt(4)))) # (!\CK_cycle~5_combout\ & (\LessThan2~2_combout\ & !CNVclk_cnt(4))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "eafe",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \LessThan2~1_combout\,
	datab => \CK_cycle~5_combout\,
	datac => \LessThan2~2_combout\,
	datad => CNVclk_cnt(4),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \LessThan2~3_combout\);

CNVen_SHFT : maxv_lcell
-- Equation(s):
-- \CNVen_SHFT~regout\ = DFFEAS((\LessThan2~3_combout\ & (((!CNVclk_cnt(5))))), \ReadCLK~combout\, !\ADC_clocks~0_combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "00aa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadCLK~combout\,
	dataa => \LessThan2~3_combout\,
	datad => CNVclk_cnt(5),
	aclr => \ADC_clocks~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \CNVen_SHFT~regout\);

\nFS~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_nFS,
	combout => \nFS~combout\);

\Mux5~8\ : maxv_lcell
-- Equation(s):
-- \Mux5~8_combout\ = (\AVG~combout\(2) & (\AVG~combout\(0) & (\AVG~combout\(1))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8080",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \AVG~combout\(2),
	datab => \AVG~combout\(0),
	datac => \AVG~combout\(1),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux5~8_combout\);

\Mux5~9\ : maxv_lcell
-- Equation(s):
-- \Mux5~9_combout\ = (\AVG~combout\(2) & (\AVG~combout\(1) & ((!\AVG~combout\(0)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0088",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \AVG~combout\(2),
	datab => \AVG~combout\(1),
	datad => \AVG~combout\(0),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux5~9_combout\);

\Mux5~7\ : maxv_lcell
-- Equation(s):
-- \Mux5~7_combout\ = (\AVG~combout\(2) & (\AVG~combout\(0) & ((!\AVG~combout\(1)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0088",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \AVG~combout\(2),
	datab => \AVG~combout\(0),
	datad => \AVG~combout\(1),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux5~7_combout\);

\Mux5~6\ : maxv_lcell
-- Equation(s):
-- \Mux5~6_combout\ = (\Mux5~1_combout\ & (\AVG~combout\(2)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8888",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Mux5~1_combout\,
	datab => \AVG~combout\(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux5~6_combout\);

\Mux5~4\ : maxv_lcell
-- Equation(s):
-- \Mux5~4_combout\ = (\AVG~combout\(0) & (\AVG~combout\(1) & ((!\AVG~combout\(2)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0088",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \AVG~combout\(0),
	datab => \AVG~combout\(1),
	datad => \AVG~combout\(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux5~4_combout\);

\Mux5~5\ : maxv_lcell
-- Equation(s):
-- \Mux5~5_combout\ = (\AVG~combout\(1) & (((!\AVG~combout\(2) & !\AVG~combout\(0)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "000a",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \AVG~combout\(1),
	datac => \AVG~combout\(2),
	datad => \AVG~combout\(0),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux5~5_combout\);

\Mux5~2\ : maxv_lcell
-- Equation(s):
-- \Mux5~2_combout\ = (\AVG~combout\(0) & (((!\AVG~combout\(2) & !\AVG~combout\(1)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "000a",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \AVG~combout\(0),
	datac => \AVG~combout\(2),
	datad => \AVG~combout\(1),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux5~2_combout\);

\Mux5~3\ : maxv_lcell
-- Equation(s):
-- \Mux5~3_combout\ = (\Mux5~1_combout\ & (((!\AVG~combout\(2)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "00aa",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Mux5~1_combout\,
	datad => \AVG~combout\(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux5~3_combout\);

\Add2~10\ : maxv_lcell
-- Equation(s):
-- \Add2~10_combout\ = (!\Mux5~3_combout\)
-- \Add2~12\ = CARRY((\Mux5~3_combout\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "55aa",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Mux5~3_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add2~10_combout\,
	cout => \Add2~12\);

\Add2~5\ : maxv_lcell
-- Equation(s):
-- \Add2~5_combout\ = \Mux5~2_combout\ $ ((((!\Add2~12\))))
-- \Add2~7\ = CARRY((!\Mux5~2_combout\ & ((!\Add2~12\))))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "a505",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Mux5~2_combout\,
	cin => \Add2~12\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add2~5_combout\,
	cout => \Add2~7\);

\Add2~20\ : maxv_lcell
-- Equation(s):
-- \Add2~20_combout\ = \Mux5~5_combout\ $ ((((\Add2~7\))))
-- \Add2~22\ = CARRY((\Mux5~5_combout\) # ((!\Add2~7\)))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "5aaf",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Mux5~5_combout\,
	cin => \Add2~7\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add2~20_combout\,
	cout => \Add2~22\);

\Add2~15\ : maxv_lcell
-- Equation(s):
-- \Add2~15_combout\ = \Mux5~4_combout\ $ ((((!\Add2~22\))))
-- \Add2~17\ = CARRY((!\Mux5~4_combout\ & ((!\Add2~22\))))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "a505",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Mux5~4_combout\,
	cin => \Add2~22\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add2~15_combout\,
	cout => \Add2~17\);

\Add2~30\ : maxv_lcell
-- Equation(s):
-- \Add2~30_combout\ = \Mux5~6_combout\ $ ((((\Add2~17\))))
-- \Add2~32\ = CARRY((\Mux5~6_combout\) # ((!\Add2~17\)))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "5aaf",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Mux5~6_combout\,
	cin => \Add2~17\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add2~30_combout\,
	cout => \Add2~32\);

\Add2~25\ : maxv_lcell
-- Equation(s):
-- \Add2~25_combout\ = \Mux5~7_combout\ $ ((((!\Add2~32\))))
-- \Add2~27\ = CARRY((!\Mux5~7_combout\ & ((!\Add2~32\))))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "a505",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Mux5~7_combout\,
	cin => \Add2~32\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add2~25_combout\,
	cout => \Add2~27\);

\Add2~40\ : maxv_lcell
-- Equation(s):
-- \Add2~40_combout\ = \Mux5~9_combout\ $ ((((\Add2~27\))))
-- \Add2~42\ = CARRY((\Mux5~9_combout\) # ((!\Add2~27\)))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "5aaf",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Mux5~9_combout\,
	cin => \Add2~27\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add2~40_combout\,
	cout => \Add2~42\);

\Add2~35\ : maxv_lcell
-- Equation(s):
-- \Add2~35_combout\ = \Mux5~8_combout\ $ ((((!\Add2~42\))))
-- \Add2~37\ = CARRY((!\Mux5~8_combout\ & ((!\Add2~42\))))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "a505",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Mux5~8_combout\,
	cin => \Add2~42\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add2~35_combout\,
	cout => \Add2~37\);

\Add2~0\ : maxv_lcell
-- Equation(s):
-- \Add2~0_combout\ = (((\Add2~37\)))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "f0f0",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	cin => \Add2~37\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add2~0_combout\);

\OutOfRange~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_OutOfRange,
	combout => \OutOfRange~combout\);

\Clear~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_Clear,
	combout => \Clear~combout\);

\AVG_cycles~6\ : maxv_lcell
-- Equation(s):
-- \AVG_cycles~6_combout\ = (\OutOfRange~combout\) # ((\Clear~combout\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "eeee",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \OutOfRange~combout\,
	datab => \Clear~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \AVG_cycles~6_combout\);

\AVG_count[0]\ : maxv_lcell
-- Equation(s):
-- AVG_count(0) = DFFEAS((!AVG_count(0) & (((\LessThan3~0_combout\)))), \nFS~combout\, !\AVG_cycles~6_combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "5500",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \nFS~combout\,
	dataa => AVG_count(0),
	datad => \LessThan3~0_combout\,
	aclr => \AVG_cycles~6_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => AVG_count(0));

\Add1~45\ : maxv_lcell
-- Equation(s):
-- \Add1~45_cout\ = CARRY((!AVG_count(0)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ff55",
	operation_mode => "arithmetic",
	output_mode => "none",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(0),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add1~43\,
	cout => \Add1~45_cout\);

\Add1~1\ : maxv_lcell
-- Equation(s):
-- \Add1~1_combout\ = AVG_count(1) $ ((((\Add1~45_cout\))))
-- \Add1~3\ = CARRY(((!\Add1~45_cout\)) # (!AVG_count(1)))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "5a5f",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(1),
	cin => \Add1~45_cout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add1~1_combout\,
	cout => \Add1~3\);

\Add1~7\ : maxv_lcell
-- Equation(s):
-- \Add1~7_combout\ = AVG_count(2) $ ((((!\Add1~3\))))
-- \Add1~9\ = CARRY((AVG_count(2) & ((!\Add1~3\))))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "a50a",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(2),
	cin => \Add1~3\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add1~7_combout\,
	cout => \Add1~9\);

\AVG_count[2]\ : maxv_lcell
-- Equation(s):
-- AVG_count(2) = DFFEAS((\LessThan3~0_combout\ & (\Add1~7_combout\)), \nFS~combout\, !\AVG_cycles~6_combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8888",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \nFS~combout\,
	dataa => \LessThan3~0_combout\,
	datab => \Add1~7_combout\,
	aclr => \AVG_cycles~6_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => AVG_count(2));

\Add1~13\ : maxv_lcell
-- Equation(s):
-- \Add1~13_combout\ = AVG_count(3) $ ((((\Add1~9\))))
-- \Add1~15\ = CARRY(((!\Add1~9\)) # (!AVG_count(3)))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "5a5f",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(3),
	cin => \Add1~9\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add1~13_combout\,
	cout => \Add1~15\);

\AVG_count[3]\ : maxv_lcell
-- Equation(s):
-- AVG_count(3) = DFFEAS((\LessThan3~0_combout\ & (\Add1~13_combout\)), \nFS~combout\, !\AVG_cycles~6_combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8888",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \nFS~combout\,
	dataa => \LessThan3~0_combout\,
	datab => \Add1~13_combout\,
	aclr => \AVG_cycles~6_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => AVG_count(3));

\Add1~19\ : maxv_lcell
-- Equation(s):
-- \Add1~19_combout\ = AVG_count(4) $ ((((!\Add1~15\))))
-- \Add1~21\ = CARRY((AVG_count(4) & ((!\Add1~15\))))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "a50a",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(4),
	cin => \Add1~15\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add1~19_combout\,
	cout => \Add1~21\);

\AVG_count[4]\ : maxv_lcell
-- Equation(s):
-- AVG_count(4) = DFFEAS((\LessThan3~0_combout\ & (\Add1~19_combout\)), \nFS~combout\, !\AVG_cycles~6_combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8888",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \nFS~combout\,
	dataa => \LessThan3~0_combout\,
	datab => \Add1~19_combout\,
	aclr => \AVG_cycles~6_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => AVG_count(4));

\Add1~25\ : maxv_lcell
-- Equation(s):
-- \Add1~25_combout\ = AVG_count(5) $ ((((\Add1~21\))))
-- \Add1~27\ = CARRY(((!\Add1~21\)) # (!AVG_count(5)))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "5a5f",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(5),
	cin => \Add1~21\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add1~25_combout\,
	cout => \Add1~27\);

\AVG_count[5]\ : maxv_lcell
-- Equation(s):
-- AVG_count(5) = DFFEAS((\LessThan3~0_combout\ & (\Add1~25_combout\)), \nFS~combout\, !\AVG_cycles~6_combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8888",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \nFS~combout\,
	dataa => \LessThan3~0_combout\,
	datab => \Add1~25_combout\,
	aclr => \AVG_cycles~6_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => AVG_count(5));

\Add1~31\ : maxv_lcell
-- Equation(s):
-- \Add1~31_combout\ = AVG_count(6) $ ((((!\Add1~27\))))
-- \Add1~33\ = CARRY((AVG_count(6) & ((!\Add1~27\))))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "a50a",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(6),
	cin => \Add1~27\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add1~31_combout\,
	cout => \Add1~33\);

\AVG_count[6]\ : maxv_lcell
-- Equation(s):
-- AVG_count(6) = DFFEAS((\LessThan3~0_combout\ & (\Add1~31_combout\)), \nFS~combout\, !\AVG_cycles~6_combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8888",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \nFS~combout\,
	dataa => \LessThan3~0_combout\,
	datab => \Add1~31_combout\,
	aclr => \AVG_cycles~6_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => AVG_count(6));

\Add1~37\ : maxv_lcell
-- Equation(s):
-- \Add1~37_combout\ = AVG_count(7) $ ((((\Add1~33\))))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "5a5a",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(7),
	cin => \Add1~33\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Add1~37_combout\);

\AVG_count[7]\ : maxv_lcell
-- Equation(s):
-- AVG_count(7) = DFFEAS((\LessThan3~0_combout\ & (\Add1~37_combout\)), \nFS~combout\, !\AVG_cycles~6_combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8888",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \nFS~combout\,
	dataa => \LessThan3~0_combout\,
	datab => \Add1~37_combout\,
	aclr => \AVG_cycles~6_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => AVG_count(7));

\LessThan3~37\ : maxv_lcell
-- Equation(s):
-- \LessThan3~37_cout\ = CARRY((AVG_count(0) & (\Mux5~3_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ff88",
	operation_mode => "arithmetic",
	output_mode => "none",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(0),
	datab => \Mux5~3_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \LessThan3~35\,
	cout => \LessThan3~37_cout\);

\LessThan3~32\ : maxv_lcell
-- Equation(s):
-- \LessThan3~32_cout\ = CARRY((AVG_count(1) & ((!\LessThan3~37_cout\) # (!\Mux5~2_combout\))) # (!AVG_count(1) & (!\Mux5~2_combout\ & !\LessThan3~37_cout\)))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "ff2b",
	operation_mode => "arithmetic",
	output_mode => "none",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(1),
	datab => \Mux5~2_combout\,
	cin => \LessThan3~37_cout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \LessThan3~30\,
	cout => \LessThan3~32_cout\);

\LessThan3~27\ : maxv_lcell
-- Equation(s):
-- \LessThan3~27_cout\ = CARRY((AVG_count(2) & (\Mux5~5_combout\ & !\LessThan3~32_cout\)) # (!AVG_count(2) & ((\Mux5~5_combout\) # (!\LessThan3~32_cout\))))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "ff4d",
	operation_mode => "arithmetic",
	output_mode => "none",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(2),
	datab => \Mux5~5_combout\,
	cin => \LessThan3~32_cout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \LessThan3~25\,
	cout => \LessThan3~27_cout\);

\LessThan3~22\ : maxv_lcell
-- Equation(s):
-- \LessThan3~22_cout\ = CARRY((AVG_count(3) & ((!\LessThan3~27_cout\) # (!\Mux5~4_combout\))) # (!AVG_count(3) & (!\Mux5~4_combout\ & !\LessThan3~27_cout\)))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "ff2b",
	operation_mode => "arithmetic",
	output_mode => "none",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(3),
	datab => \Mux5~4_combout\,
	cin => \LessThan3~27_cout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \LessThan3~20\,
	cout => \LessThan3~22_cout\);

\LessThan3~17\ : maxv_lcell
-- Equation(s):
-- \LessThan3~17_cout\ = CARRY((AVG_count(4) & (\Mux5~6_combout\ & !\LessThan3~22_cout\)) # (!AVG_count(4) & ((\Mux5~6_combout\) # (!\LessThan3~22_cout\))))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "ff4d",
	operation_mode => "arithmetic",
	output_mode => "none",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(4),
	datab => \Mux5~6_combout\,
	cin => \LessThan3~22_cout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \LessThan3~15\,
	cout => \LessThan3~17_cout\);

\LessThan3~12\ : maxv_lcell
-- Equation(s):
-- \LessThan3~12_cout\ = CARRY((AVG_count(5) & ((!\LessThan3~17_cout\) # (!\Mux5~7_combout\))) # (!AVG_count(5) & (!\Mux5~7_combout\ & !\LessThan3~17_cout\)))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "ff2b",
	operation_mode => "arithmetic",
	output_mode => "none",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(5),
	datab => \Mux5~7_combout\,
	cin => \LessThan3~17_cout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \LessThan3~10\,
	cout => \LessThan3~12_cout\);

\LessThan3~7\ : maxv_lcell
-- Equation(s):
-- \LessThan3~7_cout\ = CARRY((AVG_count(6) & (\Mux5~9_combout\ & !\LessThan3~12_cout\)) # (!AVG_count(6) & ((\Mux5~9_combout\) # (!\LessThan3~12_cout\))))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "ff4d",
	operation_mode => "arithmetic",
	output_mode => "none",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(6),
	datab => \Mux5~9_combout\,
	cin => \LessThan3~12_cout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \LessThan3~5\,
	cout => \LessThan3~7_cout\);

\LessThan3~0\ : maxv_lcell
-- Equation(s):
-- \LessThan3~0_combout\ = (AVG_count(7) & (\Mux5~8_combout\ & (\LessThan3~7_cout\))) # (!AVG_count(7) & ((\Mux5~8_combout\) # ((\LessThan3~7_cout\))))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "d4d4",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(7),
	datab => \Mux5~8_combout\,
	cin => \LessThan3~7_cout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \LessThan3~0_combout\);

\AVG_count[1]\ : maxv_lcell
-- Equation(s):
-- AVG_count(1) = DFFEAS((\LessThan3~0_combout\ & (\Add1~1_combout\)), \nFS~combout\, !\AVG_cycles~6_combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8888",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \nFS~combout\,
	dataa => \LessThan3~0_combout\,
	datab => \Add1~1_combout\,
	aclr => \AVG_cycles~6_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => AVG_count(1));

\Equal1~0\ : maxv_lcell
-- Equation(s):
-- \Equal1~0_combout\ = (AVG_count(1) & (\Mux5~2_combout\ & (AVG_count(0) $ (\Mux5~3_combout\)))) # (!AVG_count(1) & (!\Mux5~2_combout\ & (AVG_count(0) $ (\Mux5~3_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0990",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(1),
	datab => \Mux5~2_combout\,
	datac => AVG_count(0),
	datad => \Mux5~3_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Equal1~0_combout\);

\Equal1~1\ : maxv_lcell
-- Equation(s):
-- \Equal1~1_combout\ = (\Mux5~4_combout\ & (AVG_count(3) & (AVG_count(2) $ (!\Mux5~5_combout\)))) # (!\Mux5~4_combout\ & (!AVG_count(3) & (AVG_count(2) $ (!\Mux5~5_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8241",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Mux5~4_combout\,
	datab => AVG_count(2),
	datac => \Mux5~5_combout\,
	datad => AVG_count(3),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Equal1~1_combout\);

\Equal1~2\ : maxv_lcell
-- Equation(s):
-- \Equal1~2_combout\ = (\Mux5~6_combout\ & (AVG_count(4) & (AVG_count(5) $ (!\Mux5~7_combout\)))) # (!\Mux5~6_combout\ & (!AVG_count(4) & (AVG_count(5) $ (!\Mux5~7_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8241",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Mux5~6_combout\,
	datab => AVG_count(5),
	datac => \Mux5~7_combout\,
	datad => AVG_count(4),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Equal1~2_combout\);

\Equal1~3\ : maxv_lcell
-- Equation(s):
-- \Equal1~3_combout\ = (AVG_count(6) & (\Mux5~9_combout\ & (AVG_count(7) $ (!\Mux5~8_combout\)))) # (!AVG_count(6) & (!\Mux5~9_combout\ & (AVG_count(7) $ (!\Mux5~8_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8241",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(6),
	datab => AVG_count(7),
	datac => \Mux5~8_combout\,
	datad => \Mux5~9_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Equal1~3_combout\);

\Equal1~4\ : maxv_lcell
-- Equation(s):
-- \Equal1~4_combout\ = (\Equal1~0_combout\ & (\Equal1~1_combout\ & (\Equal1~2_combout\ & \Equal1~3_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8000",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Equal1~0_combout\,
	datab => \Equal1~1_combout\,
	datac => \Equal1~2_combout\,
	datad => \Equal1~3_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Equal1~4_combout\);

\Equal0~0\ : maxv_lcell
-- Equation(s):
-- \Equal0~0_combout\ = (AVG_count(1) & (\Add2~5_combout\ & (AVG_count(0) $ (\Add2~10_combout\)))) # (!AVG_count(1) & (!\Add2~5_combout\ & (AVG_count(0) $ (\Add2~10_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0990",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(1),
	datab => \Add2~5_combout\,
	datac => AVG_count(0),
	datad => \Add2~10_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Equal0~0_combout\);

\Equal0~1\ : maxv_lcell
-- Equation(s):
-- \Equal0~1_combout\ = (AVG_count(2) & (\Add2~20_combout\ & (AVG_count(3) $ (!\Add2~15_combout\)))) # (!AVG_count(2) & (!\Add2~20_combout\ & (AVG_count(3) $ (!\Add2~15_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8241",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(2),
	datab => AVG_count(3),
	datac => \Add2~15_combout\,
	datad => \Add2~20_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Equal0~1_combout\);

\Equal0~2\ : maxv_lcell
-- Equation(s):
-- \Equal0~2_combout\ = (AVG_count(4) & (\Add2~30_combout\ & (AVG_count(5) $ (!\Add2~25_combout\)))) # (!AVG_count(4) & (!\Add2~30_combout\ & (AVG_count(5) $ (!\Add2~25_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8241",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(4),
	datab => AVG_count(5),
	datac => \Add2~25_combout\,
	datad => \Add2~30_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Equal0~2_combout\);

\Equal0~3\ : maxv_lcell
-- Equation(s):
-- \Equal0~3_combout\ = (AVG_count(6) & (\Add2~40_combout\ & (AVG_count(7) $ (!\Add2~35_combout\)))) # (!AVG_count(6) & (!\Add2~40_combout\ & (AVG_count(7) $ (!\Add2~35_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8241",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(6),
	datab => AVG_count(7),
	datac => \Add2~35_combout\,
	datad => \Add2~40_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Equal0~3_combout\);

\Equal0~4\ : maxv_lcell
-- Equation(s):
-- \Equal0~4_combout\ = (\Equal0~0_combout\ & (\Equal0~1_combout\ & (\Equal0~2_combout\ & \Equal0~3_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8000",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Equal0~0_combout\,
	datab => \Equal0~1_combout\,
	datac => \Equal0~2_combout\,
	datad => \Equal0~3_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Equal0~4_combout\);

AVGen_SCK : maxv_lcell
-- Equation(s):
-- \AVGen_SCK~regout\ = DFFEAS((\AQMODE~combout\ & ((\Add2~0_combout\) # ((!\Equal0~4_combout\)))) # (!\AQMODE~combout\ & (((\Equal1~4_combout\)))), \nFS~combout\, !\AVG_cycles~6_combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "acfc",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \nFS~combout\,
	dataa => \Add2~0_combout\,
	datab => \Equal1~4_combout\,
	datac => \AQMODE~combout\,
	datad => \Equal0~4_combout\,
	aclr => \AVG_cycles~6_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \AVGen_SCK~regout\);

T_CNVen_SHFT : maxv_lcell
-- Equation(s):
-- \T_CNVen_SHFT~regout\ = DFFEAS((\CNVen_SHFT~regout\), !\ReadCLK~combout\, \AVGen_SCK~regout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ALT_INV_ReadCLK~combout\,
	dataa => \CNVen_SHFT~regout\,
	aclr => \ALT_INV_AVGen_SCK~regout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \T_CNVen_SHFT~regout\);

\AVG_cycles~0\ : maxv_lcell
-- Equation(s):
-- \AVG_cycles~0_combout\ = (AVG_count(5)) # ((AVG_count(6)) # ((AVG_count(7))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "fefe",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(5),
	datab => AVG_count(6),
	datac => AVG_count(7),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \AVG_cycles~0_combout\);

\Div0|auto_generated|divider|divider|StageOut[5]\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|StageOut\(5) = (\Mux5~1_combout\) # (((!\CK_cycle~6_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaff",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Mux5~1_combout\,
	datad => \CK_cycle~6_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|StageOut\(5));

\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[0]\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella\(0) = (\CK_cycle~6_combout\ & (!\Mux5~1_combout\))
-- \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[0]~COUT\ = CARRY(((\Mux5~1_combout\)) # (!\CK_cycle~6_combout\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "22dd",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \CK_cycle~6_combout\,
	datab => \Mux5~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella\(0),
	cout => \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[0]~COUT\);

\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~20\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~20_combout\ = (((\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[0]~COUT\)))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "f0f0",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	cin => \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[0]~COUT\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~20_combout\);

\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~17\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~17_cout\ = CARRY((\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~20_combout\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ffaa",
	operation_mode => "arithmetic",
	output_mode => "none",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~20_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~15\,
	cout => \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~17_cout\);

\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~10\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~10_combout\ = \Div0|auto_generated|divider|divider|StageOut\(5) $ (\CK_cycle~2_combout\ $ ((!\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~17_cout\)))
-- \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~12\ = CARRY((\Div0|auto_generated|divider|divider|StageOut\(5) & (\CK_cycle~2_combout\ & !\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~17_cout\)) # 
-- (!\Div0|auto_generated|divider|divider|StageOut\(5) & ((\CK_cycle~2_combout\) # (!\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~17_cout\))))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "694d",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Div0|auto_generated|divider|divider|StageOut\(5),
	datab => \CK_cycle~2_combout\,
	cin => \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~17_cout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~10_combout\,
	cout => \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~12\);

\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~5\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~5_combout\ = \CK_cycle~6_combout\ $ (\CK_cycle~3_combout\ $ ((!\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~12\)))
-- \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~7\ = CARRY((\CK_cycle~6_combout\ & (!\CK_cycle~3_combout\ & !\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~12\)) # (!\CK_cycle~6_combout\ & 
-- ((!\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~12\) # (!\CK_cycle~3_combout\))))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "6917",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \CK_cycle~6_combout\,
	datab => \CK_cycle~3_combout\,
	cin => \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~12\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~5_combout\,
	cout => \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~7\);

\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~0\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~0_combout\ = (((\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~7\)))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "f0f0",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	cin => \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~7\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~0_combout\);

\Div0|auto_generated|divider|divider|StageOut[12]~0\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|StageOut[12]~0_combout\ = (\CK_cycle~4_combout\ & ((\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~0_combout\ & (\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~5_combout\)) # 
-- (!\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~0_combout\ & ((!\CK_cycle~6_combout\))))) # (!\CK_cycle~4_combout\ & (((!\CK_cycle~6_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "80bf",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~5_combout\,
	datab => \CK_cycle~4_combout\,
	datac => \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~0_combout\,
	datad => \CK_cycle~6_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|StageOut[12]~0_combout\);

\Div0|auto_generated|divider|divider|StageOut[11]~2\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|StageOut[11]~2_combout\ = (\CK_cycle~4_combout\ & ((\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~0_combout\ & (\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~10_combout\)) # 
-- (!\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~0_combout\ & ((\Div0|auto_generated|divider|divider|StageOut\(5)))))) # (!\CK_cycle~4_combout\ & (((\Div0|auto_generated|divider|divider|StageOut\(5)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "accc",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~10_combout\,
	datab => \Div0|auto_generated|divider|divider|StageOut\(5),
	datac => \CK_cycle~4_combout\,
	datad => \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|StageOut[11]~2_combout\);

\Div0|auto_generated|divider|divider|StageOut[10]~4\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|StageOut[10]~4_combout\ = (\CK_cycle~4_combout\ & (\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~0_combout\ & (\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella\(0))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8080",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \CK_cycle~4_combout\,
	datab => \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~0_combout\,
	datac => \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella\(0),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|StageOut[10]~4_combout\);

\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[0]\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella\(0) = (\CK_cycle~6_combout\ & (!\Mux5~1_combout\))
-- \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[0]~COUT\ = CARRY(((\Mux5~1_combout\)) # (!\CK_cycle~6_combout\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "22dd",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \CK_cycle~6_combout\,
	datab => \Mux5~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella\(0),
	cout => \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[0]~COUT\);

\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~25\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~25_combout\ = (((\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[0]~COUT\)))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "f0f0",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	cin => \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[0]~COUT\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~25_combout\);

\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~22\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~22_cout\ = CARRY((\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~25_combout\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ffaa",
	operation_mode => "arithmetic",
	output_mode => "none",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~25_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~20\,
	cout => \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~22_cout\);

\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~15\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~15_combout\ = \Div0|auto_generated|divider|divider|StageOut[10]~4_combout\ $ (\CK_cycle~2_combout\ $ ((!\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~22_cout\)))
-- \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~17\ = CARRY((\Div0|auto_generated|divider|divider|StageOut[10]~4_combout\ & (\CK_cycle~2_combout\ & !\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~22_cout\)) # 
-- (!\Div0|auto_generated|divider|divider|StageOut[10]~4_combout\ & ((\CK_cycle~2_combout\) # (!\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~22_cout\))))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "694d",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Div0|auto_generated|divider|divider|StageOut[10]~4_combout\,
	datab => \CK_cycle~2_combout\,
	cin => \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~22_cout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~15_combout\,
	cout => \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~17\);

\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~10\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~10_combout\ = \Div0|auto_generated|divider|divider|StageOut[11]~2_combout\ $ (\CK_cycle~3_combout\ $ ((\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~17\)))
-- \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~12\ = CARRY((\Div0|auto_generated|divider|divider|StageOut[11]~2_combout\ & ((!\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~17\) # (!\CK_cycle~3_combout\))) # 
-- (!\Div0|auto_generated|divider|divider|StageOut[11]~2_combout\ & (!\CK_cycle~3_combout\ & !\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~17\)))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "962b",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Div0|auto_generated|divider|divider|StageOut[11]~2_combout\,
	datab => \CK_cycle~3_combout\,
	cin => \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~17\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~10_combout\,
	cout => \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~12\);

\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~5\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~5_combout\ = \Div0|auto_generated|divider|divider|StageOut[12]~0_combout\ $ (\CK_cycle~4_combout\ $ ((\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~12\)))
-- \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~7\ = CARRY((\Div0|auto_generated|divider|divider|StageOut[12]~0_combout\ & (!\CK_cycle~4_combout\ & !\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~12\)) # 
-- (!\Div0|auto_generated|divider|divider|StageOut[12]~0_combout\ & ((!\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~12\) # (!\CK_cycle~4_combout\))))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "9617",
	operation_mode => "arithmetic",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Div0|auto_generated|divider|divider|StageOut[12]~0_combout\,
	datab => \CK_cycle~4_combout\,
	cin => \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~12\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~5_combout\,
	cout => \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~7\);

\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~0\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~0_combout\ = (((!\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~7\)))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "0f0f",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	cin => \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~7\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~0_combout\);

\Div0|auto_generated|divider|divider|selnose[18]\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|selnose\(18) = (((!\AVG~combout\(2) & !\AVG~combout\(1))) # (!\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~0_combout\)) # (!\AQMODE~combout\)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1fff",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \AVG~combout\(2),
	datab => \AVG~combout\(1),
	datac => \AQMODE~combout\,
	datad => \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|selnose\(18));

\Div0|auto_generated|divider|divider|StageOut[18]~1\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|StageOut[18]~1_combout\ = ((\Div0|auto_generated|divider|divider|selnose\(18) & (\Div0|auto_generated|divider|divider|StageOut[12]~0_combout\)) # (!\Div0|auto_generated|divider|divider|selnose\(18) & 
-- ((\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~5_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aacc",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Div0|auto_generated|divider|divider|StageOut[12]~0_combout\,
	datab => \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~5_combout\,
	datad => \Div0|auto_generated|divider|divider|selnose\(18),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|StageOut[18]~1_combout\);

\Div0|auto_generated|divider|divider|StageOut[17]~3\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|StageOut[17]~3_combout\ = ((\Div0|auto_generated|divider|divider|selnose\(18) & (\Div0|auto_generated|divider|divider|StageOut[11]~2_combout\)) # (!\Div0|auto_generated|divider|divider|selnose\(18) & 
-- ((\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~10_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aacc",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Div0|auto_generated|divider|divider|StageOut[11]~2_combout\,
	datab => \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~10_combout\,
	datad => \Div0|auto_generated|divider|divider|selnose\(18),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|StageOut[17]~3_combout\);

\Div0|auto_generated|divider|divider|StageOut[16]~5\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|StageOut[16]~5_combout\ = ((\Div0|auto_generated|divider|divider|selnose\(18) & (\Div0|auto_generated|divider|divider|StageOut[10]~4_combout\)) # (!\Div0|auto_generated|divider|divider|selnose\(18) & 
-- ((\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~15_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aacc",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Div0|auto_generated|divider|divider|StageOut[10]~4_combout\,
	datab => \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella[1]~15_combout\,
	datad => \Div0|auto_generated|divider|divider|selnose\(18),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|StageOut[16]~5_combout\);

\Div0|auto_generated|divider|divider|StageOut[15]~6\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|StageOut[15]~6_combout\ = (\Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella\(0) & (((!\Div0|auto_generated|divider|divider|selnose\(18)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "00aa",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Div0|auto_generated|divider|divider|add_sub_3|add_sub_cella\(0),
	datad => \Div0|auto_generated|divider|divider|selnose\(18),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|StageOut[15]~6_combout\);

\Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~27\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~27_cout\ = CARRY((!\CK_cycle~1_combout\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "ff55",
	operation_mode => "arithmetic",
	output_mode => "none",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \CK_cycle~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~25\,
	cout => \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~27_cout\);

\Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~22\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~22_cout\ = CARRY((\Div0|auto_generated|divider|divider|StageOut[15]~6_combout\ & (\CK_cycle~2_combout\ & !\Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~27_cout\)) # 
-- (!\Div0|auto_generated|divider|divider|StageOut[15]~6_combout\ & ((\CK_cycle~2_combout\) # (!\Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~27_cout\))))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "ff4d",
	operation_mode => "arithmetic",
	output_mode => "none",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Div0|auto_generated|divider|divider|StageOut[15]~6_combout\,
	datab => \CK_cycle~2_combout\,
	cin => \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~27_cout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~20\,
	cout => \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~22_cout\);

\Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~17\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~17_cout\ = CARRY((\Div0|auto_generated|divider|divider|StageOut[16]~5_combout\ & ((!\Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~22_cout\) # (!\CK_cycle~3_combout\))) # 
-- (!\Div0|auto_generated|divider|divider|StageOut[16]~5_combout\ & (!\CK_cycle~3_combout\ & !\Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~22_cout\)))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "ff2b",
	operation_mode => "arithmetic",
	output_mode => "none",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Div0|auto_generated|divider|divider|StageOut[16]~5_combout\,
	datab => \CK_cycle~3_combout\,
	cin => \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~22_cout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~15\,
	cout => \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~17_cout\);

\Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~12\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~12_cout\ = CARRY((\Div0|auto_generated|divider|divider|StageOut[17]~3_combout\ & (!\CK_cycle~4_combout\ & !\Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~17_cout\)) # 
-- (!\Div0|auto_generated|divider|divider|StageOut[17]~3_combout\ & ((!\Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~17_cout\) # (!\CK_cycle~4_combout\))))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "ff17",
	operation_mode => "arithmetic",
	output_mode => "none",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Div0|auto_generated|divider|divider|StageOut[17]~3_combout\,
	datab => \CK_cycle~4_combout\,
	cin => \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~17_cout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~10\,
	cout => \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~12_cout\);

\Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~7\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~7_cout\ = CARRY((\Div0|auto_generated|divider|divider|StageOut[18]~1_combout\ & ((!\Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~12_cout\) # (!\CK_cycle~5_combout\))) # 
-- (!\Div0|auto_generated|divider|divider|StageOut[18]~1_combout\ & (!\CK_cycle~5_combout\ & !\Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~12_cout\)))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "ff2b",
	operation_mode => "arithmetic",
	output_mode => "none",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \Div0|auto_generated|divider|divider|StageOut[18]~1_combout\,
	datab => \CK_cycle~5_combout\,
	cin => \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~12_cout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~5\,
	cout => \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~7_cout\);

\Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~0\ : maxv_lcell
-- Equation(s):
-- \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~0_combout\ = (((\Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~7_cout\)))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "f0f0",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	cin => \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~7_cout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~0_combout\);

\AVG_cycles~1\ : maxv_lcell
-- Equation(s):
-- \AVG_cycles~1_combout\ = (AVG_count(1) & (AVG_count(0) & (\Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~0_combout\ & !\Div0|auto_generated|divider|divider|selnose\(18)))) # (!AVG_count(1) & (((AVG_count(0) & 
-- \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~0_combout\)) # (!\Div0|auto_generated|divider|divider|selnose\(18))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "088f",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => AVG_count(0),
	datab => \Div0|auto_generated|divider|divider|add_sub_4|add_sub_cella[1]~0_combout\,
	datac => AVG_count(1),
	datad => \Div0|auto_generated|divider|divider|selnose\(18),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \AVG_cycles~1_combout\);

\AVG_cycles~2\ : maxv_lcell
-- Equation(s):
-- \AVG_cycles~2_combout\ = (\AVG_cycles~1_combout\ & (((\CK_cycle~4_combout\ & \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~0_combout\)) # (!AVG_count(2)))) # (!\AVG_cycles~1_combout\ & (\CK_cycle~4_combout\ & 
-- (\Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~0_combout\ & !AVG_count(2))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "80ea",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \AVG_cycles~1_combout\,
	datab => \CK_cycle~4_combout\,
	datac => \Div0|auto_generated|divider|divider|add_sub_2|add_sub_cella[1]~0_combout\,
	datad => AVG_count(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \AVG_cycles~2_combout\);

\AVG_cycles~3\ : maxv_lcell
-- Equation(s):
-- \AVG_cycles~3_combout\ = (\CK_cycle~6_combout\ & (AVG_count(3) & (!\AVG_cycles~2_combout\))) # (!\CK_cycle~6_combout\ & (!AVG_count(3) & (\AVG_cycles~2_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1818",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \CK_cycle~6_combout\,
	datab => AVG_count(3),
	datac => \AVG_cycles~2_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \AVG_cycles~3_combout\);

\AVG_cycles~4\ : maxv_lcell
-- Equation(s):
-- \AVG_cycles~4_combout\ = (\CK_cycle~2_combout\ & (!AVG_count(4) & (\CK_cycle~6_combout\ $ (\AVG_cycles~3_combout\)))) # (!\CK_cycle~2_combout\ & ((\AVG_cycles~3_combout\ & (!AVG_count(4))) # (!\AVG_cycles~3_combout\ & ((\CK_cycle~6_combout\)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1370",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \CK_cycle~2_combout\,
	datab => AVG_count(4),
	datac => \CK_cycle~6_combout\,
	datad => \AVG_cycles~3_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \AVG_cycles~4_combout\);

AVGen_READ : maxv_lcell
-- Equation(s):
-- \AVGen_READ~regout\ = DFFEAS((\Equal1~4_combout\) # ((!\AVG_cycles~0_combout\ & (\AVG_cycles~4_combout\))), \nFS~combout\, !\AVG_cycles~6_combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "baba",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \nFS~combout\,
	dataa => \Equal1~4_combout\,
	datab => \AVG_cycles~0_combout\,
	datac => \AVG_cycles~4_combout\,
	aclr => \AVG_cycles~6_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \AVGen_READ~regout\);

\ADC_SHIFT~0\ : maxv_lcell
-- Equation(s):
-- \ADC_SHIFT~0_combout\ = (\T_CNVen_SHFT~regout\ & (\AVGen_READ~regout\ & (\ReadCLK~combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8080",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \T_CNVen_SHFT~regout\,
	datab => \AVGen_READ~regout\,
	datac => \ReadCLK~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \ADC_SHIFT~0_combout\);

\LessThan0~0\ : maxv_lcell
-- Equation(s):
-- \LessThan0~0_combout\ = (!CNVclk_cnt(0) & (!CNVclk_cnt(1) & (!CNVclk_cnt(2) & !CNVclk_cnt(3))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0001",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => CNVclk_cnt(0),
	datab => CNVclk_cnt(1),
	datac => CNVclk_cnt(2),
	datad => CNVclk_cnt(3),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \LessThan0~0_combout\);

CNVen_SCK : maxv_lcell
-- Equation(s):
-- \CNVen_SCK~regout\ = DFFEAS(((\LessThan1~4_combout\ & ((CNVclk_cnt(4)) # (!\LessThan0~0_combout\)))), \ReadCLK~combout\, !\ADC_clocks~0_combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "f500",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadCLK~combout\,
	dataa => \LessThan0~0_combout\,
	datac => CNVclk_cnt(4),
	datad => \LessThan1~4_combout\,
	aclr => \ADC_clocks~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \CNVen_SCK~regout\);

T_CNVen_SCK : maxv_lcell
-- Equation(s):
-- \T_CNVen_SCK~regout\ = DFFEAS((\CNVen_SCK~regout\), !\ReadCLK~combout\, \AVGen_SCK~regout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ALT_INV_ReadCLK~combout\,
	dataa => \CNVen_SCK~regout\,
	aclr => \ALT_INV_AVGen_SCK~regout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \T_CNVen_SCK~regout\);

\ADC_CLK~0\ : maxv_lcell
-- Equation(s):
-- \ADC_CLK~0_combout\ = LCELL((\ReadCLK~combout\ & (\AVGen_SCK~regout\ & (\T_CNVen_SCK~regout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8080",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ReadCLK~combout\,
	datab => \AVGen_SCK~regout\,
	datac => \T_CNVen_SCK~regout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \ADC_CLK~0_combout\);

\CLKBypass~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_CLKBypass,
	combout => \CLKBypass~combout\);

\ReadADCclock~0\ : maxv_lcell
-- Equation(s):
-- \ReadADCclock~0_combout\ = LCELL((\CLKBypass~combout\ & (((\ADC_CLK~0_combout\)))) # (!\CLKBypass~combout\ & (!\ADC_SHIFT~0_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "c5c5",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ADC_SHIFT~0_combout\,
	datab => \ADC_CLK~0_combout\,
	datac => \CLKBypass~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \ReadADCclock~0_combout\);

\SDOL~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_SDOL,
	combout => \SDOL~combout\);

\ResetAVGread~0\ : maxv_lcell
-- Equation(s):
-- \ResetAVGread~0_combout\ = (\Mux5~1_combout\ & ((\AVG~combout\(2) & ((!\AVGen_READ~regout\))) # (!\AVG~combout\(2) & (\nFS~combout\)))) # (!\Mux5~1_combout\ & (((!\AVGen_READ~regout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "08fb",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => \nFS~combout\,
	datab => \Mux5~1_combout\,
	datac => \AVG~combout\(2),
	datad => \AVGen_READ~regout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \ResetAVGread~0_combout\);

\TCLK23[1]\ : maxv_lcell
-- Equation(s):
-- TCLK23(1) = DFFEAS(TCLK23(1) $ ((TCLK23(0))), \ADC_CLK~0_combout\, !\ResetAVGread~0_combout\, , \LessThan5~0_combout\, , , , )
-- \TCLK23[1]~1\ = CARRY((TCLK23(1) & (TCLK23(0))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "6688",
	operation_mode => "arithmetic",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ADC_CLK~0_combout\,
	dataa => TCLK23(1),
	datab => TCLK23(0),
	aclr => \ResetAVGread~0_combout\,
	ena => \LessThan5~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => TCLK23(1),
	cout => \TCLK23[1]~1\);

\TCLK23[2]\ : maxv_lcell
-- Equation(s):
-- TCLK23(2) = DFFEAS(TCLK23(2) $ ((((\TCLK23[1]~1\)))), \ADC_CLK~0_combout\, !\ResetAVGread~0_combout\, , \LessThan5~0_combout\, , , , )
-- \TCLK23[2]~3\ = CARRY(((!\TCLK23[1]~1\)) # (!TCLK23(2)))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "5a5f",
	operation_mode => "arithmetic",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ADC_CLK~0_combout\,
	dataa => TCLK23(2),
	aclr => \ResetAVGread~0_combout\,
	ena => \LessThan5~0_combout\,
	cin => \TCLK23[1]~1\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => TCLK23(2),
	cout => \TCLK23[2]~3\);

\TCLK23[3]\ : maxv_lcell
-- Equation(s):
-- TCLK23(3) = DFFEAS(TCLK23(3) $ ((((!\TCLK23[2]~3\)))), \ADC_CLK~0_combout\, !\ResetAVGread~0_combout\, , \LessThan5~0_combout\, , , , )
-- \TCLK23[3]~5\ = CARRY((TCLK23(3) & ((!\TCLK23[2]~3\))))

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "a50a",
	operation_mode => "arithmetic",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ADC_CLK~0_combout\,
	dataa => TCLK23(3),
	aclr => \ResetAVGread~0_combout\,
	ena => \LessThan5~0_combout\,
	cin => \TCLK23[2]~3\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => TCLK23(3),
	cout => \TCLK23[3]~5\);

\Mux34~0\ : maxv_lcell
-- Equation(s):
-- \Mux34~0_combout\ = (TCLK23(0) & (TCLK23(1) & (TCLK23(2))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8080",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(0),
	datab => TCLK23(1),
	datac => TCLK23(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux34~0_combout\);

\LessThan5~0\ : maxv_lcell
-- Equation(s):
-- \LessThan5~0_combout\ = (((!TCLK23(3) & !\Mux34~0_combout\)) # (!TCLK23(4)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "03ff",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datab => TCLK23(3),
	datac => \Mux34~0_combout\,
	datad => TCLK23(4),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \LessThan5~0_combout\);

\TCLK23[4]\ : maxv_lcell
-- Equation(s):
-- TCLK23(4) = DFFEAS(TCLK23(4) $ ((((\TCLK23[3]~5\)))), \ADC_CLK~0_combout\, !\ResetAVGread~0_combout\, , \LessThan5~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	cin_used => "true",
	lut_mask => "5a5a",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "cin",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ADC_CLK~0_combout\,
	dataa => TCLK23(4),
	aclr => \ResetAVGread~0_combout\,
	ena => \LessThan5~0_combout\,
	cin => \TCLK23[3]~5\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => TCLK23(4));

\TCLK23[0]\ : maxv_lcell
-- Equation(s):
-- TCLK23(0) = DFFEAS(TCLK23(0) $ ((((!TCLK23(3) & !\Mux34~0_combout\)) # (!TCLK23(4)))), \ADC_CLK~0_combout\, !\ResetAVGread~0_combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "9993",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ADC_CLK~0_combout\,
	dataa => TCLK23(4),
	datab => TCLK23(0),
	datac => TCLK23(3),
	datad => \Mux34~0_combout\,
	aclr => \ResetAVGread~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => TCLK23(0));

\Mux34~1\ : maxv_lcell
-- Equation(s):
-- \Mux34~1_combout\ = (TCLK23(0) & (TCLK23(1) & (TCLK23(2) & TCLK23(4))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8000",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(0),
	datab => TCLK23(1),
	datac => TCLK23(2),
	datad => TCLK23(4),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux34~1_combout\);

\r_DATAL[0]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(0) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \Mux34~1_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \Mux34~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(0));

\DOUTL[0]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[0]~reg0_regout\ = DFFEAS((r_DATAL(0)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(0),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[0]~reg0_regout\);

\Mux33~0\ : maxv_lcell
-- Equation(s):
-- \Mux33~0_combout\ = (TCLK23(1) & (TCLK23(2) & (TCLK23(4) & !TCLK23(0))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0080",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(1),
	datab => TCLK23(2),
	datac => TCLK23(4),
	datad => TCLK23(0),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux33~0_combout\);

\r_DATAL[1]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(1) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \Mux33~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \Mux33~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(1));

\DOUTL[1]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[1]~reg0_regout\ = DFFEAS((r_DATAL(1)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(1),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[1]~reg0_regout\);

\Mux32~0\ : maxv_lcell
-- Equation(s):
-- \Mux32~0_combout\ = (TCLK23(0) & (TCLK23(2) & (TCLK23(4) & !TCLK23(1))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0080",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(0),
	datab => TCLK23(2),
	datac => TCLK23(4),
	datad => TCLK23(1),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux32~0_combout\);

\r_DATAL[2]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(2) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \Mux32~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \Mux32~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(2));

\DOUTL[2]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[2]~reg0_regout\ = DFFEAS((r_DATAL(2)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(2),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[2]~reg0_regout\);

\Mux31~0\ : maxv_lcell
-- Equation(s):
-- \Mux31~0_combout\ = (TCLK23(2) & (TCLK23(4) & (!TCLK23(0) & !TCLK23(1))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0008",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(2),
	datab => TCLK23(4),
	datac => TCLK23(0),
	datad => TCLK23(1),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux31~0_combout\);

\r_DATAL[3]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(3) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \Mux31~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \Mux31~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(3));

\DOUTL[3]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[3]~reg0_regout\ = DFFEAS((r_DATAL(3)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(3),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[3]~reg0_regout\);

\Mux30~0\ : maxv_lcell
-- Equation(s):
-- \Mux30~0_combout\ = (TCLK23(0) & (TCLK23(1) & (TCLK23(4) & !TCLK23(2))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0080",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(0),
	datab => TCLK23(1),
	datac => TCLK23(4),
	datad => TCLK23(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux30~0_combout\);

\r_DATAL[4]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(4) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \Mux30~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \Mux30~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(4));

\DOUTL[4]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[4]~reg0_regout\ = DFFEAS((r_DATAL(4)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(4),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[4]~reg0_regout\);

\Mux29~0\ : maxv_lcell
-- Equation(s):
-- \Mux29~0_combout\ = (TCLK23(1) & (TCLK23(4) & (!TCLK23(0) & !TCLK23(2))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0008",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(1),
	datab => TCLK23(4),
	datac => TCLK23(0),
	datad => TCLK23(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux29~0_combout\);

\r_DATAL[5]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(5) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \Mux29~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \Mux29~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(5));

\DOUTL[5]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[5]~reg0_regout\ = DFFEAS((r_DATAL(5)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(5),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[5]~reg0_regout\);

\Mux28~0\ : maxv_lcell
-- Equation(s):
-- \Mux28~0_combout\ = (TCLK23(0) & (TCLK23(4) & (!TCLK23(1) & !TCLK23(2))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0008",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(0),
	datab => TCLK23(4),
	datac => TCLK23(1),
	datad => TCLK23(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux28~0_combout\);

\r_DATAL[6]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(6) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \Mux28~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \Mux28~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(6));

\DOUTL[6]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[6]~reg0_regout\ = DFFEAS((r_DATAL(6)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(6),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[6]~reg0_regout\);

\Mux27~0\ : maxv_lcell
-- Equation(s):
-- \Mux27~0_combout\ = (TCLK23(4) & (!TCLK23(0) & (!TCLK23(1) & !TCLK23(2))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0002",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(4),
	datab => TCLK23(0),
	datac => TCLK23(1),
	datad => TCLK23(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux27~0_combout\);

\r_DATAL[7]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(7) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \Mux27~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \Mux27~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(7));

\DOUTL[7]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[7]~reg0_regout\ = DFFEAS((r_DATAL(7)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(7),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[7]~reg0_regout\);

\Mux26~0\ : maxv_lcell
-- Equation(s):
-- \Mux26~0_combout\ = (TCLK23(0) & (TCLK23(1) & (TCLK23(2) & TCLK23(3))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8000",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(0),
	datab => TCLK23(1),
	datac => TCLK23(2),
	datad => TCLK23(3),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux26~0_combout\);

\r_DATAL[8]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(8) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \Mux26~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \Mux26~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(8));

\DOUTL[8]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[8]~reg0_regout\ = DFFEAS((r_DATAL(8)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(8),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[8]~reg0_regout\);

\Mux25~0\ : maxv_lcell
-- Equation(s):
-- \Mux25~0_combout\ = (TCLK23(1) & (TCLK23(2) & (TCLK23(3) & !TCLK23(0))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0080",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(1),
	datab => TCLK23(2),
	datac => TCLK23(3),
	datad => TCLK23(0),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux25~0_combout\);

\r_DATAL[9]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(9) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \Mux25~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \Mux25~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(9));

\DOUTL[9]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[9]~reg0_regout\ = DFFEAS((r_DATAL(9)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(9),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[9]~reg0_regout\);

\Mux24~0\ : maxv_lcell
-- Equation(s):
-- \Mux24~0_combout\ = (TCLK23(0) & (TCLK23(2) & (TCLK23(3) & !TCLK23(1))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0080",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(0),
	datab => TCLK23(2),
	datac => TCLK23(3),
	datad => TCLK23(1),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux24~0_combout\);

\r_DATAL[10]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(10) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \Mux24~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \Mux24~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(10));

\DOUTL[10]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[10]~reg0_regout\ = DFFEAS((r_DATAL(10)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(10),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[10]~reg0_regout\);

\Mux23~0\ : maxv_lcell
-- Equation(s):
-- \Mux23~0_combout\ = (TCLK23(2) & (TCLK23(3) & (!TCLK23(0) & !TCLK23(1))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0008",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(2),
	datab => TCLK23(3),
	datac => TCLK23(0),
	datad => TCLK23(1),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux23~0_combout\);

\r_DATAL[11]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(11) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \Mux23~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \Mux23~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(11));

\DOUTL[11]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[11]~reg0_regout\ = DFFEAS((r_DATAL(11)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(11),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[11]~reg0_regout\);

\Mux22~0\ : maxv_lcell
-- Equation(s):
-- \Mux22~0_combout\ = (TCLK23(0) & (TCLK23(1) & (TCLK23(3) & !TCLK23(2))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0080",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(0),
	datab => TCLK23(1),
	datac => TCLK23(3),
	datad => TCLK23(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux22~0_combout\);

\r_DATAL[12]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(12) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \Mux22~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \Mux22~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(12));

\DOUTL[12]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[12]~reg0_regout\ = DFFEAS((r_DATAL(12)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(12),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[12]~reg0_regout\);

\Mux21~0\ : maxv_lcell
-- Equation(s):
-- \Mux21~0_combout\ = (TCLK23(1) & (TCLK23(3) & (!TCLK23(0) & !TCLK23(2))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0008",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(1),
	datab => TCLK23(3),
	datac => TCLK23(0),
	datad => TCLK23(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux21~0_combout\);

\r_DATAL[13]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(13) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \Mux21~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \Mux21~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(13));

\DOUTL[13]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[13]~reg0_regout\ = DFFEAS((r_DATAL(13)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(13),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[13]~reg0_regout\);

\Mux20~0\ : maxv_lcell
-- Equation(s):
-- \Mux20~0_combout\ = (TCLK23(0) & (TCLK23(3) & (!TCLK23(1) & !TCLK23(2))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0008",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(0),
	datab => TCLK23(3),
	datac => TCLK23(1),
	datad => TCLK23(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux20~0_combout\);

\r_DATAL[14]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(14) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \Mux20~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \Mux20~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(14));

\DOUTL[14]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[14]~reg0_regout\ = DFFEAS((r_DATAL(14)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(14),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[14]~reg0_regout\);

\Mux19~0\ : maxv_lcell
-- Equation(s):
-- \Mux19~0_combout\ = (TCLK23(3) & (!TCLK23(0) & (!TCLK23(1) & !TCLK23(2))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0002",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(3),
	datab => TCLK23(0),
	datac => TCLK23(1),
	datad => TCLK23(2),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \Mux19~0_combout\);

\r_DATAL[15]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(15) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \Mux19~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \Mux19~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(15));

\DOUTL[15]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[15]~reg0_regout\ = DFFEAS((r_DATAL(15)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(15),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[15]~reg0_regout\);

\r_DATAL[19]~4\ : maxv_lcell
-- Equation(s):
-- \r_DATAL[19]~4_combout\ = (((!TCLK23(3) & !TCLK23(4))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "000f",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	datac => TCLK23(3),
	datad => TCLK23(4),
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \r_DATAL[19]~4_combout\);

\r_DATAL[16]~10\ : maxv_lcell
-- Equation(s):
-- \r_DATAL[16]~10_combout\ = (TCLK23(0) & (TCLK23(1) & (TCLK23(2) & \r_DATAL[19]~4_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "8000",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(0),
	datab => TCLK23(1),
	datac => TCLK23(2),
	datad => \r_DATAL[19]~4_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \r_DATAL[16]~10_combout\);

\r_DATAL[16]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(16) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \r_DATAL[16]~10_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \r_DATAL[16]~10_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(16));

\DOUTL[16]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[16]~reg0_regout\ = DFFEAS((r_DATAL(16)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(16),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[16]~reg0_regout\);

\r_DATAR[17]~0\ : maxv_lcell
-- Equation(s):
-- \r_DATAR[17]~0_combout\ = (!TCLK23(0) & (TCLK23(1) & (TCLK23(2) & \r_DATAL[19]~4_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "4000",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(0),
	datab => TCLK23(1),
	datac => TCLK23(2),
	datad => \r_DATAL[19]~4_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \r_DATAR[17]~0_combout\);

\r_DATAL[17]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(17) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \r_DATAR[17]~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \r_DATAR[17]~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(17));

\DOUTL[17]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[17]~reg0_regout\ = DFFEAS((r_DATAL(17)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(17),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[17]~reg0_regout\);

\r_DATAL[18]~5\ : maxv_lcell
-- Equation(s):
-- \r_DATAL[18]~5_combout\ = (!TCLK23(1) & (TCLK23(0) & (TCLK23(2) & \r_DATAL[19]~4_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "4000",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(1),
	datab => TCLK23(0),
	datac => TCLK23(2),
	datad => \r_DATAL[19]~4_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \r_DATAL[18]~5_combout\);

\r_DATAL[18]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(18) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \r_DATAL[18]~5_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \r_DATAL[18]~5_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(18));

\DOUTL[18]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[18]~reg0_regout\ = DFFEAS((r_DATAL(18)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(18),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[18]~reg0_regout\);

\r_DATAL[19]~6\ : maxv_lcell
-- Equation(s):
-- \r_DATAL[19]~6_combout\ = (!TCLK23(0) & (!TCLK23(1) & (TCLK23(2) & \r_DATAL[19]~4_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1000",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(0),
	datab => TCLK23(1),
	datac => TCLK23(2),
	datad => \r_DATAL[19]~4_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \r_DATAL[19]~6_combout\);

\r_DATAL[19]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(19) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \r_DATAL[19]~6_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \r_DATAL[19]~6_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(19));

\DOUTL[19]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[19]~reg0_regout\ = DFFEAS((r_DATAL(19)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(19),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[19]~reg0_regout\);

\r_DATAL[20]~7\ : maxv_lcell
-- Equation(s):
-- \r_DATAL[20]~7_combout\ = (!TCLK23(2) & (TCLK23(0) & (TCLK23(1) & \r_DATAL[19]~4_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "4000",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(2),
	datab => TCLK23(0),
	datac => TCLK23(1),
	datad => \r_DATAL[19]~4_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \r_DATAL[20]~7_combout\);

\r_DATAL[20]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(20) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \r_DATAL[20]~7_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \r_DATAL[20]~7_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(20));

\DOUTL[20]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[20]~reg0_regout\ = DFFEAS((r_DATAL(20)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(20),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[20]~reg0_regout\);

\r_DATAL[21]~8\ : maxv_lcell
-- Equation(s):
-- \r_DATAL[21]~8_combout\ = (!TCLK23(0) & (!TCLK23(2) & (TCLK23(1) & \r_DATAL[19]~4_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1000",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(0),
	datab => TCLK23(2),
	datac => TCLK23(1),
	datad => \r_DATAL[19]~4_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \r_DATAL[21]~8_combout\);

\r_DATAL[21]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(21) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \r_DATAL[21]~8_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \r_DATAL[21]~8_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(21));

\DOUTL[21]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[21]~reg0_regout\ = DFFEAS((r_DATAL(21)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(21),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[21]~reg0_regout\);

\r_DATAR[22]~1\ : maxv_lcell
-- Equation(s):
-- \r_DATAR[22]~1_combout\ = (!TCLK23(1) & (!TCLK23(2) & (TCLK23(0) & \r_DATAL[19]~4_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1000",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(1),
	datab => TCLK23(2),
	datac => TCLK23(0),
	datad => \r_DATAL[19]~4_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \r_DATAR[22]~1_combout\);

\r_DATAL[22]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(22) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \r_DATAR[22]~1_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \r_DATAR[22]~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(22));

\DOUTL[22]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[22]~reg0_regout\ = DFFEAS((r_DATAL(22)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(22),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[22]~reg0_regout\);

\r_DATAL[23]~9\ : maxv_lcell
-- Equation(s):
-- \r_DATAL[23]~9_combout\ = (!TCLK23(0) & (!TCLK23(1) & (!TCLK23(2) & \r_DATAL[19]~4_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0100",
	operation_mode => "normal",
	output_mode => "comb_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	dataa => TCLK23(0),
	datab => TCLK23(1),
	datac => TCLK23(2),
	datad => \r_DATAL[19]~4_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	combout => \r_DATAL[23]~9_combout\);

\r_DATAL[23]\ : maxv_lcell
-- Equation(s):
-- r_DATAL(23) = DFFEAS((\SDOL~combout\), \ReadADCclock~0_combout\, VCC, , \r_DATAL[23]~9_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOL~combout\,
	aclr => GND,
	ena => \r_DATAL[23]~9_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAL(23));

\DOUTL[23]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTL[23]~reg0_regout\ = DFFEAS((r_DATAL(23)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAL(23),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTL[23]~reg0_regout\);

\SDOR~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_SDOR,
	combout => \SDOR~combout\);

\r_DATAR[0]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(0) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \Mux34~1_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \Mux34~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(0));

\DOUTR[0]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[0]~reg0_regout\ = DFFEAS((r_DATAR(0)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(0),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[0]~reg0_regout\);

\r_DATAR[1]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(1) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \Mux33~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \Mux33~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(1));

\DOUTR[1]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[1]~reg0_regout\ = DFFEAS((r_DATAR(1)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(1),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[1]~reg0_regout\);

\r_DATAR[2]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(2) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \Mux32~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \Mux32~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(2));

\DOUTR[2]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[2]~reg0_regout\ = DFFEAS((r_DATAR(2)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(2),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[2]~reg0_regout\);

\r_DATAR[3]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(3) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \Mux31~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \Mux31~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(3));

\DOUTR[3]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[3]~reg0_regout\ = DFFEAS((r_DATAR(3)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(3),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[3]~reg0_regout\);

\r_DATAR[4]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(4) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \Mux30~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \Mux30~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(4));

\DOUTR[4]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[4]~reg0_regout\ = DFFEAS((r_DATAR(4)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(4),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[4]~reg0_regout\);

\r_DATAR[5]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(5) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \Mux29~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \Mux29~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(5));

\DOUTR[5]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[5]~reg0_regout\ = DFFEAS((r_DATAR(5)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(5),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[5]~reg0_regout\);

\r_DATAR[6]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(6) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \Mux28~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \Mux28~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(6));

\DOUTR[6]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[6]~reg0_regout\ = DFFEAS((r_DATAR(6)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(6),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[6]~reg0_regout\);

\r_DATAR[7]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(7) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \Mux27~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \Mux27~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(7));

\DOUTR[7]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[7]~reg0_regout\ = DFFEAS((r_DATAR(7)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(7),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[7]~reg0_regout\);

\r_DATAR[8]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(8) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \Mux26~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \Mux26~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(8));

\DOUTR[8]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[8]~reg0_regout\ = DFFEAS((r_DATAR(8)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(8),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[8]~reg0_regout\);

\r_DATAR[9]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(9) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \Mux25~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \Mux25~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(9));

\DOUTR[9]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[9]~reg0_regout\ = DFFEAS((r_DATAR(9)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(9),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[9]~reg0_regout\);

\r_DATAR[10]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(10) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \Mux24~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \Mux24~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(10));

\DOUTR[10]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[10]~reg0_regout\ = DFFEAS((r_DATAR(10)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(10),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[10]~reg0_regout\);

\r_DATAR[11]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(11) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \Mux23~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \Mux23~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(11));

\DOUTR[11]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[11]~reg0_regout\ = DFFEAS((r_DATAR(11)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(11),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[11]~reg0_regout\);

\r_DATAR[12]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(12) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \Mux22~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \Mux22~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(12));

\DOUTR[12]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[12]~reg0_regout\ = DFFEAS((r_DATAR(12)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(12),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[12]~reg0_regout\);

\r_DATAR[13]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(13) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \Mux21~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \Mux21~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(13));

\DOUTR[13]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[13]~reg0_regout\ = DFFEAS((r_DATAR(13)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(13),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[13]~reg0_regout\);

\r_DATAR[14]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(14) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \Mux20~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \Mux20~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(14));

\DOUTR[14]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[14]~reg0_regout\ = DFFEAS((r_DATAR(14)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(14),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[14]~reg0_regout\);

\r_DATAR[15]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(15) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \Mux19~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \Mux19~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(15));

\DOUTR[15]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[15]~reg0_regout\ = DFFEAS((r_DATAR(15)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(15),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[15]~reg0_regout\);

\r_DATAR[16]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(16) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \r_DATAL[16]~10_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \r_DATAL[16]~10_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(16));

\DOUTR[16]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[16]~reg0_regout\ = DFFEAS((r_DATAR(16)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(16),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[16]~reg0_regout\);

\r_DATAR[17]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(17) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \r_DATAR[17]~0_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \r_DATAR[17]~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(17));

\DOUTR[17]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[17]~reg0_regout\ = DFFEAS((r_DATAR(17)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(17),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[17]~reg0_regout\);

\r_DATAR[18]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(18) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \r_DATAL[18]~5_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \r_DATAL[18]~5_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(18));

\DOUTR[18]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[18]~reg0_regout\ = DFFEAS((r_DATAR(18)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(18),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[18]~reg0_regout\);

\r_DATAR[19]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(19) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \r_DATAL[19]~6_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \r_DATAL[19]~6_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(19));

\DOUTR[19]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[19]~reg0_regout\ = DFFEAS((r_DATAR(19)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(19),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[19]~reg0_regout\);

\r_DATAR[20]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(20) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \r_DATAL[20]~7_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \r_DATAL[20]~7_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(20));

\DOUTR[20]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[20]~reg0_regout\ = DFFEAS((r_DATAR(20)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(20),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[20]~reg0_regout\);

\r_DATAR[21]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(21) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \r_DATAL[21]~8_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \r_DATAL[21]~8_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(21));

\DOUTR[21]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[21]~reg0_regout\ = DFFEAS((r_DATAR(21)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(21),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[21]~reg0_regout\);

\r_DATAR[22]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(22) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \r_DATAR[22]~1_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \r_DATAR[22]~1_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(22));

\DOUTR[22]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[22]~reg0_regout\ = DFFEAS((r_DATAR(22)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(22),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[22]~reg0_regout\);

\r_DATAR[23]\ : maxv_lcell
-- Equation(s):
-- r_DATAR(23) = DFFEAS((\SDOR~combout\), \ReadADCclock~0_combout\, VCC, , \r_DATAL[23]~9_combout\, , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \ReadADCclock~0_combout\,
	dataa => \SDOR~combout\,
	aclr => GND,
	ena => \r_DATAL[23]~9_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => r_DATAR(23));

\DOUTR[23]~reg0\ : maxv_lcell
-- Equation(s):
-- \DOUTR[23]~reg0_regout\ = DFFEAS((r_DATAR(23)), \Fso~combout\, !\OutOfRange~combout\, , , , , , )

-- pragma translate_off
GENERIC MAP (
	lut_mask => "aaaa",
	operation_mode => "normal",
	output_mode => "reg_only",
	register_cascade_mode => "off",
	sum_lutc_input => "datac",
	synch_mode => "off")
-- pragma translate_on
PORT MAP (
	clk => \Fso~combout\,
	dataa => r_DATAR(23),
	aclr => \OutOfRange~combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	regout => \DOUTR[23]~reg0_regout\);

\MCLK~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_MCLK);

\SR[0]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_SR(0));

\SR[1]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_SR(1));

\SR[2]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "input")
-- pragma translate_on
PORT MAP (
	oe => GND,
	padio => ww_SR(2));

\DOUTL[0]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[0]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(0));

\DOUTL[1]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[1]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(1));

\DOUTL[2]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[2]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(2));

\DOUTL[3]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[3]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(3));

\DOUTL[4]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[4]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(4));

\DOUTL[5]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[5]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(5));

\DOUTL[6]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[6]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(6));

\DOUTL[7]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[7]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(7));

\DOUTL[8]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[8]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(8));

\DOUTL[9]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[9]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(9));

\DOUTL[10]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[10]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(10));

\DOUTL[11]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[11]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(11));

\DOUTL[12]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[12]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(12));

\DOUTL[13]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[13]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(13));

\DOUTL[14]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[14]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(14));

\DOUTL[15]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[15]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(15));

\DOUTL[16]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[16]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(16));

\DOUTL[17]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[17]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(17));

\DOUTL[18]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[18]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(18));

\DOUTL[19]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[19]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(19));

\DOUTL[20]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[20]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(20));

\DOUTL[21]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[21]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(21));

\DOUTL[22]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[22]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(22));

\DOUTL[23]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTL[23]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTL(23));

\DOUTR[0]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[0]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(0));

\DOUTR[1]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[1]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(1));

\DOUTR[2]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[2]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(2));

\DOUTR[3]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[3]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(3));

\DOUTR[4]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[4]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(4));

\DOUTR[5]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[5]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(5));

\DOUTR[6]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[6]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(6));

\DOUTR[7]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[7]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(7));

\DOUTR[8]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[8]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(8));

\DOUTR[9]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[9]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(9));

\DOUTR[10]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[10]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(10));

\DOUTR[11]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[11]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(11));

\DOUTR[12]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[12]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(12));

\DOUTR[13]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[13]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(13));

\DOUTR[14]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[14]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(14));

\DOUTR[15]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[15]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(15));

\DOUTR[16]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[16]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(16));

\DOUTR[17]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[17]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(17));

\DOUTR[18]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[18]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(18));

\DOUTR[19]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[19]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(19));

\DOUTR[20]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[20]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(20));

\DOUTR[21]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[21]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(21));

\DOUTR[22]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[22]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(22));

\DOUTR[23]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \DOUTR[23]~reg0_regout\,
	oe => VCC,
	padio => ww_DOUTR(23));

\nCNVL~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \ALT_INV_nFS~combout\,
	oe => VCC,
	padio => ww_nCNVL);

\SCKL~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \ADC_CLK~0_combout\,
	oe => VCC,
	padio => ww_SCKL);

\nCNVR~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \ALT_INV_nFS~combout\,
	oe => VCC,
	padio => ww_nCNVR);

\SCKR~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \ADC_CLK~0_combout\,
	oe => VCC,
	padio => ww_SCKR);

\Test_CK_cycle[0]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \CK_cycle~1_combout\,
	oe => VCC,
	padio => ww_Test_CK_cycle(0));

\Test_CK_cycle[1]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \CK_cycle~2_combout\,
	oe => VCC,
	padio => ww_Test_CK_cycle(1));

\Test_CK_cycle[2]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \CK_cycle~3_combout\,
	oe => VCC,
	padio => ww_Test_CK_cycle(2));

\Test_CK_cycle[3]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \ALT_INV_CK_cycle~4_combout\,
	oe => VCC,
	padio => ww_Test_CK_cycle(3));

\Test_CK_cycle[4]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \CK_cycle~5_combout\,
	oe => VCC,
	padio => ww_Test_CK_cycle(4));

\Test_ADC_CLK~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \ADC_CLK~0_combout\,
	oe => VCC,
	padio => ww_Test_ADC_CLK);

\Test_ADC_SHIFT~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \ADC_SHIFT~0_combout\,
	oe => VCC,
	padio => ww_Test_ADC_SHIFT);

\Test_AVGen_READ~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \AVGen_READ~regout\,
	oe => VCC,
	padio => ww_Test_AVGen_READ);

\Test_CNVen_SHFT~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \CNVen_SHFT~regout\,
	oe => VCC,
	padio => ww_Test_CNVen_SHFT);

\Test_AVGen_SCK~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \AVGen_SCK~regout\,
	oe => VCC,
	padio => ww_Test_AVGen_SCK);

\Test_CNVen_SCK~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \CNVen_SCK~regout\,
	oe => VCC,
	padio => ww_Test_CNVen_SCK);

\Test_CNVclk_cnt[0]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => CNVclk_cnt(0),
	oe => VCC,
	padio => ww_Test_CNVclk_cnt(0));

\Test_CNVclk_cnt[1]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => CNVclk_cnt(1),
	oe => VCC,
	padio => ww_Test_CNVclk_cnt(1));

\Test_CNVclk_cnt[2]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => CNVclk_cnt(2),
	oe => VCC,
	padio => ww_Test_CNVclk_cnt(2));

\Test_CNVclk_cnt[3]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => CNVclk_cnt(3),
	oe => VCC,
	padio => ww_Test_CNVclk_cnt(3));

\Test_CNVclk_cnt[4]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => CNVclk_cnt(4),
	oe => VCC,
	padio => ww_Test_CNVclk_cnt(4));

\Test_CNVclk_cnt[5]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => CNVclk_cnt(5),
	oe => VCC,
	padio => ww_Test_CNVclk_cnt(5));

\Test_AVG_count[0]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => ALT_INV_AVG_count(0),
	oe => VCC,
	padio => ww_Test_AVG_count(0));

\Test_AVG_count[1]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => AVG_count(1),
	oe => VCC,
	padio => ww_Test_AVG_count(1));

\Test_AVG_count[2]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => AVG_count(2),
	oe => VCC,
	padio => ww_Test_AVG_count(2));

\Test_AVG_count[3]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => AVG_count(3),
	oe => VCC,
	padio => ww_Test_AVG_count(3));

\Test_AVG_count[4]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => AVG_count(4),
	oe => VCC,
	padio => ww_Test_AVG_count(4));

\Test_AVG_count[5]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => AVG_count(5),
	oe => VCC,
	padio => ww_Test_AVG_count(5));

\Test_AVG_count[6]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => AVG_count(6),
	oe => VCC,
	padio => ww_Test_AVG_count(6));

\Test_TCLK23[0]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => TCLK23(0),
	oe => VCC,
	padio => ww_Test_TCLK23(0));

\Test_TCLK23[1]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => TCLK23(1),
	oe => VCC,
	padio => ww_Test_TCLK23(1));

\Test_TCLK23[2]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => TCLK23(2),
	oe => VCC,
	padio => ww_Test_TCLK23(2));

\Test_TCLK23[3]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => TCLK23(3),
	oe => VCC,
	padio => ww_Test_TCLK23(3));

\Test_TCLK23[4]~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => TCLK23(4),
	oe => VCC,
	padio => ww_Test_TCLK23(4));

\Test_ReadADCclock~I\ : maxv_io
-- pragma translate_off
GENERIC MAP (
	operation_mode => "output")
-- pragma translate_on
PORT MAP (
	datain => \ReadADCclock~0_combout\,
	oe => VCC,
	padio => ww_Test_ReadADCclock);
END structure;


