# Fail Wiggler Boss Race If Wiggler Wins [QB22]

# Inject @:
# PAL   : 806ce154
# NTSC-U: 806e9ad0
# NTSC-J: 806cd7c0
# NTSC-K: 806bc4fc

# Credit to 456 for the Mission Mode failure logic.

.set region, '' # Fill with P, E, J, or K to assemble for a particular region.
.if (region == 'P' || region == 'p')
    # Pointers
    .set raceInfoBase, 0x809c28d0
    .set sectionMgrBase, 0x809c1e38

    # Functions
    .set GeoObjectBossHanachan_setAngryState, 0x806cc43c
    .set RaceModeMissionRunCompetition_canEndRace, 0x8053db34
.elseif (region == 'E' || region == 'e')
    # Pointers:
    .set raceInfoBase, 0x809c7090
    .set sectionMgrBase, 0x809cd508

    # Functions:
    .set GeoObjectBossHanachan_setAngryState, 0x806c1848
    .set RaceModeMissionRunCompetition_canEndRace, 0x8055008c
.elseif (region == 'J' || region == 'j')
    # Pointers:
    .set raceInfoBase, 0x809c3870
    .set sectionMgrBase, 0x809c0e98

    # Functions:
    .set GeoObjectBossHanachan_setAngryState, 0x806cbaa8
    .set RaceModeMissionRunCompetition_canEndRace, 0x8053d4b4
.elseif (region == 'K' || region == 'k')
    # Pointers:
    .set raceInfoBase, 0x809b4290
    .set sectionMgrBase, 0x809b0478

    # Functions:
    .set GeoObjectBossHanachan_setAngryState, 0x806ba7e4
    .set RaceModeMissionRunCompetition_canEndRace, 0x8052bb8c
.else
    .err
.endif

.set RACESTAGE_FINISHED, 0x4
.set SECTION_COMPETITION, 0x2d

# Original instruction set
lis r12, GeoObjectBossHanachan_setAngryState@h
ori r12, r12, GeoObjectBossHanachan_setAngryState@l
mtctr r12
bctrl                                                       # GeoObjectBossHanachan::SetAngryState

# Are we in Tournament Mode?
lis r6, sectionMgrBase@h
lwz r5, sectionMgrBase@l (r6)
lwz r5, 0 (r5)
cmpwi r5, 0                                                 # Anti-freeze
beq end
lwz r0, 0 (r5)
cmpwi r0, SECTION_COMPETITION
beq end

# Make sure the race wasn't already finished.
lwz r5, -raceInfoBase@l (r6)
lwz r0, 0x28 (r5)                                           # raceinfo->raceStage
cmpwi r0, RACESTAGE_FINISHED
beq end

# Set Mission Mode failure flags.
lwz r6, 0x14 (r5)
li r0, 0x72
stb r0, 0xf (r6)
li r0, 0x633b
sth r0, 0x9 (r6)

# End the race.
li r4, RACESTAGE_FINISHED                                   # Set the race stage.
lis r12, RaceModeMissionRunCompetition_canEndRace@h
lwz r3, 0x10 (r5)                                           # raceinfo->gameModeData
ori r12, r12, RaceModeMissionRunCompetition_canEndRace@l
mtctr r12
bctrl                                                       # RaceModeMissionRunCompetition::canEndCompetition

end: