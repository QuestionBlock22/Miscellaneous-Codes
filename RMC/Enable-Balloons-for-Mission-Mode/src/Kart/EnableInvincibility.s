# Enable Battle Mode invincibility functionality for Boss Missions.

# Credit to Ro for the addresses from the code "Battle Blinking Invincibility in VS."

# Hook 1 - Allow in Boss Missions generally.:
# PAL   : 8056747c
# NTSC-U: 805630fc
# NTSC-J: 80566dfc
# NTSC-K: 805554d4

# Hook 2 - Allow in Boss Missions after taking damage.:
# PAL   : 805819c4
# NTSC-U: 8057b160
# NTSC-J: 80581344
# NTSC-K: 8056fa1c

# Hook 3 - Allow in Boss Missions after respawning.:
# PAL   : 80581e94
# NTSC-U: 8057b630
# NTSC-J: 80581814
# NTSC-K: 8056feec

# Hook 4 - Allows balloon removal on item hit generally.:
# PAL   : 80572818
# NTSC-U: 8056d9c8
# NTSC-J: 80572198
# NTSC-K: 80560870

# .set region, '' # Fill with P, E, J, or K to assemble for a particular region.
# .set version, '' # Fill with 1, 2, 3, or 4 to assemble for a particular hook.
.if (region == 'P' || region == 'p')
    .set raceDataBase, 0x809c28d8
    .set sectionMgrBase, 0x809c1e38
.elseif (region == 'E' || region == 'e')
    .set raceDataBase, 0x809c7098
    .set sectionMgrBase, 0x809cd508
.elseif (region == 'J' || region == 'j')
    .set raceDataBase, 0x809c3878
    .set sectionMgrBase, 0x809c0e98
.elseif (region == 'K' || region == 'k')
    .set raceDataBase, 0x809b4298
    .set sectionMgrBase, 0x809b0478
.else
    .err
.endif

.if (version == '1')
    .set gameModeRegister, 3
    .if (region == 'P' || region == 'p')
        .set return, 0x805674a0
    .elseif (region == 'E' || region == 'e')
        .set return, 0x80563120
    .elseif (region == 'J' || region == 'j')
        .set return, 0x80566e20
    .elseif (region == 'K' || region == 'k')
        .set return, 0x805554f8
    .else
        .err
    .endif
.elseif (version == '2')
    .set gameModeRegister, 4
    .if (region == 'P' || region == 'p')
        .set return, 0x805819ec
    .elseif (region == 'E' || region == 'e')
        .set return, 0x8057b188
    .elseif (region == 'J' || region == 'j')
        .set return, 0x8058136c
    .elseif (region == 'K' || region == 'k')
        .set return, 0x8056fa44
    .else
        .err
    .endif
.elseif (version == '3')
    .set gameModeRegister, 3
    .if (region == 'P' || region == 'p')
        .set return, 0x80581ebc
    .elseif (region == 'E' || region == 'e')
        .set return, 0x8057b658
    .elseif (region == 'J' || region == 'j')
        .set return, 0x8058183c
    .elseif (region == 'K' || region == 'k')
        .set return, 0x8056ff14
    .else
        .err
    .endif
.elseif (version == '4')
    .set gameModeRegister, 4
    .if (region == 'P' || region == 'p')
        .set return, 0x8057283c
    .elseif (region == 'E' || region == 'e')
        .set return, 0x8056d9ec
    .elseif (region == 'J' || region == 'j')
        .set return, 0x805721bc
    .elseif (region == 'K' || region == 'k')
        .set return, 0x80560894
    .else
        .err
    .endif
.else
    .err
.endif

.set MODE_BATTLE, 0x3
.set MODE_MISSION_RUN_COMPETITION, 0x4
.set MR_MODE_ENEMYDOWN02, 0x6
.set MR_MODE_LAPRUN01, 0x1
.set SECTION_COMPETITION, 0x2d

# Is the current game mode Mission Mode?
cmpwi gameModeRegister, MODE_MISSION_RUN_COMPETITION
bne end

# Setup Racedata
lis r11, raceDataBase@h
lwz r12, -raceDataBase@l (r11)

# Check mission_single.kmt
addi r12, r12, 0xB9C
lbz r0, 0x2b (r12)
cmpwi r0, 0x1
bne end                                                       # if (enableBalloonManager == TRUE)

# Is the current mission type a Boss Battle? (Invincibility will only be enabled for Boss Battles sans Wiggler.)
lwz r12, -raceDataBase@l (r11)
lhz r7, 0xB9E (r12)                                           # racedata->racesScenario->settings->missionType
cmpwi r7, MR_MODE_ENEMYDOWN02
.if (version == '4')
    beq sectionCheck
    cmpwi r7, MR_MODE_LAPRUN01
    bne end
.else
    bne end
.endif

# Are we in Tournament Mode?
sectionCheck:
lwz r11, sectionMgrBase@l (r11)
lwz r11, 0 (r11)
cmpwi r11, 0
beq end
lwz r7, 0 (r11)                                              # sectionMgr->currentSection
cmpwi r7, SECTION_COMPETITION
beq end

# Return
lis r12, return@h
ori r12, r12, return@l
mtctr r12
bctr

end:
subi r0, gameModeRegister, MODE_BATTLE                        # Original instruction