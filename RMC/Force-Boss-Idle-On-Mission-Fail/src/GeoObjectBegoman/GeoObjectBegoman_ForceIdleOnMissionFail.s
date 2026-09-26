# Force the Spiky Topmen into the idle state if the player failed the mission. 

# Inject @:
# PAL   : 807549d0
# NTSC-U: 8074cd54
# NTSC-J: 8075403c
# NTSC-K: 80742d90

# .set region, '' # Fill with P, E, J, or K to assemble for a particular region.
.if (region == 'P' || region == 'p')
    .set raceInfoBase, 0x809c28d0
    .set sectionMgrBase, 0x809c1e38
.elseif (region == 'E' || region == 'e')
    .set raceInfoBase, 0x809c7090
    .set sectionMgrBase, 0x809bd508
.elseif (region == 'J' || region == 'j')
    .set raceInfoBase, 0x809c3870
    .set sectionMgrBase, 0x809c0e98
.elseif (region == 'K' || region == 'k')
    .set raceInfoBase, 0x809b4290
    .set sectionMgrBase, 0x809b0478
.else
    .err
.endif

.set SECTION_COMPETITION, 0x2d
.set default_idle, 0
.set case_facePlayer, 0x4

/*
default_idle (default)
case_startSpin (case 1)
case_startCharge (case 2)
case_move (case 3)
case_facePlayer (case 4)
case_attack (case 5)
case_unknown6 (case 6)
case_turn (case 7)
case_hide (case 8) Tells ModelDirector to set the opacity to 0.
case_cower (case 9)
case_delete (case 10) This one's neat in that they shrink like players do at the end of a Ghost Replay.
 */

# Are we in Tournament Mode?
lis r12, sectionMgrBase@h
lwz r11, sectionMgrBase@l (r12)
lwz r11, 0 (r11)
cmpwi r11, 0
beq end
lwz r6, 0 (r11)                                         # sectionMgr->currentSection
cmpwi r6, SECTION_COMPETITION
beq end

# Get Mission Mode failure flags. Credit to 456 for deriving the logic for this game state.
lwz r11, -raceInfoBase@l (r12)
lwz r12, 0x14 (r11)
lbz r6, 0xf (r12)
cmpwi r6, 0x72
bne end
lhz r6, 0x9 (r12)
cmpwi r6, 0x633b
bne end

# Set animation playback state.
lwz r6, 0x1c (r29)                                      
lwz r0, 0x20 (r6)                                       # GeoObjectBegomanSpike->values->bitfield

# Was this bit set already?
srwi r0, r0, 24
cmpwi r0, 0x1
beq setAnimation

# Set bitfield.
lwz r0, 0x20 (r6)
li r8, 0x1
slwi r8, r8, 24
add r0, r0, r8
stw r0, 0x20 (r6)

setAnimation:
li r0, 0xb4
stw r0, 0x180 (r29)
li r0, 0x5
stw r0, 0x19c (r29)                                     # GeoObjectBegomanSpike.nextAnimation = 5;
li r0, case_facePlayer                                  # Used to be the default case, but this one ended up looking prettier.
stw r0, 0xb0 (r29)                                      # GeoObjectBegomanSpike.action = 4;

end:
cmplwi r0, 0xa