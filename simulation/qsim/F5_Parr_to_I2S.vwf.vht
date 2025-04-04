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

-- *****************************************************************************
-- This file contains a Vhdl test bench with test vectors .The test vectors     
-- are exported from a vector file in the Quartus Waveform Editor and apply to  
-- the top level entity of the current Quartus project .The user can use this   
-- testbench to simulate his design using a third-party simulation tool .       
-- *****************************************************************************
-- Generated on "04/04/2025 08:24:07"
                                                             
-- Vhdl Test Bench(with test vectors) for design  :          F1_readADCmulti_ExtClkII
-- 
-- Simulation tool : 3rd Party
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY F1_readADCmulti_ExtClkII_vhd_vec_tst IS
END F1_readADCmulti_ExtClkII_vhd_vec_tst;
ARCHITECTURE F1_readADCmulti_ExtClkII_arch OF F1_readADCmulti_ExtClkII_vhd_vec_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL AQMODE : STD_LOGIC;
SIGNAL AVG : STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL BUSYL : STD_LOGIC;
SIGNAL BUSYR : STD_LOGIC;
SIGNAL Clear : STD_LOGIC;
SIGNAL CLKBypass : STD_LOGIC;
SIGNAL DOUTL : STD_LOGIC_VECTOR(23 DOWNTO 0);
SIGNAL DOUTR : STD_LOGIC_VECTOR(23 DOWNTO 0);
SIGNAL Fso : STD_LOGIC;
SIGNAL MCLK : STD_LOGIC;
SIGNAL nCNVL : STD_LOGIC;
SIGNAL nCNVR : STD_LOGIC;
SIGNAL nFS : STD_LOGIC;
SIGNAL OutOfRange : STD_LOGIC;
SIGNAL ReadCLK : STD_LOGIC;
SIGNAL SCKL : STD_LOGIC;
SIGNAL SCKR : STD_LOGIC;
SIGNAL SDOL : STD_LOGIC;
SIGNAL SDOR : STD_LOGIC;
SIGNAL SR : STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL Test_ADC_CLK : STD_LOGIC;
SIGNAL Test_ADC_SHIFT : STD_LOGIC;
SIGNAL Test_AVG_count : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL Test_AVGen_READ : STD_LOGIC;
SIGNAL Test_AVGen_SCK : STD_LOGIC;
SIGNAL Test_CK_cycle : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL Test_CNVclk_cnt : STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL Test_CNVen_SCK : STD_LOGIC;
SIGNAL Test_CNVen_SHFT : STD_LOGIC;
SIGNAL Test_ReadADCclock : STD_LOGIC;
SIGNAL Test_TCLK23 : STD_LOGIC_VECTOR(4 DOWNTO 0);
COMPONENT F1_readADCmulti_ExtClkII
	PORT (
	AQMODE : IN STD_LOGIC;
	AVG : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
	BUSYL : IN STD_LOGIC;
	BUSYR : IN STD_LOGIC;
	Clear : IN STD_LOGIC;
	CLKBypass : IN STD_LOGIC;
	DOUTL : BUFFER STD_LOGIC_VECTOR(23 DOWNTO 0);
	DOUTR : BUFFER STD_LOGIC_VECTOR(23 DOWNTO 0);
	Fso : IN STD_LOGIC;
	MCLK : IN STD_LOGIC;
	nCNVL : BUFFER STD_LOGIC;
	nCNVR : BUFFER STD_LOGIC;
	nFS : IN STD_LOGIC;
	OutOfRange : IN STD_LOGIC;
	ReadCLK : IN STD_LOGIC;
	SCKL : BUFFER STD_LOGIC;
	SCKR : BUFFER STD_LOGIC;
	SDOL : IN STD_LOGIC;
	SDOR : IN STD_LOGIC;
	SR : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
	Test_ADC_CLK : BUFFER STD_LOGIC;
	Test_ADC_SHIFT : BUFFER STD_LOGIC;
	Test_AVG_count : BUFFER STD_LOGIC_VECTOR(6 DOWNTO 0);
	Test_AVGen_READ : BUFFER STD_LOGIC;
	Test_AVGen_SCK : BUFFER STD_LOGIC;
	Test_CK_cycle : BUFFER STD_LOGIC_VECTOR(4 DOWNTO 0);
	Test_CNVclk_cnt : BUFFER STD_LOGIC_VECTOR(5 DOWNTO 0);
	Test_CNVen_SCK : BUFFER STD_LOGIC;
	Test_CNVen_SHFT : BUFFER STD_LOGIC;
	Test_ReadADCclock : BUFFER STD_LOGIC;
	Test_TCLK23 : BUFFER STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END COMPONENT;
BEGIN
	i1 : F1_readADCmulti_ExtClkII
	PORT MAP (
-- list connections between master ports and signals
	AQMODE => AQMODE,
	AVG => AVG,
	BUSYL => BUSYL,
	BUSYR => BUSYR,
	Clear => Clear,
	CLKBypass => CLKBypass,
	DOUTL => DOUTL,
	DOUTR => DOUTR,
	Fso => Fso,
	MCLK => MCLK,
	nCNVL => nCNVL,
	nCNVR => nCNVR,
	nFS => nFS,
	OutOfRange => OutOfRange,
	ReadCLK => ReadCLK,
	SCKL => SCKL,
	SCKR => SCKR,
	SDOL => SDOL,
	SDOR => SDOR,
	SR => SR,
	Test_ADC_CLK => Test_ADC_CLK,
	Test_ADC_SHIFT => Test_ADC_SHIFT,
	Test_AVG_count => Test_AVG_count,
	Test_AVGen_READ => Test_AVGen_READ,
	Test_AVGen_SCK => Test_AVGen_SCK,
	Test_CK_cycle => Test_CK_cycle,
	Test_CNVclk_cnt => Test_CNVclk_cnt,
	Test_CNVen_SCK => Test_CNVen_SCK,
	Test_CNVen_SHFT => Test_CNVen_SHFT,
	Test_ReadADCclock => Test_ReadADCclock,
	Test_TCLK23 => Test_TCLK23
	);
END F1_readADCmulti_ExtClkII_arch;
