-------------------------------------------
--										 --
--  RTW BoneCoordinate Export       --
--  by Sirrianus Dagovax (dagovax@gmail.com)   --
-- 
--										 --
--										 --
--  Please do not distribute any part of --
--     this script without permission.   --
--    Also, please email me or visit my  --
--   thread if you have found any bugs.  --
--										 --
-------------------------------------------

-------------------------------------------
--										 --
-- 			Revision history:			 --
--										 --
-- v1.0 -- current  					 --
--										 --
-------------------------------------------

function GetBonePropsByName inputBone skelType =
(
	local resultArr = #()
	local frontValue = 0
	local flagOne = 0
	local flagTwo = 0
	
	-- SOLDIER SKELETONS
	if(inputBone.name == "bone_Pelvis") then
	(
		frontValue = 0 -- game right hand modifier
		case of
		(
			(skelType == "fs_archer"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_big_elephant_rider"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_dagger"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_slinger_new"):
			(
				flagOne = 0
				flagTwo = 0
			)
		)
	)
	
	if(inputBone.name == "bone_RThigh") then
	(
		frontValue = 0 -- game right hand modifier
		case of
		(
			(skelType == "fs_archer"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_big_elephant_rider"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_dagger"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_slinger_new"):
			(
				flagOne = 0
				flagTwo = 0
			)
		)
	)
	
	if(inputBone.name == "bone_Rlowerleg") then
	(
		frontValue = 0 -- game right hand modifier
		case of
		(
			(skelType == "fs_archer"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_big_elephant_rider"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_dagger"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_slinger_new"):
			(
				flagOne = 0
				flagTwo = 0
			)
		)
	)
	
	if(inputBone.name == "bone_Rfoot") then
	(
		frontValue = 0 -- game right hand modifier
		case of
		(
			(skelType == "fs_archer"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_big_elephant_rider"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_dagger"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_slinger_new"):
			(
				flagOne = 0
				flagTwo = 0
			)
		)
	)
	
	if(inputBone.name == "bone_abs") then
	(
		frontValue = 0 -- game right hand modifier
		case of
		(
			(skelType == "fs_archer"):
			(
				flagOne = 1
				flagTwo = 1
			)
			(skelType == "fs_big_elephant_rider"):
			(
				flagOne = 0
				flagTwo = 1
			)
			(skelType == "fs_dagger"):
			(
				flagOne = 1
				flagTwo = 1
			)
			(skelType == "fs_slinger_new"):
			(
				flagOne = 0
				flagTwo = 1
			)
		)
	)
	
	if(inputBone.name == "bone_torso") then
	(
		frontValue = 0 -- game right hand modifier
		case of
		(
			(skelType == "fs_archer"):
			(
				flagOne = 1
				flagTwo = 1
			)
			(skelType == "fs_big_elephant_rider"):
			(
				flagOne = 0
				flagTwo = 1
			)
			(skelType == "fs_dagger"):
			(
				flagOne = 1
				flagTwo = 1
			)
			(skelType == "fs_slinger_new"):
			(
				flagOne = 0
				flagTwo = 1
			)
		)
	)
	
	if(inputBone.name == "bone_head") then
	(
		frontValue = 0 -- game right hand modifier
		case of
		(
			(skelType == "fs_archer"):
			(
				flagOne = 1
				flagTwo = 0
			)
			(skelType == "fs_big_elephant_rider"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_dagger"):
			(
				flagOne = 1
				flagTwo = 0
			)
			(skelType == "fs_slinger_new"):
			(
				flagOne = 0
				flagTwo = 0
			)
		)
	)
	
	if(inputBone.name == "bone_cloak_top") then
	(
		frontValue = 0 -- game right hand modifier
		case of
		(
			(skelType == "fs_fast_archer"):
			(
				flagOne = 1
				flagTwo = 0
			)
			(skelType == "fs_big_elephant_rider"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_dagger"):
			(
				flagOne = 1
				flagTwo = 0
			)
			(skelType == "fs_slinger_new"):
			(
				flagOne = 0
				flagTwo = 0
			)
		)
	)
	
	if(inputBone.name == "bone_cloak_mid") then
	(
		frontValue = 0 -- game right hand modifier
		case of
		(
			(skelType == "fs_archer"):
			(
				flagOne = 1
				flagTwo = 0
			)
			(skelType == "fs_big_elephant_rider"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_dagger"):
			(
				flagOne = 1
				flagTwo = 0
			)
			(skelType == "fs_slinger_new"):
			(
				flagOne = 0
				flagTwo = 0
			)
		)
	)
	
	if(inputBone.name == "bone_cloak_bottom") then
	(
		frontValue = 0 -- game right hand modifier
		case of
		(
			(skelType == "fs_archer"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_big_elephant_rider"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_dagger"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_slinger_new"):
			(
				flagOne = 0
				flagTwo = 0
			)
		)
	)
	
	if(inputBone.name == "bone_Rupperarm") then
	(
		frontValue = 0 -- game right hand modifier
		case of
		(
			(skelType == "fs_archer"):
			(
				flagOne = 1
				flagTwo = 0
			)
			(skelType == "fs_big_elephant_rider"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_dagger"):
			(
				flagOne = 1
				flagTwo = 0
			)
			(skelType == "fs_slinger_new"):
			(
				flagOne = 0
				flagTwo = 0
			)
		)
	)
	
	if(inputBone.name == "bone_Relbow") then
	(
		frontValue = 0 -- game right hand modifier
		case of
		(
			(skelType == "fs_archer"):
			(
				flagOne = 1
				flagTwo = 0
			)
			(skelType == "fs_big_elephant_rider"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_dagger"):
			(
				flagOne = 1
				flagTwo = 0
			)
			(skelType == "fs_slinger_new"):
			(
				flagOne = 0
				flagTwo = 0
			)
		)
	)
	
	if(inputBone.name == "bone_Rhand") then
	(
		frontValue = 5 -- game right hand modifier
		case of
		(
			(skelType == "fs_archer"):
			(
				flagOne = 1
				flagTwo = 0
			)
			(skelType == "fs_big_elephant_rider"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_dagger"):
			(
				flagOne = 1
				flagTwo = 0
			)
			(skelType == "fs_slinger_new"):
			(
				flagOne = 0
				flagTwo = 0
			)
		)
	)
	
	if(inputBone.name == "bone_Lupperarm") then
	(
		frontValue = 0 -- game right hand modifier
		case of
		(
			(skelType == "fs_archer"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_big_elephant_rider"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_dagger"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_slinger_new"):
			(
				flagOne = 0
				flagTwo = 0
			)
		)
	)
	
	if(inputBone.name == "bone_Lelbow") then
	(
		frontValue = 0 -- game right hand modifier
		case of
		(
			(skelType == "fs_archer"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_big_elephant_rider"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_dagger"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_slinger_new"):
			(
				flagOne = 0
				flagTwo = 0
			)
		)
	)
	
	if(inputBone.name == "bone_Lhand") then
	(
		frontValue = 4 -- game left hand modifier
		case of
		(
			(skelType == "fs_archer"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_big_elephant_rider"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_dagger"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_slinger_new"):
			(
				flagOne = 0
				flagTwo = 0
			)
		)
	)
	
	if(inputBone.name == "bone_LThigh") then
	(
		frontValue = 0 -- game right hand modifier
		case of
		(
			(skelType == "fs_archer"):
			(
				flagOne = 1
				flagTwo = 0
			)
			(skelType == "fs_big_elephant_rider"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_dagger"):
			(
				flagOne = 1
				flagTwo = 0
			)
			(skelType == "fs_slinger_new"):
			(
				flagOne = 0
				flagTwo = 0
			)
		)
	)
	
	if(inputBone.name == "bone_Llowerleg") then
	(
		frontValue = 0 -- game right hand modifier
		case of
		(
			(skelType == "fs_archer"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_big_elephant_rider"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_dagger"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_slinger_new"):
			(
				flagOne = 0
				flagTwo = 0
			)
		)
	)
	
	if(inputBone.name == "bone_Lfoot") then
	(
		frontValue = 0 -- game right hand modifier
		case of
		(
			(skelType == "fs_archer"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_big_elephant_rider"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_dagger"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_slinger_new"):
			(
				flagOne = 0
				flagTwo = 0
			)
		)
	)
	
	-- ELEPHANT BONES
	if(inputBone.name == "bone_E_platform") then
	(
		frontValue = 2 -- game bone platform identifier
		case of
		(
			(skelType == "fs_african_elephant"):
			(
				flagOne = 1
				flagTwo = 0
			)		
		)
	)
	if(inputBone.name == "bone_E_back") then
	(
		case of
		(
			(skelType == "fs_african_elephant"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_forest_elephant"):
			(
				flagOne = 0
				flagTwo = 0
			)			
		)
	)
	if(inputBone.name == "bone_E_tail__2" or inputBone.name == "bone_E_tail") then
	(
		case of
		(
			(skelType == "fs_african_elephant"):
			(
				flagOne = 1
				flagTwo = 0
			)
			(skelType == "fs_forest_elephant"):
			(
				flagOne = 0
				flagTwo = 0
			)			
		)
	)
	if(inputBone.name == "bone_E_right__back__foot" or inputBone.name == "bone_E_right_back_foot") then
	(
		case of
		(
			(skelType == "fs_african_elephant"):
			(
				flagOne = 1
				flagTwo = 0
			)
			(skelType == "fs_forest_elephant"):
			(
				flagOne = 0
				flagTwo = 0
			)			
		)
	)
	if(inputBone.name == "bone_E_left__back__thigh" or inputBone.name == "bone_E_left_back_thigh") then
	(
		case of
		(
			(skelType == "fs_african_elephant"):
			(
				flagOne = 1
				flagTwo = 0
			)
			(skelType == "fs_forest_elephant"):
			(
				flagOne = 1
				flagTwo = 0
			)			
		)
	)
	if(inputBone.name == "bone_E_left__back__lower__leg" or inputBone.name == "bone_E_left_back_lower_leg") then
	(
		case of
		(
			(skelType == "fs_african_elephant"):
			(
				flagOne = 1
				flagTwo = 0
			)
			(skelType == "fs_forest_elephant"):
			(
				flagOne = 1
				flagTwo = 0
			)			
		)
	)
	if(inputBone.name == "bone_E_left__back__foot" or inputBone.name == "bone_E_left_back_foot") then
	(
		case of
		(
			(skelType == "fs_african_elephant"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_forest_elephant"):
			(
				flagOne = 1
				flagTwo = 0
			)			
		)
	)
	if(inputBone.name == "bone_E_trunk__1" or inputBone.name == "bone_E_trunk_1") then
	(
		case of
		(
			(skelType == "fs_african_elephant"):
			(
				flagOne = 1
				flagTwo = 0
			)
			(skelType == "fs_forest_elephant"):
			(
				flagOne = 1
				flagTwo = 0
			)			
		)
	)
	if(inputBone.name == "bone_E_trunk__2" or inputBone.name == "bone_E_trunk_2") then
	(
		case of
		(
			(skelType == "fs_african_elephant"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_forest_elephant"):
			(
				flagOne = 1
				flagTwo = 0
			)			
		)
	)
	if(inputBone.name == "bone_E_trunk__3" or inputBone.name == "bone_E_trunk_3") then
	(
		case of
		(
			(skelType == "fs_african_elephant"):
			(
				flagOne = 1
				flagTwo = 0
			)
			(skelType == "fs_forest_elephant"):
			(
				flagOne = 1
				flagTwo = 0
			)			
		)
	)
	if(inputBone.name == "bone_E_trunk__4" or inputBone.name == "bone_E_trunk_4") then
	(
		case of
		(
			(skelType == "fs_african_elephant"):
			(
				flagOne = 1
				flagTwo = 0
			)	
		)
	)
	if(inputBone.name == "bone_E_right__ear__main" or inputBone.name == "bone_E_right_ear_main") then
	(
		case of
		(
			(skelType == "fs_african_elephant"):
			(
				flagOne = 1
				flagTwo = 0
			)	
		)
	)
	if(inputBone.name == "bone_E_right__ear__tip" or inputBone.name == "bone_E_right_ear_tip") then
	(
		case of
		(
			(skelType == "fs_african_elephant"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_forest_elephant"):
			(
				flagOne = 1
				flagTwo = 0
			)					
		)
	)
	if(inputBone.name == "bone_E_left__ear__main" or inputBone.name == "bone_E_left_ear_main") then
	(
		case of
		(
			(skelType == "fs_african_elephant"):
			(
				flagOne = 1
				flagTwo = 0
			)
			(skelType == "fs_forest_elephant"):
			(
				flagOne = 0
				flagTwo = 0
			)					
		)
	)
	if(inputBone.name == "bone_E_right__front__foot" or inputBone.name == "bone_E_right_front_foot") then
	(
		case of
		(
			(skelType == "fs_african_elephant"):
			(
				flagOne = 0
				flagTwo = 0
			)
			(skelType == "fs_forest_elephant"):
			(
				flagOne = 1
				flagTwo = 0
			)					
		)
	)
	if(inputBone.name == "bone_E_left__front__thigh" or inputBone.name == "bone_E_left_front_thigh") then
	(
		case of
		(
			(skelType == "fs_african_elephant"):
			(
				flagOne = 1
				flagTwo = 0
			)
			(skelType == "fs_forest_elephant"):
			(
				flagOne = 0
				flagTwo = 0
			)					
		)
	)
	
	append resultArr frontValue
	append resultArr flagOne
	append resultArr flagTwo
	return resultArr
)

function GetHierarchy inputBones skelType =
(
	local exportArr = #() -- format [name, game index, bone idx, bone special props]
	local counter = 0
	for i in inputBones do
	(
		if(i.parent.name == "Armature") then
		(
			-- first bone
			local entry = #()
			append entry i.name
			append entry -1
			append entry counter
			append entry (GetBonePropsByName i skelType)
			append exportArr entry
		) else
		(
			local entry = #()
			local foundParent = false
			for p in exportArr do
			(
				if(i.parent.name == p[1]) then
				(
					foundParent = true
					append entry i.name
					append entry (p[3])
					append entry counter
					append entry (GetBonePropsByName i skelType)
					append exportArr entry
				)
			)
		)
		counter = (counter + 1)
	)
	return exportArr
)

function FormatSkeletonEntry val zeroes noPlus = 
(
	tempzeros = "000000000000"
	if (val > -0.0001) and (val < 0.0001) then
	(
		val = 0.0
	)
	
	-- if there is no '-', add a '+'.
	if findString (val as string) "-" == undefined then
	(
		if(noPlus) then
		(
			val = " " + (val as string) -- spacer
		) else
		(
			val = "+" + (val as string)	
		)
	)
	
	-- fill string with extra zeros before using substring
	val = (val as string) + tempzeros
	
	-- Set the string length
	val = substring val 1 (3 + zeroes)
	
	return val
)

utility IWTECoordinateExporter "IWTE Bone Exporter"
(
	group "Info:"
	(
		label titleLabel1 "Bone Coordinate Exporter"
		label extraLabel "for RTW RR (IWTE)"
		label titleLabel2 "v2.0" color:(color 0 20 80)
		label empt " "
		label titleLabel3 "Use this tool to export bone" color:(color 0 180 50)
		label extraLabel5 "coordinates for" color:(color 0 180 50)
		label extraLabel2 "IWTE skeleton files" color:(color 0 180 50)
		HyperLink author "by Sirrianus Dagovax" align:#center address:"mailto:dagovax@gmail.com" color:(color 0 0 170) hoverColor:(color 170 0 0)
	)
	
	group "Bone Coordinates"
	(
		spinner skelScale "Scale:" range:[0.00,10.00,1.00] type:#float tooltip:"Define the scale of the skeleton (animations)" align:#right width:120 scale:0.01
		spinner lerpFloat "Lerp Float:" range:[0.00,1.00,0.00] type:#float tooltip:"Lerp Float" align:#right width:150 scale:0.01
		groupBox emptyLineGro width: 130 height:2
		label fillerLabel1 "Export current hierarchy"
		button exportBones "Export" width:130 height:30
	)
	
	-- export bones
	on exportBones pressed do
	(
		local canContinue = true
		
		pointers = for t in objects where (classOf t == Point) and (t.name != "Scene Root") collect t
		global dummies = for t in objects where (classOf t == Dummy) and (t.name != "Armature") collect t
		
		--Check if there are bones, otherwise, close message
		if ((dummies == undefined and pointers == undefined) or (dummies.count == 0 and pointers.count == 0)) then
		(
			canContinue = false
			messageBox "There are no bones in this scene!"
		)
		
		-- Old format not supported by this script, use other one!
		if (dummies.count == 0 and pointers.count > 0) then
		(
			canContinue = false
			messageBox "You have an old skeleton format! Use openCOLLADA for this script!"
		)
		
		if(canContinue) then
		(
			local skelType = "None"
			--Dialog to let the user select the wanted bone structure
			rollout skelSelectorDialog "Choose used base Skeleton"
			(
				label labelHeader "In the list below, select the"
				label labelHeader2 "base skeleton you altered"
				dropdownlist list "Choose an option:" items:#("fs_archer","fs_big_elephant_rider","fs_dagger", "fs_slinger_new", "fs_camel", "fs_dog", "fs_horse", "fs_african_elephant", "fs_forest_elephant", "fs_indian_elephant", "fs_pig", "None") selection:3 height:9 tooltip:"Select an entry!"
				button continueButton "Continue" height:20
				
				on continueButton pressed do
				(
					try (destroydialog skelSelectorDialog) catch()
					local boneHierarchyArray = GetHierarchy dummies list.selected
					--print boneHierarchyArray
					output = newScript()
					
					local scaleValue = skelScale.value
					local lerpFloatValue = lerpFloat.value
					scaleValue = FormatSkeletonEntry scaleValue 4 true
					lerpFloatValue = FormatSkeletonEntry lerpFloatValue 4 true
					
					format "  %\t\t\t\t\t\t\t\t\t\t\t\t\t# skeleton scale\n%\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t# number of bones\n%\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t# bone count 2\n  %\t\t\t\t\t\t\t\t\t\t\t\t\t# lerp float\n" \
					scaleValue boneHierarchyArray.count 0 lerpFloatValue to:output					
					
					for i in boneHierarchyArray do
					(
						local boneName = i[1]
						local boner = (for t in dummies where (t.name == boneName) collect t)[1]
						local boneHierarchy = i[2]
						local boneIndex = i[3]
						local boneSpecs = i[4]
						local boneIndexType = boneSpecs[1]
						local boneFlagOne = boneSpecs[2]
						local boneFlagTwo = boneSpecs[3]
						
						_x = boner.pos.x
						_z = boner.pos.z
						_y = boner.pos.y
						
						-- Loop through parent if it has one and compare the difference
						if boner.parent != undefined then
						(
							local parent = boner.parent
							-- Gets the height difference between the parent and child
							if parent.pos.z < _z then
							(
								_z = (boner.pos.z - parent.pos.z)
							) else
							(
								_z = (parent.pos.z - boner.pos.z) *-1
							)
							
							-- Gets the horizontal 'x' difference between the parent and child
							if parent.pos.x < _x then
							(
								_x = (boner.pos.x - parent.pos.x) *-1
							) else
							(
								_x = (parent.pos.x - boner.pos.x) 
							)
							
							-- Gets the depth 'y' difference between the parent and child
							if parent.pos.y < _y then
							(
								_y = (boner.pos.y - parent.pos.y) *-1
							) else
							(
								_y = (parent.pos.y - boner.pos.y) 
							)
						)
						
						_x = _x * -1
						_y = _y * -1
						
						_x = FormatSkeletonEntry _x 4 true
						_y = FormatSkeletonEntry _y 4 true
						_z = FormatSkeletonEntry _z 4 true
						
						local boneHierarchyString = boneHierarchy as string
						if(boneHierarchyString.count == 1) then
						(
							boneHierarchyString = " " + boneHierarchyString
						)
						
						format "   %   %   %   %  %   %   %\t\t\t\t# bone idx %\t-- %\n" \
						boneIndexType _x _z _y boneHierarchyString boneFlagOne boneFlagTwo boneIndex boneName to:output
					)
				)
			)
			createDialog skelSelectorDialog 210 120
		)
	)
)
