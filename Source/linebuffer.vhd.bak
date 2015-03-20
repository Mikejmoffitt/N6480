-------------------------------------------------------------------------------
-- N6480 - Nintendo 64 480p line doubler                                     --
-- Michael Moffitt 2015                                                      --
-- https://github.com/Mikejmoffitt/N6480                                     --
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity linebuffer is
generic (line_len: integer := 774;
		 pixel_depth: integer := 21);
port (
	clk: in std_logic; -- A 12MHz clock (use Neo-Geo CPU clock)
	enable: in std_logic; -- set to allow shifting on each clock, clear to hold
	buffer_in : in std_logic_vector((pixel_depth - 1) downto 0);
	buffer_out: out std_logic_vector((pixel_depth - 1) downto 0)
);
end linebuffer;

architecture behavioral of linebuffer is

subtype pixel is std_logic_vector((pixel_depth - 1) downto 0);
type buffer_arr is array ((line_len - 1) downto 0) of pixel;

signal line_buffer: buffer_arr;

begin
	neo_buffer: process (clk,line_buffer)
	begin
		if (rising_edge(clk)) then
			if (enable = '1') then
				-- Shift out the line
				line_buffer((line_len - 1) downto 1) <= line_buffer((line_len - 2) downto 0);
				-- Bring in the new element
				line_buffer(0) <= buffer_in;
			end if;
		end if;
		
	buffer_out <= line_buffer(line_len - 1);
	end process;
end behavioral;
