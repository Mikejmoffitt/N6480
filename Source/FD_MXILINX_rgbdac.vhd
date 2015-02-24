LIBRARY ieee;
LIBRARY UNISIM;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE UNISIM.Vcomponents.ALL;

ENTITY FD_MXILINX_rgbdac IS
   PORT ( C	:	IN	STD_LOGIC; 
          D	:	IN	STD_LOGIC; 
          Q	:	OUT	STD_LOGIC);

end FD_MXILINX_rgbdac;

ARCHITECTURE SCHEMATIC OF FD_MXILINX_rgbdac IS
   SIGNAL XLXN_4	:	STD_LOGIC;

   ATTRIBUTE fpga_dont_touch : STRING ;
   ATTRIBUTE fpga_dont_touch OF U0 : LABEL IS "true";
   ATTRIBUTE fpga_dont_touch OF I_36_43 : LABEL IS "true";

BEGIN

   U0 : FDCP
      PORT MAP (C=>C, CLR=>XLXN_4, D=>D, PRE=>XLXN_4, Q=>Q);

   I_36_43 : GND
      PORT MAP (G=>XLXN_4);

END SCHEMATIC;
