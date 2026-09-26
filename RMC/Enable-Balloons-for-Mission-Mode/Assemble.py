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

codeName = "Enable Balloons in Mission Mode [QB22]"
codeDesc = "Enables the balloon object in Mission Mode."

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
        sys.exit

    return region

def getBaseAddress(regionLetter):
    # C2 Base Addresses
    EnableBalloonManager1 = "808697e8"
    EnableBalloonManager2 = "80869818"
    EndOnBalloonDepletion = "8086a0c8"
    HalfWordOverwriteFix = "80535a9c"
    EnableBalloonRemoval = "805729c8"
    EnableInvincibility = "8056747c"
    HookFix = "80573bdc"
    PreventIncrementingBattleScore = "8053887c"
    RemoveBalloonsOnWin = "805965f0"
    RemoveOnItemHit =  "805729d4"
    RemoveOnObjectHit = "80572204"

    # A list of C2 hooks
    baseAddress = [
        EnableBalloonManager1, # 0
        EnableBalloonManager2, # 1
        EndOnBalloonDepletion, # 2
        HalfWordOverwriteFix, # 3
        EnableBalloonRemoval, # 4
        EnableInvincibility, # 5
        HookFix, # 6
        PreventIncrementingBattleScore, # 7
        RemoveBalloonsOnWin, # 8
        RemoveOnItemHit, # 9
        RemoveOnObjectHit, # 10
    ]

    list(OrderedDict.fromkeys(baseAddress))
    baseAddress.sort

    if regionLetter == 'p' or regionLetter == 'P':
        return baseAddress
    elif regionLetter == 'e' or regionLetter == 'E':
        baseAddress[0] = "808653b8"
        baseAddress[1] = "808653e8"
        baseAddress[2] = "80865c98"
        baseAddress[3] = "80530f54"
        baseAddress[4] = "8056db78"
        baseAddress[5] = "805630fc"
        baseAddress[6] = "8056ed8c"
        baseAddress[7] = "80533d34"
        baseAddress[8] = "8058fdcc"
        baseAddress[9] = "8056db84"
        baseAddress[10] = "8056d3b4"
    elif regionLetter == 'j' or regionLetter == 'J':
        baseAddress[0] = "80868e54"
        baseAddress[1] = "80868e84"
        baseAddress[2] = "80869734"
        baseAddress[3] = "8053541c"
        baseAddress[4] = "80572348"
        baseAddress[5] = "80566dfc"
        baseAddress[6] = "8057355c"
        baseAddress[7] = "805381fc"
        baseAddress[8] = "80595f70"
        baseAddress[9] = "80572354"
        baseAddress[10] = "80571b84"
    elif regionLetter == 'k' or regionLetter == 'K':
        baseAddress[0] = "80857ba8"
        baseAddress[1] = "80857bd8"
        baseAddress[2] = "80858488"
        baseAddress[3] = "80523af4"
        baseAddress[4] = "80560a20"
        baseAddress[5] = "805554d4"
        baseAddress[6] = "80561c34"
        baseAddress[7] = "805268d4"
        baseAddress[8] = "80584648"
        baseAddress[9] = "80560a2c"
        baseAddress[10] = "8056025c"

    return baseAddress

def writeTempFile(regionLetter, curDir, addressCycle, baseAddress, tempCode, asmOut, codeFile, file, fileCycle, finalOut, hookVersion):
    with open(codeFile, 'r') as code, open(tempCode, 'w') as tmp:
        tmp.write(f".set region, '{regionLetter}'\n\n")

        if fileCycle >= 10 or fileCycle <= 22:
            tmp.write(f".set version, '{hookVersion}'\n\n")
        for line in code:
            tmp.write(line)

    print(baseAddress[addressCycle])

    if fileCycle >= 10:
        print(file)
    else:
        print(file.name)

    status = subprocess.run(["python", pyiiasmh, tempCode, 'a', '--dest', asmOut, '--codetype', 'C2D2', '--bapo', f'{baseAddress[addressCycle]}'])

    if status.returncode != 0:
        stderr = status.stderr
        print(f"{stderr}\n\nPyiiASMH failed! Aborting.")
        sys.exit

    with open(asmOut, 'r') as scratchAssembly, open(finalOut, 'a') as codeOutput:
        for line in scratchAssembly:
            codeOutput.write(line)
        codeOutput.write("\n")

def processOutOfOrderFiles(regionLetter, file, OOO_FileIndex, job):
    if file == OOO_FileIndex[0]: # "EnableInvincibility.s"
        addressCycle = 5

        if regionLetter == 'p' or regionLetter == 'P':
            versions = [
                "805819c4",
                "80581e94",
                "80572818"
            ]
        elif regionLetter == 'e' or regionLetter == 'E':
            versions = [
                "8057b160",
                "8057b630",
                "8056d9c8"
            ]
        elif regionLetter == 'j' or regionLetter == 'J':
            versions = [
                "80581344",
                "80581814",
                "80572198"
            ]
        elif regionLetter == 'k' or regionLetter == 'K':
            versions = [
                "8056fa1c",
                "8056feec",
                "80560870"
            ]

    if file == OOO_FileIndex[1]: # RemoveOnObjectHit.s"
        addressCycle = 10

        if regionLetter == 'p' or regionLetter == 'P':
            versions = [
                "80573c38",
                "80595110"
            ]
        elif regionLetter == 'e' or regionLetter == 'E':
            versions = [
                "8056ede8",
                "8058e8ec"
            ]
        elif regionLetter == 'j' or regionLetter == 'J':
            versions = [
                "805735b8",
                "80594a90"
            ]
        elif regionLetter == 'k' or regionLetter == 'K':
            versions = [
                "80561c90",
                "80583168"
            ]

    if file == OOO_FileIndex[2]: # "EnableBalloonRemoval.s"
        addressCycle = 4
        
        if regionLetter == 'p' or regionLetter == 'P':
            versions = [
                "80573c30",
                "805721fc",
                "80595108"
            ]
        elif regionLetter == 'e' or regionLetter == 'E':
            versions = [
                "8056ede0",
                "8056d3ac",
                "8058e8e4"
            ]
        elif regionLetter == 'j' or regionLetter == 'J':
            versions = [
                "805735b0",
                "80571b7c",
                "80594a88"
            ]
        elif regionLetter == 'k' or regionLetter == 'K':
            versions = [
                "80561c88",
                "80560254",
                "80583160"
            ]

    if file == OOO_FileIndex[3]: # "PreventIncrementingBattleScore.s"
        addressCycle = 7

        if regionLetter == 'p' or regionLetter == 'P':
            versions = [
                "80538c6c",
                "80538d8c"
            ]
        elif regionLetter == 'e' or regionLetter == 'E':
            versions = [
                "80534124",
                "80534244"
            ]
        elif regionLetter == 'j' or regionLetter == 'J':
            versions = [
                "805385ec",
                "8053870c"
            ]
        elif regionLetter == 'k' or regionLetter == 'K':
            versions = [
                "80526cc4",
                "80526de4"
            ]

    if file == OOO_FileIndex[4]: # "HookFix.s"
        addressCycle = 6
        
        if regionLetter == 'p' or regionLetter == 'P':
            versions = [
                "805721c0",
                "80573e40"
            ]
        elif regionLetter == 'e' or regionLetter == 'E':
            versions = [
                "8056d370",
                "8056eff0"
            ]
        elif regionLetter == 'j' or regionLetter == 'J':
            versions = [
                "80571b40",
                "805737c0"
            ]
        elif regionLetter == 'k' or regionLetter == 'K':
            versions = [
                "80560218",
                "80561e98"
            ]
            
    if job == 1:
        return addressCycle

    return versions

def assembleFromFile(regionLetter, curDir, addressCycle, finalOut):
    baseAddress = getBaseAddress(regionLetter)

    # The current working directory is unaware that this file is needed so let's copy it.
    includeFile = "__includes.s"
    shutil.copyfile(f"tools/pyiiasmh/{includeFile}", f"{includeFile}")

    tempCode = "tmp.s"
    asmOut = "asmOut.txt"
    fileCycle = 0
    hookVersion = 1

    # Out-of-Order File Index
    OOO_FileIndex = [
        "EnableInvincibility.s",
        "RemoveOnObjectHit.s",
        "EnableBalloonRemoval.s",
        "PreventIncrementingBattleScore.s",
        "HookFix.s"
    ]

    list(OrderedDict.fromkeys(OOO_FileIndex))

    for file in sorted(Path(curDir).rglob('*.s')):
        codeFile = f"{curDir}/{file.name}"

        writeTempFile(regionLetter, curDir, addressCycle, baseAddress, tempCode, asmOut, codeFile, file, fileCycle, finalOut, hookVersion)

        if addressCycle == 3:
            return
        if addressCycle == 10:
            break

        addressCycle += 1

    if addressCycle == 10:
        fileCycle = addressCycle

        for file in OOO_FileIndex:
            job = 0
            versions = processOutOfOrderFiles(regionLetter, file, OOO_FileIndex, job)
            codeFile = f"{curDir}/{file}"
            hookVersion = 2

            for hook in versions:
                job = 1
                addressCycle = processOutOfOrderFiles(regionLetter, file, OOO_FileIndex, job)
                baseAddress[addressCycle] = hook

                writeTempFile(regionLetter, curDir, addressCycle, baseAddress, tempCode, asmOut, codeFile, file, fileCycle, finalOut, hookVersion)

                fileCycle += 1
                hookVersion += 1

    os.remove(includeFile)
    os.remove(tempCode)
    os.remove(asmOut)


def assembleASMCode(regionLetter, finalOut):
    balloonMgrDir = "src/BalloonManager"
    kartDir = "src/Kart"
    objDir = "src/Objects"

    # Balloon Manager
    curDir = balloonMgrDir
    addressCycle = 0
    
    assembleFromFile(regionLetter, curDir, addressCycle, finalOut)

    # Kart
    curDir = kartDir
    addressCycle = 4

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
