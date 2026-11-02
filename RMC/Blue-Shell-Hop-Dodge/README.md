## Dodge Blue Shell with Timed Hop and Mini-Turbo

This is a gecko code that restores dodging the Blue Shell using a mini-turbo boost and well timed hop, just like in Mario Kart DS. Note: This is not a port of lanny's hop dodge code, but instead a different implementation inspired by it. In fact, this implementation is based on [prior research](https://x.com/B_squo/status/2038704243381538871#m) done by B_Squo! The result is an implementation more faithful to its original functionality than any other.

The following codes are best used as companions to this one:

* [Prevent Blue Mini-Turbo Boost](https://mariokartwii.com/showthread.php?tid=2694) [QB22]
* [Orange MT on Bikes](https://mariokartwii.com/showthread.php?tid=2587) [_tZ]
* [MKDS MT Charging](https://mariokartwii.com/showthread.php?tid=2024) [Gaberboo, Vabold] ([Pulsar C++ Port](https://github.com/LannyCF/MKMayhem/blob/main/PulsarEngine/Race/DS/Snaking.cpp))


### Notable Benefits

* Stricter timing: Instead of granting the player invincibility, the shell is physically slowed down, punishing worse timing.
* More visually appealing: The kart and character actually look like they've escaped the explosion.


### Known Problems

* Can also apply to regular, blue mini-turbos unless codes like "Prevent Blue Mini-Turbo Boost [QB22]" are used, negating the increased challenge.

### Building

To assemble this code, PyiiASMH must be downloaded from "Releases" and put in to the *tools* folder. For more information, see *BUILDING.md*.


### Credits

Melg and Brawlboxgaming - Pulsar, used as reference.
B_Squo - Documenting the Blue Shell dodge state + addresses.
lanny - Original Blue Shell Hop-Dodge implementation that inpsired this project.
Ghidra Project - Function names and symbol map.