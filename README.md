4piobmt.z80 - Z80 PIO bit mode test program for CP/M
----------------------------------------------------

Version 20-Oct-2018 
Phil Summers
difficultylevelhigh@gmail.com

Set the base address, number of PIO chips and chip addressing configuration in the source and assemble with SLR Systems Z80ASM.

Default test pattern for each port is:
 
 1 Toggle all bits on and off. 
 2 Toggle each bit on and off.
 3 Toggle alternate bits on and off. 

Test pattern can be changed by modifying the table at the end of the source.

Initially designed for testing RetroBrewComputers ECB-4PIO and ECB-Zilog Peripherals boards:

https://www.retrobrewcomputers.org/doku.php?id=boards:ecb:zilog-peripherals:start
https://www.retrobrewcomputers.org/doku.php?id=boards:ecb:4pio:start

Should work with any Z80 system with appropriate configuration.

piociotst.asm - Z80 PIO bit mode test program for CP/M ROMWBW HBIOS
-------------------------------------------------------------------

Version 27-Nov-2018 
Phil Summers
difficultylevelhigh@gmail.com

This is generic test program for ROMWBW with pio.asm driver - currently not submitted to ROMWBW master.

USAGE: PIOCIOTST n

Where n is the device to output the test pattern to.

Default test pattern for each port is:
 
1 Toggle all bits on and off. 
2 Toggle each bit on and off.
3 Toggle alternate bits on and off.

Only tested with ECB-SBC-V2 and ECP-4PIO.


