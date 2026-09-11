# Start playback.

# Inject @:
# PAL   : 8086a218
# NTSC-U: 80865de8
# NTSC-J: 80869884
# NTSC-K: 808585d8

# .set region, '' # Fill with P, E, J, or K to assemble for a particular region.
.if (region == 'P' || region == 'p')
    .set GeoObjectBalloonProxy, 0x808b2218 # Port this manually
    .set GeoObject_startSound, 0x80871684
    .set KartObjectProxy_getSound, 0x80590794
    .set KartObjectManager_getObject, 0x80590100
    .set PlayerHolder_player, 0x809c18f8 # Port this manually
.elseif (region == 'E' || region == 'e')
    .set GeoObjectBalloonProxy, 0x808ade50
    .set GeoObject_startSound, 0x8087d9fc
    .set KartObjectProxy_getSound, 0x80589f70
    .set KartObjectManager_getObject, 0x805898dc
    .set PlayerHolder_player, 0x809cd110
.elseif (region == 'J' || region == 'j')
    .set GeoObjectBalloonProxy, 0x808b1378
    .set GeoObject_startSound, 0x80870cf0
    .set KartObjectProxy_getSound, 0x80590114
    .set KartObjectManager_getObject, 0x8058fa80
    .set PlayerHolder_player, 0x809c0958
.elseif (region == 'K' || region == 'k')
    .set GeoObjectBalloonProxy, 0x808604d8
    .set GeoObject_startSound, 0x8085fa44
    .set KartObjectProxy_getSound, 0x8057e7ec
    .set KartObjectManager_getObject, 0x8057e158
    .set PlayerHolder_player, 0x809bff38
.else
    .err
.endif

# .set SE_CC_BALLOON_GET, 0x1f5                     # Uncomment if you don't want the sound ID fix or you refuse to/unable to use PyiiASMH.
.set SE_CC_BALLOON_TAKE, 0x1f8                      # Explanation below.

/*
Just like "SE_ITM_THNDR_SMALL," this sound effect also went unused. The difference between the above sound effect
and the used variant: "SE_CC_BALLOON_GET," is mainly the decay ratio, so this variant of the sound will play for
longer.
*/

stb r0, 0x3c4 (r29)                                 # Store victim balloon count (Original instruction)
cmpwi r23, 5                                        # Don't play the sound if the recipient is at max balloon count.
beq end

# Is the player a CPU?
lis r3, PlayerHolder_player@h
lis r12, KartObjectManager_getObject@h
lwz r3, PlayerHolder_player@l (r3)
ori r12, r12, KartObjectManager_getObject@l
lbz r4, 0 (r7)
mtctr r12
bctrl
lis r12, KartObjectProxy_getSound@h
ori r12, r12, KartObjectProxy_getSound@l
mtctr r12
bctrl
lbz r0, 0xe0 (r3)
cmpwi r0, 0
beq end                                             # End if true.
lwz r3, 0x4 (r27)                                   # Get the recipient's new balloon address from r27.
li r4, SE_CC_BALLOON_TAKE
lis r12, GeoObject_startSound@h
lis r5, GeoObjectBalloonProxy@h
ori r12, r12, GeoObject_startSound@l
lfs f1, GeoObjectBalloonProxy@l (r5)
mtctr r12
bctrl

end: