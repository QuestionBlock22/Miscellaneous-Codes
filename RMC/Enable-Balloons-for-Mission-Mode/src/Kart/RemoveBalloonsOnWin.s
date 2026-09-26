# Make Boss Mission ending scene consistent with Balloon Battle.

# Inject @:
# PAL   : 805965f0
# NTSC-U: 8058fdcc
# NTSC-J: 80595f70
# NTSC-K: 80584648

# .set region, '' # Fill with P, E, J, or K to assemble for a particular region.
.if (region == 'P' || region == 'p')
    # Pointers:
    .set raceDataBase, 0x809c28d8
    .set raceInfoBase, 0x809c28d0

    # Return Address:
    .set return, 0x80596600
.elseif (region == 'E' || region == 'e')
    # Pointers:
    .set raceDataBase, 0x809c7098
    .set raceInfoBase, 0x809c7090

    # Return Address:
    .set return, 0x8058fddc
.elseif (region == 'J' || region == 'j')
    # Pointers:
    .set raceDataBase, 0x809c3878
    .set raceInfoBase, 0x809c3870

    # Return Address:
    .set return, 0x80595f80
.elseif (region == 'K' || region == 'k')
    # Pointers:
    .set raceDataBase, 0x809b4298
    .set raceInfoBase, 0x809b4290
    
    # Return Address:
    .set return, 0x80584658
.else
    .err
.endif

.set MODE_MISSION_RUN_COMPETITION, 0x4
.set MR_MODE_ENEMYDOWN02, 0x6
.set MR_MODE_LAPRUN01, 0x1

# Setup Racedata
lis r12, raceDataBase@h
lwz r11, -raceDataBase@l (r12)

# Check mission_single.kmt
addi r6, r11, 0xB9C                             # mission_single.kmt
lbz r0, 0x2b (r6)
cmpwi r0, 1                                     # if (enableBalloonManager == TRUE)
bne end

# Is the current game mode Mission Mode and current mission type a Boss Battle or Time Trial?
lwz r0, 0xB70 (r11)
lhz r6, 0xB9E (r11)
cmpwi cr1, r0, MODE_MISSION_RUN_COMPETITION
cmpwi cr2, r6, MR_MODE_ENEMYDOWN02
crand 4*cr0+eq, 4*cr1+eq, 4*cr2+eq
beq raceStatusCheck
cmpwi cr2, r6, MR_MODE_LAPRUN01
crand 4*cr0+eq, 4*cr1+eq, 4*cr2+eq
bne end

# Has the race ended?
raceStatusCheck:
lwz r11, -raceInfoBase@l (r12)
lwz r0, 0x28 (r11)
cmpwi r0, 4
bne end

# Fix a bug where the mission type "LapRun01" disables the winning animation if one of the upper bits were set. Balloons only need to be hidden once.
cmpwi r6, MR_MODE_LAPRUN01
bne mrEnd
li r0, 0x1
slwi r0, r0, 20
sub r4, r4, r0
lwz r3, 0x4 (r3)
stw r4, 0x14 (r3)

# Force Battle Mode ending routine.
mrEnd:
lis r12, return@h
ori r12, r12, return@l
mtctr r12
bctr

end:
rlwinm. r0, r4, 0, 12, 12                           # Original instruction