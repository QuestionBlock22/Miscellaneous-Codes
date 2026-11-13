# Start the fade out animation.

# Inject @:
# PAL   : 807e9ccc
# NTSC-U: 807e0420
# NTSC-J: 807e9338
# NTSC-K: 807d808c

# .set region, '' # Fill with P, E, J, or K to assemble for a particular region.
.if (region == 'P' || region == 'p')
	# Pointers
	.set sectionMgrBase, 0x809c1e38

	# Functions
	.set Section_getActivePage, 0x80622ea0
	.set Animator_getGroup, 0x8063c820
	.set Group_setAnimation, 0x8063c91c
	.set Group_setAnimationAndDisable, 0x8063cb20
.elseif (region == 'E' || region == 'e')
	# Pointers
    .set sectionMgrBase, 0x809cd508

	# Functions
	.set Section_getActivePage, 0x805f1fec
    .set Animator_getGroup, 0x8060b400
    .set Group_setAnimation, 0x8060b4fc
	.set Group_setAnimationAndDisable, 0x8060b700
.elseif (region == 'J' || region == 'j')
	# Pointers
    .set sectionMgrBase, 0x809c0e98

	# Functions
	.set Section_getActivePage, 0x806225ec
    .set Animator_getGroup, 0x8063be8c
    .set Group_setAnimation, 0x8063bf88
	.set Group_setAnimationAndDisable, 0x8063c18c
.elseif (region == 'K' || region == 'k')
	# Pointers
    .set sectionMgrBase, 0x809b0478

	# Functions
	.set Section_getActivePage, 0x80611298
    .set Animator_getGroup, 0x8062ab38
    .set Group_setAnimation, 0x8062ac34
	.set Group_setAnimationAndDisable, 0x8062ae38
.else
	.err
.endif

.macro push
	stwu sp, -0x10 (sp)
	mflr r0
	stw r0, 0x14 (sp)
	stmw r29, 0x8 (sp)
.endm

.macro pop
	lmw r29, 0x8 (sp)
	lwz r0, 0x14 (sp)
	mtlr r0
	addi sp, sp, 0x10
	blr					               			# Original instruction.
.endm

.set PAGE_TITLE_SCREEN, 0x57

# void CtrlMenuPressStart::calc()

push
mr r30, r3
subi r29, r3, 0x54								# Hack: Derive the TitlePage class simply by subtracting the offset to the CtrlMenuPressStart pointer.
bl getData
	startFrame_fadeIn:
	.float 1.0

	endFrame_fadeIn:
	.float 10.0

	speed:
	.double 1.66666667

getData:
mflr r4
stw r4, 0x18 (sp)				        		# Store our floats in the stack pointer.

# Get the current page.
lis r3, sectionMgrBase@h
lwz r4, sectionMgrBase@l (r3)
cmpwi r4, 0
beq end
lis r12, Section_getActivePage@h
lwz r3, 0 (r4)
ori r12, r12, Section_getActivePage@l
mtctr r12
bctrl											# Section::getActivePage
cmpwi r3, 0
beq end
lwz r0, 0x4 (r3)
cmpwi r0, PAGE_TITLE_SCREEN
bne end

# Is the page exiting?
lwz r0, 0x8 (r3)
cmpwi r0, 5                         			# pageState = Exiting
bne end

# Prepare animation playback.
lbz r0, 0x356 (r29)								# TitlePage->fadeOutStarted (Padding, apparently.)
cmpwi r0, 1										# Did the animation start already?
beq hideControl
li r0, 1
stb r0, 0x356 (r29)								# We've started this animation already. Don't set the animation again.

# Disable the currently running animation.
lwz r5, 0x18 (sp)
li r4, 0
bl getAnimationGroup
li r4, 1
lis r12, Group_setAnimationAndDisable@h
lfs f1, 0 (r5)
ori r12, r12, Group_setAnimationAndDisable@l
mtctr r12
bctrl											# Group::setAnimationInactive

# Start the new animation.
li r4, 0
bl getAnimationGroup
lwz r5, 0x18 (sp)
lfs f1, 0 (r5)
li r4, 1
lwz r6, 0 (r3)
addi r6, r6, 0x10
lis r12, Group_setAnimation@h
lfd f2, 0x8 (r5)								# Get new speed.
ori r12, r12, Group_setAnimation@l
stfs f2, 0x8 (r6)								# Set new speed.
mtctr r12
stb r4, 0xc (r6)								# Reverse/rewind the animation.
bctrl											# Group::setAnimation

# Reset default speed on frame 10.
hideControl:
li r4, 0
bl getAnimationGroup
lwz r5, 0x18 (sp)
lfs f1, 0x4 (r5)
lfs f2, 0x3c (r3)
fcmpo cr0, f2, f1
crand 4*cr0+eq, 4*cr0+eq, 4*cr0+eq
bne end
li r4, 0
bl getAnimationGroup
lwz r5, 0x18 (sp)
lwz r3, 0 (r3)
addi r3, r3, 0x10
lfs f2, 0 (r5)
stfs f2, 0x8 (r3)

end:
pop

getAnimationGroup:
mr r3, r30
lis r12, Animator_getGroup@h
addi r3, r3, 0x98
ori r12, r12, Animator_getGroup@l
mtctr r12
bctr											# Animator::getGroup