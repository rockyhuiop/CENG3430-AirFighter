----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/13/2024 09:44:21 PM
-- Design Name: 
-- Module Name: player_ctrl - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use work.state_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity player_ctrl is
    Port (
        state: in t_state;
        clk, btnL, btnR, btnU, btnD: in std_logic;
        p1_x, p1_y, p2_x, p2_y: out integer;
        p1b_x, p1b_y, p2b_x, p2b_y: out integer;
        m1_x, m1_y, m2_x, m2_y: out integer;
        p1_score, p2_score: out integer
    );
end player_ctrl;

architecture Behavioral of player_ctrl is

    -- init position
    signal sig_p1_x: integer := 100;
    signal sig_p1_y: integer := 300;
    signal sig_p2_x: integer := 924;
    signal sig_p2_y: integer := 300;
    signal sig_p1b_x: integer := 100;
    signal sig_p1b_y: integer := 300;
    signal sig_p2b_x: integer := 924;
    signal sig_p2b_y: integer := 300;
    
    -- mobile plane
    signal sig_m1_x: integer := 0;
    signal sig_m1_y: integer := 300;
    signal m1_cos1_in: unsigned(7 downto 0);
    signal m1_cos1_out: signed(15 downto 0);
    signal m1_cos_in: unsigned(7 downto 0);
    signal m1_cos_out: signed(15 downto 0);
    signal m1_rand: integer;
    signal rand_num: std_logic_vector(9 downto 0);
    
    signal sig_m2_x: integer := 0;
    signal sig_m2_y: integer := 300;
    signal m2_cos1_in: unsigned(7 downto 0);
    signal m2_cos1_out: signed(15 downto 0);
    signal m2_cos_in: unsigned(7 downto 0);
    signal m2_cos_out: signed(15 downto 0);
    signal m2_rand: integer;
    signal rand_num2: std_logic_vector(9 downto 0);
    
    -- score
    signal sig_p1_score: integer := 0;
    signal sig_p2_score: integer := 0;
    
    --signal p1_is_hit: boolean := false;
    --signal p2_is_hit: boolean := false;
    signal p1_eff_count: integer := 0;
    signal p2_eff_count: integer := 0;
    
    signal m1_eff_count: integer := 0;
    signal m2_eff_count: integer := 0;
    
    signal clk50MHz: std_logic;
    signal clk50Hz: std_logic;
    signal clk10Hz: std_logic;
    signal clk27Hz: std_logic;
    
    component clock_divider is
    generic (N: integer);
    port( 
        clk: in std_logic;
        clk_out: out std_logic
    );
    end component;
    
    component cosine_lut is
    Port ( clk : in STD_LOGIC;
           angle : in unsigned(7 downto 0);  -- Input angle, 0-255 represents 0-2pi
           cos_out : out signed(15 downto 0)  -- Output cosine value, scaled to use full 16-bit range
         );
    end component;
    
    component cos_lut is
    Port ( clk : in STD_LOGIC;
           angle : in unsigned(7 downto 0);  -- Input angle, 0-255 represents 0-2pi
           cos_out : out signed(15 downto 0)  -- Output cosine value, scaled to use full 16-bit range
         );
    end component;
    
    component rand_gen is
        port(
            clk : in std_logic;
            rand_out : out std_logic_vector(9 downto 0)
        );
    end component;
   
    constant p1_baseline : integer := (100 + 64);
    constant p2_baseline : integer := (924 - 64); 
    constant TOP : integer := 0;
    constant BOTTOM : integer := 600;
    constant LEFT : integer := 0;
    constant RIGHT : integer := 1024;
    constant p_LENGTH : integer := 128;
    constant p_WIDTH : integer := 128;
    signal p_SPEED: integer := 4;
    signal b_SPEED: integer := 12; -- 50 pixels per second
    constant b_LENGTH: integer := 28;
    constant b_WIDTH: integer := 6;
    constant m_SPEED: integer := 5;
    constant m_LENGTH: integer := 76;
    constant m_WIDTH: integer := 52;
    
    
    
begin
    comp_clk50MHz: clock_divider generic map(N => 1) port map(clk, clk50MHz);
    comp_clk10Hz: clock_divider generic map(N => 5000000) port map(clk, clk10Hz);
    comp_clk50Hz: clock_divider generic map(N => 1000000) port map(clk, clk50Hz);
    comp_clk27Hz: clock_divider generic map(N => 1851852) port map(clk, clk27Hz);
    m1_cos: cosine_lut port map(clk, m1_cos_in, m1_cos_out);
    m1_cos1: cos_lut port map(clk, m1_cos1_in, m1_cos1_out);
    m2_cos: cosine_lut port map(clk, m2_cos_in, m2_cos_out);
    m2_cos1: cos_lut port map(clk, m2_cos1_in, m2_cos1_out);
    comp_rand_gen: rand_gen port map(clk27Hz, rand_num);
    comp_rand_gen2: rand_gen port map(clk10Hz, rand_num2);
    
    
    
    
    
-- Task: BTN Controller
    btn_proc: process(btnL, btnR, btnU, btnD)
    begin
        if (rising_edge(clk50Hz)) then
            case state is
                when RUN =>
                    p_SPEED <= 4;
                when RUSH =>
                    p_SPEED <= 8;
                when others =>
                    p_SPEED <= 0;
                    sig_p1_y <= 300;
                    sig_p2_y <= 300;
            end case; 
        end if;
               
        if(rising_edge(clk50Hz) and (state = RUN or state = RUSH)) then
            if(btnU = '1') then
                if(sig_p1_y - p_SPEED >= TOP) then
                    sig_p1_y <= (sig_p1_y - p_SPEED);
                else
                    sig_p1_y <= TOP;
                end if;
            end if;
            if(btnD = '1') then
                if(sig_p1_y + p_SPEED + p_length/2 < bottom) then
                    sig_p1_y <= (sig_p1_y + p_SPEED);
                else
                    sig_p1_y <= (bottom - p_length/2 - p_SPEED);
                end if;
            end if;
            if(btnL = '1') then
                if(sig_p2_y - p_SPEED >= TOP) then
                    sig_p2_y <= (sig_p2_y - p_SPEED);
                else
                    sig_p2_y <= TOP;
                end if;
            end if;
            if(btnR = '1') then
                if(sig_p2_y + p_SPEED + p_length/2 < bottom) then
                    sig_p2_y <= (sig_p2_y + p_SPEED);
                else
                    sig_p2_y <= (bottom - p_length/2 - p_SPEED);
                end if;
            end if;
        end if;
    end process btn_proc;
    
    
    
    

    bullet_proc: process(clk50Hz) 
    begin
--        if rising_edge(clk27Hz) then
--            rand_num <= rand_num + 1;
--            if(rand_num + 1 > 10000) then
--                rand_num <= 0;
--            end if;
--        end if;
        if (rising_edge(clk50Hz)) then
            case state is
                when RUN =>
                    b_SPEED <= 12;
                when RUSH =>
                    b_SPEED <= 24;
                when others =>
                    b_SPEED <= 0;
                    sig_m1_x <= 0;
                    sig_m2_x <= 1024;
                    sig_p1b_x <= 0;
                    sig_p2b_x <= 1024;
                    sig_p1_score <= 0;
                    sig_p2_score <= 0;
                    
            end case;
        end if;
        
        
        if (rising_edge(clk50Hz) and (state = RUN or state = RUSH)) then
            if sig_p1_score >= 99 then
                sig_p1_score <= 0;
            end if;
            if sig_p2_score >= 99 then
                sig_p2_score <= 0;
            end if;
            
            if sig_p1b_x = sig_p1_x + 14 then
                sig_p1b_y <= sig_p1_y;
            end if;
            if sig_p2b_x = sig_p2_x - 14 then
                sig_p2b_y <= sig_p2_y;
            end if;
            
            -- Update player 1's bullet position
            if sig_p1b_x + b_SPEED <= right  then
                sig_p1b_x <= sig_p1b_x + b_SPEED;
            else
                sig_p1b_x <= sig_p1_x + 14; -- Reset the bullet position when it hits the end
            end if;
    
            -- Update player 2's bullet position
            if sig_p2b_x - b_SPEED >= left then
                sig_p2b_x <= sig_p2b_x - b_SPEED;
            else
                sig_p2b_x <= sig_p2_x - 14; -- Reset the bullet position when it hits the start
            end if;
            
            -- Update monster 1's position
            if  sig_m1_x - m_WIDTH/2 < RIGHT then
                if m1_rand mod 2 = 0 then
                    -- cos(x/2)^3 - cos x + rand
                    m1_cos1_in <= to_unsigned(((sig_m1_x * 256) / 1024), m1_cos1_in'length);
                    m1_cos_in <= to_unsigned((((sig_m1_x * 256) / 2) / 1024), m1_cos_in'length) ;
                    sig_m1_y <= ((to_integer(m1_cos_out) - to_integer(m1_cos1_out)) * 300 / 65536) + 300 - m1_rand;
                else
                    m1_cos1_in <= to_unsigned(((sig_m1_x * 256) / 1024), m1_cos1_in'length);
                    m1_cos_in <= to_unsigned((((sig_m1_x * 256) / 2) / 1024), m1_cos_in'length) ;
                    sig_m1_y <= 300-((to_integer(m1_cos_out) - to_integer(m1_cos1_out)) * 300 / 65536) + m1_rand;
                end if;
                sig_m1_x <= sig_m1_x + m_speed;
                
            else
                m1_rand <= to_integer(unsigned(rand_num)) mod 300;
                sig_m1_x <= 0 - m_WIDTH/2;
            end if;
            
            -- Update monster 2's position
            if  sig_m2_x + m_WIDTH/2 > LEFT then
                if m2_rand mod 2 = 0 then
                    -- cos(x/2)^3 - cos x + rand
                    m2_cos1_in <= to_unsigned((((sig_m2_x) * 256) / 1024), m2_cos1_in'length);
                    m2_cos_in <= to_unsigned((((((sig_m2_x) * 256) / 2) / 1024) + 128) mod 256, m2_cos_in'length) ;
                    sig_m2_y <= ((to_integer(m2_cos_out) - to_integer(m2_cos1_out)) * 300 / 65536) + 300 - m2_rand;
                else
                    m2_cos1_in <= to_unsigned((((sig_m2_x) * 256) / 1024), m2_cos1_in'length);
                    m2_cos_in <= to_unsigned((((((sig_m2_x) * 256) / 2) / 1024) + 128) mod 256, m2_cos_in'length) ;
                    sig_m2_y <= 300-((to_integer(m2_cos_out) - to_integer(m2_cos1_out)) * 300 / 65536) + m2_rand;
                end if;
                sig_m2_x <= sig_m2_x - m_speed;
                
            else
                m2_rand <= to_integer(unsigned(rand_num2)) mod 300;
                sig_m2_x <= 1024 + m_WIDTH/2;
            end if;
            
            -- Check hit
            if p2_eff_count < 1 then
                -- if hit enter show eff
                if (sig_p1b_x >= p2_baseline and sig_p1b_x <= sig_p2_x) and (sig_p1b_y >= sig_p2_y - p_length/2 and sig_p1b_y <= sig_p2_y + p_length/2) then
                    sig_p1b_x <= sig_p1_x + 14;
                    p2_eff_count <= p2_eff_count + 1;
                    sig_p1_score <= sig_p1_score + 2;
                end if;
            else
                -- eff process
                if p2_eff_count mod 2 = 0 then
                    sig_p2_x <= sig_p2_x - 10;
                else
                    sig_p2_x <= sig_p2_x + 10;
                end if;
                p2_eff_count <= p2_eff_count + 1;
                if p2_eff_count >= 10 then
                    sig_p2_x <= 924;
                    p2_eff_count <= 0;
                end if;
            end if;
            
            if p1_eff_count < 1 then
                if sig_p2b_x <= p1_baseline and sig_p2b_x >= sig_p1_x and (sig_p2b_y >= sig_p1_y - p_length/2 and sig_p2b_y <= sig_p1_y + p_length/2) then
                    sig_p2b_x <= sig_p2_x - 14;
                    p1_eff_count <= p1_eff_count + 1;
                    sig_p2_score <= sig_p2_score + 2; 
                end if;  
            else
                if p1_eff_count mod 2 = 0 then
                    sig_p1_x <= sig_p1_x + 10;
                else
                    sig_p1_x <= sig_p1_x - 10;
                end if;
                p1_eff_count <= p1_eff_count + 1;
                if p1_eff_count >= 10 then
                    sig_p1_x <= 100;
                    p1_eff_count <= 0;
                end if;
            end if;
            -- monster 1
            if m1_eff_count < 1 then
                if (sig_p2b_x <= sig_m1_x + m_WIDTH/2 and sig_p2b_x >= sig_m1_x)  
                    and (sig_p2b_y >= sig_m1_y - m_length/2 and sig_p2b_y <= sig_m1_y + m_length/2) then
                    sig_p2b_x <= sig_p2_x - 14;
                    m1_eff_count <= m1_eff_count + 1;
                    sig_p2_score <= sig_p2_score + 1; 
                end if;
            else
                if m1_eff_count mod 2 = 0 then
                    sig_m1_x <= sig_m1_x - 10;
                else
                    sig_m1_x <= sig_m1_x + 10;
                end if;
                m1_eff_count <= m1_eff_count + 1;
                if m1_eff_count >= 10 then
                    sig_m1_x <= 0;
                    m1_rand <= to_integer(unsigned(rand_num)) mod 300;
                    m1_eff_count <= 0;
                end if;
            end if;
            -- monster 2
            if m2_eff_count < 1 then
                if (sig_p1b_x >= sig_m2_x - m_WIDTH/2 and sig_p1b_x <= sig_m2_x) 
                    and (sig_p1b_y >= sig_m2_y - m_length/2 and sig_p1b_y <= sig_m2_y + m_length/2) then
                    sig_p1b_x <= sig_p1_x + 14;
                    m2_eff_count <= m2_eff_count + 1;
                    sig_p1_score <= sig_p1_score + 1; 
                end if;
            else
                if m2_eff_count mod 2 = 0 then
                    sig_m2_x <= sig_m2_x - 10;
                else
                    sig_m2_x <= sig_m2_x + 10;
                end if;
                m2_eff_count <= m2_eff_count + 1;
                if m2_eff_count >= 10 then
                    sig_m2_x <= RIGHT;
                    m2_rand <= to_integer(unsigned(rand_num2)) mod 300;
                    m2_eff_count <= 0;
                end if;
            end if;
            
            
        end if;
    end process bullet_proc;
    
    
    
    p1_x <= sig_p1_x;
    p1_y <= sig_p1_y;
    p2_x <= sig_p2_x;
    p2_y <= sig_p2_y;
    p1b_x <= sig_p1b_x;
    p1b_y <= sig_p1b_y;
    p2b_x <= sig_p2b_x;
    p2b_y <= sig_p2b_y;
    m1_x <= sig_m1_x;
    m1_y <= sig_m1_y;
    m2_x <= sig_m2_x;
    m2_y <= sig_m2_y;
    p1_score <= sig_p1_score;
    p2_score <= sig_p2_score;


end Behavioral;
