# Enable RaceBalloonManager if the current mission type is "EnemyDown02."

# Inject @:
# PAL   : 80869818
# NTSC-U: 808653e8
# NTSC-J: 80868e84
# NTSC-K: 80857bd8

# .set region, '' # Fill with P, E, J, or K to assemble for a particular region.
.if (region == 'P' || region == 'p')
    # Pointers:
    .set raceDataBase, 0x809c28d8
    .set sectionMgrBase, 0x809c1e38

    # Return Address:
    .set return, 0x80869834
.elseif (region == 'E' || region == 'e')
    # Pointers:
    .set raceDataBase, 0x809c7098
    .set sectionMgrBase, 0x809bd508

    # Return Address:
    .set return, 0x80865404
.elseif (region == 'J' || region == 'j')
    # Pointers:
    .set raceDataBase, 0x809c3878
    .set sectionMgrBase, 0x809c0e98

    # Return Address:
    .set return, 0x80868ea0
.elseif (region == 'K' || region == 'k')
    # Pointers:
    .set raceDataBase, 0x809b4298
    .set sectionMgrBase, 0x809b0478

    # Return Address:
    .set return, 0x80857bf4
.else
    .err
.endif

.set MODE_BATTLE, 0x3
.set BATTLE_BALLOON, 0
.set MODE_MISSION_RUN_COMPETITION, 0x4
.set MR_MODE_ENEMYDOWN02, 0x6
.set MR_MODE_LAPRUN01, 0x1
.set SECTION_MISSION_RUN, 0x2c

# Is the current game mode Mission Mode and current mission type a Boss Battle or Time Trial?
cmpwi cr1, r0, MODE_BATTLE
cmpwi cr2, r0, MODE_MISSION_RUN_COMPETITION
crxor 4*cr0+eq, 4*cr1+eq, 4*cr2+eq
bne end
lis r4, raceDataBase@h
cmpwi r0, MODE_BATTLE
lwz r4, -raceDataBase@l (r4)
bne objectiveCheck

# Balloon Battle check
lwz r0, 0xB78 (r4)                                  # racedata->racesScenario->settings->battleType
cmpwi r0, BATTLE_BALLOON
beq enableBalloonManager

objectiveCheck:
lhz r0, 0xB9E (r4)                                  # racedata->racesScenario->settings->missionType
cmpwi r0, MR_MODE_ENEMYDOWN02
beq kmtCheck
cmpwi r0, MR_MODE_LAPRUN01
bne end

# Check mission_single.kmt. Offset 0x2b, a byte the Custom Mario Kart Wiiki presumes is padding, must be 1.
kmtCheck:
addi r5, r4, 0xB9C                                  # mission_single.kmt
lbz r0, 0x2b (r5)
cmpwi r0, 1                                         # if (enableBalloonManager == TRUE)
bne end

# Are we in Mission Mode?
sectionCheck:
lis r4, sectionMgrBase@h
lwz r4, sectionMgrBase@l (r4)
lwz r4, 0xc (r4)                                    # sectionMgr->currentSection
cmpwi r4, SECTION_MISSION_RUN
beq enableBalloonManager

end:
lis r12, return@h
ori r12, r12, return@l
mtctr r12
bctr

enableBalloonManager:
li r3, 0x4f8                                        # Original instruction