# N6480
Nintendo 64 lagless line-doubler using an FPGA.

Features
========

* 480p/240p output
* VGA (RGB) or YPbPr (Component) encoding
* Optional scanline injection
* Sync-on-green optional
* C-Sync or HV-sync selectable
* De-blur for 320x240 games optional

Issues
======
These are known caveats or outright problems, listed from highest to lowest priority.

De-blur Detection
-----------------
Currently de-blur is enabled manually. It works by dropping every other column of the 640px line the RCP outputs. Whether or not even or odd columns are dropped is selectable via a switch. When a 480i output is detected, de-blur is disabled, as the output is likely true 640px-width.

The problem here is that some games actually do output a 640x240 progressive image, like Mario Tennis. For games like this, de-blur should be disabled outright, as it just drops information. A heuristic should be implemented to detect whether or not de-blur is appropriate, and on which column, to provide an "Automatic" mode.

PCB Shape
---------
The current PCB is a quick job, and while it's fairly compact it would be nice if it was shaped to slot into the Nintendo 64 for a more professional install. Presently there are no suggested mounting points for switches and wires, so the installer must free-wire everything. This project isn't intended as a professional kit to be sold or anything, so this is low priority.

480i Support
------------
Games that run in 480i are "supported" in that they run, and N6480 detects them. However, the even and odd fields aren't blended in any meaningful way, so the end result is a somewhat broken 960i "bob" interlaced output. Many games use this mode just for intro screens and menus, but a few that run in this mode all the time (Starcraft 64) will be unpleasant. 

This issue can not be easily resolved without the use of external memory for a framebuffer, so a solution is absolute bottom priority. 
