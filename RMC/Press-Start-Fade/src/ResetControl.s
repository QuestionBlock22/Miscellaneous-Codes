# Reset the control.

# Inject @:
# PAL   : 807e9c74
# NTSC-U: 807e03c8
# NTSC-J: 807e92e0
# NTSC-K: 807d8034


# Reset fade out boolean.
mr r4, r30
subi r4, r4, 0x54       # Hack: Derive the TitlePage class simply by subtracting the offset to the CtrlMenuPressStart pointer.
li r0, 0
stb r0, 0x356 (r4)      # TitlePage->fadeOutStarted (Padding, apparently.)

# Reset reverse boolean.
lwz r4, 0 (r3)
li r0, 0
addi r4, r4, 0x10
stb r0, 0xc (r4)
lis r31, 0x808b         # Original instruction