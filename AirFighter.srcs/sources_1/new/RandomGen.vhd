library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rand_gen is
    port(
        clk : in std_logic;
        rand_out : out std_logic_vector(9 downto 0)
    );
end rand_gen;

architecture behavioral of rand_gen is
    signal temp : std_logic_vector(9 downto 0) := "0000000001";
begin
    process(clk)
    begin
        if rising_edge(clk) then
            temp <= temp(8 downto 0) & (temp(9) xor temp(5));
        end if;
    end process;
    rand_out <= temp;
end behavioral;
