# Consistency fix for the code "Watch Replays After Regular VS Races" Removes the quit confirmation screen if the current game mode is VS.

# Inject @
# PAL:    8062cacc
# NTSC-U: 805fbc18
# NTSC-J: 8062c218
# NTSC-K: 8061aec4

.set region, '' # Fill with P, E, J, or K in the quotes to assemble for a particular region.
.if (region == 'P' || region == 'p')
    .set raceDataBase, 0x809c28d8 # Resolves to 809c7d28 (Racedata::spInstance)
    .set codeBreak, 0x8062cad8  # "break"
.elseif (region == 'E' || region == 'e')
    .set raceDataBase, 0x809c7098
    .set codeBreak, 0x805fbc24
.elseif (region == 'J' || region == 'j')
    .set raceDataBase, 0x809c3878
    .set codeBreak, 0x8062c224
.elseif (region == 'K' || region == 'k')
    .set raceDataBase, 0x809b4298
    .set codeBreak, 0x8061aed0
.else
    .err
.endif

lis r12, raceDataBase@h
lwz r12, -raceDataBase@l (r12)
lwz r0, 0xB70 (r12)
cmpwi r0, 1
bne loadPageId
lis r12, codeBreak@h
ori r12, r12, codeBreak@l
mtctr r12
bctr
loadPageId:
li r4, 0x2c              # Original instruction