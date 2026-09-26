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

codeName = "Force Bosses to Idle on Mission Fail [QB22]"
codeDesc = "Resets boss objects to the idle state if the player fails the mission."

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
    GeoObjectBegoman_ForceIdleOnMissionFail = "807549d0"
    GeoObjectSanboBig_ForceIdleOnMissionFail = "80759ac4"

    # A list of C2 hooks
    baseAddress = [
        GeoObjectBegoman_ForceIdleOnMissionFail,
        GeoObjectSanboBig_ForceIdleOnMissionFail
    ]

    list(OrderedDict.fromkeys(baseAddress))

    if regionLetter == 'p' or regionLetter == 'P':
        return baseAddress
    elif regionLetter == 'e' or regionLetter == 'E':
        baseAddress[0] = "8074cd54"
        baseAddress[1] = "807715e0"

    elif regionLetter == 'j' or regionLetter == 'J':
        baseAddress[0] = "8075403c"
        baseAddress[1] = "80759130"

    elif regionLetter == 'k' or regionLetter == 'K':
        baseAddress[0] = "80742d90"
        baseAddress[1] = "80747e84"

    return baseAddress

def writeTempFile(regionLetter, finalOut, addressCycle, baseAddress, tempCode, asmOut, codeFile, file):
    with open(codeFile, 'r') as code, open(tempCode, 'w') as tmp:
        tmp.write(f".set region, '{regionLetter}'\n\n")
        for line in code:
            tmp.write(line)

    print(baseAddress[addressCycle])
    print(f"{file.name}\n")

    subprocess.run(["python", pyiiasmh, tempCode, 'a', '--dest', asmOut, '--codetype', 'C2D2', '--bapo', f'{baseAddress[addressCycle]}'])

    with open(asmOut, 'r') as scratchAssembly, open(finalOut, 'a') as codeOutput:
        for line in scratchAssembly:
            codeOutput.write(line)
        codeOutput.write("\n")

def assembleFromFile(regionLetter, finalOut, curDir, addressCycle):
    baseAddress = getBaseAddress(regionLetter)

    # The current working directory is unaware that this file is needed so let's copy it.
    includeFile = "__includes.s"
    shutil.copyfile(f"tools/pyiiasmh/{includeFile}", f"{includeFile}")

    tempCode = "tmp.s"
    asmOut = "asmOut.txt"

    for file in sorted(Path(curDir).rglob('*.s')):
        codeFile = f"{curDir}/{file.name}"

        writeTempFile(regionLetter, finalOut, addressCycle, baseAddress, tempCode, asmOut, codeFile, file)

        if addressCycle == 0:
            return
        
        if addressCycle == 1:
            os.remove(includeFile)
            os.remove(tempCode)
            os.remove(asmOut)

def assembleASMCode(regionLetter, finalOut):
    BegomanDir = "src/GeoObjectBegoman"
    SanboBigDir = "src/GeoObjectSanboBig"
    addressCycle = 0

    curDir = BegomanDir
    assembleFromFile(regionLetter, finalOut, curDir, addressCycle)

    addressCycle += 1
    curDir = SanboBigDir
    assembleFromFile(regionLetter, finalOut, curDir, addressCycle)

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
    finalOut = "finalOut.txt"
    region = processRegion(regionLetter)
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

def main():
    pyiiasmh_path = Path(pyiiasmh)
    if pyiiasmh_path.is_file():
        print("System check passed.\n")
        prepareAssembly()
        print("\nOperation completed successfully.")
    else:
        print("PyiiASMH is required for this build script to function. Download PyiiASMH from 'https://github.com/JoshuaMKW/pyiiasmh' from the releases section and put it inside the tools directory.\n")
        sys.exit

main()
