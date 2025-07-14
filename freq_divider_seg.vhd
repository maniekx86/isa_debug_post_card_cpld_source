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
-- Create Date:    23:19:22 06/13/2025 
-- Design Name: 
-- Module Name:    freq_divider_seg - Behavioral 
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity freq_divider_seg is
    Port ( CLK : in  STD_LOGIC;
           SEG_CLK_EN : out  STD_LOGIC);
end freq_divider_seg;

architecture Behavioral of freq_divider_seg is
	-- CLK is 20MHz
	-- SEG_CLK_EN should be active minimum 180 times per second 32767 -> 610 times per second
	
	SIGNAL counter		: INTEGER RANGE 0 to 32767 := 0;
begin

	PROCESS (CLK)
	BEGIN
		IF RISING_EDGE(CLK) THEN
			IF COUNTER = 32767 THEN
				counter <= 0;
			ELSE
				counter <= counter + 1;
			END IF;
		END IF;
	END PROCESS;
		
	SEG_CLK_EN <= '1' WHEN counter =  0 ELSE '0';

end Behavioral;

