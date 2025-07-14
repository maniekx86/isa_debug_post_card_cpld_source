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
-- Create Date:    22:46:33 06/13/2025 
-- Design Name: 
-- Module Name:    segment_driver - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity segment_driver is
    Port ( VAL_1 : in  STD_LOGIC_VECTOR (3 downto 0);
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

			  
			  SEG_CFG	: in STD_LOGIC_VECTOR(1 downto 0) 
			  -- seg_cfg ->
				-- 00 - normal 
				-- 01 - two segments only
				-- 10 - first segment blank
				-- 11 - two, segments blank
			  );
end segment_driver;
	
	
architecture Behavioral of segment_driver is
	TYPE dig_rom_type IS ARRAY(0 TO 15) OF STD_LOGIC_VECTOR(6 DOWNTO 0);
	
--	-- NOTed outputs
--	CONSTANT dig_rom			: dig_rom_type := (
--		0  => "0000001",
--		1  => "1001111",
--		2  => "0010010",
--		3  => "0000110",
--		4  => "1001100",
--		5  => "0100100",
--		6  => "0100000",
--		7  => "0001111",
--		8  => "0000000",
--		9  => "0000100",
--		10 => "0001000", -- A
--		11 => "1100000", -- B
--		12 => "0110001", -- C
--		13 => "1000010", -- D
--		14 => "0110000", -- E
--		15 => "0111000"  -- F
--	);
	
	-- normal outputs
	CONSTANT dig_rom			: dig_rom_type := (
		0  => "1111110",
		1  => "0110000",
		2  => "1101101",
		3  => "1111001",
		4  => "0110011",
		5  => "1011011",
		6  => "1011111",
		7  => "1110000",
		8  => "1111111",
		9  => "1111011",
		10 => "1110111", -- A
		11 => "0011111", -- B
		12 => "1001110", -- C
		13 => "0111101", -- D
		14 => "1001111", -- E
		15 => "1000111"  -- F
	);	

	SIGNAL current_dig		: INTEGER RANGE 0 TO 5 := 0;
begin
	
	
	
	PROCESS (CLK) 
	BEGIN
		IF RISING_EDGE(CLK) AND CLK_EN = '1' THEN
			IF (current_dig = 5) THEN
				current_dig <= 0;
			ELSE
				current_dig <= current_dig + 1;
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS (current_dig) 
		VARIABLE temp_val		: STD_LOGIC_VECTOR(3 DOWNTO 0);
		VARIABLE dot_en		: STD_LOGIC;
	BEGIN
		dot_en := '0';
		CASE current_dig IS
			WHEN 0 => 
				temp_val := VAL_1;	
			WHEN 1 => 
				temp_val := VAL_2;
				dot_en := DOT_2;
			WHEN 2 => 
				temp_val := VAL_3;
			WHEN 3 => 
				temp_val := VAL_4;
				dot_en := DOT_4_6;
			WHEN 4 => 
				temp_val := VAL_5;
			WHEN 5 => 
				temp_val := VAL_6;
				dot_en := DOT_4_6;
		END CASE;
		
		IF SEG_CFG = "11" THEN
			SEG <= "0000001" & dot_en;
		ELSE
			SEG <= dig_rom(TO_INTEGER(UNSIGNED(temp_val))) & dot_en; -- conversion		
		END IF;
		
	END PROCESS;
	
	
	

	DIG_1 <= '0' WHEN (current_dig = 0) AND NOT (SEG_CFG = "10") ELSE '1';	-- 0 is active
	DIG_2 <= '0' WHEN (current_dig = 1) ELSE '1';
	--DIG_3 <= '0' WHEN (current_dig = 2) AND SEG_CFG(0) = '0' ELSE '1';
	--DIG_4 <= '0' WHEN (current_dig = 3) AND SEG_CFG(0) = '0' ELSE '1';
	--DIG_5 <= '0' WHEN (current_dig = 4) AND SEG_CFG(0) = '0' ELSE '1';
	--DIG_6 <= '0' WHEN (current_dig = 5) AND SEG_CFG(0) = '0' ELSE '1';
	
	DIG_3 <= '0' WHEN (current_dig = 2) ELSE '1';
	DIG_4 <= '0' WHEN (current_dig = 3) ELSE '1';
	DIG_5 <= '0' WHEN (current_dig = 4) ELSE '1';
	DIG_6 <= '0' WHEN (current_dig = 5) ELSE '1';

end Behavioral;

