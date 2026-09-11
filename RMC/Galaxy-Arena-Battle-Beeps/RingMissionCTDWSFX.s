# Use the Battle Countdown Sounds on Galaxy Colosseum/Galaxy Arena [QB22]

# WRITE32 @
# PAL   : 047166d4 41820020
# NTSC-U: 0470ec30 41820020
# NTSC-J: 04715d40 41820020
# NTSC-K: 04704a7c 41820020

# bgt -> beq

# Inject @
# PAL   : 807166d0
# NTSC-U: 8070ec2c
# NTSC-J: 80715d3c
# NTSC-K: 80704a78

.set old_matenro_64, 0x29
.set ring_mission, 0x36

cmpwi cr1, r0, old_matenro_64       # Original-ish instruction
cmpwi cr2, r0, ring_mission
crxor 4*cr0+eq, 4*cr1+gt, 4*cr2+eq
