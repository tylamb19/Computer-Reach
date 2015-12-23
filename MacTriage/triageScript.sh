#!/bin/sh

#  triageScript.sh
#  
#
#  Created by Tyler Lamb on 6/12/15.
#

manufacturer="Apple"
shortModel="$(sysctl hw.model | cut -c 11-1000)"
serialNum="$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')"
gpuType="$(system_profiler SPDisplaysDataType | grep Chipset | cut -c 22-1000)"


processorType="$(sysctl -n machdep.cpu.brand_string)"
processorSpeed="$(system_profiler SPHardwareDataType | grep Processor | grep Speed | cut -c 24-10000)"
numProcessor="$(sysctl hw.physicalcpu | cut -c 17)"

hdSize="$(diskutil info disk0 | grep Total | cut -c 30-37)"

numberUSB="$(system_profiler SPUSBDataType | grep USB | grep Hi-Speed | wc -l | cut -c 8-1000)"
numberFW="$(system_profiler SPFireWireDataType | grep FireWire | grep Bus | wc -l | cut -c 8-1000)"
speedFW="$(system_profiler SPFireWireDataType | grep to | cut -c 28-1000)"

if [ "$numberUSB" > 0 ]; then
circleUSB="Circle USB"
else
circleUSB=""
fi

if [ "$numberFW" > 0 ]; then
circleFireWire="Circle FireWire"
else
circleFireWire=""
fi

DVDReadType="$(system_profiler SPDiscBurningDataType | grep Reads | cut -c 18-10000)"

if [ "$DVDReadType" = "Yes" ]; then
DVDReadTrue="Yes"
else
DVDReadTrue="No"
fi

DVDBurnType="$(system_profiler SPDiscBurningDataType | grep DVD-Write: | cut -c 18-10000)"
CDBurnType="$(system_profiler SPDiscBurningDataType | grep CD-Write: | cut -c 17-10000)"

RAMSize="$(sysctl -n hw.memsize | awk '{print $0/1073741824" GB"}')"

OSVersion="$(sw_vers | awk -F':\t' '{print $2}' | paste -d ' ' - - -)"

airportData="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I)"

if [ "$airportData | wc -l" > 1 ]; then
airportPresent="Yes"
else
airportPresent="No"
fi

computerArch="$(uname -m)"


getANumber () {
    crNum="$(osascript -e 'Tell application "System Events" to display dialog "Enter the Computer Reach ID Number for this machine." default answer ""' -e 'text returned of result' 2>/dev/null)"
    if [ $? -ne 0 ]; then
    osascript -e 'Tell application "System Events" to display alert "You must enter an ID number!" as warning'
    getANumber
    elif [ -z "$crNum" ]; then
    osascript -e 'Tell application "System Events" to display alert "You must enter an ID number!" as warning'
    getANumber
    fi
}

getANumber

date="$(date +"%m-%d-%y")"

osascript << EOF

set crID to do shell script "echo '$crNum'"
set HWModel to do shell script "echo '$shortModel'"
set serialNum to do shell script "echo '$serialNum'"
set circleUSB to do shell script "echo '$numberUSB'"
set circleFW to do shell script "echo '$numberFW'"
set speedFW to do shell script "echo '$speedFW'"
set GPUType to do shell script "echo '$gpuType'"
set processor to do shell script "echo '$processorType'"
set clockSpeed to do shell script "echo '$processorSpeed'"
set numProcessors to do shell script "echo '$numProcessor'"
set amountRAM to do shell script "echo '$RAMSize'"
set HDSize to do shell script "echo '$hdSize'"
set CDBurnTypes to do shell script "echo '$CDBurnType'"
set DVDReadTrue to do shell script "echo '$DVDReadTrue'"
set writesDVDTypes to do shell script "echo '$DVDBurnType'"
set APInstalled to do shell script "echo '$airportPresent'"
set todayDate to do shell script "echo '$date'"
set installOS to do shell script "echo '$OSVersion'"

tell application "System Events"
display dialog "Place this info on your triage sheet:

Computer Reach ID: " & crID & "
Model: " & HWModel & "
Serial Number: " & serialNum & "

Number of USB Ports: " & circleUSB & "
Number of FireWire Ports: " & circleFW & "
FireWire Speed: " & speedFW & "

GPU Model: " & GPUType & "
CPU: " & processor & "
CPU Speed: " & clockSpeed & "
Number of Processors: " & numProcessors & "
Amount of RAM: " & amountRAM & "

Hard Drive Size: " & HDSize & "

CD Burning: " & CDBurnTypes & "
Reads DVDs: " & DVDReadTrue & "
DVD Burning: " & writesDVDTypes & "

Airport WiFi: " & APInstalled & "

Date: " & todayDate & "

Operating System: " & installOS
end tell
EOF

#echo
#echo "Computer Reach ID: $crNum"
#echo
#echo "Board Manufacturer: $manufacturer"
#echo "Hardware Model: $shortModel"
#echo "Serial Number: $serialNum"
#echo
#echo "Number of USB Ports: $numberUSB"
#echo "Number of FireWire Ports: $numberFW"
#echo "Speed of FireWire Bus: $speedFW"
#echo
#echo "GPU Model: $gpuType"
#echo "Processor: $processorType"
#echo "Clock Speed: $processorSpeed"
#echo "Number of processors: $numProcessor"
#echo "Amount of RAM: $RAMSize"
#echo "Machine Architecture: $computerArch"
#echo
#echo "Hard Drive Size: $hdSize"
#echo
#echo "Writes CD Types: $CDBurnType"
#echo "Reads DVDs: $DVDReadTrue"
#echo "Writes DVD Types: $DVDBurnType"
#echo
#echo "Airport Installed: $airportPresent"
#echo
#echo "Date: $date"
#echo "Installed OS: $OSVersion"

mkdir /Volumes/NASMnt
mount_afp afp://10.0.88.5/Public/triage /Volumes/NASMnt
touch "$crNum.Mac.triage.txt"

cd /Volumes/NASmnt

echo "--------------------------------------" >> "$crNum.Mac.triage.txt"
echo "Computer Reach ID: $crNum">> "$crNum.Mac.triage.txt"
echo "--------------------------------------" >> "$crNum.Mac.triage.txt"
echo "Board Manufacturer: $manufacturer" >> "$crNum.Mac.triage.txt"
echo "Hardware Model: $shortModel" >> "$crNum.Mac.triage.txt"
echo "Serial Number: $serialNum" >> "$crNum.Mac.triage.txt"
echo "--------------------------------------" >> "$crNum.Mac.triage.txt"
echo "Number of USB Ports: $numberUSB" >> "$crNum.Mac.triage.txt"
echo "Number of FireWire Ports: $numberFW" >> "$crNum.Mac.triage.txt"
echo "Speed of FireWire Bus: $speedFW" >> "$crNum.Mac.triage.txt"
echo "--------------------------------------" >> "$crNum.Mac.triage.txt"
echo "GPU Model: $gpuType" >> "$crNum.Mac.triage.txt"
echo "Processor: $processorType" >> "$crNum.Mac.triage.txt"
echo "Clock Speed: $processorSpeed" >> "$crNum.Mac.triage.txt"
echo "Number of processors: $numProcessor" >> "$crNum.Mac.triage.txt"
echo "Amount of RAM: $RAMSize" >> "$crNum.Mac.triage.txt"
echo "Machine Architecture: $computerArch" >> "$crNum.Mac.triage.txt"
echo "--------------------------------------" >> "$crNum.Mac.triage.txt"
echo "Hard Drive Size: $hdSize" >> "$crNum.Mac.triage.txt"
echo "--------------------------------------" >> "$crNum.Mac.triage.txt"
echo "Writes CD Types: $CDBurnType" >> "$crNum.Mac.triage.txt"
echo "Reads DVDs: $DVDReadTrue" >> "$crNum.Mac.triage.txt"
echo "Writes DVD Types: $DVDBurnType" >> "$crNum.Mac.triage.txt"
echo "--------------------------------------" >> "$crNum.Mac.triage.txt"
echo "Airport Installed: $airportPresent" >> "$crNum.Mac.triage.txt"
echo "--------------------------------------" >> "$crNum.Mac.triage.txt"
echo "Installed OS: $OSVersion" >> "$crNum.Mac.triage.txt"
echo "--------------------------------------" >> "$crNum.Mac.triage.txt"
echo "Date: $date" >> "$crNum.Mac.triage.txt"
echo "--------------------------------------" >> "$crNum.Mac.triage.txt"
sleep 2
diskutil unmount force /Volumes/NASmnt
