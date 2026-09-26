# Enable balloon hit removal in Mission Mode.

# Hook 1 - Enable for item hits.
# PAL   : 805729c8
# NTSC-U: 8056db78
# NTSC-J: 80572348
# NTSC-K: 80560a20

# Hook 2 - Enable for fall boundary crosses.
# PAL   : 80573c30
# NTSC-U: 8056ede0
# NTSC-J: 805735b0
# NTSC-K: 80561c88

# Hook 3 - Enable for object hits.
# PAL   : 805721fc
# NTSC-U: 8056d3ac
# NTSC-J: 80571b7c
# NTSC-K: 80560254

# Hook 4 - Enable on cactus collision.
# PAL   : 80595108
# NTSC-U: 8058e8e4
# NTSC-J: 80594a88
# NTSC-K: 80583160

# .set version, '' # Fill with 1, 2, or 3 to assemble for a particular hook.
.if (version == '1')
    .set gameModeRegister, 4
.elseif (version == '2' || version == '3' || version == '4')
    .set gameModeRegister, 5
.else
    .err
.endif

.set MODE_BATTLE, 0x3
.set MODE_MISSION_RUN_COMPETITION, 0x4

cmpwi cr1, gameModeRegister, MODE_BATTLE                          # Original-ish instruction(s)
cmpwi cr2, gameModeRegister, MODE_MISSION_RUN_COMPETITION
crxor 4*cr0+eq, 4*cr1+eq, 4*cr2+eq