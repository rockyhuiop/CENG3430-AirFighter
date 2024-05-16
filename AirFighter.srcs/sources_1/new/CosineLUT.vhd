library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cosine_lut is
    Port ( clk : in STD_LOGIC;
           angle : in unsigned(7 downto 0);  -- Input angle, 0-255 represents 0-2pi
           cos_out : out signed(15 downto 0)  -- Output cosine value, scaled to use full 16-bit range
         );
end cosine_lut;

architecture Behavioral of cosine_lut is
    type cos_table_type is array (0 to 255) of signed(15 downto 0);
    constant cos_table : cos_table_type := (
        -- Precomputed cosine values go here, one for each possible input angle
        -- For example:
        X"7FFF",
        X"7FE1",
        X"7F89",
        X"7EF5",
        X"7E28",
        X"7D21",
        X"7BE3",
        X"7A6D",
        X"78C2",
        X"76E4",
        X"74D4",
        X"7296",
        X"702A",
        X"6D94",
        X"6AD6",
        X"67F4",
        X"64EF",
        X"61CD",
        X"5E8E",
        X"5B38",
        X"57CC",
        X"5450",
        X"50C5",
        X"4D30",
        X"4993",
        X"45F4",
        X"4253",
        X"3EB6",
        X"3B1F",
        X"3792",
        X"3411",
        X"30A0",
        X"2D41",
        X"29F7",
        X"26C4",
        X"23AB",
        X"20AE",
        X"1DCE",
        X"1B0F",
        X"1870",
        X"15F3",
        X"139A",
        X"1164",
        X"0F54",
        X"0D68",
        X"0BA2",
        X"0A01",
        X"0885",
        X"072C",
        X"05F7",
        X"04E5",
        X"03F3",
        X"0322",
        X"026E",
        X"01D6",
        X"0159",
        X"00F3",
        X"00A4",
        X"0068",
        X"003C",
        X"001F",
        X"000D",
        X"0004",
        X"0000",
        X"0000",
        X"0000",
        X"FFFC",
        X"FFF3",
        X"FFE1",
        X"FFC4",
        X"FF98",
        X"FF5C",
        X"FF0D",
        X"FEA7",
        X"FE2A",
        X"FD92",
        X"FCDE",
        X"FC0D",
        X"FB1B",
        X"FA09",
        X"F8D4",
        X"F77B",
        X"F5FF",
        X"F45E",
        X"F298",
        X"F0AC",
        X"EE9C",
        X"EC66",
        X"EA0D",
        X"E790",
        X"E4F1",
        X"E232",
        X"DF52",
        X"DC55",
        X"D93C",
        X"D609",
        X"D2BF",
        X"CF60",
        X"CBEF",
        X"C86E",
        X"C4E1",
        X"C14A",
        X"BDAD",
        X"BA0C",
        X"B66D",
        X"B2D0",
        X"AF3B",
        X"ABB0",
        X"A834",
        X"A4C8",
        X"A172",
        X"9E33",
        X"9B11",
        X"980C",
        X"952A",
        X"926C",
        X"8FD6",
        X"8D6A",
        X"8B2C",
        X"891C",
        X"873E",
        X"8593",
        X"841D",
        X"82DF",
        X"81D8",
        X"810B",
        X"8077",
        X"801F",
        X"8001",
        X"801F",
        X"8077",
        X"810B",
        X"81D8",
        X"82DF",
        X"841D",
        X"8593",
        X"873E",
        X"891C",
        X"8B2C",
        X"8D6A",
        X"8FD6",
        X"926C",
        X"952A",
        X"980C",
        X"9B11",
        X"9E33",
        X"A172",
        X"A4C8",
        X"A834",
        X"ABB0",
        X"AF3B",
        X"B2D0",
        X"B66D",
        X"BA0C",
        X"BDAD",
        X"C14A",
        X"C4E1",
        X"C86E",
        X"CBEF",
        X"CF60",
        X"D2BF",
        X"D609",
        X"D93C",
        X"DC55",
        X"DF52",
        X"E232",
        X"E4F1",
        X"E790",
        X"EA0D",
        X"EC66",
        X"EE9C",
        X"F0AC",
        X"F298",
        X"F45E",
        X"F5FF",
        X"F77B",
        X"F8D4",
        X"FA09",
        X"FB1B",
        X"FC0D",
        X"FCDE",
        X"FD92",
        X"FE2A",
        X"FEA7",
        X"FF0D",
        X"FF5C",
        X"FF98",
        X"FFC4",
        X"FFE1",
        X"FFF3",
        X"FFFC",
        X"0000",
        X"0000",
        X"0000",
        X"0004",
        X"000D",
        X"001F",
        X"003C",
        X"0068",
        X"00A4",
        X"00F3",
        X"0159",
        X"01D6",
        X"026E",
        X"0322",
        X"03F3",
        X"04E5",
        X"05F7",
        X"072C",
        X"0885",
        X"0A01",
        X"0BA2",
        X"0D68",
        X"0F54",
        X"1164",
        X"139A",
        X"15F3",
        X"1870",
        X"1B0F",
        X"1DCE",
        X"20AE",
        X"23AB",
        X"26C4",
        X"29F7",
        X"2D41",
        X"30A0",
        X"3411",
        X"3792",
        X"3B1F",
        X"3EB6",
        X"4253",
        X"45F4",
        X"4993",
        X"4D30",
        X"50C5",
        X"5450",
        X"57CC",
        X"5B38",
        X"5E8E",
        X"61CD",
        X"64EF",
        X"67F4",
        X"6AD6",
        X"6D94",
        X"702A",
        X"7296",
        X"74D4",
        X"76E4",
        X"78C2",
        X"7A6D",
        X"7BE3",
        X"7D21",
        X"7E28",
        X"7EF5",
        X"7F89",
        X"7FE1");
begin
    process(clk)
    begin
        if rising_edge(clk) then
            cos_out <= cos_table(to_integer(angle));
        end if;
    end process;
end Behavioral;