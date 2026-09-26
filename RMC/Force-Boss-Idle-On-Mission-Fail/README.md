## Force Bosses to Idle on Mission Fail

This is a gecko code that resets boss objects to the idle state if the player fails the mission. This code **must** be used in conjunction with [Add Mission Mode "Failed" Features](https://mariokartwii.com/showthread.php?tid=2740) by which this code reads data written specifically by it.

### Building
To build this gecko code, you must use PyiiASMH. Download the latest build from the releases section and place it in the tools folder. For more information, see the file *BUILDING.md* .

### Credits:
* Melg and Brawlboxgaming: [Pulsar](https://github.com/MelgMKW/Pulsar) used as reference.
* 456: "Add Mission Mode 'Failed' Features" used as reference for failure features.
* Ghidra Project: Function names and symbol map.