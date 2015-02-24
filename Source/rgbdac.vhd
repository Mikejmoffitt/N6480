LIBRARY ieee;
LIBRARY UNISIM;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE UNISIM.Vcomponents.ALL;

ENTITY rgbdac IS
   PORT ( clock	:	IN	STD_LOGIC; 
          inp	:	IN	STD_LOGIC_VECTOR (6 DOWNTO 0); 
          nclear	:	IN	STD_LOGIC; 
          b0	:	OUT	STD_LOGIC; 
          b1	:	OUT	STD_LOGIC; 
          b2	:	OUT	STD_LOGIC; 
          b3	:	OUT	STD_LOGIC; 
          b4	:	OUT	STD_LOGIC; 
          b5	:	OUT	STD_LOGIC; 
          b6	:	OUT	STD_LOGIC; 
          clamp	:	OUT	STD_LOGIC; 
          csync	:	OUT	STD_LOGIC; 
          g0	:	OUT	STD_LOGIC; 
          g1	:	OUT	STD_LOGIC; 
          g2	:	OUT	STD_LOGIC; 
          g3	:	OUT	STD_LOGIC; 
          g4	:	OUT	STD_LOGIC; 
          g5	:	OUT	STD_LOGIC; 
          g6	:	OUT	STD_LOGIC; 
          hsync	:	OUT	STD_LOGIC; 
          r0	:	OUT	STD_LOGIC; 
          r1	:	OUT	STD_LOGIC; 
          r2	:	OUT	STD_LOGIC; 
          r3	:	OUT	STD_LOGIC; 
          r4	:	OUT	STD_LOGIC; 
          r5	:	OUT	STD_LOGIC; 
          r6	:	OUT	STD_LOGIC; 
          vsync	:	OUT	STD_LOGIC);

end rgbdac;

ARCHITECTURE SCHEMATIC OF rgbdac IS
   SIGNAL XLXN_166	:	STD_LOGIC;
   SIGNAL XLXN_191	:	STD_LOGIC;
   SIGNAL XLXN_193	:	STD_LOGIC;
   SIGNAL XLXN_201	:	STD_LOGIC;
   SIGNAL XLXN_202	:	STD_LOGIC;
   SIGNAL XLXN_203	:	STD_LOGIC;
   SIGNAL XLXN_204	:	STD_LOGIC;
   SIGNAL XLXN_75	:	STD_LOGIC;
   SIGNAL XLXN_84	:	STD_LOGIC;
   SIGNAL XLXN_93	:	STD_LOGIC;
   SIGNAL test3	:	STD_LOGIC;

   ATTRIBUTE fpga_dont_touch : STRING ;
   ATTRIBUTE KEEP_HIERARCHY : STRING ;
   ATTRIBUTE KEEP_HIERARCHY OF XLXI_27 : LABEL IS "TRUE";
   ATTRIBUTE KEEP_HIERARCHY OF XLXI_28 : LABEL IS "TRUE";
   ATTRIBUTE KEEP_HIERARCHY OF XLXI_29 : LABEL IS "TRUE";
   ATTRIBUTE KEEP_HIERARCHY OF XLXI_30 : LABEL IS "TRUE";
   ATTRIBUTE KEEP_HIERARCHY OF XLXI_31 : LABEL IS "TRUE";
   ATTRIBUTE KEEP_HIERARCHY OF XLXI_32 : LABEL IS "TRUE";
   ATTRIBUTE KEEP_HIERARCHY OF XLXI_33 : LABEL IS "TRUE";
   ATTRIBUTE fpga_dont_touch OF XLXI_35 : LABEL IS "true";
   ATTRIBUTE fpga_dont_touch OF XLXI_36 : LABEL IS "true";
   ATTRIBUTE fpga_dont_touch OF XLXI_37 : LABEL IS "true";
   ATTRIBUTE fpga_dont_touch OF XLXI_76 : LABEL IS "true";
   ATTRIBUTE fpga_dont_touch OF XLXI_73 : LABEL IS "true";
   ATTRIBUTE fpga_dont_touch OF XLXI_74 : LABEL IS "true";
   ATTRIBUTE KEEP_HIERARCHY OF XLXI_75 : LABEL IS "TRUE";
   ATTRIBUTE fpga_dont_touch OF XLXI_77 : LABEL IS "true";

   COMPONENT FD4_MXILINX_rgbdac
      PORT ( C	:	IN	STD_LOGIC; 
             D0	:	IN	STD_LOGIC; 
             D1	:	IN	STD_LOGIC; 
             D2	:	IN	STD_LOGIC; 
             D3	:	IN	STD_LOGIC; 
             Q0	:	OUT	STD_LOGIC; 
             Q1	:	OUT	STD_LOGIC; 
             Q2	:	OUT	STD_LOGIC; 
             Q3	:	OUT	STD_LOGIC);
   END COMPONENT;

   COMPONENT SR4CE_MXILINX_rgbdac
      PORT ( C	:	IN	STD_LOGIC; 
             CE	:	IN	STD_LOGIC; 
             CLR	:	IN	STD_LOGIC; 
             SLI	:	IN	STD_LOGIC; 
             Q0	:	OUT	STD_LOGIC; 
             Q1	:	OUT	STD_LOGIC; 
             Q2	:	OUT	STD_LOGIC; 
             Q3	:	OUT	STD_LOGIC);
   END COMPONENT;

BEGIN

   XLXI_27 : FD4_MXILINX_rgbdac
      PORT MAP (C=>XLXN_193, D0=>inp(0), D1=>inp(1), D2=>inp(2), D3=>inp(3),
      Q0=>r0, Q1=>r1, Q2=>r2, Q3=>r3);

   XLXI_28 : FD4_MXILINX_rgbdac
      PORT MAP (C=>XLXN_166, D0=>inp(0), D1=>inp(1), D2=>inp(2), D3=>inp(3),
      Q0=>g0, Q1=>g1, Q2=>g2, Q3=>g3);

   XLXI_29 : FD4_MXILINX_rgbdac
      PORT MAP (C=>test3, D0=>inp(0), D1=>inp(1), D2=>inp(2), D3=>inp(3),
      Q0=>b0, Q1=>b1, Q2=>b2, Q3=>b3);

   XLXI_30 : FD4_MXILINX_rgbdac
      PORT MAP (C=>XLXN_191, D0=>inp(0), D1=>inp(1), D2=>inp(2), D3=>inp(3),
      Q0=>csync, Q1=>hsync, Q2=>clamp, Q3=>vsync);

   XLXI_31 : FD4_MXILINX_rgbdac
      PORT MAP (C=>XLXN_193, D0=>inp(4), D1=>inp(5), D2=>inp(6), D3=>XLXN_75,
      Q0=>r4, Q1=>r5, Q2=>r6, Q3=>open);

   XLXI_32 : FD4_MXILINX_rgbdac
      PORT MAP (C=>XLXN_166, D0=>inp(4), D1=>inp(5), D2=>inp(6), D3=>XLXN_84,
      Q0=>g4, Q1=>g5, Q2=>g6, Q3=>open);

   XLXI_33 : FD4_MXILINX_rgbdac
      PORT MAP (C=>test3, D0=>inp(4), D1=>inp(5), D2=>inp(6), D3=>XLXN_93,
      Q0=>b4, Q1=>b5, Q2=>b6, Q3=>open);

   XLXI_35 : GND
      PORT MAP (G=>XLXN_75);

   XLXI_36 : GND
      PORT MAP (G=>XLXN_84);

   XLXI_37 : GND
      PORT MAP (G=>XLXN_93);

   XLXI_76 : GND
      PORT MAP (G=>XLXN_204);

   XLXI_73 : INV
      PORT MAP (I=>nclear, O=>XLXN_201);

   XLXI_74 : INV
      PORT MAP (I=>clock, O=>XLXN_202);

   XLXI_75 : SR4CE_MXILINX_rgbdac
      PORT MAP (C=>XLXN_202, CE=>XLXN_203, CLR=>XLXN_204, SLI=>XLXN_201,
      Q0=>XLXN_191, Q1=>XLXN_193, Q2=>XLXN_166, Q3=>test3);

   XLXI_77 : VCC
      PORT MAP (P=>XLXN_203);

END SCHEMATIC;
