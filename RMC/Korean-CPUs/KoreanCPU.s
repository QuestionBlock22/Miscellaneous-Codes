# Korean CPUs [QB22]

# Inject @:
# PAL   : 80742b84
# NTSC-U: 80732cb8
# NTSC-J: 807421f0
# NTSC-K: N/A

.set region, '' # Fill with P, E, or J to assemble for a particular region.
.if (region == 'P' || region == 'p')
    .set raceDataBase, 0x809c28d8
.elseif (region == 'E' || region == 'e')
    .set raceDataBase, 0x809c7098
.elseif (region == 'J' || region == 'j')
    .set raceDataBase, 0x809c3878
.else
    .err
.endif

.macro is_MISSION_RUN_COMPETITION
    rlwinm r0, r0, 0, 0x1d, 0x1d
    cmpwi r0, 0x4
.endm

lis r12, raceDataBase@h
lha r4, 0x20 (r29)                      # Original instruction
lwz r12, -raceDataBase@l (r12)
lwz r0, 0xB90 (r12)                     # racedata->scenario->settings->modeFlags
is_MISSION_RUN_COMPETITION
beq end                                 # 80% probability for tournaments/competitions only.
li r4, 0x28
end: