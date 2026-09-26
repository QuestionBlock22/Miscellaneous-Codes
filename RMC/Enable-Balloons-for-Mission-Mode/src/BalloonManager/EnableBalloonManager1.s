# Enable RaceBalloonManager for Mission Mode and Competitions.

# Inject @:
# PAL   : 808697e8
# NTSC-U: 808653b8
# NTSC-J: 80868e54
# NTSC-K: 80857ba8

.set MODE_BATTLE, 0x3
.set MODE_MISSION_RUN_COMPETITION, 0x4

cmpwi cr1, r0, MODE_BATTLE                          # Original-ish instruction
cmpwi cr2, r0, MODE_MISSION_RUN_COMPETITION
crxor 4*cr0+eq, 4*cr1+eq, 4*cr2+eq