# Prevent calling a null pointer and call the balloon removal function when hit by an object or when crossing a fall boundary.

# Hook 1 - Remove the player's balloon on object hit.
# PAL   : 80572204
# NTSC-U: 8056d3b4
# NTSC-J: 80571b84
# NTSC-K: 8056025c

# Hook 2 - Remove the player's balloon after crossing a fall boundary.
# PAL   : 80573c38
# NTSC-U: 8056ede8
# NTSC-J: 805735b8
# NTSC-K: 80561c90

# Hook 3 - Remove the player's balloon after hitting cactus collision.
# PAL   : 80595110
# NTSC-U: 8058e8ec
# NTSC-J: 80594a90
# NTSC-K: 80583168

# .set region, '' # Fill with P, E, J, or K to assemble for a particular region.
# .set version, '' # Fill with 1, 2, or 3 to assemble for a particular region.

.if (region == 'P' || region == 'p')
    # Pointers:
    .set sectionMgrBase, 0x809c1e38

    # Functions:
    .set RaceModeBalloonBattle_removePoints, 0x80538bc0
    .set RaceModeBalloonBattle_onCourseCollisionHit, 0x80538ce0
.elseif (region == 'E' || region == 'e')
    # Pointers:
    .set sectionMgrBase, 0x809cd508

    # Functions:
    .set RaceModeBalloonBattle_removePoints, 0x80534078
    .set RaceModeBalloonBattle_onCourseCollisionHit, 0x80534198
.elseif (region == 'J' || region == 'j')
    # Pointers:
    .set sectionMgrBase, 0x809c0e98

    # Functions:
    .set RaceModeBalloonBattle_removePoints, 0x80538540
    .set RaceModeBalloonBattle_onCourseCollisionHit, 0x80538660
.elseif (region == 'K' || region == 'k')
    # Pointers:
    .set sectionMgrBase, 0x809b0478

    # Functions:
    .set RaceModeBalloonBattle_removePoints, 0x80526c18
    .set RaceModeBalloonBattle_onCourseCollisionHit, 0x80526d38
.else
    .err
.endif

.if (version == '1')
    .if (region == 'P' || region == 'p')
        .set return, 0x805722a8
    .elseif (region == 'E' || region == 'e')
        .set return, 0x8056d458
    .elseif (region == 'J' || region == 'j')
        .set return, 0x80571c28
    .elseif (region == 'K' || region == 'k')
        .set return, 0x80560300
    .else
        .err
    .endif
.elseif (version == '2')
    .if (region == 'P' || region == 'p')
        .set return, 0x80573dc8
    .elseif (region == 'E' || region == 'e')
        .set return, 0x8056ef78
    .elseif (region == 'J' || region == 'j')
        .set return, 0x80573748
    .elseif (region == 'K' || region == 'k')
        .set return, 0x80561e20
    .else
        .err
    .endif

.elseif (version == '3')
    .if (region == 'P' || region == 'p')
        .set return, 0x805951b4
    .elseif (region == 'E' || region == 'e')
        .set return, 0x8058e990
    .elseif (region == 'J' || region == 'j')
        .set return, 0x80594b34
    .elseif (region == 'K' || region == 'k')
        .set return, 0x8058320c
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
cmpwi r5, MODE_MISSION_RUN_COMPETITION
bne end

# Check mission_single.kmt
addi r8, r4, 0xB9C
lbz r8, 0x2b (r8)
cmpwi r8, 0x1
bne end                                                         # if (enableBalloonManager == TRUE)

# Is the current mission type a Boss Battle or Time Trial?
lhz r11, 0xB9E (r4)                                             # racedata->racesScenario->settings->missionType
cmpwi r11, MR_MODE_ENEMYDOWN02
beq sectionCheck
cmpwi r11, MR_MODE_LAPRUN01
bne mrEnd

# Are we in Tournament Mode?
sectionCheck:
lis r11, sectionMgrBase@h
lwz r11, sectionMgrBase@l (r11)
lwz r11, 0 (r11)
cmpwi r11, 0
beq end
lwz r11, 0 (r11)                                                 # sectionMgr->currentSection
cmpwi r11, SECTION_COMPETITION
beq mrEnd

# Remove the player's balloon.
lwz r3, 0x10 (r3)
mr r4, r23

.if (version == '1' || version == '2')
    lis r12, RaceModeBalloonBattle_removePoints@h
    rlwinm r4, r0, 0, 24, 31
    ori r12, r12, RaceModeBalloonBattle_removePoints@l
    mtctr r12
    bctrl                                                       # RaceModeBalloonBattle::removePoints
.else
    lis r12, RaceModeBalloonBattle_onCourseCollisionHit@h
    rlwinm r4, r0, 0, 24, 31
    ori r12, r12, RaceModeBalloonBattle_onCourseCollisionHit@l
    mtctr r12
    bctrl                                                       # RaceModeBalloonBattle::onCourseCollisionHit
.endif

mrEnd:
lis r12, return@h
ori r12, r12, return@l
mtctr r12
bctr

end:
lwz r4, 0xB78 (r4)                                              # Original instruction