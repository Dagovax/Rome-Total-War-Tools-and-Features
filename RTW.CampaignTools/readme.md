# Rome: Total War - Campaign Tools
A .NET 6 Windows application that validates campaign files and shows region information


## Installation
[Download](https://github.com/Dagovax/Rome-Total-War-Tools-and-Features/tree/master/RTW.CampaignTools) one of the <i>RTW.CampaignTools</i> executables.<br/>

Make sure you have <B>.NET Desktop Runtime 6.0.xx </B> installed: You can find that [here](https://dotnet.microsoft.com/en-us/download/dotnet/6.0).
- If you downloaded <b>RTW.CampaignTools (32-bit).exe</b>, download the <b><u>x86</u></b> version
- If you downloaded <b>RTW.CampaignTools (64-bit).exe</b>, download the <b><u>x64</u></b> version

I recommend you to use the 64 bit variant. Only use 32 bit if your pc is not running on a 64 bit processor.

## Startup Window
The first window, also called startup window, does not have campaign loaded. You can use the menu bar to load a new campaign, or use the shortcut <b>Ctrl + N</b>.
>
![Imgur](https://i.imgur.com/qOCBv3W.png)

Additionaly, before even loading a campaign, you can change the settings using the menu bar. If you have a campaign that has very large regions inside it, you can check the <b>Settings -> Campaign -> Skip Border Calculation</b>. This will speed up the validation, but will have visual side effects later. For additional settings, keep an eye on the <b>Change Log</b>. 

### Load Campaign
The load campaign window will ask you to browse to your campaign directory. This does not need to be the 'base' directory, because the tool automatically searches that one if certain files can not be found in your selected campaign.<br/><br/>
![Imgur](https://i.imgur.com/ldJKYH0.png)

The continue button will become enabled when you have chosen a valid directory.

### Validation
After clicking the 'Continue' button, the tool will load required files and also validates them. This might take some time, but you can see the progressbar.<br/><br/>
![Imgur](https://i.imgur.com/GRC2iTi.png)

During the validation process you might get some warning dialogs, that tell you something is wrong in one of your files, or (most of the time) missing lookup entries:

![Imgur](https://i.imgur.com/zQ5E30X.png)

I advice that you solve these problems. You could also get some messages with an exception stack trace; those are application issues and should be forwarded to me.
Since one of the first updates, you can reload campaign files once you are in the <b>Campaign View Window</b>. You can use <b>File -> Reload (Ctl+R)</b> to reload any changed files, and the tool will also revalidate the campaign files if necessary. 

### Campaign View
![Imgur](https://i.imgur.com/Zs9L2bB.png)

This is the main window where you can see your <i>map_regions.tga</i>. You can click the regions and get the region information. 
On the right side of the screen, you can see the region information based on the selected region.

Note that the current version is view-only, meaning that you can not edit stuff with this tool. 

#### Overlays
![Imgur](https://i.imgur.com/sbkE0AH.png)
>
The <b>Overlays</b> tab on the right side allows you to show the specific maps in <b>scaled mode</b>. This means that, if a certain .tga has larger dimensions than the map_regions.tga, the tool will show the overlay of that specific .tga in the way the game engine reads them for region validation. If a map has issues, you can click on the error indicator to view the issues in a dialog. 

To enable the default overlays, click the <b>Show Overlay</b> button. Then click on the map you want to view. Selected regions will be rendered over any default overlays. Click the <b>Hide Overlay</b> button to hide the default overlays again.

Overlays such as <i>map_features.tga</i> are loaded at top most render, and are even rendered on top of the selected region highlighter. They can be toggled on/off by clicking om them without any overlay on/off mode required.

#### Resources
![Imgur](https://i.imgur.com/nmLynVO.png)
>
The <b>Resources</b> tab allows you to view resource allocation. For both <b><i>Hidden Resources</i></b> and <b><i>Trade Resources</i></b>, you can highlight which regions have the selected resource(s). To do so, click the <b>Start Highlight</b> button. Turn the highlight off again by clicking the <b>Stop Highlight</b> button. During highlight mode you can check/uncheck multiple resources. 

Additionaly, <b><i>Trade Resources</i></b> you have defined in <i>descr_strat.txt</i>, can be made visible on the main view using the settings and selecting them in the list. If you have a custom <i>descr_sm_resources.txt</i> in your mod, with unique icons, they will be loaded (as can be seen in example list). If the icon can not be loaded, or is undefined, then a default resource RR icon will be shown.
Resource quantity etc for Rome Remastered can be seen in the region information after selecting it.

#### Mercenaries
![Imgur](https://i.imgur.com/CuXwqGN.png)
>
The <b>Mercenaries</b> tab provides the same highlight mode as for hidden resources, but then based on the mercenary pools. Select a <b>mercenary pool</b> in the dropdown. The unit entries in the mercenary pool will be updated in the section below the dropdown. Press the <b>Start Highlight</b> button to start the mercenaries highlight mode. During highlight mode, you can select other mercenary pools. Turn the highlight off again by clicking the <b>Stop Highlight</b> button.

## Change Log
***Version 1.0.15***
- Fixed some dialogs not applying the correct theme once shown.
- Added multiple **Settings -> Campaign -> Ignore Warnings** options. These warnings will be ignored during validation if checked.
- Changed yellow color on the Default theme to match that of the RTW UI panel color.
- Added a x50 zoom factor. Note that the bigger the zoom, the more CPU the tool uses.
- Added a Grid, which can be turned on and off in **Display -> Grid**. Also allows you to pick the grid color.
- Fixed an issue where resource icons were not in the correct position when scaled.
- Added a Generic tab that shows useful information about loaded campaign files.
- Previously 'Region Information' is now a tab next to Generic information called 'Selected Region'.
- Resources assigned to a region are now moved to a new tab 'Region Usages'.
- Region Usages also shows the region's mercenary pool information.
- Updated `descr_mercenaries.txt` warnings. You now get warnings if a region is already used in another pool, or when a region is orphan (unless turned off in settings).
- Added a new **Warnings** tab, next to Overlays, which shows all warnings that occurred during the validation in a sortable list.
- Fixed an issue when being in full screen, a tight border could be seen around the application that was the background (application).
- Added a **Campaign -> Generate** menu, with currently the ability to generate a `descr_regions_and_settlement_name_lookup.txt` file.

<i><b>Version 1.0.14</b></i>
- Added multiple themes. Select the application theme that fits you best under <b>Theme</b>
- Added **map.wfc** read/write support. Currently you can edit placement information, such as ambient settlement positions!
- Added a setting that saves the previous selected campaign location when you load one. Next time you load a campaign it is already filled in the search box
- Some optimizations
- Added region size warning message, if you have regions that are bigger than the maximum of 100x100 allowed.
- When a **map_heights.hgt** file is present, the warnings of black pixels in **map_heights.tga** are now skipped.

<i><b>Version 1.0.13</b></i>
- Fixed an issue where the application would still be running in the background when loading new campaign
- Fixed the issue where resource icons were not loaded correctly
- Added internal checks for 32-bit and 64-bit application. Will be shown in the title and application's executable description
- Fixed the issue where, after reloading, the drawn views were not updated automatically
- Same as above, but now for Redraw button
- Fixed an issue where if Alt key was pressed to zoom in, and application lost focus, the next scroll was bugged
- Added validation check for settlement and port locations. It will first check map_ground_types.tga, and then map_features.tga. Now you will see warnings if pixel  is placed at the wrong location:
	* <b>Settlement</b>:
		* You have chosen an invalid tile (x,y) for the settlement of <u>settlement_name</u>: ground type at this tile is impassible (<ground_type>)!
		* You have chosen an invalid tile (x,y) for the settlement of <u>settlement_name</u>. It will mean not being able to reach this settlement and is a bug (surrounded by impassible ground types)!
		* You have chosen an invalid tile (x,y) for the settlement of <u>settlement_name</u>. It will mean not being able to reach this settlement and is a bug (surrounded by impassible ground and/or feature tiles)!
	* <b>Port</b>:
		* You have chosen an invalid tile (x,y) for the port in <u>region_name</u>: ground type at this tile is impassible (<ground_type>)!
		* You have chosen an invalid tile (x,y) for the port in <u>region_name</u>. It will mean not being able to reach this settlement and is a bug (surrounded by impassible ground types)!
		* You have chosen an invalid tile (x,y) for the port in <u>region_name</u>. This port is not surrounded by any water (map_ground_types.tga)!
		* You have chosen an invalid tile (x,y) for the port in <u>region_name</u>. It will mean not being able to reach this settlement and is a bug (surrounded by impassible ground and/or feature tiles)!

<i><b>Version 1.0.12</b></i>
- Added read support for text data for resources
- Fixed an issue where OG resources could cause an exception to be thrown
- Added <b>Display -> Resources -> Ellipse Transparency</b> setting, which allows you to change the transparancy of the ellipse that is rendered behind the resource icon.
- Added <b>Display -> Resources -> Icon Scale</b> setting, which changes the scale of the rendered resource icon on the main view
- Added a track bar to Resources side panel to scale down the resource icons in the list
- Improved the placement of resource icons on the main view

<i><b>Version 1.0.10</b></i>
- Added map_heights.tga read support
- Added map_ground_types.tga read support
- Added descr_climates.txt read support
- Added map_climates.tga read support
- Added map_features.tga read support
- Tool now starts in main window. You can change settings there before loading a campaign
- Added <b>Settings -> Campaign -> Skip Border Calculation</b>. If you check this setting, loading the campaign files will skip border calculation process, which will save a lot of calculation time, but will result in missing borders.
- Added <b>Display -> Overlay -> map_features.tga -> Hide Black Pixels</b>
- Added a new `Overlay` tab wich shows you the (scaled down) version of the map files. 
- Added <b>Campaign -> Fix -> Create corrected_regions.tga</b>. In case you do not have a faulty map_heights.tga, this will generate a `corrected_regions.tga`, like how OG engine did. This is still beta
- Added <b>Campaign -> Maps -> ... -> Export scaled image</b>. This is super usefull. This will exports a map_heights, map_ground_types or map_climate with the same size as your map_regions.tga file. Exactly how the engine also processes the tiles on the map. So perfect to use as overlay in your photoshop psd files, to check if you are placing settlements on correct tiles!
- Reworked Trade Resource tab. Icons will be loaded as well, if you check <b>Display -> Resources -> Render Images</b>. With this checked, if you select a resource, the position on the map will be marked with the resource icon (even when not in region highlight mode. 

<i><b>Version 1.0.9</b></i>
- Fixed the issue where disabled quantity resources were not being read at all
- Fixed the reload mechanism not working on descr_strat.txt
- Removed Triumph Point value due to it being unused by the game
- If a region has no belief breakdown, the textbox will not be shown
- If you now click on an 'Orphan' region from the list, the region will be selected on the map
- You can now zoom the map using <b>Alt + Mouse Scroll</b>
- Added version info at the top bar

<i><b>Version 1.0.8</b></i>
- Added initial descr_strat.txt read. Defined resources will now be loaded
- Updated <i>Resources</i> dialog (when you click on resources under region information)
- If resources in region information window is longer than the width, text will roll to the left when you hover over it.
- Added <b>Display -> Zoom</b> options. You can set zoom level modification here, which enables higher zoom level.
- Added double buffering for the map view; there is lower chance this way that you get 'flicking' issue when clicking or scrolling on the map. Only 'lag' I encounter is while zooming.
- Fixed application hanging when you don't have a lookup file for regions and settlement names. You still need that file though!

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
