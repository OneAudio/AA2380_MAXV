-- Copyright (C) 2016  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Intel and sold by Intel or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 16.1.0 Build 196 10/24/2016 SJ Lite Edition"
-- CREATED		"Wed Oct 11 11:23:57 2017"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY Testclock IS 
	PORT
	(
		CLK2M :  IN  STD_LOGIC;
		V1_2K :  OUT  STD_LOGIC;
		V1_500 :  OUT  STD_LOGIC;
		V1_8 :  OUT  STD_LOGIC;
		V1_100 :  OUT  STD_LOGIC;
		V2_2K :  OUT  STD_LOGIC;
		V2_8 :  OUT  STD_LOGIC;
		V2_500 :  OUT  STD_LOGIC;
		V2_100 :  OUT  STD_LOGIC
	);
END Testclock;

ARCHITECTURE bdf_type OF Testclock IS 

COMPONENT multipleclockv2
	PORT(Reset : IN STD_LOGIC;
		 clk2MHz : IN STD_LOGIC;
		 CLK8kHz : OUT STD_LOGIC;
		 CLK4kHz : OUT STD_LOGIC;
		 CLK2kHz : OUT STD_LOGIC;
		 CLK8Hz : OUT STD_LOGIC;
		 CLK500mHz : OUT STD_LOGIC;
		 CLK100mHz : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT multipleclock
	PORT(clk2MHz : IN STD_LOGIC;
		 CLK2kHz : OUT STD_LOGIC;
		 CLK500mHz : OUT STD_LOGIC;
		 CLK8Hz : OUT STD_LOGIC;
		 CLK100mHz : OUT STD_LOGIC
	);
END COMPONENT;

SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;


BEGIN 
SYNTHESIZED_WIRE_0 <= '0';



b2v_inst : multipleclockv2
PORT MAP(Reset => SYNTHESIZED_WIRE_0,
		 clk2MHz => CLK2M,
		 CLK2kHz => V2_2K,
		 CLK8Hz => V2_8,
		 CLK500mHz => V2_500,
		 CLK100mHz => V2_100);


b2v_inst1 : multipleclock
PORT MAP(clk2MHz => CLK2M,
		 CLK2kHz => V1_2K,
		 CLK500mHz => V1_500,
		 CLK8Hz => V1_8,
		 CLK100mHz => V1_100);



END bdf_type;