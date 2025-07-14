----------------------------------------------------------------------------------
-- This file is part of ISA Debug POST Card CPLD firmware
-- Copyright (C) 2025 maniek86
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <https://www.gnu.org/licenses/>.
----------------------------------------------------------------------------------
-- Company: maniek86.xyz
-- Engineer: maniek86
-- 
-- Create Date:    22:35:29 06/13/2025 
-- Design Name: 
-- Module Name:    main - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity main is
    Port ( ADDR : in  STD_LOGIC_VECTOR (19 downto 0);
           DATA_IN : in  STD_LOGIC_VECTOR (7 downto 0);
           CLK_ISA : in  STD_LOGIC;
           CLK_20MHZ : in  STD_LOGIC;
           CLK_ISA_OSC : in  STD_LOGIC;
           RESET_ISA : in  STD_LOGIC;
           IO_W : in  STD_LOGIC;
           SEG : out  STD_LOGIC_VECTOR (7 downto 0);
           DIG_1 : out  STD_LOGIC;
           DIG_2 : out  STD_LOGIC;
           DIG_3 : out  STD_LOGIC;
           DIG_4 : out  STD_LOGIC;
           DIG_5 : out  STD_LOGIC;
           DIG_6 : out  STD_LOGIC;
           SW_CONFIG : in  STD_LOGIC_VECTOR (1 downto 0);
			  SW_CONFIG_ALT : in  STD_LOGIC; -- basically 3rd switch
			  POST_CFG	: in	STD_LOGIC_VECTOR (2 downto 0)
			  );
end main;

architecture Behavioral of main is

	COMPONENT freq_divider_seg IS
		PORT(	CLK : in  STD_LOGIC;
				SEG_CLK_EN : out  STD_LOGIC);
	END COMPONENT;
	
	
	COMPONENT segment_driver is
		PORT( VAL_1 : in  STD_LOGIC_VECTOR (3 downto 0);
				VAL_2 : in  STD_LOGIC_VECTOR (3 downto 0);
				VAL_3 : in  STD_LOGIC_VECTOR (3 downto 0);
				VAL_4 : in  STD_LOGIC_VECTOR (3 downto 0);
				VAL_5 : in  STD_LOGIC_VECTOR (3 downto 0);
				VAL_6 : in  STD_LOGIC_VECTOR (3 downto 0);
				CLK : in  STD_LOGIC;
				CLK_EN : in  STD_LOGIC;
				DIG_1 : out  STD_LOGIC;
				DIG_2 : out  STD_LOGIC;
				DIG_3 : out  STD_LOGIC;
				DIG_4 : out  STD_LOGIC;
				DIG_5 : out  STD_LOGIC;
				DIG_6 : out  STD_LOGIC;
				SEG : out  STD_LOGIC_VECTOR (7 downto 0);
				DOT_2 : in  STD_LOGIC;
				DOT_4_6 : in  STD_LOGIC;
				SEG_CFG	: in STD_LOGIC_VECTOR (1 downto 0)
				);
	END COMPONENT;
	
	COMPONENT freq_counter is
    Port ( CLK_MAIN 		: in  STD_LOGIC;
			  CLK_EN			: in	STD_LOGIC;
           CLK_MEASURE 	: in  STD_LOGIC;
           FREQ_OUT 		: out UNSIGNED (23 downto 0));
	END COMPONENT;
	
	COMPONENT freq_counter_decimal is
    Port ( CLK_MAIN 		: in  STD_LOGIC;
			  CLK_EN			: in	STD_LOGIC;
           CLK_MEASURE 	: in  STD_LOGIC;
           FREQ_OUT_1	: out STD_LOGIC_VECTOR(3 downto 0);
			  FREQ_OUT_2	: out STD_LOGIC_VECTOR(3 downto 0);
			  FREQ_OUT_3	: out STD_LOGIC_VECTOR(3 downto 0);
			  FREQ_OUT_4	: out STD_LOGIC_VECTOR(3 downto 0);
			  FREQ_OUT_5	: out STD_LOGIC_VECTOR(3 downto 0);
			  FREQ_OUT_6	: out STD_LOGIC_VECTOR(3 downto 0));
	end COMPONENT;

	
	SIGNAL seg_clk_en			:	STD_LOGIC;
	SIGNAL measured_freq_1	:  STD_LOGIC_VECTOR (3 downto 0);
	SIGNAL measured_freq_2	:  STD_LOGIC_VECTOR (3 downto 0);
	SIGNAL measured_freq_3	:  STD_LOGIC_VECTOR (3 downto 0);
	SIGNAL measured_freq_4	:  STD_LOGIC_VECTOR (3 downto 0);
	SIGNAL measured_freq_5	:  STD_LOGIC_VECTOR (3 downto 0);
	SIGNAL measured_freq_6	:  STD_LOGIC_VECTOR (3 downto 0);
	SIGNAL measured_clk		:	STD_LOGIC;
	
	SIGNAL out_seg_1			: 	STD_LOGIC_VECTOR (3 downto 0);
	SIGNAL out_seg_2			: 	STD_LOGIC_VECTOR (3 downto 0);
	SIGNAL out_seg_3			: 	STD_LOGIC_VECTOR (3 downto 0);
	SIGNAL out_seg_4			: 	STD_LOGIC_VECTOR (3 downto 0);
	SIGNAL out_seg_5			: 	STD_LOGIC_VECTOR (3 downto 0);
	SIGNAL out_seg_6			: 	STD_LOGIC_VECTOR (3 downto 0);
	
	SIGNAL out_dot_2			:	STD_LOGIC;
	SIGNAL out_dot_4_6		: 	STD_LOGIC;
	
	SIGNAL SEG_CFG				:	STD_LOGIC_VECTOR (1 downto 0);
	
	SIGNAL check_addr  : std_logic_vector(15 downto 0);
	SIGNAL post_seg_empty	:  STD_LOGIC := '1';
	SIGNAL post_code			:  STD_LOGIC_VECTOR (7 downto 0) := X"00";
	SIGNAL post_code_1		:  STD_LOGIC_VECTOR (7 downto 0) := X"00";
	SIGNAL post_code_2		:  STD_LOGIC_VECTOR (7 downto 0) := X"00";

	SIGNAL data_analyzer		:	STD_LOGIC_VECTOR (23 downto 0);
	
	
	CONSTANT VAL_ZERO		:	STD_LOGIC_VECTOR (3 downto 0) := "0000";
	
	attribute PWR_MODE : string;
   attribute PWR_MODE of seg_drv : label is "LOW";
	
	
begin

	freq_seg: freq_divider_seg PORT MAP(
		CLK => CLK_20MHZ, 
		SEG_CLK_EN => seg_clk_en);
		
	freq_cnt: freq_counter_decimal PORT MAP(
		CLK_MAIN => 	CLK_20MHZ,
		CLK_EN => 		seg_clk_en,
		CLK_MEASURE =>	measured_clk,
		FREQ_OUT_1 =>		measured_freq_1,
		FREQ_OUT_2 =>		measured_freq_2,
		FREQ_OUT_3 =>		measured_freq_3,
		FREQ_OUT_4 =>		measured_freq_4,
		FREQ_OUT_5 =>		measured_freq_5,
		FREQ_OUT_6 =>		measured_freq_6
		);

	seg_drv: segment_driver PORT MAP(
		VAL_1 => 	out_seg_1,
		VAL_2 => 	out_seg_2,
		VAL_3 => 	out_seg_3,
		VAL_4 => 	out_seg_4,
		VAL_5 => 	out_seg_5,
		VAL_6 => 	out_seg_6,
		DOT_2 =>		out_dot_2,
		DOT_4_6 =>  out_dot_4_6,
		CLK => 		CLK_20MHZ,
		CLK_EN =>	seg_clk_en,
		DIG_1 =>		DIG_1,
		DIG_2 =>		DIG_2,
		DIG_3 =>		DIG_3,
		DIG_4 =>		DIG_4,
		DIG_5 =>		DIG_5,
		DIG_6 =>		DIG_6,
		SEG =>		SEG,
		SEG_CFG =>	seg_cfg
		);
		
		
	PROCESS(POST_CFG)
	BEGIN
		 CASE POST_CFG IS
			  WHEN "000"  => check_addr	<= X"0080";
			  WHEN "001"  => check_addr   <= X"0084";
			  WHEN "010"  => check_addr   <= X"0090";
			  WHEN "011"  => check_addr   <= X"0300";
			  WHEN "100"  => check_addr   <= X"0680";
			  WHEN "101"  => check_addr   <= X"0060";
			  WHEN "110"  => check_addr   <= X"0190";
			  WHEN "111"  => check_addr   <= X"0378";
			  WHEN OTHERS => check_addr   <= X"0080";
		 END CASE;
	END PROCESS;

		
	-- POST analyzer
	PROCESS(IO_W, RESET_ISA)
	BEGIN
		 IF RESET_ISA = '1' THEN
			  post_seg_empty <= '1';
			  
			  post_code_1 <= X"00";
			  post_code_2 <= X"00";
			  

		 ELSIF RISING_EDGE(IO_W) THEN
			  IF ADDR(15 downto 0) = check_addr THEN
					post_seg_empty <= '0';

					post_code_2 <= post_code_1;
					post_code_1 <= post_code;
					post_code <= DATA_IN;
			  END IF;
		 END IF;
	END PROCESS;

	-- clock measure, when SW_CONFIG_ALT = 1 then measure OSC, else the CLK (normal)
	--measured_clk <= CLK_ISA WHEN SW_CONFIG_ALT = '0' ELSE CLK_ISA_OSC;
	measured_clk <= CLK_ISA WHEN SW_CONFIG_ALT = '0' ELSE CLK_ISA_OSC;
	

	-- data/address measure
	-- SW_CONFIG_ALT = 0 - DATA
	-- SW_CONFIG_ALT = 1 - ADDR
	data_analyzer <= X"0" & ADDR WHEN SW_CONFIG_ALT = '1' ELSE DATA_IN & X"0000";
	
	-- sw_config : 00 
	-- 00 = post analyzer, sw_push nothing
	-- 10 = freq analyzer, sw_push CLK/OSC
	-- 01 = data analyzer, sw_push ADDR/DATA
	
	WITH SW_CONFIG SELECT
		out_seg_1 <= 	post_code(7 downto 4) 			WHEN "00",
							data_analyzer(23 downto	20)	WHEN "01",
							measured_freq_1		 			WHEN "10",
							(OTHERS => '0')					WHEN OTHERS;
		
	WITH SW_CONFIG SELECT
		out_seg_2 <= 	post_code(3 downto 0)			WHEN "00",
							data_analyzer(19 downto	16)	WHEN "01",
							measured_freq_2 					WHEN "10",		
							(OTHERS => '0')					WHEN OTHERS;
		
	WITH SW_CONFIG SELECT
		out_seg_3 <= 	post_code_1(7 downto 4)			WHEN "00",
							data_analyzer(15 downto	12)	WHEN "01",
							measured_freq_3 					WHEN "10",
							check_addr(15 downto 12)		WHEN "11",
							(OTHERS => '0')					WHEN OTHERS;
	
	WITH SW_CONFIG SELECT
		out_seg_4 <= 	post_code_1(3 downto 0)			WHEN "00",
							data_analyzer(11 downto	08)	WHEN "01",
							measured_freq_4 					WHEN "10",
							check_addr(11 downto 8)			WHEN "11",
							(OTHERS => '0')					WHEN OTHERS;
							
	WITH SW_CONFIG SELECT
		out_seg_5 <= 	post_code_2(7 downto 4)			WHEN "00",
							data_analyzer(07 downto	04)	WHEN "01",
							measured_freq_5 					WHEN "10",
							check_addr(7 downto 4)			WHEN "11",
							(OTHERS => '0')					WHEN OTHERS;
		
	WITH SW_CONFIG SELECT
		out_seg_6 <= 	post_code_2(3 downto 0)			WHEN "00",
							data_analyzer(03 downto	00)	WHEN "01",
							measured_freq_6 					WHEN "10",
							check_addr(3 downto 0)			WHEN "11",
							(OTHERS => '0')					WHEN OTHERS;
		

	-- seg_cfg ->
	-- 00 - normal 
	-- 01 - normal (before: two segments only)
	-- 10 - first segment blank
	-- 11 - two segments only and empty
	
	-- two segments only	
	WITH SW_CONFIG SELECT
		seg_cfg(0) <= 	'1' 					WHEN "00",  -- post
							NOT SW_CONFIG_ALT	WHEN "01",	-- bus analyzer, SW_CONFIG_ALT = 0 - DATA
							'0' 					WHEN OTHERS;
							
	
	WITH SW_CONFIG SELECT
		seg_cfg(1) <=  post_seg_empty		WHEN "00", -- when seg_cfg = "11" then two but blank
							SW_CONFIG_ALT 		WHEN "01", -- bus analyzer, first segment blank only when analyzer mode and SW_CONFIG_ALT = 1 (addr)
							'0' 					WHEN OTHERS;
							
						
	-- first segment blank
	--seg_cfg(1) <= '1' WHEN (SW_CONFIG = "01") AND (config_push = '1') ELSE '0';
	
	-- empty segments (------)
	--WITH SW_CONFIG SELECT
	--	seg_empty <= post_seg_empty	WHEN "00",
	--					 '0' 					WHEN OTHERS;
						 
	-- dot at 2 (top)
	WITH SW_CONFIG SELECT
		out_dot_2 <= 	'1'						WHEN "00",  -- POST
							'1'						WHEN "01",  -- bus analyzer, SW_CONFIG_ALT = 0 - DATA, show dot at 2 when data analyzer on
							'1'						WHEN "10",  -- freq
							'0' 						WHEN OTHERS;
	
	WITH SW_CONFIG SELECT
		out_dot_4_6  <=	'1' WHEN "00",
								'0' WHEN OTHERS;
						 


end Behavioral;


