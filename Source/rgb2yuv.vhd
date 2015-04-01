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
			y <= (("00" & r(7 downto 2)) + ('0' & g(7 downto 1)) + ("0000" & b(7 downto 4)) + ("00000" & b(7 downto 5)) + 16);
			u <= (128 + (("00" & r(7 downto 2)) + ("000" & r(7 downto 3)) + ("0000" & r(7 downto 4))) - (("00" & g(7 downto 2)) + ("000" & g(7 downto 3))) - ("0000" & b(7 downto 4)));
			v <= (128 - ("000" & r(7 downto 3)) - (("00" & g(7 downto 2)) + ("000" & g(7 downto 3))) + (("00" & b(7 downto 2)) + ("000" & b(7 downto 3)) + ("0000" & b(7 downto 4))));
		else
			y <= r;
			u <= g;
			v <= b;
		end if;
	end process;
end behavioral;