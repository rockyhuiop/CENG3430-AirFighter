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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity player_ctrl is
    Port (
        clk, btnL, btnR, btnU, btnD: in std_logic;
        p1_x, p1_y, p2_x, p2_y: out integer;
        p1b_x, p1b_y, p2b_x, p2b_y: out integer
    );
end player_ctrl;

architecture Behavioral of player_ctrl is
    signal sig_p1_x: integer := 100;
    signal sig_p1_y: integer := 300;
    signal sig_p2_x: integer := 924;
    signal sig_p2_y: integer := 300;
    signal sig_p1b_x: integer := 100;
    signal sig_p1b_y: integer := 300;
    signal sig_p2b_x: integer := 924;
    signal sig_p2b_y: integer := 300;
    
    signal p1_is_hit: boolean := false;
    signal p2_is_hit: boolean := true;
    signal p1_eff_count: integer := 0;
    signal p2_eff_count: integer := 0;
    
    signal clk50MHz: std_logic;
    signal clk50Hz: std_logic;
    signal clk10Hz: std_logic;
    
    component clock_divider is
    generic (N: integer);
    port( 
        clk: in std_logic;
        clk_out: out std_logic
    );
    end component;
   
    constant p1_baseline : integer := (100 + 10);
    constant p2_baseline : integer := (924 - 10); 
    constant TOP : integer := 0;
    constant BOTTOM : integer := 600;
    constant LEFT : integer := 0;
    constant RIGHT : integer := 1024;
    constant p_LENGTH : integer := 100;
    constant p_WIDTH : integer := 20;
    constant b_SPEED: integer := 10; -- 50 pixels per second
    constant b_LENGTH: integer := 28;
    constant b_WIDTH: integer := 12;
    
    
begin
    comp_clk50MHz: clock_divider generic map(N => 1) port map(clk, clk50MHz);
    comp_clk10Hz: clock_divider generic map(N => 5000000) port map(clk, clk10Hz);
    comp_clk50Hz: clock_divider generic map(N => 1000000) port map(clk, clk50Hz);
    
    
    
-- Task: BTN Controller
    btn_proc: process(btnL, btnR, btnU, btnD)
    begin
        if(rising_edge(clk10Hz)) then
            if(btnU = '1') then
                if(sig_p1_y - 10 >= TOP) then
                    sig_p1_y <= (sig_p1_y - 10);
                else
                    sig_p1_y <= TOP;
                end if;
            end if;
            if(btnD = '1') then
                if(sig_p1_y + 10 + p_length/2 < bottom) then
                    sig_p1_y <= (sig_p1_y + 10);
                else
                    sig_p1_y <= (bottom - p_length/2 - 10);
                end if;
            end if;
            if(btnL = '1') then
                if(sig_p2_y - 10 >= TOP) then
                    sig_p2_y <= (sig_p2_y - 10);
                else
                    sig_p2_y <= TOP;
                end if;
            end if;
            if(btnR = '1') then
                if(sig_p2_y + 10 + p_length/2 < bottom) then
                    sig_p2_y <= (sig_p2_y + 10);
                else
                    sig_p2_y <= (bottom - p_length/2 - 10);
                end if;
            end if;
        end if;
    end process btn_proc;

    bullet_proc: process(clk50Hz)
    begin
        if rising_edge(clk50Hz) then
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
            
            -- Check hit
            if sig_p1b_x >= p2_baseline and (sig_p1b_y >= sig_p2_y - p_length/2 and sig_p1b_y <= sig_p2_y + p_length/2) then
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
            if sig_p2b_x <= p1_baseline and (sig_p2b_y >= sig_p1_y - p_length/2 and sig_p2b_y <= sig_p1_y + p_length/2) then
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


end Behavioral;
