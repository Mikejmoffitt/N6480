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

-- Yr: ("00" & r(7 downto 2)) + ("00000" & r(7 downto 5)) + ("000000" & r(7 downto 6)) -- 0.297 ~ 0.299
-- Yg: ('0' & g(7 downto 1)) + ("0000" & g(7 downto 4)) + ("000000" & g(7 downto 6)) -- 0.578 ~ 0.587
-- Yb: ("000" & b(7 downto 3)) -- 0.125 ~ 0.114

-- Pbr: - (("000" & r(7 downto 3)) + ("00000" & r(7 downto 5)) + ("0000000" & r(7))) -- 0.164 ~ 0.169
-- Pbg: - (("00" & g(7 downto 2)) + ("0000" & g(7 downto 4)) + ("00000" & g(7 downto 5))) -- 0.344 ~ 0.331
-- Pbb: ('0' & b(7 downto 1)) -- 0.5 ~ 0.5

-- Prr: ('0' & r(7 downto 1)) -- 0.5 ~ 0.5
-- Prg: - (("00" & g(7 downto 2)) + ("000" & g(7 downto 3)) + ("00000" & g(7 downto 5)) + ("000000" & g(7 downto 6))) -- 0.422 ~ 0.419
-- Prb: - (("0000" & b(7 downto 4)) + ("000000" & b(7 downto 6))) -- 0.078 ~ 0.081


architecture behavioral of rgb2yuv is 
begin
	make_yuv: process(r, g, b, sw_en)
	begin
		if (sw_en = '1') then
			y <= ("00" & r(7 downto 2)) + ("00000" & r(7 downto 5)) + ("000000" & r(7 downto 6)) + ('0' & g(7 downto 1)) + ("0000" & g(7 downto 4)) + ("000000" & g(7 downto 6)) + ("000" & b(7 downto 3));
			u <= 128 + ('0' & r(7 downto 1)) - (("00" & g(7 downto 2)) + ("000" & g(7 downto 3)) + ("00000" & g(7 downto 5)) + ("000000" & g(7 downto 6)))- (("0000" & b(7 downto 4)) + ("000000" & b(7 downto 6)));
			v <= 128 + ('0' & b(7 downto 1))- (("00" & g(7 downto 2)) + ("0000" & g(7 downto 4)) + ("00000" & g(7 downto 5)))- (("000" & r(7 downto 3)) + ("00000" & r(7 downto 5)) + ("0000000" & r(7)));
		else
			y <= r;
			u <= g;
			v <= b;
		end if;
	end process;
end behavioral;