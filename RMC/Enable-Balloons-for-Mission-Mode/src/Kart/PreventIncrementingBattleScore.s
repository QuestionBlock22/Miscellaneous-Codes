# Fix a crash caused by the game incrementing a non-existent team score counter.

# Hook 1 - Prevent incrementing the score after getting hit by an item.:
# PAL   : 8053887c
# NTSC-U: 80533d34
# NTSC-J: 805381fc
# NTSC-K: 805268d4

# Hook 2 - Prevent incrementing the score after getting hit by an object or crossing a fall boundary.:
# PAL   : 80538c6c
# NTSC-U: 80534124
# NTSC-J: 805385ec
# NTSC-K: 80526cc4

# Hook 3 - Prevent incrementing the score after getting hit by cactus collision.:
# PAL   : 80538d8c
# NTSC-U: 80534244
# NTSC-J: 8053870c
# NTSC-K: 80526de4

# .set region, '' # Fill with P, E, J, or K to assemble for a particular region.
# .set version, '' # Fill with 1, 2, or 3 to assemble for a particular hook.

.if (region == 'P' || region == 'p')
    .set raceDataBase, 0x809c28d8
.elseif (region == 'E' || region == 'e')
    .set raceDataBase, 0x809c7098
.elseif (region == 'J' || region == 'j')
    .set raceDataBase, 0x809c3878
.elseif (region == 'K' || region == 'k')
    .set raceDataBase, 0x809b4298
.else
    .err
.endif

.if (version == '1')
    .if (region == 'P' || region == 'p')
        .set return, 0x80538980
    .elseif (region == 'E' || region == 'e')
        .set return, 0x80533e38
    .elseif (region == 'J' || region == 'j')
        .set return, 0x80538300
    .elseif (region == 'K' || region == 'k')
        .set return, 0x805269d8
    .else
        .err
    .endif

	.macro originalInstruction
		cmpwi r31, 0
	.endm
.elseif (version == '2' || version == '3')
    .if (region == 'P' || region == 'p')
        .if (version == '2')
            .set return, 0x80538ccc
        .endif

        .if (version == '3')
            .set return, 0x80538dec
        .endif
    .elseif (region == 'E' || region == 'e')
        .if (version == '2')
            .set return, 0x80534184
        .endif

        .if (version == '3')
            .set return, 0x805342a4
        .endif
    .elseif (region == 'J' || region == 'j')
        .if (version == '2')
            .set return, 0x8053864c
        .endif

        .if (version == '3')
            .set return, 0x8053876c
        .endif
    .elseif (region == 'K' || region == 'k')
        .if (version == '2')
            .set return, 0x80526d24
        .endif

        .if (version == '3')
            .set return, 0x80526e44
        .endif
    .else
        .err
    .endif

    .macro originalInstruction
		lwz r3, 0x4 (r29)
	.endm
.else
    .err
.endif

.set MODE_MISSION_RUN_COMPETITION, 0x4
.set MR_MODE_ENEMYDOWN02, 0x6
.set MR_MODE_LAPRUN01, 0x1

# Setup Racedata
lis r11, raceDataBase@h
lwz r11, -raceDataBase@l (r11)

# Check mission_single.kmt
addi r12, r11, 0xB9C
lbz r0, 0x2b (r12)
cmpwi r0, 1
bne end                                         # if (enableBalloonManager == TRUE)

# Is the current game mode Mission Mode and current mission type a Boss Battle or Time Trial?
lwz r0, 0xB70 (r11)                             # racedata->racesScenario->settings->gameMode
lhz r11, 0xB9E (r11)                            # racedata->racesScenario->settings->missionType
cmpwi cr1, r0, MODE_MISSION_RUN_COMPETITION
cmpwi cr2, r11, MR_MODE_ENEMYDOWN02
crand 4*cr0+eq, 4*cr1+eq, 4*cr2+eq
beq skipBattleScoreRoutine
cmpwi cr2, r11, MR_MODE_LAPRUN01
crand 4*cr0+eq, 4*cr1+eq, 4*cr2+eq
bne end

# Return
skipBattleScoreRoutine:
lis r12, return@h
ori r12, r12, return@l
mtctr r12
bctr

end:
originalInstruction