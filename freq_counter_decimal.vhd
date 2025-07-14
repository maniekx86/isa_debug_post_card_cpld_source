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
-- Create Date:    17:36:59 06/14/2025 
-- Design Name: 
-- Module Name:    freq_counter - Behavioral 
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

entity freq_counter_decimal is
    Port ( CLK_MAIN        : in  STD_LOGIC;
           CLK_EN          : in  STD_LOGIC;
           CLK_MEASURE     : in  STD_LOGIC;
           FREQ_OUT_1      : out STD_LOGIC_VECTOR(3 downto 0);
           FREQ_OUT_2      : out STD_LOGIC_VECTOR(3 downto 0);
           FREQ_OUT_3      : out STD_LOGIC_VECTOR(3 downto 0);
           FREQ_OUT_4      : out STD_LOGIC_VECTOR(3 downto 0);
           FREQ_OUT_5      : out STD_LOGIC_VECTOR(3 downto 0);
           FREQ_OUT_6      : out STD_LOGIC_VECTOR(3 downto 0));
end freq_counter_decimal;

architecture Behavioral of freq_counter_decimal is
    CONSTANT timer_limit : INTEGER := 610; -- 610 cycles (0 to 609) for 1 second window
    
    SIGNAL finished       : STD_LOGIC;
    SIGNAL reset_counters : STD_LOGIC;
    
    SIGNAL time_counter        : INTEGER RANGE 0 TO timer_limit := 0;
    SIGNAL freq_counter_1      : UNSIGNED (9 downto 0) := TO_UNSIGNED(0, 10); -- count to 1000 then carry
    
    SIGNAL freq_counter_1000   : UNSIGNED (3 downto 0) := TO_UNSIGNED(0, 4);
    SIGNAL freq_counter_10000  : UNSIGNED (3 downto 0) := TO_UNSIGNED(0, 4);
    SIGNAL freq_counter_100000 : UNSIGNED (3 downto 0) := TO_UNSIGNED(0, 4);
    SIGNAL freq_counter_1000000: UNSIGNED (3 downto 0) := TO_UNSIGNED(0, 4);
    SIGNAL freq_counter_10000000: STD_LOGIC := '0';
    
    -- Edge detection for carries
    SIGNAL carry_1_prev    : STD_LOGIC := '0';
    SIGNAL carry_3_prev    : STD_LOGIC := '0';
    SIGNAL carry_4_prev    : STD_LOGIC := '0';
    SIGNAL carry_5_prev    : STD_LOGIC := '0';
    SIGNAL carry_6_prev    : STD_LOGIC := '0';
    
begin

    -- Timer process - generates 1 second measurement window
    PROCESS (CLK_MAIN)
    BEGIN
        IF RISING_EDGE(CLK_MAIN) AND CLK_EN = '1' THEN
            IF time_counter = timer_limit THEN
                time_counter <= 0;
                finished <= '1';
                -- Latch the frequency values to outputs
                FREQ_OUT_1 <= "000" & freq_counter_10000000;
                FREQ_OUT_2 <= STD_LOGIC_VECTOR(freq_counter_1000000);
                FREQ_OUT_3 <= STD_LOGIC_VECTOR(freq_counter_100000);
                FREQ_OUT_4 <= STD_LOGIC_VECTOR(freq_counter_10000);
                FREQ_OUT_5 <= STD_LOGIC_VECTOR(freq_counter_1000);
                FREQ_OUT_6 <= "0000"; -- Always display 0 for the 6th digit
            ELSE
                time_counter <= time_counter + 1;
                finished <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- Generate reset pulse for counters at start of each measurement
    reset_counters <= '1' when finished = '1' else '0';

    -- Units counter (counts CLK_MEASURE pulses, rolls over at 1000)
    PROCESS (CLK_MEASURE, reset_counters)
    BEGIN
        IF reset_counters = '1' THEN
            freq_counter_1 <= TO_UNSIGNED(0, 10);
        ELSIF RISING_EDGE(CLK_MEASURE) THEN
            IF freq_counter_1 = 999 THEN
                freq_counter_1 <= TO_UNSIGNED(0, 10);
            ELSE
                freq_counter_1 <= freq_counter_1 + 1;
            END IF;
        END IF;
    END PROCESS;

    -- Thousands counter and carry detection (synchronous with CLK_MAIN)
    PROCESS (CLK_MAIN)
        VARIABLE carry_1 : STD_LOGIC;
    BEGIN
        IF RISING_EDGE(CLK_MAIN) THEN
            -- Detect carry from first counter (0-999)
            carry_1 := '0';
            IF freq_counter_1 = 999 THEN
                carry_1 := '1';
            END IF;
            
            carry_1_prev <= carry_1;
            
            -- Thousands counter
            IF reset_counters = '1' THEN
                freq_counter_1000 <= X"0";
            ELSIF carry_1 = '1' AND carry_1_prev = '0' THEN -- Rising edge detection
                IF freq_counter_1000 = 9 THEN
                    freq_counter_1000 <= X"0";
                ELSE
                    freq_counter_1000 <= freq_counter_1000 + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Ten thousands counter
    PROCESS (CLK_MAIN)
        VARIABLE carry_3 : STD_LOGIC;
    BEGIN
        IF RISING_EDGE(CLK_MAIN) THEN
            carry_3 := '0';
            IF freq_counter_1000 = 9 AND carry_1_prev = '1' THEN
                carry_3 := '1';
            END IF;
            
            carry_3_prev <= carry_3;
            
            IF reset_counters = '1' THEN
                freq_counter_10000 <= X"0";
            ELSIF carry_3 = '1' AND carry_3_prev = '0' THEN
                IF freq_counter_10000 = 9 THEN
                    freq_counter_10000 <= X"0";
                ELSE
                    freq_counter_10000 <= freq_counter_10000 + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Hundred thousands counter
    PROCESS (CLK_MAIN)
        VARIABLE carry_4 : STD_LOGIC;
    BEGIN
        IF RISING_EDGE(CLK_MAIN) THEN
            carry_4 := '0';
            IF freq_counter_10000 = 9 AND carry_3_prev = '1' THEN
                carry_4 := '1';
            END IF;
            
            carry_4_prev <= carry_4;
            
            IF reset_counters = '1' THEN
                freq_counter_100000 <= X"0";
            ELSIF carry_4 = '1' AND carry_4_prev = '0' THEN
                IF freq_counter_100000 = 9 THEN
                    freq_counter_100000 <= X"0";
                ELSE
                    freq_counter_100000 <= freq_counter_100000 + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Millions counter
    PROCESS (CLK_MAIN)
        VARIABLE carry_5 : STD_LOGIC;
    BEGIN
        IF RISING_EDGE(CLK_MAIN) THEN
            carry_5 := '0';
            IF freq_counter_100000 = 9 AND carry_4_prev = '1' THEN
                carry_5 := '1';
            END IF;
            
            carry_5_prev <= carry_5;
            
            IF reset_counters = '1' THEN
                freq_counter_1000000 <= X"0";
            ELSIF carry_5 = '1' AND carry_5_prev = '0' THEN
                IF freq_counter_1000000 = 9 THEN
                    freq_counter_1000000 <= X"0";
                ELSE
                    freq_counter_1000000 <= freq_counter_1000000 + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Ten millions counter (single bit logic to save resources)
    PROCESS (CLK_MAIN)
        VARIABLE carry_6 : STD_LOGIC;
    BEGIN
        IF RISING_EDGE(CLK_MAIN) THEN
            carry_6 := '0';
            IF freq_counter_1000000 = 9 AND carry_5_prev = '1' THEN
                carry_6 := '1';
            END IF;
            
            carry_6_prev <= carry_6;
            
            IF reset_counters = '1' THEN
                freq_counter_10000000 <= '0';
            ELSIF carry_6 = '1' AND carry_6_prev = '0' THEN
                freq_counter_10000000 <= '1'; -- Can only be 0 or 1 for max 19.999.999 Hz
            END IF;
        END IF;
    END PROCESS;

end Behavioral;
