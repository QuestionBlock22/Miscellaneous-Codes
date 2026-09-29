# Prevent calling a null pointer and call the balloon removal function when hit by an item.

# Inject @
# PAL   : 805729d4
# NTSC-U: 8056db84
# NTSC-J: 80572354
# NTSC-K: 80560a2c

# .set region, '' # Fill with P, E, J, or K to assemble for a particular region.
.if (region == 'P' || region == 'p')
    # Pointers:
    .set sectionMgrBase, 0x809c1e38

    # Functions:
    .set RaceModeBalloonBattle_onRemoval, 0x80538770
    
    # Return Address:
    .set return, 0x80572a88
.elseif (region == 'E' || region == 'e')
    # Pointers:
    .set sectionMgrBase, 0x809cd508

    # Functions:
    .set RaceModeBalloonBattle_onRemoval, 0x80533c28

    # Return Address:
    .set return, 0x8056dc38
.elseif (region == 'J' || region == 'j')
    # Pointers:
    .set sectionMgrBase, 0x809c0e98

    # Functions:
    .set RaceModeBalloonBattle_onRemoval, 0x805380f0

    # Return Address:
    .set return, 0x80572408
.elseif (region == 'K' || region == 'k')
    # Pointers:
    .set sectionMgrBase, 0x809b0478

    # Functions:
    .set RaceModeBalloonBattle_onRemoval, 0x805267c8

    # Return Address:
    .set return, 0x80560ae0
.else
    .err
.endif

.set MODE_BATTLE, 0x3
.set MODE_MISSION_RUN_COMPETITION, 0x4
.set MR_MODE_ENEMYDOWN02, 0x6
.set MR_MODE_LAPRUN01, 0x1
.set SECTION_COMPETITION, 0x2d

# Is the current game mode Mission Mode?
cmpwi r4, MODE_MISSION_RUN_COMPETITION
bne end

# Check mission_single.kmt
addi r8, r5, 0xB9C
lbz r0, 0x2b (r8)
cmpwi r0, 0x1
bne end

# Is the current mission type a Boss Battle or Time Trial?
lhz r0, 0xB9E (r5)                                      # racedata->racesScenario->settings->missionType
cmpwi r0, MR_MODE_ENEMYDOWN02
beq sectionCheck
cmpwi r0, MR_MODE_LAPRUN01
bne mrEnd

# Are we in Tournament Mode?
sectionCheck:
lis r11, sectionMgrBase@h
lwz r11, sectionMgrBase@l (r11)
lwz r11, 0 (r11)
cmpwi r11, 0
beq end
lwz r11, 0 (r11)                                        # sectionMgr->currentSection
cmpwi r11, SECTION_COMPETITION
beq mrEnd

# Remove the player's balloon.
lwz r3, 0x10 (r3)
mr r4, r23
lis r12, RaceModeBalloonBattle_onRemoval@h
rlwinm r5, r24, 0, 24, 31
ori r12, r12, RaceModeBalloonBattle_onRemoval@l
mtctr r12
bctrl                                                   # RaceModeBalloonBattle::onRemoval

mrEnd:
lis r12, return@h
ori r12, r12, return@l
mtctr r12
bctr

end:
lwz r0, 0xB78 (r5)                                      # Original instruction