----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/20/2024 02:36:04 PM
-- Design Name: 
-- Module Name: clock_divider - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clock_divider is
    generic (N: integer);
    Port (
        clk: in std_logic;
        clk_out: out std_logic
    );
end clock_divider;

architecture arch_clock_divider of clock_divider is
    signal pulse: std_logic := '0';
    signal count: integer := 0;
begin
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(count = (N - 1)) then
                pulse <= not pulse;
                count <= 0;
            else
                count <= count + 1;
            end if;
        end if;
    end process;
    clk_out <= pulse;
end arch_clock_divider;
