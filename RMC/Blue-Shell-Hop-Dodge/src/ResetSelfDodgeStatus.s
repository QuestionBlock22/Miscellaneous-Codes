# Reset "playerSelfDodgeStatus" on retarget.

# Inject @:
# PAL   : 807b3ef8
# NTSC-U: 807a5498
# NTSC-J: 807b3564
# NTSC-K: 807a22b8

stb r0, 0x2f7 (r3)
blr                 # Original instruction.