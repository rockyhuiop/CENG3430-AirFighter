----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/13/2024 05:01:12 PM
-- Design Name: 
-- Module Name: player_display - Behavioral
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
use work.image_data_pkg.all;
use work.pixelNum_pkg.all;  -- Add this line to use the image_data_pkg
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity player_display is
    Port ( 
        clk: in std_logic;
        hsync, vsync: out std_logic;
        red, green, blue: out std_logic_vector(3 downto 0);
        p1_x, p1_y, p2_x, p2_y: in integer;
        p1b_x, p1b_y, p2b_x, p2b_y: in integer;
        m1_x, m1_y: in integer;
        p1_score, p2_score: in integer
    );
end player_display;

architecture Behavioral of player_display is
    signal clk50MHz: std_logic;
    signal clk10Hz: std_logic;
    signal hcount, vcount: integer := 0; 
    
    -- 1. row and column constants
    --row constants 
    constant H_TOTAL:integer:=1344-1; 
    constant H_SYNC:integer:=48-1; 
    constant H_BACK:integer:=240-1;
    constant H_START:integer:=48+240-1; 
    constant H_ACTIVE:integer:=1024-1; 
    constant H_END:integer:=1344-32-1; 
    constant H_FRONT:integer:=32-1;
    --column constants 
    constant V_TOTAL:integer:=625-1; 
    constant V_SYNC:integer:=3-1; 
    constant V_BACK:integer:=12-1; 
    constant V_START:integer:=3+12-1; 
    constant V_ACTIVE:integer:=600-1; 
    constant V_END:integer:=625-10-1; 
    constant V_FRONT:integer:=10-1;
    
    component clock_divider is
    generic (N: integer);
    port( 
        clk: in std_logic;
        clk_out: out std_logic
    );
    end component;
    
    -- Constants of the square
    constant LENGTH: integer := 128;
    constant WIDTH: integer := 128;
    signal p1_H_TOP_LEFT: integer := H_START + p1_x - WIDTH/2;
    signal p1_V_TOP_LEFT: integer := V_START + p1_y - LENGTH/2;
    
    signal p2_H_TOP_LEFT: integer := H_START + p2_x - WIDTH/2;
    signal p2_V_TOP_LEFT: integer := V_START + p2_y - LENGTH/2;
    
    -- Constants for the bullet
    constant BULLET_SPEED: integer := 10; -- 50 pixels per second
    constant BULLET_LENGTH: integer := 28;
    constant BULLET_WIDTH: integer := 12;
    
    constant m_SPEED: integer := 10; -- 10 pixels per second
    constant m_LENGTH: integer := 64;
    constant m_WIDTH: integer := 47;

    constant S1_H_START: integer := H_START + 100 - WIDTH/2;
    constant S1_V_START: integer := V_START + 20;
    constant S2_H_START: integer := H_START + 924 + WIDTH/2;
    constant S2_V_START: integer := V_START + 20;
    
    -- Signals for the bullet
    signal p1_bullet_x: integer := H_START + p1b_x - BULLET_LENGTH/2;
    signal p2_bullet_x: integer := H_START + p2b_x - BULLET_LENGTH/2;
    signal p1_bullet_y: integer := V_START + p1b_y - BULLET_WIDTH/2;
    signal p2_bullet_y: integer := V_START + p2b_y - BULLET_WIDTH/2; 
    
    signal sig_m1_x: integer := H_START + m1_x - m_WIDTH/2;
    signal sig_m1_y: integer := V_START + m1_y - m_LENGTH/2;
    
    
    -- Signals for hit checking
    signal p1_is_hit, p2_is_hit: integer := 0;
    signal p1_flash_count, p2_flash_count : integer := 0;
    signal p1_baseline: integer := p1_H_TOP_LEFT + WIDTH;
    signal p2_baseline: integer := p2_H_TOP_LEFT - WIDTH;

begin
    -- 2. generate 50MHz clock
    comp_clk50MHz: clock_divider generic map(N => 1) port map(clk, clk50MHz);
    comp_clk10Hz: clock_divider generic map(N => 5000000) port map(clk, clk10Hz);
        
    -- 3. horizontal counter
    hcount_proc: process(clk50MHz)
    begin
        if(rising_edge(clk50MHz)) then
            if(hcount = H_TOTAL) then
                hcount <= 0;
            else
                hcount <= hcount + 1;
            end if;
        end if;
    end process hcount_proc;
    
    -- 4. vertical counter
    vcount_proc: process(clk50MHz)
    begin
        if(rising_edge(clk50MHz)) then
            if(hcount = H_TOTAL) then
                if(vcount = V_TOTAL) then
                    vcount <= 0;
                else
                    vcount <= vcount + 1;
                end if;
            end if;
        end if;
    end process vcount_proc;
    
    -- 5. generate hsync
    hsync_gen_proc: process(hcount) 
    begin
        if(hcount < H_SYNC) then
            hsync <= '0';
        else
            hsync <= '1';
        end if;
    end process hsync_gen_proc;
    
    -- 6. generate vsync
    vsync_gen_proc: process(vcount)
    begin
        if(vcount < V_SYNC) then 
            vsync <= '0';
        else
            vsync <= '1';
        end if;
    end process vsync_gen_proc;
    
    
    -- 7. generate RGB signals for 1024x600 display area
    data_output_proc: process(hcount, vcount)
    begin
        if((hcount >= H_START and hcount < H_END) and
           (vcount >= V_START and vcount < V_END)) then
            -- Display Area (draw the square here)
            if((hcount >= p1_H_TOP_LEFT and hcount < p1_H_TOP_LEFT + WIDTH) and
               (vcount >= p1_V_TOP_LEFT and vcount < p1_V_TOP_LEFT + LENGTH)) then
                red   <= Image(vcount-(p1_V_TOP_LEFT + LENGTH), hcount-(p1_H_TOP_LEFT + WIDTH))(23 downto 20); -- Extracting 4 MSBs for each color
                green <= Image(vcount-(p1_V_TOP_LEFT + LENGTH), hcount-(p1_H_TOP_LEFT + WIDTH))(15 downto 12);
                blue  <= Image(vcount-(p1_V_TOP_LEFT + LENGTH), hcount-(p1_H_TOP_LEFT + WIDTH))(7 downto 4);
            elsif((hcount >= p2_H_TOP_LEFT and hcount < p2_H_TOP_LEFT + WIDTH) and
                 (vcount >= p2_V_TOP_LEFT and vcount < p2_V_TOP_LEFT + LENGTH)) then
                red   <= "1100";
                green <= "0110";
                blue  <= "0011";
            -- Add the bullet display here
            elsif((hcount >= p1_bullet_x and hcount < p1_bullet_x + BULLET_LENGTH) and
                 (vcount >= p1_bullet_y and vcount < p1_bullet_y + BULLET_WIDTH)) then
                red   <= "1111";
                green <= "1111";
                blue  <= "0000";
            elsif((hcount >= p2_bullet_x and hcount < p2_bullet_x + BULLET_LENGTH) and
                 (vcount >= p2_bullet_y and vcount < p2_bullet_y + BULLET_WIDTH)) then
                red   <= "0000";
                green <= "1111";
                blue  <= "1111";
            -- monster display
            elsif((hcount >= sig_m1_x and hcount < sig_m1_x + m_WIDTH) and
                 (vcount >= sig_m1_y and vcount < sig_m1_y + m_LENGTH)) then
                red   <= p1drone(vcount-sig_m1_y, hcount-(sig_m1_x))(23 downto 20); -- Extracting 4 MSBs for each color
                green <= p1drone(vcount-sig_m1_y, hcount-(sig_m1_x))(15 downto 12);
                blue  <= p1drone(vcount-sig_m1_y, hcount-(sig_m1_x))(7 downto 4);
            else
                -- p1 score space 10 digit
                if((hcount >= s1_H_START and hcount < s1_H_START + 48) and
                   (vcount >= s1_V_START and vcount < s1_V_START + 48)) then
                    if p1_score / 10 = 0 then
                        red   <= pix0(vcount-(s1_V_START), hcount-(s1_H_START))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix0(vcount-(s1_V_START), hcount-(s1_H_START))(15 downto 12);
                        blue  <= pix0(vcount-(s1_V_START), hcount-(s1_H_START))(7 downto 4);
                    elsif p1_score / 10 = 1 then
                        red   <= pix1(vcount-(s1_V_START), hcount-(s1_H_START))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix1(vcount-(s1_V_START), hcount-(s1_H_START))(15 downto 12);
                        blue  <= pix1(vcount-(s1_V_START), hcount-(s1_H_START))(7 downto 4);
                    elsif p1_score / 10 = 2 then
                        red   <= pix2(vcount-(s1_V_START), hcount-(s1_H_START))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix2(vcount-(s1_V_START), hcount-(s1_H_START))(15 downto 12);
                        blue  <= pix2(vcount-(s1_V_START), hcount-(s1_H_START))(7 downto 4);
                    elsif p1_score / 10 = 3 then
                        red   <= pix3(vcount-(s1_V_START), hcount-(s1_H_START))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix3(vcount-(s1_V_START), hcount-(s1_H_START))(15 downto 12);
                        blue  <= pix3(vcount-(s1_V_START), hcount-(s1_H_START))(7 downto 4);
                    elsif p1_score / 10 = 4 then
                        red   <= pix4(vcount-(s1_V_START), hcount-(s1_H_START))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix4(vcount-(s1_V_START), hcount-(s1_H_START))(15 downto 12);
                        blue  <= pix4(vcount-(s1_V_START), hcount-(s1_H_START))(7 downto 4);
                    elsif p1_score / 10 = 5 then
                        red   <= pix5(vcount-(s1_V_START), hcount-(s1_H_START))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix5(vcount-(s1_V_START), hcount-(s1_H_START))(15 downto 12);
                        blue  <= pix5(vcount-(s1_V_START), hcount-(s1_H_START))(7 downto 4);
                    elsif p1_score / 10 = 6 then
                        red   <= pix6(vcount-(s1_V_START), hcount-(s1_H_START))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix6(vcount-(s1_V_START), hcount-(s1_H_START))(15 downto 12);
                        blue  <= pix6(vcount-(s1_V_START), hcount-(s1_H_START))(7 downto 4);
                    elsif p1_score / 10 = 7 then
                        red   <= pix7(vcount-(s1_V_START), hcount-(s1_H_START))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix7(vcount-(s1_V_START), hcount-(s1_H_START))(15 downto 12);
                        blue  <= pix7(vcount-(s1_V_START), hcount-(s1_H_START))(7 downto 4);
                    elsif p1_score / 10 = 8 then
                        red   <= pix8(vcount-(s1_V_START), hcount-(s1_H_START))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix8(vcount-(s1_V_START), hcount-(s1_H_START))(15 downto 12);
                        blue  <= pix8(vcount-(s1_V_START), hcount-(s1_H_START))(7 downto 4);
                    elsif p1_score / 10 = 9 then
                        red   <= pix9(vcount-(s1_V_START), hcount-(s1_H_START))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix9(vcount-(s1_V_START), hcount-(s1_H_START))(15 downto 12);
                        blue  <= pix9(vcount-(s1_V_START), hcount-(s1_H_START))(7 downto 4);
                    end if;
                elsif ((hcount >= s1_H_START + 48 and hcount < s1_H_START + 48 + 48) and
                      (vcount >= s1_V_START and vcount < s1_V_START + 48)) then
                    if p1_score mod 10 = 0 then
                        red   <= pix0(vcount-(s1_V_START), hcount-(s1_H_START+48))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix0(vcount-(s1_V_START), hcount-(s1_H_START+48))(15 downto 12);
                        blue  <= pix0(vcount-(s1_V_START), hcount-(s1_H_START+48))(7 downto 4);
                    elsif p1_score mod 10 = 1 then
                        red   <= pix1(vcount-(s1_V_START), hcount-(s1_H_START+48))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix1(vcount-(s1_V_START), hcount-(s1_H_START+48))(15 downto 12);
                        blue  <= pix1(vcount-(s1_V_START), hcount-(s1_H_START+48))(7 downto 4);
                    elsif p1_score mod 10 = 2 then
                        red   <= pix2(vcount-(s1_V_START), hcount-(s1_H_START+48))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix2(vcount-(s1_V_START), hcount-(s1_H_START+48))(15 downto 12);
                        blue  <= pix2(vcount-(s1_V_START), hcount-(s1_H_START+48))(7 downto 4);
                    elsif p1_score mod 10 = 3 then
                        red   <= pix3(vcount-(s1_V_START), hcount-(s1_H_START+48))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix3(vcount-(s1_V_START), hcount-(s1_H_START+48))(15 downto 12);
                        blue  <= pix3(vcount-(s1_V_START), hcount-(s1_H_START+48))(7 downto 4);
                    elsif p1_score mod 10 = 4 then
                        red   <= pix4(vcount-(s1_V_START), hcount-(s1_H_START+48))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix4(vcount-(s1_V_START), hcount-(s1_H_START+48))(15 downto 12);
                        blue  <= pix4(vcount-(s1_V_START), hcount-(s1_H_START+48))(7 downto 4);
                    elsif p1_score mod 10 = 5 then
                        red   <= pix5(vcount-(s1_V_START), hcount-(s1_H_START+48))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix5(vcount-(s1_V_START), hcount-(s1_H_START+48))(15 downto 12);
                        blue  <= pix5(vcount-(s1_V_START), hcount-(s1_H_START+48))(7 downto 4);
                    elsif p1_score mod 10 = 6 then
                        red   <= pix6(vcount-(s1_V_START), hcount-(s1_H_START+48))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix6(vcount-(s1_V_START), hcount-(s1_H_START+48))(15 downto 12);
                        blue  <= pix6(vcount-(s1_V_START), hcount-(s1_H_START+48))(7 downto 4);
                    elsif p1_score mod 10 = 7 then
                        red   <= pix7(vcount-(s1_V_START), hcount-(s1_H_START+48))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix7(vcount-(s1_V_START), hcount-(s1_H_START+48))(15 downto 12);
                        blue  <= pix7(vcount-(s1_V_START), hcount-(s1_H_START+48))(7 downto 4);
                    elsif p1_score mod 10 = 8 then
                        red   <= pix8(vcount-(s1_V_START), hcount-(s1_H_START+48))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix8(vcount-(s1_V_START), hcount-(s1_H_START+48))(15 downto 12);
                        blue  <= pix8(vcount-(s1_V_START), hcount-(s1_H_START+48))(7 downto 4);
                    elsif p1_score mod 10 = 9 then
                        red   <= pix9(vcount-(s1_V_START), hcount-(s1_H_START+48))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix9(vcount-(s1_V_START), hcount-(s1_H_START+48))(15 downto 12);
                        blue  <= pix9(vcount-(s1_V_START), hcount-(s1_H_START+48))(7 downto 4);
                    end if;
                elsif((hcount >= s2_H_START and hcount < s2_H_START + 48) and
                   (vcount >= s2_V_START and vcount < s2_V_START + 48)) then
                    if p1_score / 10 = 0 then
                        red   <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(15 downto 12);
                        blue  <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(7 downto 4);
                    elsif p1_score / 10 = 1 then
                        red   <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(15 downto 12);
                        blue  <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(7 downto 4);
                    elsif p1_score / 10 = 2 then
                        red   <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(15 downto 12);
                        blue  <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(7 downto 4);
                    elsif p1_score / 10 = 3 then
                        red   <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(15 downto 12);
                        blue  <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(7 downto 4);
                    elsif p1_score / 10 = 4 then
                        red   <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(15 downto 12);
                        blue  <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(7 downto 4);
                    elsif p1_score / 10 = 5 then
                        red   <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(15 downto 12);
                        blue  <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(7 downto 4);
                    elsif p1_score / 10 = 6 then
                        red   <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(15 downto 12);
                        blue  <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(7 downto 4);
                    elsif p1_score / 10 = 7 then
                        red   <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(15 downto 12);
                        blue  <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(7 downto 4);
                    elsif p1_score / 10 = 8 then
                        red   <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(15 downto 12);
                        blue  <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(7 downto 4);
                    elsif p1_score / 10 = 9 then
                        red   <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(15 downto 12);
                        blue  <= pix0(vcount-(s2_V_START), hcount-(s2_H_START))(7 downto 4);
                    end if;
                elsif ((hcount >= s2_H_START + 48 and hcount < s2_H_START + 48 + 48) and
                      (vcount >= s2_V_START and vcount < s2_V_START + 48)) then
                    if p1_score mod 10 = 0 then
                        red   <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(15 downto 12);
                        blue  <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(7 downto 4);
                    elsif p1_score mod 10 = 1 then
                        red   <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(15 downto 12);
                        blue  <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(7 downto 4);
                    elsif p1_score mod 10 = 2 then
                        red   <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(15 downto 12);
                        blue  <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(7 downto 4);
                    elsif p1_score mod 10 = 3 then
                        red   <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(15 downto 12);
                        blue  <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(7 downto 4);
                    elsif p1_score mod 10 = 4 then
                        red   <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(15 downto 12);
                        blue  <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(7 downto 4);
                    elsif p1_score mod 10 = 5 then
                        red   <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(15 downto 12);
                        blue  <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(7 downto 4);
                    elsif p1_score mod 10 = 6 then
                        red   <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(15 downto 12);
                        blue  <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(7 downto 4);
                    elsif p1_score mod 10 = 7 then
                        red   <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(15 downto 12);
                        blue  <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(7 downto 4);
                    elsif p1_score mod 10 = 8 then
                        red   <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(15 downto 12);
                        blue  <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(7 downto 4);
                    elsif p1_score mod 10 = 9 then
                        red   <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(23 downto 20); -- Extracting 4 MSBs for each color
                        green <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(15 downto 12);
                        blue  <= pix0(vcount-(s2_V_START), hcount-(s2_H_START+48))(7 downto 4);
                    end if;
                else
                    red   <= "1111";
                    green <= "1111";
                    blue  <= "1111";
                end if;
            end if;
        else
            -- Blanking Area
            red   <= "0000";
            green <= "0000";
            blue  <= "0000";
        end if;
    end process data_output_proc;
            
            
            
            

end Behavioral;
