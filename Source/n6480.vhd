-------------------------------------------------------------------------------
-- N6480 - Nintendo 64 480p line doubler                                     --
-- Michael Moffitt 2015                                                      --
-- https://github.com/Mikejmoffitt/N6480                                     --
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity n6480 is
port ( 
	n64_data: in  std_logic_vector (6 downto 0);
	n64_clock: in  std_logic;
	n64_dsync_n: in  std_logic;
	
	vga_red: out std_logic_vector(6 downto 0);
	vga_green: out std_logic_vector(6 downto 0);
	vga_blue: out std_logic_vector(6 downto 0);
	vga_hsync: out std_logic;
	vga_vsync: out std_logic;
	vga_blank: out std_logic
	);
end n6480;

architecture behavioral of n6480 is

constant U16_ZERO: std_logic_vector(15 downto 0) := "0000000000000000";

signal n64_red: std_logic_vector(6 downto 0);
signal n64_green: std_logic_vector(6 downto 0);
signal n64_blue: std_logic_vector(6 downto 0);
signal n64_csync_n: std_logic;
signal n64_hsync_n: std_logic;
signal n64_clamp_n: std_logic;
signal n64_vsync_n: std_logic;

-- Line length in clocks (50Mhz clock means 4 N64 pixels/clock, or 2 on VGA
constant VGA_LINE_LEN: integer := 1600;
constant N64_LINE_LEN: integer := VGA_LINE_LEN * 2;
constant NUM_LINES: integer := 525;

constant VGA_HSYNC_START: integer := 0;
constant VGA_HSYNC_END: integer := 192;
constant VGA_VSYNC_START: integer := 0;
constant VGA_VSYNC_END: integer := 2;

signal buffer_sel: std_logic; -- 0 for buffer A, 1 for buffer B (readout)

signal n64_px_count: std_logic_vector(15 downto 0) := U16_ZERO;
signal vga_px_count: std_logic_vector(15 downto 0) := U16_ZERO;
signal line_count: std_logic_vector(15 downto 0) := U16_ZERO;
signal clock_count: std_logic_vector(1 downto 0) := "00";

begin
	-- VHDL generated from Tim Worthington's N64 RGB DAC project
	-- Used to deserialize the N64 pixel bus into values for a pixel.
	-- Values are valid on the rising edge of the first clock out of four.
		
	vga_red <= "0000000";
	vga_green <= n64_red(6 downto 0);
	vga_blue <= "0000000";
	
	rgb_decoder: entity work.n64_pixel(behavioral) port map (
		n64_data, n64_clock, n64_dsync_n, n64_red, n64_green, n64_blue,
		n64_csync_n, n64_hsync_n, n64_clamp_n, n64_vsync_n);
		
	-- Increments the clock counter, resetting to 00 if the dsync line is low.
	n64_clock_count: process(n64_clock)
	begin
		if (falling_edge(n64_clock)) then
			if (n64_dsync_n = '0') then
				clock_count <= "00";
			else
				clock_count <= clock_count + 1;
			end if;
		end if;
	end process;
	
	vga_pixel_counter: process(n64_clock)
	begin
		if (falling_edge(n64_clock)) then
			if (vga_px_count = VGA_LINE_LEN) then
				vga_px_count <= U16_ZERO;
				if (line_count = NUM_LINES) then
					line_count <= U16_ZERO;
				else
					line_count <= line_count + 1;
				end if;
			else
				vga_px_count <= vga_px_count + 1;
			end if;
		end if;
	end process;
	
	n64_pixel_counter: process(n64_clock)
	begin
		if (falling_edge(n64_clock)) then
			--if (n64_vsync_n = '0') then
			--	px_count <= U16_ZERO;
			--	line_count <= U16_ZERO;
			if (n64_px_count = N64_LINE_LEN) then
				n64_px_count <= U16_ZERO;
			else
				n64_px_count <= n64_px_count + 1;
			end if;
		end if;
	end process;
	
	vga_vsync_proc: process(n64_clock)
	begin
		vga_vsync <= not n64_vsync_n;
--		if (falling_edge(n64_clock)) then
--			if (line_count >= VGA_VSYNC_START and line_count < VGA_VSYNC_END) then
--				vga_vsync <= '0';
--			else
--				vga_vsync <= '1';
--			end if;
--		end if;
	end process;
	
	vga_hsync_proc: process(n64_clock)
	begin	
		vga_hsync <= n64_csync_n;
--		if (falling_edge(n64_clock)) then
--			if (vga_px_count >= VGA_HSYNC_START and vga_px_count < VGA_HSYNC_END) then
--				vga_hsync <= '0';
--			else
--				vga_hsync <= '1';
--			end if;
--		end if;
	end process;

end behavioral;

