----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/20/2024 02:40:48 PM
-- Design Name: 
-- Module Name: vga_driver - Behavioral
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

entity AirFighter is
    Port ( 
        clk, reset, btnL, btnR, btnU, btnD: in std_logic;
        hsync, vsync: out std_logic;
        red, green, blue: out std_logic_vector(3 downto 0)
    );
end AirFighter;

architecture airfighter_arch of AirFighter is
    signal clk50MHz: std_logic;
    signal clk10Hz: std_logic;
    
    signal sig_p1_x: integer := 0;
    signal sig_p1_y: integer := 0;
    signal sig_p2_x: integer := 0;
    signal sig_p2_y: integer := 0;
    signal sig_p1b_x: integer := 0;
    signal sig_p1b_y: integer := 0;
    signal sig_p2b_x: integer := 0;
    signal sig_p2b_y: integer := 0;
    signal sig_m1_x: integer := 0;
    signal sig_m1_y: integer := 0;
    
    component clock_divider is
    generic (N: integer);
    port( 
        clk: in std_logic;
        clk_out: out std_logic
    );
    end component;
    
    component player_ctrl is
    port(
        clk, btnL, btnR, btnU, btnD: in std_logic;
        p1_x, p1_y, p2_x, p2_y: out integer;
        p1b_x, p1b_y, p2b_x, p2b_y: out integer;
        m1_x, m1_y: out integer
    );
    end component;
    
    component player_display is
    port(
        clk: in std_logic;
        hsync, vsync: out std_logic;
        red, green, blue: out std_logic_vector(3 downto 0);
        p1_x, p1_y, p2_x, p2_y: in integer;
        p1b_x, p1b_y, p2b_x, p2b_y: in integer;
        m1_x, m1_y: in integer
    );
    end component;
    

begin
    -- 2. generate 50MHz clock
    --comp_clk50MHz: clock_divider generic map(N => 1) port map(clk, clk50MHz);
    --comp_clk10Hz: clock_divider generic map(N => 5000000) port map(clk, clk10Hz);
    
    control: player_ctrl port map (
        clk, btnL, btnR, btnU, btnD,
        sig_p1_x, sig_p1_y, sig_p2_x, sig_p2_y,
        sig_p1b_x, sig_p1b_y, sig_p2b_x, sig_p2b_y,
        sig_m1_x, sig_m1_y
    );
    -- Task: BTN Controller
    display: player_display port map (
        clk,
        hsync, vsync,
        red, green, blue,
        sig_p1_x, sig_p1_y, sig_p2_x, sig_p2_y,
        sig_p1b_x, sig_p1b_y, sig_p2b_x, sig_p2b_y,
        sig_m1_x, sig_m1_y
    );
   
            
            
            
end airfighter_arch;
