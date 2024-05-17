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
package state_pkg is
    type t_state is (IDLE, RUN, RUSH, DONE);
    attribute enum_encoding : string;
    attribute enum_encoding of t_state : type is "0001 0010 0100 1000";
end package state_pkg;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std .all;
use work.state_pkg.all;

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
        sel: buffer std_logic := '0';
        ssd: out std_logic_vector (6 downto 0);
        hsync, vsync: out std_logic;
        red, green, blue: out std_logic_vector(3 downto 0)
    );
end AirFighter;

architecture airfighter_arch of AirFighter is
    -- signal clk50MHz: std_logic;
    signal clk1Hz: std_logic;
    
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
    signal sig_m2_x: integer := 0;
    signal sig_m2_y: integer := 0;
    signal sig_p1_score: integer := 0;
    signal sig_p2_score: integer := 0;
    
    signal countdown: integer := 60;
    signal data_in: std_logic_vector(7 downto 0);
    
    signal state: t_state := IDLE;
    
    component clock_divider is
    generic (N: integer);
    port( 
        clk: in std_logic;
        clk_out: out std_logic
    );
    end component;
    
    component ssd_ctrl is
    port(
        clk: in std_logic;
        data_in: in std_logic_vector(7 downto 0);
        sel: buffer std_logic := '0';
        ssd: out std_logic_vector (6 downto 0)
    );
    end component;
    
    component player_ctrl is
    port(
        state: in t_state;
        clk, btnL, btnR, btnU, btnD: in std_logic;
        p1_x, p1_y, p2_x, p2_y: out integer;
        p1b_x, p1b_y, p2b_x, p2b_y: out integer;
        m1_x, m1_y, m2_x, m2_y: out integer;
        p1_score, p2_score: out integer
    );
    end component;
    
    component player_display is
    port(
        state: in t_state;
        clk: in std_logic;
        hsync, vsync: out std_logic;
        red, green, blue: out std_logic_vector(3 downto 0);
        p1_x, p1_y, p2_x, p2_y: in integer;
        p1b_x, p1b_y, p2b_x, p2b_y: in integer;
        m1_x, m1_y, m2_x, m2_y: in integer;
        p1_score, p2_score: in integer
    );
    end component;
    

begin
    -- 2. generate 50MHz clock
    --comp_clk50MHz: clock_divider generic map(N => 1) port map(clk, clk50MHz);
    comp_clk1Hz: clock_divider generic map(N => 50000000) port map(clk, clk1Hz);
    comp_ssdctrl: ssd_ctrl port map(clk, data_in, sel, ssd);
    FSN_Proc: process(clk1Hz, reset)
    begin
        if (rising_edge(clk1Hz)) then
            case state is
            when IDLE   => -- do something
                countdown <= 60;
                if(reset = '1') then
                    state <= RUN;
                end if;
            when RUN    =>
                countdown <= countdown - 1;
                data_in(7 downto 4) <= std_logic_vector(TO_UNSIGNED(countdown/10, 4));
                data_in(3 downto 0) <= std_logic_vector(TO_UNSIGNED(countdown mod 10, 4));
                if (countdown <= 20) then
                    state <= RUSH;
                end if;
            when RUSH   =>
                countdown <= countdown - 1;
                data_in(7 downto 4) <= std_logic_vector(TO_UNSIGNED(countdown/10, 4));
                data_in(3 downto 0) <= std_logic_vector(TO_UNSIGNED(countdown mod 10, 4));
                if (sig_p1_score >= 100 or sig_p2_score >= 100) then
                    state <= DONE;
                end if;
                if (countdown <= 0) then
                    countdown <= 20;
                    state <= DONE;
                end if;
            when DONE   =>
                countdown <= countdown - 1;
                data_in(7 downto 4) <= std_logic_vector(TO_UNSIGNED(countdown/10, 4));
                data_in(3 downto 0) <= std_logic_vector(TO_UNSIGNED(countdown mod 10, 4));
                if (countdown <= 0) then
                    state <= IDLE;
                end if;
                if (reset = '1') then
                    state <= IDLE;
                end if;
            end case;
        end if;
    end process FSN_Proc;
        
    --when RUN  => -- do something
        --state <= RUN;
    --when RUSH    => -- do something
        --state <= DONE;
    --when DONE   => -- do something
        --state <= IDLE;
    
    control: player_ctrl port map (
        state, clk, btnL, btnR, btnU, btnD,
        sig_p1_x, sig_p1_y, sig_p2_x, sig_p2_y,
        sig_p1b_x, sig_p1b_y, sig_p2b_x, sig_p2b_y,
        sig_m1_x, sig_m1_y, sig_m2_x, sig_m2_y,
        sig_p1_score, sig_p2_score
    );
    -- Task: BTN Controller
    display: player_display port map (
        state, clk,
        hsync, vsync,
        red, green, blue,
        sig_p1_x, sig_p1_y, sig_p2_x, sig_p2_y,
        sig_p1b_x, sig_p1b_y, sig_p2b_x, sig_p2b_y,
        sig_m1_x, sig_m1_y, sig_m2_x, sig_m2_y,
        sig_p1_score, sig_p2_score
    );
   
            
            
            
end airfighter_arch;
