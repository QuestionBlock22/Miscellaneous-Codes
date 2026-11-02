# Use a lower Blue Shell speed, creating an effect similar to Mario Kart DS.

# Inject @:
# PAL   : 807ae060
# NTSC-U: 807a33b8
# NTSC-J: 807ad6cc
# NTSC-K: 8079c420

.set DODGE_SUCCESS, 0x1

lbz r0, 0x2f7 (r30)              # itemObjKouraTogezo->playerSelfDodgeStatus (Non-existant in the original game)
cmpwi r0, DODGE_SUCCESS
bne originalDistance

# Use a more visually appealing Blue Shell speed.
lfs f1, 0x168 (r31)             # float speed = 0.15f
b end

originalDistance:
lfs f1, 0x16c (r31)             # float speed = 0.25f (Original instruction)

end: