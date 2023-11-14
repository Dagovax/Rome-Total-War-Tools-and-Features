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
