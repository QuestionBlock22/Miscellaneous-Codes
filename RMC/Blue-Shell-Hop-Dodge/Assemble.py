#!/usr/bin/python

import sys
import subprocess
import shutil
import os

from pathlib import Path
from collections import OrderedDict

pyiiasmh = "tools/pyiiasmh/pyiiasmh_cli.py"

'''
Download PyiiASMH from the releases section. Don't clone the repository.

'''

codeName = "Dodge Blue Shell with Timed Hop and Mini-Turbo [QB22]"
codeDesc = "Dodge the Blue Shell with a well-timed hop and mini-turbo."

def getRegion():
    regionLetter = input("Input the letters P, E, J or K for your region. Or type 'all' to assemble every region.\n")
    if regionLetter == "all":
        return regionLetter
    if len(regionLetter) > 1:
            print ("No more than one character can be input. Exiting.\n")
            sys.exit()
    if regionLetter == 'p' or regionLetter == 'P' or regionLetter == 'e' or regionLetter == 'E' or regionLetter == 'j' or regionLetter == 'J' or regionLetter == 'k' or regionLetter == 'K':
        return regionLetter
    else:
        print("Only input the letters, P, E, J, or K, or the word 'all.' Exiting.")
        sys.exit()

def processRegion(regionLetter):
    if regionLetter == 'p' or regionLetter == 'P':
        region = "RMCP01"
    elif regionLetter == 'e' or regionLetter == 'E':
        region = "RMCE01"
    elif regionLetter == 'j' or regionLetter == 'J':
        region = "RMCJ01"
    elif regionLetter == 'k' or regionLetter == 'k':
        region = "RMCK01"
    else:
        print ("Invalid character(s) entered.")
        sys.exit()

    return region

def getBaseAddress(regionLetter):
    # C2 Base Addresses
    CheckSelfDodgeStatus = "807addac"
    CinematicDistance = "807ae060"
    KouraTogezoHopDodge = "807add74"
    ResetSelfDodgeStatus = "807b3ef8"

    # A list of C2 hooks
    baseAddress = [
        CheckSelfDodgeStatus,
        CinematicDistance,
        KouraTogezoHopDodge,
        ResetSelfDodgeStatus
    ]

    list(OrderedDict.fromkeys(baseAddress))

    if regionLetter == 'p' or regionLetter == 'P':
        return baseAddress

    elif regionLetter == 'e' or regionLetter == 'E':
        baseAddress[0] = "807a3104"
        baseAddress[1] = "807a33b8"
        baseAddress[2] = "807a30cc"
        baseAddress[3] = "807a5498"

    elif regionLetter == 'j' or regionLetter == 'J':
        baseAddress[0] = "807ad418"
        baseAddress[1] = "807ad6cc"
        baseAddress[2] = "807ad3e0"
        baseAddress[3] = "807b3564"

    elif regionLetter == 'k' or regionLetter == 'K':
        baseAddress[0] = "8079c16c"
        baseAddress[1] = "8079c420"
        baseAddress[2] = "8079c134"
        baseAddress[3] = "807a22b8"

    return baseAddress    

def assembleFromFile(regionLetter, curDir, addressCycle, finalOut):
    baseAddress = getBaseAddress(regionLetter)

    # The current working directory is unaware that this file is needed so let's copy it.
    includeFile = "__includes.s"
    shutil.copyfile(f"tools/pyiiasmh/{includeFile}", f"{includeFile}")

    tempCode = "tmp.s"
    asmOut = "asmOut.txt"

    for file in sorted(Path(curDir).rglob('*.s')):
        codeFile = f"{curDir}/{file.name}"

        currentFile = file.name

        with open(codeFile, 'r') as code, open(tempCode, 'w') as tmp:
            if currentFile == "KouraTogezoHopDodge.s":
                tmp.write(f".set region, '{regionLetter}'\n")
            for line in code:
                tmp.write(line)

        print(baseAddress[addressCycle])
        print(currentFile)

        subprocess.run(["python", pyiiasmh, tempCode, 'a', '--dest', asmOut, '--codetype', 'C2D2', '--bapo', f'{baseAddress[addressCycle]}'])

        with open(asmOut, 'r') as scratchAssembly, open(finalOut, 'a') as codeOutput:
            for line in scratchAssembly:
                codeOutput.write(line)
            codeOutput.write("\n")

        if addressCycle == 3:
            os.remove(includeFile)
            os.remove(tempCode)
            os.remove(asmOut)
            break

        addressCycle += 1    

def assembleASMCode(regionLetter, finalOut):
    curDir = "src"
    addressCycle = 0

    assembleFromFile(regionLetter, curDir, addressCycle, finalOut)

def assembleCode(region, regionLetter, finalOut):
    with open(f"{region}.txt", 'w') as codeOutput:
        codeOutput.write(f"{region}\n")
        codeOutput.write("Mario Kart Wii\n\n")
        codeOutput.write(f"{codeName}\n")
        assembleASMCode(regionLetter, finalOut)
        with open(finalOut, 'r') as finalAssembly:
            for line in finalAssembly:
                codeOutput.write(line)
    with open(f"{region}.txt", 'a') as codeOutput:
        codeOutput.write(f"\n{codeDesc}")

def writeAssembly(regionLetter):
    region = processRegion(regionLetter)
    finalOut = "finalOut.txt"
    codeFile = Path(f"{region}.txt")
    if codeFile.is_file():
        os.remove(codeFile)
    assembleCode(region, regionLetter, finalOut)
    os.remove(finalOut)

def prepareAssembly():
    regionLetter = getRegion()
    if regionLetter == "all":
        regionList = [
            'p',
            'e',
            'j',
            'k'
        ]
        regionCycle = 0
        marketList = [
            "Europe",
            "North America",
            "Japan",
            "South Korea"
        ]

        for entry in regionList:
            print(f"\nAssembling for {marketList[regionCycle]}.\n")
            regionLetter = regionList[regionCycle]
            writeAssembly(regionLetter)
            regionCycle += 1

        return

    writeAssembly(regionLetter)

'''
def clearPyiiASMHError(error_log):
    if error_log.is_file():
        with open(error_log, 'w') as error_file:
            pass
'''

def main():
    pyiiasmh_path = Path(pyiiasmh)
    if pyiiasmh_path.is_file():
        print("System check passed.\n")
        # error_log = Path("logs/error.log") # Symlink to PyiiASMH error file
        # clearPyiiASMHError(error_log)
        prepareAssembly()
        print("\nOperation completed successfully.")
    else:
        print("PyiiASMH is required for this build script to function. Download PyiiASMH from 'https://github.com/JoshuaMKW/pyiiasmh' from the releases section and put it inside the tools directory.\n")
        sys.exit

main()
