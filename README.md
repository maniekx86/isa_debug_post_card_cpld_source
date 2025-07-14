# ISA debug POST Card CPLD source
Xilinx VHDL sources for the [ISA Debug and POST Card](https://github.com/maniekx86/isa_debug_post_card)

Compiled .jed and ready to upload .xsvf / .svf files are available in the output folder.

## Compilation
Detailed instructions are TODO. 

1. Install Xilinx ISE 10.1
2. Create a new project targeting XC95144XL QFP-100
3. Import VHDL and constraint sources
4. Use `goal_optimize.xds` as the design strategy to successfully fit the design
5. Finally, compile

## Uploading
There are various ways to upload the firmware to the CPLD. The board provides a JTAG interface for this. You can use Xilinx iMPACT or openFPGALoader with a Xilinx Programming Cable, or even use projects that emulate Xilinx Virtual Cable (XVC) using popular microcontrollers.

Note: The XC95144XL core is powered by 3.3V, so your JTAG cable must also operate at 3.3V.

I personally used a Raspberry Pi Pico with the [xvc-pico](https://github.com/kholia/xvc-pico) project to upload the firmware directly from Xilinx iMPACT 14.7 using the `.xsvf` file. However, you don’t need to install iMPACT - openFPGALoader also works. I think it's the cheapest and easiest option:

1. Get a Raspberry Pi Pico with the xvc-pico firmware flashed. Connect it to the POST card. Use the correct pinout as shown on the xvc-pico GitHub. Connect +5V of the card to the Pico’s VBUS pin!
2. Launch the `xvc-pico` daemon
3. Run: `openFPGALoader -c xvc-client --port 2542 --detect` to detect the CPLD. If detection fails, check your connections.
4. Upload firmware:
   - Preferred (.jed): `openFPGALoader -c xvc-client --port 2542 --file-type jed file.jed`. In my case uploading .jed directly causes segmentation fault. I am not sure what causes it, but there's the second option that works fine.
   - Alternatively (.svf):
     `openFPGALoader -c xvc-client --port 2542 --file-type svf ./main_clean.svf`.
     Note: Uploading via `.svf` is much slower (~8 minutes in my case), but it works in more cases.
