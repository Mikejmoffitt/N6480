-- Rough RGB to YUV Conversion
-- Michael Moffitt 2015
-- mikejmoffitt.com
-- Please use as you wish, but credit me for the implementation
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity rgb2yuv is
port (
	r: in std_logic_vector(7 downto 0);
	g: in std_logic_vector(7 downto 0);
	b: in std_logic_vector(7 downto 0);
	
	y: out std_logic_vector(7 downto 0);
	u: out std_logic_vector(7 downto 0); -- AKA Cr
	v: out std_logic_vector(7 downto 0); -- AKA Cb
	
	sw_en: in std_logic -- Active high
	
	);
	
end entity;

architecture behavioral of rgb2yuv is 
begin
	make_yuv: process(r, g, b, sw_en)
	begin
		if (sw_en = '1') then
			y <= '0' & (r(7 downto 2) + g(7 downto 1) + b(7 downto 4) + b(7 downto 5) + 16);
			u <= "00" & (128 + (r(7 downto 2) + r(7 downto 3) + r(7 downto 4)) - (g(7 downto 2) + g(7 downto 3)) - b(7 downto 4));
			v <= "00" & (128 - r(7 downto 3) - (g(7 downto 2) + g(7 downto 3)) + (b(7 downto 2) + b(7 downto 3) + b(7 downto 4)));
		else
			y <= "00000000";
			u <= "00000000";
			v <= "00000000";
		end if;
	end process;
end behavioral;