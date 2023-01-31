-------------------------------------------
--										 --
--  COLLADA LOD exporter  --
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

function ReplaceSpaceWithUnderscore inputString = 
(
	for i = 1 to inputString.count where (findstring inputString[i] " ") != undefined do 
	(
		inputString[i] = "_"
	) 
	return inputString
)

function getSkinVertsByBone sk id: exact:on = 
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

struct VERTEX_WEIGHT (
	obj,
	vertexIndex,
	boneArray,
	weightArray,
	
	function getObj = 
	(
		return obj
	),
	function getVertexIndex =
	(
		return vertexIndex
	),
	function getBoneArray =
	(
		return boneArray
	),
	function getWeightArray =
	(
		return weightArray
	)
)

utility DAEExport "DAE multi LOD export"
(
	group "Info:"
	(
		label titleLabel1 "RTW LOD exporter"
		label extraLabel "using openCOLLADA"
		label titleLabel2 "v1.0" color:(color 0 20 80)
		label empt " "
		label titleLabel3 "Use this tool to export" color:(color 0 180 50)
		label extraLabel2 "multiple LODS" color:(color 0 180 50)
		HyperLink author "by Sirrianus Dagovax" align:#center address:"mailto:dagovax@gmail.com" color:(color 0 0 170) hoverColor:(color 170 0 0)
	)
	label fillerLabel1 " "
	
	group "Export:"
	(
		label exptLabel1 "Min. amount of vertices"
		label exptLabel2 "to apply ProOptimizer:"
		spinner minVertexAmount "" width:50 height:20 align:#center type:#integer range:[0, 100000, 150]
		radiobuttons objectMode labels:#("Skinned", "Static (Building)")
		button exportLODS "Export" width:130 height:30
	)
	
	on exportLODS pressed do
	(
		isBuilding = false
		if objectMode.state == 2 then
		(
			isBuilding = true
		)
		canContinue = true
		allBigObjects = for b in objects where (classOf b == Editable_Mesh)  collect b

		-- First get all bones
		pointers = makeUniqueArray (for t in objects where (classOf t == Dummy) collect t)
		if (isBuilding == false) then
		(
			if pointers.count == 0 then
			(
				canContinue = false
				messageBox "There are no bones in this scene!" title:"Error!"
			)
		)
		
		-- Then check if Armature is present, thust rootbone
		armature = getNodeByName "Armature" exact:true
		if (isBuilding == false) then
		(
			if (armature == undefined) and canContinue == true then 
			(			
				canContinue = false
				messageBox "There is no Armature root bone!" title:"Error!"
			)
		)
		
		-- Check Skin modifier and if all vertices for each objects are weighted
		if (canContinue == true) then
		(
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
					canContinue = false
					messageBox ("There is no Skin modifier present for object " + obj.name as string) title:"Error!"
					exit
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
							canContinue = false
							MessageBox ("Problem occured while reading the vertex weights of vertex " + ( (i-1) as string) +" in mesh " +obj.name + ". Make sure each vertex has a bone weight") title:"Error!"
							exit
						)
					)
					max create mode
					deselect obj
				)
			)
		)
	
		clones = #{}
		if(canContinue == true) then
		(
			clones = for b in allBigObjects collect (copy b)
			for clone in clones do
			(
				clone.ishidden = true 
			)
		)
		
		-- Main script now
		if(canContinue == true) then 
		(
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
				sceneName = ReplaceSpaceWithUnderscore (replace sceneName maxSectionIndex sceneNameLength "")
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
			)
			else
			(
				print ("Found valid OpenCollada exporter: " + colladaExporter[1] as string)
				fileName = getSaveFileName caption:"Choose your directory and enter your model name (without the _lod0)!" types:"OpenCOLLADA(*.DAE)|*.DAE" historyCategory:"ExportFile" filename:sceneName
				if(fileName != undefined) then 
				(
					for i = 0 to 3 do
					(
						ePath = (getFilenamePath fileName) + getFilenameFile fileName + "_lod" + i as string;
						case i of
						(
							0:
							(
								print "Generating LOD0..."
								for curr in allBigObjects do
								(
									print ("Standard amount vertices in object " + curr.name as string + ": " + getNumVerts curr as string)
								)
							)
							1:
							(
								-- Only add the modifier to the lod1 (to speed up things)
								print "Generating LOD1..."
								for i = 1 to allBigObjects.count do
								(
									curr = allBigObjects[i]
									numVerts = getNumVerts clones[i]
									select curr
									max modify mode
									for i=1 to numVerts do 
									(
										boneArray = #()
										weightArray = #()
										newWeightArray = #()
										newBoneArray = #()
										if(isBuilding == false) then -- Modify skin stuff
										(
											boneArrayCount = skinOps.GetVertexWeightCount curr.modifiers[#Skin] i
											if(boneArrayCount > 1) then -- Only if a vertex has multiple bones
											(
												highestWeight = 0.0
												currBoneIndex = 0
												for k=1 to boneArrayCount do
												(
													-- get bones index and weights
													boneIndex = skinOps.GetVertexWeightBoneID curr.modifiers[#skin] i k
													boneWeight = skinOps.GetVertexWeight curr.modifiers[#skin] i k
													if(boneWeight > highestWeight) then
													(
														currBoneIndex = boneIndex
														highestWeight = boneWeight
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
												skinOps.SetVertexWeights curr.modifiers[#Skin] i newBoneArray newWeightArray
											)
										)
									)
									
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
								print "Generating LOD2..."
								for i = 1 to allBigObjects.count do
								(
									curr = allBigObjects[i]
									numVerts = getNumVerts clones[i]
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
								print "Generating LOD3..."
								for i = 1 to allBigObjects.count do
								(
									curr = allBigObjects[i]
									numVerts = getNumVerts clones[i]
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
						Print("Done!")				
						Print("Exporting file: " + ePath as string + ".dae")
						exportFile ePath #noPrompt selectedOnly:false using:colladaExporter[1]
					)
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
	)
)