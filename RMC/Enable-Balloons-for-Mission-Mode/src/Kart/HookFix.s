# Fix for "KartCollide::calcOOBState" and "KartCollide::calcObjectCollision" skipping important hooks. Also enables longer respawn for boss missions.

# Hook 1 - Fall boundary.:
# PAL   : 80573bdc
# NTSC-U: 8056ed8c
# NTSC-J: 8057355c
# NTSC-K: 80561c34

# Hook 2 - Object hit.:
# PAL   : 805721c0
# NTSC-U: 8056d370
# NTSC-J: 80571b40
# NTSC-K: 80560218

# Hook 3 - Force longer respawn.:
# PAL   : 80573e40
# NTSC-U: 8056eff0
# NTSC-J: 805737c0
# NTSC-K: 80561e98

# .set region, '' # Fill with P, E, J, or K to assemble for a particular region.
# .set version, '' # Fill with 1, 2, or 3 to assemble for a particular hook.

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
    .if (region == 'P' || region == 'p')
        .set return, 0x80573c04
    .elseif (region == 'E' || region == 'e')
        .set return, 0x8056edb4
    .elseif (region == 'J' || region == 'j')
        .set return, 0x80573584
    .elseif (region == 'K' || region == 'k')
        .set return, 0x80561c5c
    .else
        .err
    .endif

    .set destinationRegister, 3
.elseif (version == '2' || version == '3')
    .if (region == 'P' || region == 'p')
        .if (version == '2')
            .set return, 0x805721e4
        .endif

        .if (version == '3')
            .set return, 0x80573e68
        .endif
    .elseif (region == 'E' || region == 'e')
        .if (version == '2')
            .set return, 0x8056d394
        .endif

        .if (version == '3')
            .set return, 0x8056f018
        .endif
    .elseif (region == 'J' || region == 'j')
        .if (version == '2')
            .set return, 0x80571b64
        .endif

        .if (version == '3')
            .set return, 0x805737e8
        .endif
    .elseif (region == 'K' || region == 'k')
        .if (version == '2')
            .set return, 0x8056023c
        .endif

        .if (version == '3')
            .set return, 0x80561ec0
        .endif
    .else
        .err
    .endif

    .set destinationRegister, 0
.else
    .err
.endif

.set MODE_BATTLE, 0x3
.set MODE_MISSION_RUN_COMPETITION, 0x4
.set MR_MODE_ENEMYDOWN02, 0x6
.set MR_MODE_LAPRUN01, 0x1
.set SECTION_MISSION_RUN, 0x2c

# Is the current game mode Mission Mode?
cmpwi r3, MODE_MISSION_RUN_COMPETITION
bne end

# Setup Racedata
lis r12, raceDataBase@h
lwz r12, -raceDataBase@l (r12)

# Check mission_single.kmt
addi r4, r12, 0xB9C
lbz r4, 0x2b (r4)
cmpwi r4, 0x1
bne end                                         # if (enableBalloonManager == TRUE)

# Is the current mission type a Boss Battle or Time Trial?
lhz r4, 0xB9E (r12)                              # racedata->racesScenario->settings->missionType
cmpwi r4, MR_MODE_ENEMYDOWN02
beq sectionCheck
cmpwi r4, MR_MODE_LAPRUN01
bne end
    
# Are we in Mission Mode?
sectionCheck:
lis r11, sectionMgrBase@h
lwz r11, sectionMgrBase@l (r11)
lwz r11, 0 (r11)                                 # sectionMgr->currentSection
cmpwi r11, 0
beq end
lwz r4, 0 (r11)
cmpwi r4, SECTION_MISSION_RUN
bne end

# Return
lis r12, return@h
ori r12, r12, return@l
mtctr r12
bctr

end:
subi destinationRegister, r3, MODE_BATTLE       # Original instruction(s)