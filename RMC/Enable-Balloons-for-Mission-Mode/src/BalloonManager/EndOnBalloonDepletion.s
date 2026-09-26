# Mission Mode 'Failed' Feature: End the mission prematurely and set the losing flags if the player's balloon reserves are depleted.

# Inject @:
# PAL   : 8086a0c8
# NTSC-U: 80865c98
# NTSC-J: 80869734
# NTSC-K: 80858488

# Credit to 456 for the Mission Mode failure logic.

# .set region, '' # Fill with P, E, J, or K to assemble for a particular region.
.if (region == 'P' || region == 'p')
    # Pointers:
    .set raceDataBase, 0x809c28d8
    .set raceInfoBase, 0x809c28d0
    .set sectionMgrBase, 0x809c1e38

    # Functions:
    .set RaceModeMissionRunCompetition_canEndRace, 0x8053db34
.elseif (region == 'E' || region == 'e')
    # Pointers:
    .set raceDataBase, 0x809c7098
    .set raceInfoBase, 0x809c7090
    .set sectionMgrBase, 0x809bd508

    # Functions:
    .set RaceModeMissionRunCompetition_canEndRace, 0x8055008c
.elseif (region == 'J' || region == 'j')
    # Pointers:
    .set raceDataBase, 0x809c3878
    .set raceInfoBase, 0x809c3870
    .set sectionMgrBase, 0x809c0e98

    # Functions:
    .set RaceModeMissionRunCompetition_canEndRace, 0x8053d4b4
.elseif (region == 'K' || region == 'k')
    # Pointers:
    .set raceDataBase, 0x809b4298
    .set raceInfoBase, 0x809b4290
    .set sectionMgrBase, 0x809b0478

    # Functions:
    .set RaceModeMissionRunCompetition_canEndRace, 0x8052bb8c
.else
    .err
.endif

.set MODE_BATTLE, 0x3
.set MR_MODE_ENEMYDOWN02, 0x6
.set MR_MODE_LAPRUN01, 0x1
.set RACESTAGE_FINISHED, 0x4
.set SECTION_COMPETITION, 0x2d

cmpwi r25, 0                                                # Did the player run out of balloons?
bne end

# Is the current game mode Mission Mode and current mission type a Boss Battle or Time Trial?
lis r12, raceDataBase@h
lwz r11, -raceDataBase@l (r12)
lwz r0, 0xB70 (r11)                                         # racedata->racesScenario->settings->gameMode
cmpwi r0, MODE_BATTLE
beq end
lha r0, 0xB9E (r11)                                         # racedata->racesScenario->settings->missionType
cmpwi r0, MR_MODE_ENEMYDOWN02
beq missionFailed
cmpwi r0, MR_MODE_LAPRUN01
bne end

# Set Mission Mode failure flags.
missionFailed:
lwz r3, -raceInfoBase@l (r12)
lwz r4, 0x14 (r3)
li r5, 0x72
stb r5, 0xf (r4)
li r5, 0x633b
sth r5, 0x9 (r4)

# End the race.
li r4, RACESTAGE_FINISHED                                   # Set the race stage.
lis r12, RaceModeMissionRunCompetition_canEndRace@h
lwz r3, 0x10 (r3)                                           # raceinfo->gameModeData
ori r12, r12, RaceModeMissionRunCompetition_canEndRace@l
mtctr r12
bctrl                                                       # RaceModeMissionRunCompetition::canEndCompetition

end:
lmw r19, 0xc (sp)                                           # Original instruction (pop)

