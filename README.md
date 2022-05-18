# Rome:Total War -- Tools and Features
A repository containing scripts that Dagovax created to make modding Rome: Total War easier

# 3ds Max
Currently, two new scripts are added to this repository:

## Installation
Installation of 3ds Max scripts is quite easy:
```
Place the .ms script inside your 'Autodesk\3ds Max [version]\scripts' folder.
To make them start up together with 3ds Max, place them in the 'Startup' folder.
You can find the scripts under the Utility tab. 
```

## RTW Building Export
This [script](https://github.com/Dagovax/Rome-Total-War-Tools-and-Features/tree/master/3dsMax%20Scripts/RTW%20Building%20Export) let you export building coordinates to be used in settlement plans.

### Usage
```
1. Select any object and/or groups
2. Click the 'Export Selected Building(s)' button
3. Follow the instructions.
4. Just copy/paste the result into your settlement plan to get it working.
```
<B>HINT</B>: Name the buildings/groups like they should be regarding their name in DBB. You then don't need to change the names of the output afterwards!

## RTW Skeleton Position Export
This [script](https://github.com/Dagovax/Rome-Total-War-Tools-and-Features/tree/master/3dsMax%20Scripts/RTW%20Skeleton%20Position%20Export) let you export bone coordinates of new skeletons in the right format for skeleton text files!.

### Usage
```
1. Position the bones using the move tool, don't use the rotate function because that won't work.
2. Click the 'Export Bone Coordinates' button
3. Select the skeleton you used, in order to get the best result
4. Copy/paste the result coordinates into your skeleton file where you need to set the bone position.
```
<B>NOTE:</B> A skeleton file is very advanced extracted stuff, so don't mess with removing zero's or other important stuff. Only change the same section!

## DAE Export Multiple LODS
This [script](https://github.com/Dagovax/Rome-Total-War-Tools-and-Features/tree/master/3dsMax%20Scripts/DAE%20Export%20Multiple%20LODS) will export a model using openCOLLADA, generating 4 LODS. If your model uses multi bone weighting, the LOD0 will preserve this feature, while for all other LODS the weighting is automatically set to single bone weighting.

### Usage
```
1. Finish modeling your model, and run the script.
2. Change the spinner to your desired minimal vertex value. The default is 150. This means that all objects in the scene under this vertex amount, will not be optimized.
3. Click the Export button
4. Choose your path and file name. The script will generated 4 different .dae files. Use IWTE to convert them to .cas
```
<B>NOTE:</B>: This is a heavy script. Be sure to save your scene before using it (as it might crash sometimes).

## RTW Multiple Vertex Bone Weight To Single
This [script](https://github.com/Dagovax/Rome-Total-War-Tools-and-Features/tree/master/3dsMax%20Scripts/RTW%20Multiple%20Vertex%20Bone%20Weight%20To%20Single) will loop through all your objects, and set all vertex weights to single bone only.

### Usage
```
1. Click the 'Single Vertex Weights' button
```

# RTW Multiple Turns Per Year
This tool is a WinForm application which is an improvement and renewal of the old script (and available on later Windows versions).

Simply download the [executable](https://github.com/Dagovax/Rome-Total-War-Tools-and-Features/blob/master/RTWMultipleTurnsPerYear/RTW%20Multiple%20Turns%20Per%20Year.exe) and run it (as administrator when you encounter problems). Any questions? Use the contact link. 

# RTW Name Converter
This tool will convert OG descr_names.txt file to Remastered descr_namelist.txt format.

Download: [folder] (https://github.com/Dagovax/Rome-Total-War-Tools-and-Features/tree/master/RTW.NameConverter)

You need to download all files from the folder, in order to work.

# RTW Name Parser
With this tool you can add names (from internet) for new factions and automatically create the files required for the game.

Download: [folder] (https://github.com/Dagovax/Rome-Total-War-Tools-and-Features/tree/master/RTW.NameParser)

You need to download all files from the folder, in order to work.

# RTW Text Duplicator
This tool will just duplicate a certain text entry for given amount of times

Download: [executable] (https://github.com/Dagovax/Rome-Total-War-Tools-and-Features/raw/master/RTWTextDuplicator/Rome%20Total%20War%20(RR)%20Text%20Duplicator.exe)

# License
All tools and features on this repository are created by [Sirrianus Dagovax](https://github.com/Dagovax). All Tools and Features are Free to use, but you are 
not allowed to spread this scripts and modify them without my permission. If you know someone who misuses my scripts, don't hesitate to
contact me.
