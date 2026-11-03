# Set state flags for dodging the Blue Shell.

# Inject @:
# PAL   : 807add74
# NTSC-U: 807a30cc
# NTSC-J: 807ad3e0	
# NTSC-K: 8079c134

# .set region, '' # Fill with P, E, J, or K to assemble for a particular region.
.if (region == 'P' || region == 'p')
    # Pointers
    .set raceDataBase, 0x809c28d8

    # Return Address
    .set return, 0x807addac
.elseif (region == 'E' || region == 'e')
    .set return, 0x807a3104
.elseif (region == 'J' || region == 'j')
    .set return, 0x807ad418
.elseif (region == 'K' || region == 'k')
    .set return, 0x8079c16c
.else
    .err
.endif

.set DODGE_FAILED, 0
.set DODGE_SUCCESS, 0x1
.set DODGE_ASSISTED, 0x2

# Check if the player's dodge status was assisted. Fixes Mushroom dodges getting borked by the below.
lbz r0, 0x2f7 (r30)
cmpwi r0, DODGE_ASSISTED
beq end

# Did the player's hop end?
# itemObjKouraTogezo->targetedPlayer->playerPointers->kartStatus->kartActionBitfield & HOP
lwz r3, 0x280 (r30)
lwz r3, 0 (r3)
lwz r3, 0x4 (r3)
lwz r0, 0x4 (r3)
rlwinm. r0, r0, 0, 12, 12       # (kartActionBitfield & HOP) != 0
beq revokeDodge

# Is the player still in a SMT boost? Generalized mini-turbo check.
# itemObjKouraTogezo->targetedPlayer->playerPointers->kartStatus->kartStateBitfield & MINI-TURBO
lwz r0, 0x8 (r3)
rlwinm. r0, r0, 0, 11, 11       # (kartStateBitfield & MINI-TURBO) != 0
beq revokeDodge

# Set the dodge state to true.
lis r12, return@h
li r0, DODGE_SUCCESS
ori r12, r12, return@l
stb r0, 0x2f7 (r30)             # Unused byte of memory in itemObjKouraTogezo. Let's call this "playerSelfDodgeStatus"
mtctr r12
bctr

revokeDodge:
# Revoke dodge status if the conditions are no longer true and the player is no longer in the hop state.
li r0, DODGE_FAILED
stb r0, 0x2f6 (r30)
stb r0, 0x2f7 (r30)

end:
lwz r3, 0x280 (r30)             # Original instruction
