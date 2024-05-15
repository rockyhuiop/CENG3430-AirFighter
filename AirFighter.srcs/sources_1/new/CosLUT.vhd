library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cos_lut is
    Port ( clk : in STD_LOGIC;
           angle : in unsigned(7 downto 0);  -- Input angle, 0-255 represents 0-2pi
           cos_out : out signed(15 downto 0)  -- Output cosine value, scaled to use full 16-bit range
         );
end cos_lut;

architecture Behavioral of cos_lut is
    type cos_table_type is array (0 to 255) of signed(15 downto 0);
    constant cos_table : cos_table_type := (
        -- Precomputed cosine values go here, one for each possible input angle
        -- For example:
        X"7FFF",
        X"7FF5",
        X"7FD8",
        X"7FA6",
        X"7F61",
        X"7F09",
        X"7E9C",
        X"7E1D",
        X"7D89",
        X"7CE3",
        X"7C29",
        X"7B5C",
        X"7A7C",
        X"7989",
        X"7884",
        X"776B",
        X"7641",
        X"7504",
        X"73B5",
        X"7254",
        X"70E2",
        X"6F5E",
        X"6DC9",
        X"6C23",
        X"6A6D",
        X"68A6",
        X"66CF",
        X"64E8",
        X"62F1",
        X"60EB",
        X"5ED7",
        X"5CB3",
        X"5A82",
        X"5842",
        X"55F5",
        X"539B",
        X"5133",
        X"4EBF",
        X"4C3F",
        X"49B4",
        X"471C",
        X"447A",
        X"41CE",
        X"3F17",
        X"3C56",
        X"398C",
        X"36BA",
        X"33DF",
        X"30FB",
        X"2E11",
        X"2B1F",
        X"2826",
        X"2528",
        X"2223",
        X"1F1A",
        X"1C0B",
        X"18F9",
        X"15E2",
        X"12C8",
        X"0FAB",
        X"0C8C",
        X"096A",
        X"0648",
        X"0324",
        X"0000",
        X"FCDC",
        X"F9B8",
        X"F696",
        X"F374",
        X"F055",
        X"ED38",
        X"EA1E",
        X"E707",
        X"E3F5",
        X"E0E6",
        X"DDDD",
        X"DAD8",
        X"D7DA",
        X"D4E1",
        X"D1EF",
        X"CF05",
        X"CC21",
        X"C946",
        X"C674",
        X"C3AA",
        X"C0E9",
        X"BE32",
        X"BB86",
        X"B8E4",
        X"B64C",
        X"B3C1",
        X"B141",
        X"AECD",
        X"AC65",
        X"AA0B",
        X"A7BE",
        X"A57E",
        X"A34D",
        X"A129",
        X"9F15",
        X"9D0F",
        X"9B18",
        X"9931",
        X"975A",
        X"9593",
        X"93DD",
        X"9237",
        X"90A2",
        X"8F1E",
        X"8DAC",
        X"8C4B",
        X"8AFC",
        X"89BF",
        X"8895",
        X"877C",
        X"8677",
        X"8584",
        X"84A4",
        X"83D7",
        X"831D",
        X"8277",
        X"81E3",
        X"8164",
        X"80F7",
        X"809F",
        X"805A",
        X"8028",
        X"800B",
        X"8001",
        X"800B",
        X"8028",
        X"805A",
        X"809F",
        X"80F7",
        X"8164",
        X"81E3",
        X"8277",
        X"831D",
        X"83D7",
        X"84A4",
        X"8584",
        X"8677",
        X"877C",
        X"8895",
        X"89BF",
        X"8AFC",
        X"8C4B",
        X"8DAC",
        X"8F1E",
        X"90A2",
        X"9237",
        X"93DD",
        X"9593",
        X"975A",
        X"9931",
        X"9B18",
        X"9D0F",
        X"9F15",
        X"A129",
        X"A34D",
        X"A57E",
        X"A7BE",
        X"AA0B",
        X"AC65",
        X"AECD",
        X"B141",
        X"B3C1",
        X"B64C",
        X"B8E4",
        X"BB86",
        X"BE32",
        X"C0E9",
        X"C3AA",
        X"C674",
        X"C946",
        X"CC21",
        X"CF05",
        X"D1EF",
        X"D4E1",
        X"D7DA",
        X"DAD8",
        X"DDDD",
        X"E0E6",
        X"E3F5",
        X"E707",
        X"EA1E",
        X"ED38",
        X"F055",
        X"F374",
        X"F696",
        X"F9B8",
        X"FCDC",
        X"0000",
        X"0324",
        X"0648",
        X"096A",
        X"0C8C",
        X"0FAB",
        X"12C8",
        X"15E2",
        X"18F9",
        X"1C0B",
        X"1F1A",
        X"2223",
        X"2528",
        X"2826",
        X"2B1F",
        X"2E11",
        X"30FB",
        X"33DF",
        X"36BA",
        X"398C",
        X"3C56",
        X"3F17",
        X"41CE",
        X"447A",
        X"471C",
        X"49B4",
        X"4C3F",
        X"4EBF",
        X"5133",
        X"539B",
        X"55F5",
        X"5842",
        X"5A82",
        X"5CB3",
        X"5ED7",
        X"60EB",
        X"62F1",
        X"64E8",
        X"66CF",
        X"68A6",
        X"6A6D",
        X"6C23",
        X"6DC9",
        X"6F5E",
        X"70E2",
        X"7254",
        X"73B5",
        X"7504",
        X"7641",
        X"776B",
        X"7884",
        X"7989",
        X"7A7C",
        X"7B5C",
        X"7C29",
        X"7CE3",
        X"7D89",
        X"7E1D",
        X"7E9C",
        X"7F09",
        X"7F61",
        X"7FA6",
        X"7FD8",
        X"7FF5");
begin
    process(clk)
    begin
        if rising_edge(clk) then
            cos_out <= cos_table(to_integer(angle));
        end if;
    end process;
end Behavioral;
