# Fix for random playback failure. You can exclude this if you prefer to use "SE_CC_BALLOON_GET"/sound id 0x1f5, instead.

# Inject @
# PAL   : 8070ce8c
# NTSC-U: 807064e8
# NTSC-J: 8070c4f8
# NTSC-K: 806fb234

cmplwi cr0, r4, 0x1f5               # Original instruction.
cmplwi cr1, r4, 0x1f8
cror 4*cr0+eq, 4*cr0+eq, 4*cr1+eq