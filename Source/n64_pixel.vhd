-------------------------------------------------------------------------------
-- N6480 - Nintendo 64 480p line doubler                                     --
-- Michael Moffitt 2015                                                      --
-- https://github.com/Mikejmoffitt/N6480                                     --
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity n64_pixel is
port (
	n64_data: in std_logic_vector(6 downto 0);
	n64_clock: in std_logic;
	n64_dsync_n: in std_logic;
	
	red_out: out std_logic_vector(6 downto 0);
	green_out: out std_logic_vector(6 downto 0);
	blue_out: out std_logic_vector(6 downto 0);
	csync_n_out: out std_logic;
	hsync_n_out: out std_logic;
	clamp_n_out: out std_logic;
	vsync_n_out: out std_logic;
	clock_count: out std_logic_vector(1 downto 0)
);
end n64_pixel;

architecture behavioral of n64_pixel is

signal red_cap: std_logic_vector(6 downto 0);
signal green_cap: std_logic_vector(6 downto 0);
signal blue_cap: std_logic_vector(6 downto 0);
signal csync_n_cap: std_logic;
signal hsync_n_cap: std_logic;
signal clamp_n_cap: std_logic;
signal vsync_n_cap: std_logic;

signal red_final: std_logic_vector(6 downto 0);
signal green_final: std_logic_vector(6 downto 0);
signal blue_final: std_logic_vector(6 downto 0);

signal cycle_count: std_logic_vector(1 downto 0);

begin
	cycle_step: process(n64_clock)
	begin
		if (rising_edge(n64_clock)) then
			if (n64_dsync_n = '0') then
				cycle_count <= "00";
			else
				cycle_count <= cycle_count + 1;
			end if;
		end if;
	end process;
	
	cap_data: process(n64_clock)
	begin
		if (rising_edge(n64_clock)) then
			if (cycle_count = "00") then
				red_cap <= n64_data;
			elsif (cycle_count = "01") then
				green_cap <= n64_data;
			elsif (cycle_count = "10") then
				blue_cap <= n64_data;
			else
				red_final <= red_cap;
				green_final <= green_cap;
				blue_final <= blue_cap;
				csync_n_cap <= n64_data(0);
				hsync_n_cap <= n64_data(1);
				clamp_n_cap <= n64_data(2);
				vsync_n_cap <= n64_data(3);
			end if;
		end if;
	end process;
	
	set_outputs: process(n64_clock)
	begin
		if (rising_edge(n64_clock)) then
			red_out <= red_final;
			green_out <= green_final;
			blue_out <= blue_final;
			csync_n_out <= csync_n_cap;
			hsync_n_out <= hsync_n_cap;
			clamp_n_out <= clamp_n_cap;
			vsync_n_out <= vsync_n_cap;
			clock_count <= cycle_count;
		end if;
	end process;
end behavioral;

