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
	vga_blank: out std_logic;
	
	led: out std_logic_vector(3 downto 0);
	button: in std_logic_vector(1 downto 0)
	);
end n6480;

architecture behavioral of n6480 is


constant N64_PIXEL_LEN: integer := 18;

-- What a weird number!
constant N64_PIXELS_PER_LINE: integer := 774;

-- Line length in clocks (50Mhz clock means 4 N64 pixels/clock, or 2 on VGA
constant N64_LINE_LEN: integer := N64_PIXELS_PER_LINE * 4;
constant VGA_LINE_LEN: integer := N64_PIXELS_PER_LINE * 2;
constant NUM_LINES: integer := 262;

constant VGA_HSYNC_START: integer := 0;
constant VGA_HSYNC_END: integer := 192;
constant VGA_VSYNC_START: integer := 0;
constant VGA_VSYNC_END: integer := 2;
constant U16_ZERO: std_logic_vector(15 downto 0) := "0000000000000000";

-- Deserialized pixel data, ready to read
signal n64_red: std_logic_vector(6 downto 0);
signal n64_green: std_logic_vector(6 downto 0);
signal n64_blue: std_logic_vector(6 downto 0);
signal n64_csync_n: std_logic;
signal n64_hsync_n: std_logic;
signal n64_clamp_n: std_logic;
signal n64_vsync_n: std_logic;

-- Line buffer selection
signal buffer_in_a: std_logic_vector((N64_PIXEL_LEN - 1) downto 0);
signal buffer_in_b: std_logic_vector((N64_PIXEL_LEN - 1) downto 0);
signal buffer_out_a: std_logic_vector((N64_PIXEL_LEN - 1) downto 0);
signal buffer_out_b: std_logic_vector((N64_PIXEL_LEN - 1) downto 0);
signal buffer_en_a: std_logic;
signal buffer_en_b: std_logic;
signal buffer_sel: std_logic; -- 0 for buffer A, 1 for buffer B (capture)
-- Synchronization information
signal n64_px_count: std_logic_vector(15 downto 0) := U16_ZERO;
signal vga_px_count: std_logic_vector(15 downto 0) := U16_ZERO;
signal line_count: std_logic_vector(15 downto 0) := U16_ZERO;
signal clock_count: std_logic_vector(1 downto 0) := "00";

-- For assigning from the buffers
signal out_red: std_logic_vector(6 downto 0);
signal out_green: std_logic_vector(6 downto 0);
signal out_blue: std_logic_vector(6 downto 0);

begin
	-- Used to deserialize the N64 pixel bus into values for a pixel.
	-- Values are valid on the rising edge of the first clock out of four.		
	rgb_decoder: entity work.n64_pixel(behavioral) port map (
		n64_data, n64_clock, n64_dsync_n, n64_red, n64_green, n64_blue,
		n64_csync_n, n64_hsync_n, n64_clamp_n, n64_vsync_n, clock_count);
		
	led <= clock_count & '0' & n64_vsync_n;
	
	-- Both alternating line buffers
	buffer_a: entity work.linebuffer(behavioral) 
		generic map (line_len => N64_PIXELS_PER_LINE - 1, pixel_depth => N64_PIXEL_LEN)
		port map (n64_clock, buffer_en_a, buffer_in_a, buffer_out_a);
	
	buffer_b: entity work.linebuffer(behavioral) 
		generic map (line_len => N64_PIXELS_PER_LINE - 1, pixel_depth => N64_PIXEL_LEN)
		port map (n64_clock, buffer_en_b, buffer_in_b, buffer_out_b);
	
	select_buffer_output: process(n64_clock)
	begin
		if (falling_edge(n64_clock)) then
			if (buffer_sel = '1') then
				out_red <= buffer_out_a(17 downto 12) & '0';
				out_green <= buffer_out_a(11 downto 6) & '0';
				out_blue <= buffer_out_a(5 downto 0) & '0';
			else
				out_red <= buffer_out_b(17 downto 12) & '0';
				out_green <= buffer_out_b(11 downto 6) & '0';
				out_blue <= buffer_out_b(5 downto 0) & '0';
			end if;
		end if;
	end process;
	
	vga_assign_outputs: process(n64_clock)
	begin
		if (falling_edge(n64_clock)) then
			vga_red <= out_red;
			vga_green <= out_green;
			vga_blue <= out_blue;
		end if;
	end process;
	
	-- Capture pixels into the active buffer when clock_count is "00".
	write_buffers: process(n64_clock)
	begin
		if (falling_edge(n64_clock)) then
			if (buffer_sel = '0') then
				-- Feed pixel data as a vector into the buffer
				buffer_in_a <= n64_red(6 downto 1) & n64_green(6 downto 1) & n64_blue(6 downto 1);
				
				-- Capture only when a new N64 pixel is ready
				case clock_count is
					when "00" => buffer_en_a <= '1';
					when others => buffer_en_a <= '0';
				end case;
				
				buffer_in_b <= buffer_out_b;
				
				-- Have it shift out data twice for every one N64 pixel 
				-- (or once per VGA pixel)
				buffer_en_b <= not clock_count(0);
			else
				-- Feed pixel data as a vector into the buffer
				buffer_in_b <= n64_red(6 downto 1) & n64_green(6 downto 1) & n64_blue(6 downto 1);
				
				-- Capture only when a new N64 pixel is ready
				case clock_count is
					when "00" => buffer_en_b <= '1';
					when others => buffer_en_b <= '0';
				end case;
				
				buffer_in_a <= buffer_out_a;
				
				-- Have it shift out data twice for every one N64 pixel 
				-- (or once per VGA pixel)
				buffer_en_a <= not clock_count(0);
			end if;
		end if;
	end process;
	
	-- Count progress across a VGA line
	vga_pixel_counter: process(n64_clock)
	begin
		if (falling_edge(n64_clock)) then
			if (n64_vsync_n = '0') then
				vga_px_count <= U16_ZERO;
			elsif (vga_px_count = VGA_LINE_LEN - 1) then
				vga_px_count <= U16_ZERO;
			else
				vga_px_count <= vga_px_count + 1;
			end if;
		end if;
	end process;
	
	-- Count progress across an N64 line (generates line count too)
	n64_pixel_counter: process(n64_clock)
	begin
		if (falling_edge(n64_clock)) then
			if (n64_vsync_n = '0') then
				n64_px_count <= U16_ZERO;
				line_count <= U16_ZERO;
			-- End of N64 line - swap buffers, increment line count
			elsif (n64_px_count = N64_LINE_LEN - 1) then
				buffer_sel <= not buffer_sel;
				n64_px_count <= U16_ZERO;
				if (line_count = NUM_LINES) then
					line_count <= U16_ZERO;
				else
					line_count <= line_count + 1;
				end if;
			else
				n64_px_count <= n64_px_count + 1;
			end if;
		end if;
	end process;
	
	-- Set VGA Vsync based on line progress (VGA sync should be active 2 lines of 480 lines)
	vga_vsync_proc: process(n64_clock)
	begin
		if (falling_edge(n64_clock)) then
			if (line_count >= VGA_VSYNC_START and line_count < VGA_VSYNC_END) then
				vga_vsync <= '0';
			else
				vga_vsync <= '1';
			end if;
		end if;
	end process;
	
	-- Set VGA Hsync based on VGA line progress
	vga_hsync_proc: process(n64_clock)
	begin	
		if (falling_edge(n64_clock)) then
			if (vga_px_count >= VGA_HSYNC_START and vga_px_count < VGA_HSYNC_END) then
				vga_hsync <= '0';
			else
				vga_hsync <= '1';
			end if;
		end if;
	end process;

end behavioral;

