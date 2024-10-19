-------------------------------------------
--										 --
--  COLLADA RTW exporter  --
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

----------------------------------------------------------
--										 				--
-- 			Revision history:			 				--
--										 				--
-- v1.0 -- intial version 				 				--
-- v1.1 -- fixed sometimes no export 				--
-- v1.2 -- Added default safe and ## fix  			--
--       -- renamed the tool  			--
-- v1.3 -- Fixed errors due to scripts having duplicate functions   --
-- v1.4 -- Export file name will be lowercase
-- v1.5 -- Added Single weight button
-- v1.6 -- Added nocull
-- v1.7 -- Added skip LOD1 (for IWTE)
----------------------------------------------------------

function RTWColladaTools_ReplaceSpaceWithUnderscore inputString = 
(
	for i = 1 to inputString.count where (findstring inputString[i] " ") != undefined do 
	(
		inputString[i] = "_"
	) 
	return inputString
)

function RTWColladaTools_GetSkinVertsByBone sk id: exact:on = 
(
	if id == unsupplied do id = skinops.getselectedbone sk
   
	verts = #{}
	for k=1 to skinops.getnumbervertices sk do
	(
	  found = off
	  for i=1 to skinops.getvertexweightcount sk k while not found do
	  (
		 if (skinops.getvertexweightboneid sk k i) == id do 
		 (
			if not exact or (skinops.getvertexweight sk k i > 0) do
			(
			   append verts k
			   found = on
			)
		 )
	  )
	)
	verts
)

function RTWColladaTools_SkinRemoveUnusedBones obj =
(
	local weightThresh = 0.0001
	select obj
	for m in obj.modifiers where classof m == Skin do 
	(
		modPanel.setCurrentObject m

		local vertCount = skinOps.GetNumberVertices m
		local bonesCount = skinOps.GetNumberBones m
		local unusedBones = #{1..bonesCount}
			
		for v = 1 to vertCount do 
		(
			local vertWeightCount = skinOps.GetVertexWeightCount m v

			for i = 1 to vertWeightCount do 
			(
				local weight = skinOps.GetVertexWeight m v i
				local boneID = skinOps.GetVertexWeightBoneID m v i
				if weight >= weightThresh then 
				(
					unusedBones[boneID] = false
				) else
				(
					unusedBones[boneID] = true
				)
			)
		)
		for i = bonesCount to 1 by -1 where unusedBones[i] do 
		(
			skinOps.SelectBone m i
			skinOps.RemoveBone m
		)
	)
)

function RTWColladaTools_SetVertexWeightToSingleBone obj delZeroBones =
(
	local hasSkin = (obj.modifiers[#Skin] != undefined)
	if(hasSkin) then
	(
		local numVerts = getNumVerts obj
		local vertsWithoutSkin = #()
		
		select obj
		max modify mode
		for i=1 to numVerts do 
		(
			local boneArray = #()
			local weightArray = #()
			local newWeightArray = #()
			local newBoneArray = #()
			
			boneArrayCount = skinOps.GetVertexWeightCount obj.modifiers[#Skin] i
			if(boneArrayCount > 1) then -- Only if a vertex has multiple bones
			(
				local highestWeight = 0.0
				local weightChanged = false
				local currBoneIndex = 0
				for k=1 to boneArrayCount do
				(
					-- get bones index and weights
					local boneIndex = skinOps.GetVertexWeightBoneID obj.modifiers[#skin] i k
					local boneWeight = skinOps.GetVertexWeight obj.modifiers[#skin] i k
					if(boneWeight > highestWeight) then
					(
						currBoneIndex = boneIndex
						highestWeight = boneWeight
						weightChanged = true
					)
					append boneArray boneIndex
					append weightArray boneWeight
				)
				
				for p in boneArray do
				(
					if p == currBoneIndex then
					(
						append newBoneArray p
						append newWeightArray 1.0 -- Set the bone to 1.0
					)
					else
					(
						append newBoneArray p
						append newWeightArray 0.0
					)
				)
				skinOps.SetVertexWeights obj.modifiers[#Skin] i newBoneArray newWeightArray
			) else
			(
				if(boneArrayCount == 1) then
				(
					local boneIndex = skinOps.GetVertexWeightBoneID obj.modifiers[#skin] i 1
					if(boneIndex == undefined) then
					(
						print ("Vertex " + i as string + " of mesh " + obj.name + " has no weight applied at all!")
						append vertsWithoutSkin i
					) 
					else
					(
						append newBoneArray boneIndex
						append newWeightArray 1.0
						skinOps.SetVertexWeights obj.modifiers[#Skin] i newBoneArray newWeightArray
					)
				)
				else -- no weight at all!
				(
					print ("Vertex " + i as string + " of mesh " + obj.name + " has no weight applied at all!")
					append vertsWithoutSkin i
				)
			)
		)
		if(delZeroBones) then
		(
			RTWColladaTools_SkinRemoveUnusedBones obj
		)
		
		if(vertsWithoutSkin.count > 0) then
		(
			local skinMod = obj.modifiers[#Skin]
			for i = 1 to vertsWithoutSkin.count do
			(
				-- Get the position of the vertex
				local vertPos = getVert obj vertsWithoutSkin[i]

				-- Find the nearest bone
				local nearestBone = undefined
				local nearestDist = 999999 -- Some large initial distance

				for boneIndex = 1 to skinOps.GetNumberBones skinMod do
				(
					local boneTM = getNodeTM obj
					local bonePos = boneTM.translation
					local dist = distance vertPos bonePos
					
					if dist < nearestDist do
					(
						nearestDist = dist
						nearestBone = boneIndex
					)
				)

				-- Assign the nearest bone with a weight of 1.0
				if nearestBone != undefined do
				(
					skinOps.SetVertexWeights skinMod i nearestBone 1.0
				)
			)
		)
	)
	return true
)

function RTWColladaTools_ConvertBitmapNameToIWTE inString =
(
	local resultString = inString
	local hh = "##"
	local hhIndex = findString resultString hh
	if(hhIndex != undefined) then
	(
		if(resultString[1] == hh[1] and resultString[2] == hh[2]) then
		(
			resultString = replace resultString hhIndex 2 "hh_"
		)
	)
	
	local ha = "#&"
	local haIndex = findString resultString ha
	if(haIndex != undefined) then
	(
		if(resultString[1] == ha[1] and resultString[2] == ha[2]) then
		(
			resultString = replace resultString haIndex 2 "ha_"
		)
	)

	local h = "#"
	local hIndex = findString resultString h
	if(hIndex != undefined) then
	(
		if(resultString[1] == h[1]) then
		(
			resultString = replace resultString hIndex 1 "h_"
		)
	)
	
	if(resultString != inString) then
	(
		print("Swapped texture name from '" + inString as string + "' to '" + resultString +"'")
	)
	
	return resultString
)

function RTWColladaTools_ConvertBitmapNameFromIWTE inString =
(
	resultString = inString
	
	-- Remove nocull flag
	local nc = "_nocull"
	local noCullIndex = findString resultString nc
	if(noCullIndex != undefined) then
	(
		resultString = replace resultString noCullIndex 7 "" 
		print("Removing _nocull at end of texture name!")
	)
	
	local hh = "hh_"
	local hhIndex = findString resultString hh
	if(hhIndex != undefined) then
	(
		if(resultString[1] == hh[1] and resultString[2] == hh[2] and resultString[3] == hh[3]) then
		(
			resultString = replace resultString hhIndex 3 "##"
		)
	)
	
	local ha = "ha_"
	local haIndex = findString resultString ha
	if(haIndex != undefined) then
	(
		if(resultString[1] == ha[1] and resultString[2] == ha[2] and resultString[3] == ha[3]) then
		(
			resultString = replace resultString haIndex 3 "#&"
		)
	)

	local h = "h_"
	local hIndex = findString resultString h
	if(hIndex != undefined) then
	(
		if(resultString[1] == h[1] and resultString[2] == h[2]) then
		(
			resultString = replace resultString hIndex 2 "#"
		)
	)
	
	if(resultString != inString) then
	(
		print("Swapped texture name back from '" + inString as string + "' to '" + resultString +"'")
	)
	
	return resultString
)

function RTWColladaTools_ConvertMaterialExtensionToIWTE inString = 
(
	local resultString = inString
	
	local tga = ".tga"
	local tgaIndex = findString resultString tga
	if(tgaIndex != undefined) then
	(
		resultString = replace resultString tgaIndex 4 "_tga"
	)
	
	return resultString
)

function RTWColladaTools_ConvertMaterialExtensionFromIWTE inString = 
(
	local resultString = inString
	
	local tga = "_tga"
	local tgaIndex = findString resultString tga
	if(tgaIndex != undefined) then
	(
		resultString = replace resultString tgaIndex 4 ".tga"
	)
	
	return resultString
)

function RTWColladaTools_CheckMaterialName inBoolean noCullArr changeMatBool ignoreFrozen =
(
	local allObjects = for b in objects where (classOf b == Editable_Mesh and (b.isHidden == false))  collect b
	if(ignoreFrozen) then
	(
		allObjects = for b in allObjects where (b.isFrozen == false) collect b
	)
	local mats = makeUniqueArray (for o in allObjects collect o.material)
	if(mats != undefined) then
	(		
		for m in mats do
		(
			if(m == undefined) then
			(
				exit
			)
			local errorArr = #()
			for b in getClassInstances bitmapTex target:m where b != undefined  do
			(
				local noCull = false
				textureName = getFilenameFile b.filename
				if(inBoolean) then
				(
					if(noCullArr != undefined) then
					(
						for item in noCullArr do
						(
							if item[1] == textureName do
							(
								-- Texture name found, return its corresponding boolean value
								noCull = item[2]
							)
						)
					)
					result = RTWColladaTools_ConvertBitmapNameToIWTE textureName
				) else
				(
					result = RTWColladaTools_ConvertBitmapNameFromIWTE textureName
				)
				local newName = (getFilenamePath b.filename) + result + (getFilenameType b.filename)
				local newMatName = RTWColladaTools_ConvertMaterialExtensionToIWTE result
				if(inBoolean == true and noCull == true) then
				(
					newMatName =  newMatName + "_nocull"
				)
				
				b.filename = newName
				if(changeMatBool) then
				(
					m.name = newMatName -- Change material name
				)
				if (inBoolean == false) then
				(
					-- Remove nocull flag
					local nc = "_nocull"
					local noCullIndex = findString newName nc
					if(noCullIndex != undefined) then
					(
						newName = replace newName noCullIndex 7 "" 
					)
					b.filename = newName
					if (not doesFileExist newName and newName != undefined and newName != "") then
					(
						local suffix = ".tga"
						if ((substring newName (newName.count - suffix.count + 1) newName.count) == suffix) then
						(
							newName = newName + ".dds"
						)
						else
						(
							newName = newName + ".tga"
						)
						
						b.filename = newName
						if (not doesFileExist newName and newName != undefined and newName != "") then
						(							
							if ((substring newName (newName.count - suffix.count + 1) newName.count) == suffix) then
							(
								newName = newName + ".dds"
							)
							
							b.filename = newName
							if (not doesFileExist newName and newName != undefined and newName != "") then
							(
								if (finditem errorArr newName == 0) then
								(
									append errorArr newName
									messageBox ("Could not find texture: \n\n'" + newName + "'") title:"Error!"	
								)
							)
						)
					)
					
					if(changeMatBool) then
					(
						m.name = RTWColladaTools_ConvertMaterialExtensionFromIWTE newMatName
					)
				)
			)
		)	
	)
)

function RTWColladaTools_GetNoCullTextures ignoreFrozen =
(
	local resultArr = #()
	
	local allObjects = for b in objects where (classOf b == Editable_Mesh and (b.isHidden == false))  collect b
	if(ignoreFrozen) then
	(
		allObjects = for b in allObjects where (b.isFrozen == false) collect b
	)
	local mats = makeUniqueArray (for o in allObjects collect o.material)

	local textures = #()
		
	if(mats != undefined) then
	(			
		for m in mats do
		(
			for b in getClassInstances bitmapTex target:m where b != undefined  do
			(
				local textureName = getFilenameFile b.filename
				appendIfUnique textures textureName
			)
		)
	)
	
	for textureName in textures do
	(
		local result = queryBox ("Do you want to enable No Back-face Culling to this texture?\n\n" + textureName) title:"No Back-face Culling" beep:true
		if result then
		(
			append resultArr #(textureName, true)
		)
		else
		(
			append resultArr #(textureName, false)
		)
	)
	
	return resultArr
)

-- Get the root NODE (not bone!), either Armature or Scene Root depending on imported file
function RTWColladaTools_GetRootNode =
(
	local armature = getNodeByName "Armature" exact:true
	if (armature == undefined) then 
	(			
		armature = getNodeByName "Scene_Root" exact:true
		if(armature == undefined) then
		(
			armature = getNodeByName "Scene Root" exact:true
			if(armature == undefined) then
			(
				return null
			)
		)
	)
	return armature
)

-- Return a list of bones (without Armature/Scene Root)
function RTWColladaTools_GetBones =
(
	local armature = RTWColladaTools_GetRootNode()
	if(armature != undefined) then
	(
		local dummies = for t in objects where (classOf t == Dummy and t.name != armature.name and t.parent != undefined) collect t
		local pointers = for t in objects where (classOf t == Point and t.name != armature.name and t.parent != undefined) collect t
		if (dummies == undefined or dummies.count == 0) then
		(
			if(pointers == undefined or pointers.count == 0) then
			(
				return null
			)
			return pointers
		)
		return dummies	
	)
)

-- Count all bones in the scene
function RTWColladaTools_CountBones =
(
	local allBones = RTWColladaTools_GetBones()
	if(allBones == undefined) then
	(
		return 0
	)
	return allBones.count
)

utility RTWColladaTools "RTW Collada Tools"
(
	group "Info:"
	(
		label titleLabel1 "RTW Collada Tools"
		label extraLabel "using openCOLLADA"
		label titleLabel2 "v1.7" color:(color 0 20 80)
		label empt " "
		label titleLabel3 "Use this tool to import" color:(color 0 180 50)
		label titleLabel4 "Or export .DAE files." color:(color 0 180 50)
		label extraLabel2 "Also Multi LODS support" color:(color 0 180 50)
		HyperLink author "by Sirrianus Dagovax" align:#center address:"mailto:dagovax@gmail.com" color:(color 0 0 170) hoverColor:(color 170 0 0)
	)
	label fillerLabel1 " "
	
	group "Generic:"
	(
		checkbox noCullBox "No Back-face Culling" width:130 height:15 checked:false tooltip:"On RR, buildings have back-face culling on by default. Checking this will add a flag to the texture name for IWTE, to disable back-face culling."
		checkbox changeMaterialNamesBox "Auto Change Mat. Names" width:130 height:15 checked:false tooltip:"IWTE requires certain material name handling (for example for back-face culling). Disabling this might give problems for export."
	)
	
    -- Event handler for the noCullBox
    on noCullBox changed newState do
    (
        -- Change the state of change mat. names to true
        if newState == true then
        (
            changeMaterialNamesBox.checked = true
        )
		else
		(
			changeMaterialNamesBox.checked = false
		)
    )
	
	group "Import / Export:"
	(
		label miscLabel3 "Importing and Exporting"
		label miscLabel4 "files with these buttons"
		label miscLabel1 "will automatically"
		label miscLabel2 "handle textures"
		button importScene "Import" width:130 height:30
		groupBox line1 width: 130 height:2
		checkbox exportIgnoreBones "Ignore Bone Check" width:130 height:15 checked:true tooltip:"When unchecked, bone count will be validated. Keep it checked when you want to export without bones"
		checkbox exportIgnoresFrozen "Ignore Frozen Items" width:130 height:15 checked:true tooltip:"When checked, frozen meshes will not be exported."
		button exportScene "Export" width:130 height:30
	)
	
	-- Load collada
	on importScene pressed do
	(		
		print "Starting collada import..."
		maxini = getMAXIniFile()
		if(maxFileName != "") then
		(
			sceneName = maxFileName
			sceneNameCount = sceneName.count
			sceneNameCount += 1
			maxSectionIndex = findString sceneName ".max"
			sceneNameLength = sceneNameCount - maxSectionIndex
			sceneName = RTWColladaTools_ReplaceSpaceWithUnderscore (replace sceneName maxSectionIndex sceneNameLength "")
		)
		else
		(
			sceneName = ""
		)

		lastpath = getINISetting maxini "MAXHistoryList" "History_00"
		local colladaImporter = for o in importerPlugin.classes where (o as string == "OpenCOLLADAImporter" ) collect o
		if(colladaImporter.count == 0) then 
		(
			messageBox "You don't have the OpenCOLLADA plugin installed!"
			return null
		) else
		(
			print ("Found valid OpenCollada importer: " + colladaImporter[1] as string)
			fileName = getOpenFileName caption:"Import openCOLLADA file" types:"OpenCOLLADA(*.DAE)|*.DAE" historyCategory:"ImportFile"
			if(fileName != undefined) then 
			(
				importPath = (getFilenamePath fileName) + getFilenameFile fileName + ".dae";
				Print("Importing file: " + importPath as string)
				importFile importPath #noPrompt using:colladaImporter[1]
				
				RTWColladaTools_CheckMaterialName false undefined -- converts IWTE stuff to ##
				
				if($EnvironmentAmbientLight != undefined) then
				(
					delete $EnvironmentAmbientLight
				)
					
				mats = for b in sceneMaterials where b != undefined collect b
				for i in mats do
				(
					diffuseMp = i.diffuseMap
					if(diffuseMp != undefined) then
					(
						diffuseMp.alphasource = 2
					)
					
					opacityMap = i.opacityMap
					if(opacityMap != undefined) then
					(
						opacityMap.monoOutput = 1
					)
				)
			)
		)
	)
	
	-- Save current scene as Collada
	on exportScene pressed do
	(		
		local selectionClone = for sel in selection collect sel
		local allBigObjects = for b in objects where (classOf b == Editable_Mesh and (b.isHidden == false))  collect b
		if(allBigObjects == undefined or allBigObjects.count == 0) then
		(
			messageBox "There are no meshes in this scene!" title:"Error!"
			return null
		)
		local ignoreFrozen = exportIgnoresFrozen.checked
		if(ignoreFrozen) then
		(
			allBigObjects = for obj in allBigObjects where not (obj.isFrozen) collect obj
		)

		local ignoreBoneCheck = exportIgnoreBones.checked
		if(ignoreBoneCheck == false) then
		(
			local boneCount = RTWColladaTools_CountBones()
			if(boneCount == 0) then
			(
				messageBox "There are no bones in this scene!" title:"Error!"
				return null
			)
			if(boneCount > 24) then
			(
				messageBox "There are more than 24 bones in this scene {"+ boneCount as string +"}.\n\nRome: Total War does not support more bones!" title:"Error!"
				return null
			)
			print ("Bone Check: Current Scene has " + boneCount as string + " bones.")
		)

		local noCull = noCullBox.checked
		local noCullArr = #()
		if(noCull) then
		(
			noCullArr = RTWColladaTools_GetNoCullTextures ignoreFrozen
		)
		local changeMatNames = changeMaterialNamesBox.checked
		
		print "Starting collada export..."
		
		maxini = getMAXIniFile()
		if(maxFileName != "") then
		(
			sceneName = maxFileName
			sceneNameCount = sceneName.count
			sceneNameCount += 1
			maxSectionIndex = findString sceneName ".max"
			sceneNameLength = sceneNameCount - maxSectionIndex
			sceneName = RTWColladaTools_ReplaceSpaceWithUnderscore (replace sceneName maxSectionIndex sceneNameLength "")
		)
		else
		(
			sceneName = ""
		)

		lastpath = getINISetting maxini "MAXHistoryList" "History_00"
		local colladaExporter = for o in exporterPlugin.classes where (o as string == "OpenCOLLADAExporter" ) collect o
		if(colladaExporter.count == 0) then 
		(
			messageBox "You don't have the OpenCOLLADA plugin installed!"
			return null
		)
		else
		(
			print ("Found valid OpenCollada exporter: " + colladaExporter[1] as string)
			fileName = getSaveFileName caption:"Export openCOLLADA file" types:"OpenCOLLADA(*.DAE)|*.DAE" historyCategory:"ExportFile" filename:(toLower sceneName)
			if(fileName != undefined) then 
			(
				ePath = (getFilenamePath fileName) + getFilenameFile fileName + ".dae";
				Print("Exporting file: " + ePath as string + ".dae")
				RTWColladaTools_CheckMaterialName true noCullArr changeMatNames ignoreFrozen
				
				select allBigObjects
				exportFile ePath #noPrompt selectedOnly:true using:colladaExporter[1]
				RTWColladaTools_CheckMaterialName false noCullArr changeMatNames ignoreFrozen
				deselect allBigObjects
				select selectionClone
			)
		)
	)
	
	group "Multi Lods:"
	(
		checkbox skipLodOne "Skip LOD1" width:130 height:15 checked:true tooltip:"IWTE automatically creates a LOD1 when the LOD0 contains multiple vertex per bone weighting. So when you have this checked, the tool will skip LOD1 export."
		label exptLabel1 "Min. vertices threshold"
		label exptLabel2 "to apply ProOptimizer:"
		spinner minVertexAmount "" width:50 height:20 align:#center type:#integer range:[0, 100000, 150]
		radiobuttons objectMode labels:#("Skinned", "Static (Building)")
		button exportLODS "Export LODS" width:130 height:30
	)
	
	on exportLODS pressed do
	(
		isBuilding = false
		if objectMode.state == 2 then
		(
			isBuilding = true
		)
		allBigObjects = for b in objects where (classOf b == Editable_Mesh and (b.isHidden == false))  collect b

		-- First get all bones
		pointers = makeUniqueArray (for t in objects where (classOf t == Dummy) collect t)
		if (isBuilding == false) then
		(
			local boneCount = RTWColladaTools_CountBones()
			if(boneCount == 0) then
			(
				messageBox "There are no bones in this scene!" title:"Error!"
				return null
			)
			if(boneCount > 24) then
			(
				messageBox "There are more than 24 bones in this scene {"+ boneCount as string +"}.\n\nRome: Total War does not support more bones!" title:"Error!"
				return null
			)
			print ("Bone Check: Current Scene has " + boneCount as string + " bones.")
		)
		
		-- Then check if Armature is present, thust rootbone
		armature = getNodeByName "Armature" exact:true
		if (isBuilding == false) then
		(
			if (armature == undefined) and canContinue == true then 
			(			
				messageBox "There is no Armature root bone!" title:"Error!"
				return null
			)
		)
		
		-- Check Skin modifier and if all vertices for each objects are weighted
		skinChecked = false
		for obj in allBigObjects do
		(
			if(isBuilding) then -- Skip Skin check if the user selected building,
			(
				exit
			)
			theMods = for m in obj.modifiers where (classOf m == Skin) collect m
			if(theMods == undefined) or (theMods.count == 0) then
			(
				messageBox ("There is no Skin modifier present for object " + obj.name as string) title:"Error!"
				return null
			)
			else
			(
				vertAssign = #()
				numVerts = getNumVerts obj
				select obj
				max modify mode
				for i=1 to numVerts do 
				(
					for k=1 to (skinOps.GetVertexWeightCount obj.modifiers[#Skin] i) do
					(
						if((skinOps.GetVertexWeight obj.modifiers[#Skin] i k) > 0.1) then
						(
							append vertAssign (skinOps.GetVertexWeightBoneId obj.modifiers[#Skin] i k)
						)
					)
				)
				for i=1 to numVerts do 
				(
					if vertAssign[i]==undefined then
					(
						messageBox ("Problem occured while reading the vertex weights of vertex " + ( (i-1) as string) +" in mesh " +obj.name + ". Make sure each vertex has a bone weight") title:"Error!"
						return null
					)
				)
				max create mode
				deselect obj
			)
		)
	
		clones = #{}
		clones = for b in allBigObjects collect (copy b)
		for clone in clones do
		(
			clone.ishidden = true 
		)
		
		-- Main script now
		minVA = minVertexAmount.value
		print ("Spinner input set to " + minVA as string)
		print "Starting multi lods export..."
		maxini = getMAXIniFile()
		if(maxFileName != "") then
		(
			sceneName = maxFileName
			sceneNameCount = sceneName.count
			sceneNameCount += 1
			maxSectionIndex = findString sceneName ".max"
			sceneNameLength = sceneNameCount - maxSectionIndex
			sceneName = RTWColladaTools_ReplaceSpaceWithUnderscore (replace sceneName maxSectionIndex sceneNameLength "")
		)
		else
		(
			sceneName = ""
		)

		local noCull = noCullBox.checked
		local noCullArr = #()
		if(noCull) then
		(
			noCullArr = RTWColladaTools_GetNoCullTextures false
		)
		
		local changeMatNames = changeMaterialNamesBox.checked
		
		lastpath = getINISetting maxini "MAXHistoryList" "History_00"
		local colladaExporter = for o in exporterPlugin.classes where (o as string == "OpenCOLLADAExporter" ) collect o
		if(colladaExporter.count == 0) then 
		(
			messageBox "You don't have the OpenCOLLADA plugin installed!"
			return null
		)
		else
		(
			print ("Found valid OpenCollada exporter: " + colladaExporter[1] as string)
			fileName = getSaveFileName caption:"Choose your directory and enter your model name (without the _lod0)!" types:"OpenCOLLADA(*.DAE)|*.DAE" historyCategory:"ExportFile" filename:(toLower sceneName)
			if(fileName != undefined) then 
			(
				RTWColladaTools_CheckMaterialName true noCullArr changeMatNames false
				for i = 0 to 3 do
				(
					local lodInt = i
					if(skipLodOne.checked and i > 0) then
					(
						lodInt = lodInt + 1
					)
					ePath = (getFilenamePath fileName) + getFilenameFile fileName + "_lod" + lodInt as string + ".dae";
					print ("Generating LOD " + lodInt as string +"...")
					case i of
					(
						0:
						(
							--print "Generating LOD0..."
							for curr in allBigObjects do
							(
								print ("Standard amount vertices in object " + curr.name as string + ": " + getNumVerts curr as string)
							)
						)
						1:
						(
							-- Only add the modifier to the lod1 (to speed up things)
							for b = 1 to allBigObjects.count do
							(
								curr = allBigObjects[b]
								RTWColladaTools_SetVertexWeightToSingleBone curr false
								numVerts = getNumVerts clones[b]
								
								max modify mode
								select curr
								if (numVerts > minVA) then
								(
									print ("Added ProOptimizer modifier to " + curr.name as string)
									addmodifier curr (ProOptimizer())
									--collect all modifiers in the current object (move new smooth to bottom stack)
									theMods = for m in curr.modifiers collect m
									for m in theMods where classOf m == ProOptimizer do
									(
										addModifier curr m before:theMods.count --instance it to the bottom of the stack
										deleteModifier curr m --and remove the original instance from where it was on the stack
									)
									$.modifiers[#ProOptimizer].OptimizationMode  = 1
									$.modifiers[#ProOptimizer].LockMat = true
									$.modifiers[#ProOptimizer].KeepUV = true
									$.modifiers[#ProOptimizer].LockUV = true
									$.modifiers[#ProOptimizer].KeepNormals = true
									$.modifiers[#ProOptimizer].NormalMode = 1
									$.modifiers[#ProOptimizer].VertexPercent = 80
									$.modifiers[#ProOptimizer].CompactFaces = true
									$.modifiers[#ProOptimizer].PreventFlip = true
									$.modifiers[#ProOptimizer].Calculate = true
									print ("Reduced vertices of object " + curr.name as string + " to " + getNumVerts curr as string)
								)
								deselect curr
							)
						)
						2:
						(
							--print "Generating LOD2..."
							for b = 1 to allBigObjects.count do
							(
								curr = allBigObjects[b]
								numVerts = getNumVerts clones[b]
								if (numVerts > minVA) then
								(
									max modify mode
									select curr
									$.modifiers[#ProOptimizer].VertexPercent = 50
									print ("Reduced vertices of object " + curr.name as string + " to " + getNumVerts curr as string)
									deselect curr
								)
							)
						)
						3:
						(
							if(skipLodOne.checked == false) then
							(
								--print "Generating LOD3..."
								for b = 1 to allBigObjects.count do
								(
									curr = allBigObjects[b]
									numVerts = getNumVerts clones[b]
									if (numVerts > minVA) then
									(
										max modify mode
										select curr
										$.modifiers[#ProOptimizer].VertexPercent = 20
										print ("Reduced vertices of object " + curr.name as string + " to " + getNumVerts curr as string)
										deselect curr
									)
								)
							)
						)
					)
					Print("Done!")				
					if(skipLodOne.checked and i == 3) then
					(
						print("Skipped exporting last lod")
					) else
					(
						print("Exporting file: " + ePath as string + ".dae")
						exportFile ePath #noPrompt selectedOnly:false using:colladaExporter[1]
					)
				)
				RTWColladaTools_CheckMaterialName false undefined changeMatNames false
			)
		)
		print ("Using clones...")
		for i = 1 to clones.count do
		(
			clones[i].name = allBigObjects[i].name
			print("Renamed " + clones[i].name as string + " to " + allBigObjects[i].name as string)
			if(allBigObjects[i] != undefined) then
			(
				delete allBigObjects[i]
			)
			clones[i].ishidden=false
		)
		print ("All LODS Exported!")
	)
	
	group "Misc:"
	(
		checkbox deleteUnusedBonesSkin "Del. Unweighted" width:130 height:15 checked:true tooltip:"When checked, removes every bone that has no weight from the skin table."
		button setSingleWeight "Skin Single Weight" width:130 height:30 tooltip:"For every Editable_Mesh with a Skin modifier, sets the weight to single bone only."
	)
	
	-- Set single bone weight
	on setSingleWeight pressed do
	(
		local allMeshes = for b in objects where (classOf b == Editable_Mesh and (b.isHidden == false))  collect b
		if(allMeshes == undefined or allMeshes.count == 0) then
		(
			messageBox "There are no (visible) meshes in this scene!" title:"Error!"
			return null
		)
		
		-- Main fun
		for i = 1 to allMeshes.count do
		(
			local curr = allMeshes[i]
			local continueFor = RTWColladaTools_SetVertexWeightToSingleBone curr deleteUnusedBonesSkin.checked
			if(continueFor == false) then
			(
				return false
			)
		)
	)
)