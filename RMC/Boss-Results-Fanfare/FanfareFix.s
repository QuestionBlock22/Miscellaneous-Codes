# Play the Boss Win Music After Beating a Boss Tournament/Competition [QB22]

# Inject @
# PAL   : 80711fac
# NTSC-U: 8070a508
# NTSC-J: 80711618
# NTSC-K: 80700354

.set region, '' # Fill with P, E, J, or K to assemble for a particular region.
.if (region == 'P' || region == 'p')
    .set WC24Mgr_getTournamentData, 0x8066c8d8
    .set raceDataBase, 0x809c28d8
    .set distmap_file_ptr, 0x809c2144
.elseif (region == 'E' || region == 'e')
    .set WC24Mgr_getTournamentData, 0x80665174
    .set raceDataBase, 0x809c7098
    .set distmap_file_ptr, 0x809cd964
.elseif (region == 'J' || region == 'j')
    .set WC24Mgr_getTournamentData, 0x8066bf44
    .set raceDataBase, 0x809c3878
    .set distmap_file_ptr, 0x809c11a4
.elseif (region == 'K' || region == 'k)
    .set WC24Mgr_getTournamentData, 0x8065ac30
    .set raceDataBase, 0x809b4298
    .set distmap_file_ptr, 0x809b0784
.else
    .err
.endif

lis r3, raceDataBase@h                     # Original instruction
lwz r3, -raceDataBase@l (r3)
lwz r0, 0xB90 (r3)                         # racedata->racesScenario->settings->modeFlags
rlwinm. r0, r0, 0, 0x1d, 0x1d
beq end
lis r3, distmap_file_ptr@h
li r0, 0
stb r0, 0x8 (sp)
addi r4, sp, 0x8
lwz r3, distmap_file_ptr@l (r3)
cmpwi r3, 0
beq end
lis r12, WC24Mgr_getTournamentData@h
stw r0, 0xc (sp)
ori r12, r12, WC24Mgr_getTournamentData@l
mtctr r12
bctrl                                      # WC24Mgr::getTournamentData
lwz r3, 0xc (sp)
lbz r0, 0x44 (r3)                          # compFile->introSetting
stw r0, 0x74 (r30)                         # Store the intro setting.

end:
lis r3, raceDataBase@h