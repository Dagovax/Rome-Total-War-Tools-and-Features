# Rome: Total War - Campaign Tools
A .NET 6 Windows application that validates campaign files and shows region information


## Installation
[Download](https://github.com/Dagovax/Rome-Total-War-Tools-and-Features/raw/master/RTW.CampaignTools/RTW.CampaignTools.exe) the RTW.CampaignTools.exe and run it.<br/>
Make sure you have <B>.NET Desktop Runtime 6.0.xx </B> installed. You can find that [here](https://dotnet.microsoft.com/en-us/download/dotnet/6.0)

## Usage

### First Window
The first window will ask you to browse to your campaign directory. This does not need to be the 'base' directory, because the tool automatically searches that one if certain files can not be found in your selected campaign.<br/><br/>
![Imgur](https://i.imgur.com/ldJKYH0.png)

The continue button will become enabled when you have chosen a valid directory.

### Validation
After clicking the 'Continue' button, the tool will load required files and also validates them. This might take some time, but you can see the progressbar.<br/><br/>
![Imgur](https://i.imgur.com/GRC2iTi.png)

During the validation process you might get some warning dialogs, that tell you something is wrong in one of your files, or (most of the time) missing lookup entries:

![Imgur](https://i.imgur.com/zQ5E30X.png)

I advice that you solve these problems. You could also get some messages with an exception stack trace; those are application issues and should be forwarded to me.

### Campaign View Window
![Imgur](https://i.imgur.com/B0HsXNB.png)

This is the main window where you can see your <i>map_regions.tga</i>. You can click the regions and get the region information. Note that the current version is view-only, meaning that you can not edit stuff with this tool.

## Change Log
<i><b>Version 1.0.7</b></i>
- Added Mercenary pool support and highlighting.
- Check out the 'Orphan Regions' tab for all regions that are not defined in descr_mercenaries.txt
- You can choose to sort the pool list or not. Setting will be saved inside the program for next usage.

<i><b>Version 1.0.6</b></i>
- Fixed the issue where resources could not be read

<i><b>Version 1.0.5</b></i>
- Added <b>File -> Reload (Ctl+R)</b> and <b>File -> Hard Reload</b> to (quickly) reload the campaign files after you made changes.
- Added popup
- Disabled the close button on the top right, to release all pc resources, use <b>File -> Exit</b> or Alt+F4.

<i><b>Version 1.0.4</b></i>
- Added user settings. Certain settings will now be saved over multiple sessions. 
- Added menu shortcuts for certain actions
- <b>Settings -> Reset User Settings</b> or (Alt+R) to reset saved user settings to default. Will relaunch the window.
- Added counter when validating region borders, to keep you informed
- Added <b>Search -> Find Region...</b> or (Ctl+F) dialog. You can now search regions based on input parameters.
![Imgur](https://i.imgur.com/EVO9bw9.png)
- Resources are now sorted.

<i><b>Version 1.0.3</b></i>
- Added <b>Display -> Text</b> options. Toggle between Internal and Localized names
- Added <b>Info</b> options to view current application version
- Added read support for <i>descr_sm_resources.txt</i>
- Added <b><i>Resources</i></b> tabsheet section. You can now view regions that has specific resources. You can also define own overlay color for both viewing modes
![Imgur](https://i.imgur.com/RXj574u.png)
- Added more warnings
- Disabled the 'Numeric Spinners', preventing accidentally changing the RGB entries.

<i><b>Version 1.0.2</b></i>
- Added menu bar with close and option to load another campaign
- Improved validation window 'Calculating Borders' speed
- Added grey border around selected region when 'Color All Regions' is not checked
- Fixed support for 32bit TGA files. They should not properly work too
- `descr_belief.txt` file is now being read as well. If not present in mod folder, default religions will be used.

<i><b>Version 1.0.1</b></i>
- Fixed issue with beliefs not showing up
- Fixed Settlement and Region name display showing internal names instead of the ones defined in the data/text directory
- Changed borders around selected region
- You can now click on resources, and a new form will show them in order.

<i><b>Version 1.0.0</b></i>
- Initial version

## License
All tools and features on this repository are created by [Sirrianus Dagovax](https://github.com/Dagovax). All Tools and Features are Free to use, but you are 
not allowed to spread this scripts and modify them without my permission. If you know someone who misuses my scripts, don't hesitate to
contact me.
