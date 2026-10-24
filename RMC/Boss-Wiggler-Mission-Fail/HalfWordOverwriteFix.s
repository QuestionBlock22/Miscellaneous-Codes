# Bug fix for where part of the half-word that determines the player's race outcome gets overwritten by another part of the game.

# Inject @:
# PAL   : 80535a9c
# NTSC-U: 80530f54
# NTSC-J: 8053541c
# NTSC-K: 80523af4

# .set region, '' # Fill with P, E, J, or K to assemble for a particular region.
.if (region == 'P' || region == 'p')
    # Pointers
    .set raceDataBase, 0x809c28d8
    .set raceInfoBase, 0x809c28d0
    .set sectionMgrBase, 0x809c1e38

    # Return Address
    .set return, 0x80535ab0
.elseif (region == 'E' || region == 'e')
    # Pointers
    .set raceDataBase, 0x809c7098
    .set raceInfoBase, 0x809c7090
    .set sectionMgrBase, 0x809cd508

    # Return Address
    .set return, 0x80530f68
.elseif (region == 'J' || region == 'j')
    # Pointers
    .set raceDataBase, 0x809c3878
    .set raceInfoBase, 0x809c3870
    .set sectionMgrBase, 0x809c0e98

    # Return Address
    .set return, 0x80535430
.elseif (region == 'K' || region == 'k')
    # Pointers
    .set raceDataBase, 0x809b4298
    .set raceInfoBase, 0x809b4290
    .set sectionMgrBase, 0x809b0478

    # Return Address
    .set return, 0x80523b08
.else
    .err
.endif

.set MODE_MISSION_RUN_COMPETITION, 0x4
.set MR_MODE_ENEMYDOWN02, 0x6
.set MR_MODE_LAPRUN01, 0x1
.set SECTION_COMPETITION, 0x2d

# Is the current game mode Mission Mode and current mission type a Boss Battle or Time Trial?
lis r12, raceDataBase@h
lwz r12, -raceDataBase@l (r12)
lwz r6, 0xB70 (r12)
cmpwi r6, MODE_MISSION_RUN_COMPETITION
bne end
lhz r6, 0xB9E (r12)
cmpwi r6, MR_MODE_ENEMYDOWN02
beq sectionCheck
cmpwi r6, MR_MODE_LAPRUN01
bne end

# Are we in Tournament Mode?
sectionCheck:
lis r12, sectionMgrBase@h
lwz r12, sectionMgrBase@l (r12)
lwz r6, 0 (r12)
cmpwi r6, 0
beq end
lwz r6, 0 (r6)                             # sectionMgr->currentSection
cmpwi r6, SECTION_COMPETITION
beq end

# Get Mission Mode failure flags. Credit to 456 for deriving the logic for this game state.
lbz r6, 0xf (r29)
cmpwi r6, 0x72
bne end

# Set failure flag.
li r6, 0x633b
sth r6, 0x9 (r29)
lis r12, return@h
ori r12, r12, return@l
mtctr r12
bctr

end:
cmpwi r0, 0                                 # Original instruction
