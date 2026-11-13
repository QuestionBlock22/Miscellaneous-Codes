## Building

To build the gecko code, download the software "PyiiASMH" from its releases section on [Github](https://github.com/JoshuaMKW/pyiiasmh). Avoid cloning the repository. 

Make a new folder in the empty "tools" folder called "pyiiasmh" if it does not already exist and navigate into it. Download the release file named "python3.8.rar" and extract it in place in the "pyiiasmh" folder. 

If done correctly, the contetns of the entire archive, including python files, should appear. If not and it extracted to a folder named "python3.8," move the folder out of the "pyiiasmh" directory, delete it, and then rename the "python3.8" to "pyiiasmh."

### Mark Files as Executable

Depending on your operating system, you may need to mark relevant files as executable. On most Linux distros, it's as simple as right clicking the file, going to "Properties," and then, in the permissions section, checking the box that says "Make executable."

However, on some distros and macOS, this GUI option does not exist.

In order to run the script, the following files need to be made executable first:

```
Pyiiasmh program files:

	children_ui.py
	errors.py
	mainwindow_ui.py
	ppctools.py
	pyiiasmh_cli.py
	pyiiasmh.py
	setup.py

PowerPC assemblers inside the "lib" directory:

Linux (in lib/linux_x86_64):
	powerpc-eabi-as  
	powerpc-eabi-ld  
	powerpc-eabi-objcopy 
	vdappc
	
macOS (in lib/darwin):
	powerpc-eabi-as 
	powerpc-eabi-ld
	powerpc-eabi-objcopy
	vdappc
```

Run the following command to make these files executable:

```
chmod 755 [ Files from the above. ]
```

### Running

To run the build script, run any of these commands at the root of the repository.:

```
python Assemble.py

or

./Assemble.py
```
