# Force the Giant Pokey into the idle state if the player failed the mission. 
# Won't stop rolling segments from hitting the player if past phase 1 but will stop the Giant Pokey from infinitely throwing segments at the player. 

# Inject @:
# PAL   : 80759ac4
# NTSC-U: 807715e0
# NTSC-J: 80759130
# NTSC-K: 80747e84

# .set region, '' # Fill with P, E, J, or K to assemble for a particular region.
.if (region == 'P' || region == 'p')
    # Pointers
    .set raceInfoBase, 0x809c28d0
    .set sectionMgrBase, 0x809c1e38

    # Functions
    .set AnimationMgr_playAnimation, 0x80557684

    # Return Address
    .set return, 0x80759b70
.elseif (region == 'E' || region == 'e')
    # Pointers
    .set raceInfoBase, 0x809c7090
    .set sectionMgrBase, 0x809bd508

    # Functions
    .set AnimationMgr_playAnimation, 0x80553304

    # Return Address
    .set return, 0x8077168c
.elseif (regoin == 'J' || region == 'j')
    # Pointers
    .set raceInfoBase, 0x809c3870
    .set sectionMgrBase, 0x809c0e98

    # Functions
    .set AnimationMgr_playAnimation, 0x80557004

    # Return Address
    .set return, 0x807591dc
.elseif (region == 'K' || region == 'k')
    # Pointers
    .set raceInfoBase, 0x809b4290
    .set sectionMgrBase, 0x809b0478

    # Functions
    .set AnimationMgr_playAnimation, 0x805456dc

    # Return Address
    .set return, 0x80747f30
.else
    .err
.endif

.set SECTION_COMPETITION, 0x2d

# Are we in Tournament Mode?
lis r11, sectionMgrBase@h
lwz r12, sectionMgrBase@l (r11)
lwz r12, 0 (r12)
cmpwi r12, 0
beq end
lwz r0, 0 (r12)                                             # sectionMgr->currentSection
cmpwi r0, SECTION_COMPETITION
beq end

# Get Mission Mode failure flags. Credit to 456 for deriving the logic for this game state.
lwz r12, -raceInfoBase@l (r11)
lwz r6, 0x14 (r12)
lbz r0, 0xf (r6)
cmpwi r0, 0x72
bne end
lhz r0, 0x9 (r6)
cmpwi r0, 0x633b
bne end                                                      # GeoObjectSanboBig::setQuicksandState

# Check if the Giant Pokey collided with another entity.
lbz r0, 0xf0 (r30)                                          # GeoObjectSanboBig->collidedWithEntity
cmpwi r0, 0x1
beq mrEnd

# Replace the current animation with the idle animation.
lwz r3, 0x8 (r30)
li r4, 0
lfs f1, 0 (r31)
lis r12, AnimationMgr_playAnimation@h
li r5, 0x1
ori r12, r12, AnimationMgr_playAnimation@l
lwz r3, 0x28 (r3)
mtctr r12
lfs f2, 0x3c (r31)
bctrl                                                       # AnimMgr::playAnim

mrEnd:
lis r12, return@h
ori r12, r12, return@l
mtctr r12
bctr

end:
lwz r4, 0xfc (r30)                                          # Original instruction