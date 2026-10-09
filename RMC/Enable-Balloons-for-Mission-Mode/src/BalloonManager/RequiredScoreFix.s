# Fixes failure to set the Mission Mode failure state if the required score is greater than 4.

# Inject @:
# PAL   : 8053db7c
# NTSC-U: 805500d4
# NTSC-J: 8053d4fc
# NTSC-K: 8052bbd4

# .set region, '' # Fill with P, E, J, or K to assemble for a particular region.
.if (region == 'P' || region == 'p')
    # Pointers
    .set raceDataBase, 0x809c28d8
    .set raceInfoBase, 0x809c28d0
    .set sectionMgrBase, 0x809c1e38
.elseif (region == 'E' || region == 'e')
    # Pointers
    .set raceDataBase, 0x809c7098
    .set raceInfoBase, 0x809c7090
    .set sectionMgrBase, 0x809cd508
.elseif (region == 'J' || region == 'j')
    # Pointers
    .set raceDataBase, 0x809c3878
    .set raceInfoBase, 0x809c3870
    .set sectionMgrBase, 0x809c0e98
.elseif (region == 'K' || region == 'k')
    # Pointers
    .set raceDataBase, 0x809b4298
    .set raceInfoBase, 0x809b4290
    .set sectionMgrBase, 0x809b0478
.else
    .err
.endif

.set MODE_MISSION_RUN_COMPETITION, 0x4
.set SECTION_COMPETITION, 0x2d

lis r5, raceDataBase@h
lwz r6, -raceDataBase@l (r5)
lwz r0, 0xB70 (r6)                          # racedata->racesScenario->settings->gameMode
cmpwi r0, MODE_MISSION_RUN_COMPETITION
bne end

# Are we in Tournament Mode?
sectionCheck:
lwz r6, sectionMgrBase@l (r5)
lwz r7, 0 (r6)
cmpwi r7, 0
beq end
lwz r0, 0 (r7)                              # sectionMgr->currentSection
cmpwi r0, SECTION_COMPETITION
beq end

# Get Mission Mode failure flags. Credit to 456 for deriving the logic for this game state.
lwz r6, -raceInfoBase@l (r5)
lwz r6, 0x14 (r6)
lbz r0, 0xf (r6)
cmpwi r0, 0x72
bne end
lhz r0, 0x9 (r6)
cmpwi r0, 0x633b
bne end

# End local player race.
lwz r0, 0x38 (sp)
cmpw r4, r0
blt endLocalRace
b end

endLocalRace:
li r0, 0
stw r0, 0x38 (sp)

end:
lwz r0, 0x4c (sp)                           # Original instruction