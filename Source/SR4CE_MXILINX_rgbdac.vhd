LIBRARY ieee;
LIBRARY UNISIM;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE UNISIM.Vcomponents.ALL;

ENTITY SR4CE_MXILINX_rgbdac IS
   PORT ( C	:	IN	STD_LOGIC; 
          CE	:	IN	STD_LOGIC; 
          CLR	:	IN	STD_LOGIC; 
          SLI	:	IN	STD_LOGIC; 
          Q0	:	OUT	STD_LOGIC; 
          Q1	:	OUT	STD_LOGIC; 
          Q2	:	OUT	STD_LOGIC; 
          Q3	:	OUT	STD_LOGIC);

end SR4CE_MXILINX_rgbdac;

ARCHITECTURE SCHEMATIC OF SR4CE_MXILINX_rgbdac IS
   SIGNAL Q0_DUMMY	:	STD_LOGIC;
   SIGNAL Q1_DUMMY	:	STD_LOGIC;
   SIGNAL Q2_DUMMY	:	STD_LOGIC;

   ATTRIBUTE fpga_dont_touch : STRING ;
   ATTRIBUTE fpga_dont_touch OF U3 : LABEL IS "true";
   ATTRIBUTE fpga_dont_touch OF U1 : LABEL IS "true";
   ATTRIBUTE fpga_dont_touch OF U0 : LABEL IS "true";
   ATTRIBUTE fpga_dont_touch OF U2 : LABEL IS "true";

BEGIN
   Q0 <= Q0_DUMMY;
   Q1 <= Q1_DUMMY;
   Q2 <= Q2_DUMMY;

   U3 : FDCE
      PORT MAP (C=>C, CE=>CE, CLR=>CLR, D=>Q2_DUMMY, Q=>Q3);

   U1 : FDCE
      PORT MAP (C=>C, CE=>CE, CLR=>CLR, D=>Q0_DUMMY, Q=>Q1_DUMMY);

   U0 : FDCE
      PORT MAP (C=>C, CE=>CE, CLR=>CLR, D=>SLI, Q=>Q0_DUMMY);

   U2 : FDCE
      PORT MAP (C=>C, CE=>CE, CLR=>CLR, D=>Q1_DUMMY, Q=>Q2_DUMMY);

END SCHEMATIC;
