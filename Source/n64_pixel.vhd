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
	clock_count: out std_logic_vector(1 downto 0);
	
	sharp_en_n: in std_logic;
	sharp_odd_n: in std_logic
);
end n64_pixel;

architecture behavioral of n64_pixel is

constant CYCLE_00_RED: std_logic_vector(1 downto 0) := "00";
constant CYCLE_01_GREEN: std_logic_vector(1 downto 0) := "01";
constant CYCLE_10_BLUE: std_logic_vector(1 downto 0) := "10";
constant CYCLE_11_SYNC: std_logic_vector(1 downto 0) := "11";

signal red_cap: std_logic_vector(6 downto 0);
signal green_cap: std_logic_vector(6 downto 0);
signal blue_cap: std_logic_vector(6 downto 0);

signal red_store: std_logic_vector(6 downto 0);
signal green_store: std_logic_vector(6 downto 0);
signal blue_store: std_logic_vector(6 downto 0);

signal csync_n_cap: std_logic;
signal hsync_n_cap: std_logic;
signal clamp_n_cap: std_logic;
signal vsync_n_cap: std_logic;
signal vsync_n_prev: std_logic;

signal red_final: std_logic_vector(6 downto 0);
signal green_final: std_logic_vector(6 downto 0);
signal blue_final: std_logic_vector(6 downto 0);

signal red_prev: std_logic_vector(6 downto 0);
signal green_prev: std_logic_vector(6 downto 0);
signal blue_prev: std_logic_vector(6 downto 0);

signal red_prev2: std_logic_vector(6 downto 0);
signal green_prev2: std_logic_vector(6 downto 0);
signal blue_prev2: std_logic_vector(6 downto 0);

signal cycle_count: std_logic_vector(1 downto 0);

signal px_osc: std_logic := '0';

-- Deblur validation registers
signal mix_r: std_logic_vector(7 downto 0);
signal cmp_r: std_logic_vector(7 downto 0);
signal mix_g: std_logic_vector(7 downto 0);
signal cmp_g: std_logic_vector(7 downto 0);
signal mix_b: std_logic_vector(7 downto 0);
signal cmp_b: std_logic_vector(7 downto 0);

constant DEBLUR_DETECT_THRESH: integer := 5;
constant DEBLUR_CUTOFF: std_logic_vector(7 downto 0) := X"18";

signal deblur_even_invalid: std_logic := '0';
signal deblur_odd_invalid: std_logic := '0';
signal deblur_even_kill_counter: std_logic_vector(3 downto 0) := "0000";
signal deblur_odd_kill_counter: std_logic_vector(3 downto 0) := "0000";
signal deblur_kill: std_logic := '0';
signal deblur_select_odd: std_logic := '0';

signal x_pixel_count: std_logic_vector(9 downto 0) := "0000000000";

begin
	cycle_step: process(n64_clock)
	begin
		if (falling_edge(n64_clock)) then
			if (n64_dsync_n = '0') then
				cycle_count <= CYCLE_00_RED;
			else
				cycle_count <= cycle_count + 1;
			end if;
		end if;
	end process;
	
	cap_data: process(n64_clock)
	begin
		if (falling_edge(n64_clock)) then
			if (cycle_count = CYCLE_00_RED) then
				red_cap <= n64_data;
			elsif (cycle_count = CYCLE_01_GREEN) then
				green_cap <= n64_data;
			elsif (cycle_count = CYCLE_10_BLUE) then
				blue_cap <= n64_data;	
			else
				-- Toggle odd/even pixel counter, resetting at end of line
				if (n64_data(1) = '0') then
					px_osc <= '0';
				elsif (px_osc = '1') then
					px_osc <= '0';
				else
					px_osc <= '1';
				end if;
				
				-- Sharpening enabled
				if (sharp_en_n = '0') then
					-- Only capture on every other pixel, matching the intended column
					if ((deblur_select_odd xor sharp_odd_n) /= px_osc) then
						red_store <= red_cap;
						green_store <= green_cap;
						blue_store <= blue_cap;
					end if;
				end if;	
						
				red_final <= red_cap;
				green_final <= green_cap;
				blue_final <= blue_cap;
				
				csync_n_cap <= n64_data(0);
				hsync_n_cap <= n64_data(1);
				clamp_n_cap <= n64_data(2);
				vsync_n_cap <= n64_data(3);
				
				if (n64_data(1) = '0') then
					x_pixel_count <= "0000000000";
				else
					x_pixel_count <= x_pixel_count + 1;
				end if;
			end if;
		end if;
	end process;
	
	deblur_validator: process(n64_clock)
	begin
		if (falling_edge(n64_clock)) then
		
			-- Decrement kill counter at start of vsync
			vsync_n_prev <= vsync_n_cap;
			if (deblur_even_invalid = '1') then
				deblur_even_kill_counter <= "1111";
			elsif (vsync_n_prev /= vsync_n_cap and vsync_n_cap = '0') then
				if (deblur_even_kill_counter /= "0000") then
					deblur_even_kill_counter <= deblur_even_kill_counter - 1;
				end if;
			end if;
			if (deblur_odd_invalid = '1') then
				deblur_odd_kill_counter <= "1111";
			elsif (vsync_n_prev /= vsync_n_cap and vsync_n_cap = '0') then
				if (deblur_odd_kill_counter /= "0000") then
					deblur_odd_kill_counter <= deblur_odd_kill_counter - 1;
				end if;
			end if;

			if (cycle_count = CYCLE_00_RED) then
				-- Build potential mixed pixel
				
				mix_r <= ('0' & red_prev2) + ('0' & red_final);
				cmp_r <= ('0' & red_prev) + ('0' & red_prev);
				mix_g <= ('0' & green_prev2) + ('0' & green_final);
				cmp_g <= ('0' & green_prev) + ('0' & green_prev);
				mix_b <= ('0' & blue_prev2) + ('0' & blue_final);
				cmp_b <= ('0' & blue_prev) + ('0' & blue_prev);
			elsif (cycle_count = CYCLE_01_GREEN) then
				red_prev2 <= red_prev;	
				green_prev2 <= green_prev;	
				blue_prev2 <= blue_prev;
				
				-- Filter out noise in black border data that pops up a lot
				-- in a select few games
			elsif (cycle_count = CYCLE_10_BLUE) then
				red_prev <= red_final;	
				green_prev <= green_final;	
				blue_prev <= blue_final;
			else
				-- If we are on a "definitely valid pixel boundary"...
					-- If the current pixel + the second-to-last pixel is NOT the last pixel...
				if (x_pixel_count > 96 and vsync_n_cap = '1' and hsync_n_cap = '1' and clamp_n_cap = '1'
					and (mix_r > DEBLUR_CUTOFF) and (mix_g > DEBLUR_CUTOFF) and (mix_b > DEBLUR_CUTOFF) 
					and not (mix_r > cmp_r - DEBLUR_DETECT_THRESH or mix_r < cmp_r + DEBLUR_DETECT_THRESH)
					and not (mix_g > cmp_g - DEBLUR_DETECT_THRESH or mix_g < cmp_g + DEBLUR_DETECT_THRESH)
					and not (mix_b > cmp_b - DEBLUR_DETECT_THRESH or mix_b < cmp_b + DEBLUR_DETECT_THRESH)) then
					if (sharp_odd_n = px_osc) then
						deblur_even_invalid <= '1';
					else
						deblur_odd_invalid <= '1';
					end if;
				else
					if (sharp_odd_n = px_osc) then
						deblur_even_invalid <= '0';
					else
						deblur_odd_invalid <= '0';
					end if;
				end if;
			end if;
			
			-- Select phase based on heuristics
			if (deblur_even_kill_counter /= "0000") then
				if (deblur_odd_kill_counter /= "0000") then
					deblur_kill <= '1';
				else
					deblur_kill <= '0';
					deblur_select_odd <= '1';
				end if;
			else
				deblur_kill <= '0';
				deblur_select_odd <= '0';
			end if;
		end if;
	end process;
	
	set_outputs: process(n64_clock)
	begin
		if (falling_edge(n64_clock)) then
			if (sharp_en_n = '0' and deblur_kill = '0') then
				red_out <= red_store;
				green_out <= green_store;
				blue_out <= blue_store;
			else
				red_out <= red_final;
				green_out <= green_final;
				blue_out <= blue_final;
			end if;
			csync_n_out <= csync_n_cap;
			hsync_n_out <= hsync_n_cap;
			clamp_n_out <= clamp_n_cap;
			vsync_n_out <= vsync_n_cap;
			clock_count <= cycle_count;
		end if;
	end process;
end behavioral;

