# Inject @:
# PAL   : 807addac
# NTSC-U: 807a3104
# NTSC-J: 807ad418
# NTSC-K: 8079c16c

.set DODGE_SUCCESS, 0x1
.set DODGE_ASSISTED, 0x2

lbz r0, 0x2f7 (r30)     # itemObjKouraTogezo->playerSelfDodgeStatus (Non-existant in the original game)
cmpwi r0, DODGE_SUCCESS
beq end

dodgeWasAssisted:
li r0, DODGE_ASSISTED
stb r0, 0x2f7 (r30)

end:
li r0, 0x1              # Original instruction