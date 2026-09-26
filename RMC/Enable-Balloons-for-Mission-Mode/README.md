## Enable Balloons in Mission Mode

This is a gecko code that enables the balloon object in Mission Mode.

This code comes with an optional fix for the balloon height of any vehicle that is neither the Standard Kart or Standard Bike, courtesty of mkwcat and stebler.

Further, this code is best used with the codes [Add Mission Mode "Failed" Features](https://mariokartwii.com/showthread.php?tid=2740) and Force Bosses to Idle on Mission Fail by which functionality is added that the aforementioned codes can read.

### Usage
In the file *mission_single.kmt,* set the boolean offset 0x2b, an offset the Wiiki presumes is "padding," to either 0, Off, or 1, On. Save the file and test.

### Building
To build this gecko code, you must use PyiiASMH. Download the latest build from the releases section and place it in the tools folder. For more information, see the file *BUILDING.md* .

### License
Parts of this project is licensed under the MIT License. To know your rights, read the document *LICENSE.txt.*

### Credits:
* Retro Rewind Team: Updated source headers used as reference.
* Melg and Brawlboxgaming: [Pulsar](https://github.com/MelgMKW/Pulsar) used as reference.
* 456: "Add Mission Mode 'Failed' Features" used as reference for failure features.
* MrBean35000vr and Chadderz: [Documentation](https://mkwiiki.org/wiki/Mission_Mode)
 on the unused Mission Mode.
* Ro: Addresses from the code "[Battle Blinking Invincibility in VS](https://mariokartwii.com/showthread.php?tid=2145)."
* stebler and mkwcat: Fix for balloon height from [Mario Kart Wii Service Pack](https://github.com/stblr/mkw-sp).
* Ghidra Project: Function names and symbol map.