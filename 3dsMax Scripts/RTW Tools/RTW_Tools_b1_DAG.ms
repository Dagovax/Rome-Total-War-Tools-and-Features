-------------------------------------------
--										 --
--  			RTW TOOLS  		--
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
-- v1.0 -- intial version 				 --
-- v1.1 -- Fixed errors due to scripts having duplicate functions   --
-------------------------------------------

function RTWTools_RoundFloat val dp = --rounds a float to a set number of decimal places
(
	a = val * (10^dp)
	b = a as integer
	a = b as float / (10^dp)
	return a
)

function RTWTools_SortByVertex arr = -- sort object array by vertex count
(		
	local sortedArr = #()
	while arr.count > 0 do
	(
		local highestObj = undefined
		local currNumVerts = 0
		local indexer = 1
		for i=1 to arr.count do
		(
			obj = arr[i]
			numVerts = getNumVerts obj
			if(numVerts > currNumVerts) then
			(
				currNumVerts = numVerts
				highestObj = obj
				indexer = i
			)
		)
		append sortedArr highestObj
		deleteItem arr indexer
	)
	for obj in sortedArr do
	(
		numVerts = getNumVerts obj
		print ("SortByVertex => " + obj.name + " | verts= " + numVerts as string)
	)
	return sortedArr
)	

function RTWTools_FormatSkeletonEntry val zeroes = 
(
	tempzeros = "000000000000"
	if (val > -0.0001) and (val < 0.0001) then
	(
		val = 0.0
	)
	
	-- if there is no '-', add a '+'.
	if findString (val as string) "-" == undefined then
	(
		val = "+" + (val as string)
	)
	
	-- fill string with extra zeros before using substring
	val = (val as string) + tempzeros
	
	-- Set the string length
	val = substring val 1 (3 + zeroes)
	
	return val
)

function RTWTools_CalculateOffset refObject difObject isCollada = 
(
	resultArr = #()
	if(refObject == undefined or difObject == undefined) then
	(
		append resultArr 0.0
		append resultArr 0.0
		append resultArr 0.0
		return resultArr
	)
	
	refX =  refObject.pos.x
	refY =  refObject.pos.y
	refZ =  refObject.pos.z
	
	difX = difObject.pos.x
	difY = difObject.pos.y
	difZ = difObject.pos.Z
	
	offsetX = difX - refX
	offsetY = difY - refY
	offsetZ = difZ - refZ
	
	-- Swap around offset for non collada files
	if(isCollada == false) then
	(
		offsetX = (offsetX * -1)
		offsetY = (offsetY * -1)
	)
	
	resultX = RTWTools_RoundFloat offsetX 3
	resultY = RTWTools_RoundFloat offsetY 3
	resultZ = RTWTools_RoundFloat offsetZ 3
	append resultArr resultX
	append resultArr resultY
	append resultArr resultZ
	return resultArr
)

-- Get the root NODE (not bone!), either Armature or Scene Root depending on imported file
function RTWTools_GetRootNode =
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
function RTWTools_GetBones =
(
	local armature = RTWTools_GetRootNode()
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

-- Checks whether the scene is Collada format or OG
function RTWTools_SceneIsCollada =
(
	local armature = RTWTools_GetRootNode()
	if(armature != undefined) then
	(
		if(armature.name == "Scene Root" or armature.name == "Scene_Root") then
		(
			return false
		)
	)
	return true
)

utility RTWTools "RTW Tools"
(
	group "Info:"
	(
		label titleLabel1 "RTW Tools"
		label titleLabel2 "v1.1" color:(color 0 180 80)
		label empt " "
		label titleLabel3 "Various helpfull" color:(color 0 180 50)
		label extraLabel2 "tools for RTW" color:(color 0 180 50)
		HyperLink author "by Sirrianus Dagovax" align:#center address:"mailto:dagovax@gmail.com" color:(color 0 0 170) hoverColor:(color 170 0 0)
	)
	
	group "Mounts:"
	(
		label riderPosLabel1 "Get the rider offset for" 
		label riderPosLabel2 "elephants. General Pos" 
		label riderPosLabel3 "will add additional -1 "
		label riderPosLabel4 "to the Z value." 
		radiobuttons riderPosition labels:#("Default Pos", "General Pos")
		button getRiderOffset "Get Rider Offset" width:130 height:30
		groupBox line1 width: 130 height:2
		button getRadius "Calculate Radius" width:130 height:30
		groupBox line2 width: 130 height:2
		button getHeight "Get Height" width:130 height:30
	)
	
	on getRiderOffset pressed do
	(
		canContinue = true
		isCollada = false
		isGeneral = false
		if riderPosition.state == 2 then
		(
			isGeneral = true
		)
		
		pointers = for t in objects where (classOf t == Point) collect t
		dummies = for t in objects where (classOf t == Dummy) collect t
		if (pointers.count == 0 and dummies.count == 0) then
		(
			canContinue = false
			messageBox "There are no bones in this scene!" title:"Error!"
		)
		
		if(pointers.count > 0) then
		(
			isCollada = false
		)
		if(dummies.count > 0) then
		(
			isCollada = true
		)
		
		selected = for t in selection collect t
		if(canContinue and selected.count == 0) then
		(
			canContinue = false
			messageBox "You need to select an object or bone to calculate the rider offset with!" title:"Error!"
		)
		if(canContinue and selected.count > 1) then
		(
			canContinue = false
			messageBox "You can only select one object or bone!" title:"Error!"
		)
		
		-- Now try to get platform bone
		if(canContinue) then
		(
			boneEPlatform = (for t in objects where (classOf t == Point or classOf t == Dummy and t.name == "bone_E_platform") collect t)[1]
			if(boneEPlatform == undefined) then
			(
				canContinue = false
				messageBox "Failed to find a bone_E_platform in your scene!" title:"Error!"
			)
			
			-- bone found, lets roll
			if(canContinue) then
			(
				print selected[1]
				print boneEPlatform
				offSetArr = RTWTools_CalculateOffset boneEPlatform selected[1] isCollada
				_x = offSetArr[1]
				_y = offSetArr[2]
				_z = offSetArr[3]
				if(isGeneral) then
				(
					_z = (_z - 1)
				)
				print ("rider_offset x,z,y = " + _x as string + " | " + _z as string + " | " + _y as string)
				output = newScript()
				format "rider_offset\t\t\t%, %, %\n" _x _z _y to:output				
			)
		)
	)
	
	-- Calculate x_radius and radius of a mount using Ellipse
	on getRadius pressed do
	(
		canContinue = true
		
		ellipses = for el in objects where (classOf el == Ellipse) collect el
		if(ellipses.count == 0) then
		(
			canContinue = false
			messageBox "There is no Ellipse in this scene to calculate the radius with!" title:"Error!"
		)
		
		if(canContinue) then
		(
			theEllipse = ellipses[1]
			
			if(theEllipse == undefined) then
			(
				canContinue = false
				messageBox "Somehow the Ellipse found in the scene was undefined! Try creating another one!" title:"Error!"
			)
			
			if(canContinue and (theEllipse.width > theEllipse.length)) then
			(
				canContinue = false
				messageBox "The Ellipse length should always be bigger than the width to prevent mount bugs!" title:"Error!"
			)
			
			if(canContinue) then
			(
				outRadius = RTWTools_RoundFloat (theEllipse.length / 2) 2
				outX = RTWTools_RoundFloat (theEllipse.width / 2) 2
				
				print ("radius = " + (outRadius as string))
				print ("x_radius = " + (outX as string))
				output = newScript()
				format "radius\t\t\t\t%\nx_radius\t\t\t%\n" outRadius outX to:output
			)
		)
	)
	
	-- Get the heighest vertex from the ground and return it
	on getHeight pressed do
	(
		canContinue = true
		
		allObjects = for t in objects where ((classOf t == Editable_Mesh or classOf t == Editable_Poly) and t.isHidden == false) collect t
		if(allObjects.count == 0) then
		(
			canContinue = false
			messageBox "There are no (visible) Editable Meshes and Editable Polys in the scene!" title:"Error!"
		)
		
		if(canContinue) then
		(
			highestPoint = 0.0
			for obj in allObjects do
			(
				numVerts = getNumVerts obj
				for i=1 to numVerts do
				(
					vert = getVert obj i --get the vertex
					if(vert.z > highestPoint) then
					(
						highestPoint = vert.z
					)
				)
			)
			result = RTWTools_RoundFloat (highestPoint as float) 2
			print ("The heighest vertex Z position = " + (result as string))
			output = newScript()
			format "height\t\t\t\t%\n" result to:output
		)
	)
	
	global engineAnimationRange = #()
	global engineAnimationFrames = #()
	group "Engines:"
	(
		label engineSizeLabel1 "Calculate engine" 
		label engineSizeLabel2 "props using a Box" 
		button calculateEngineSize "Calc. Engine Props" width:130 height:30
		groupBox enginesLine1 width: 130 height:2
		radiobuttons obstacleType labels:#("Rectangle", "Ellipse", "Drop")
		button calculateObstacle "Calc. Obstacle Radius" width:130 height:30
		groupBox enginesLine2 width: 130 height:2
		label projPosLabel1 "Get the relative" 
		label projPosLabel2 "projectile offset" 
		button getProjOffset "Get Projectile Offset" width:130 height:30
		groupBox enginesLine3 width: 130 height:2
		label engineAnimCopy1 "Copy and Paste animation"
		label engineAnimCopy2 "to another engine"
		button engineCopyAnim "Copy Animation" width:130 height:30
		button enginePasteAnim "Paste Animation" width:130 height:30
	)
	
	-- Copy engine animation
	on engineCopyAnim pressed do
	(
		-- collect all bones but Armature
		local boneList = RTWTools_GetBones()
		if(boneList == undefined or boneList.count == 0) then
		(
			messageBox "There are no bones in this scene (only Root Bone?)!" title:"Error!"
			return null
		)
		if(frameRate != 20) then
		(
			messageBox "Please change the frame rate to 20 to prevent issues!" title:"Warning!"
			return null
		)
		engineAnimationRange = #()
		local numFrames = 1 + (animationRange.end - animationRange.start)
		append engineAnimationRange numFrames
		append engineAnimationRange boneList.count
		
		engineAnimationFrames = #()
		for k=1 to numFrames do in coordsys parent
		(
			local frameArray = #()
			for b=1 to boneList.count do
			(
				local posArray = #()
				local boneRot = at time k boneList[b].rotation
				local bonePos = at time k boneList[b].position
				append posArray boneRot
				append posArray bonePos
				append frameArray posArray
			)
			append engineAnimationFrames frameArray
		)
	)
	
	-- Paste engine animation
	on enginePasteAnim pressed do
	(
		local boneList = RTWTools_GetBones()
		if(boneList == undefined or boneList.count == 0) then
		(
			messageBox "There are no bones in this scene (only Root Bone?)!" title:"Error!"
			return null
		)
		if(engineAnimationRange == undefined or engineAnimationRange.count != 2) then
		(
			messageBox "You need to Copy an(other) engine animation first!" title:"Error!"
			return null
		)
		local numFrames = engineAnimationRange[1]
		local numBones = engineAnimationRange[2]
		if(numBones != boneList.count) then
		(
			local boneDifferMessage = ("Number of bones in copied animation {" + (numBones as string) + "} differs from number of bones in this scene {" + (boneList.count as string) + "}!\n\nContinue anyway?")
			if ((queryBox boneDifferMessage beep:true) == false) then
			(
				messageBox "Animation copy failed!" title:"Error!"
				return null
			)
		)
		if(engineAnimationFrames == undefined or engineAnimationFrames.count == 0) then
		(
			messageBox "No anim data copied! You need to Copy an(other) engine animation first!" title:"Error!"
			return null
		)
		frameRate = 20 -- Set the framerate to 20
		animationRange = interval 1 numFrames
		
		local saveBonePos = #()
		for b=1 to boneList.count do
		(
			local pos = at time 1 boneList[b].position
			append saveBonePos pos
		)
		
		for k=1 to numFrames do animate on coordsys parent
		(
			local frameArray = engineAnimationFrames[k]
			for b=1 to numBones do
			(
				local posArray = frameArray[b]
				at time k boneList[b].rotation = posArray[1]
				at time k boneList[b].position = posArray[2]
			)
		)
		
		if(saveBonePos != undefined and saveBonePos.count == boneList.count) then
		(
			for b=1 to boneList.count do
			(
				at time 1 boneList[b].position = saveBonePos[b]
			)
		)
	)
	
	-- Calculate Engine properties using a Box object
	on calculateEngineSize pressed do
	(
		canContinue = true
		
		boxes = for b in objects where (classOf b == Box) collect b
		if(boxes.count == 0) then
		(
			canContinue = false
			messageBox "There is no Box in this scene to calculate the engine properties with!" title:"Error!"
		)
		
		if(canContinue) then
		(
			theBox = boxes[1]
			
			if(theBox == undefined) then
			(
				canContinue = false
				messageBox "Somehow the Box found in the scene was undefined! Try creating another one!" title:"Error!"
			)
			
			if(canContinue and (theBox.height < 0)) then
			(
				canContinue = false
				messageBox "The Box should have a positive height!" title:"Error!"
			)
			
			if(canContinue) then
			(
				outLength = RTWTools_RoundFloat theBox.length 2
				outWidth = RTWTools_RoundFloat theBox.width 2
				outHeight = RTWTools_RoundFloat theBox.height 2
				outRadius = RTWTools_RoundFloat (theBox.width / 2) 2
				
				print ("engine_radius = " + (outRadius as string))
				print ("engine_length = " + (outLength as string))
				print ("engine_width = " + (outWidth as string))
				print ("engine_height = " + (outHeight as string))
				output = newScript()
				format "engine_radius\t\t%\nengine_length\t\t%\nengine_width\t\t%\nengine_height\t\t%\n" outRadius outLength outWidth outHeight to:output
			)
		)
	)
	
	on calculateObstacle pressed do
	(
		canContinue = true
		outShape = "rectangle"
		outY = 0
		outX = 0
		
		case obstacleType.state of
		(
			1: -- Rectangle
			(
				outShape = "rectangle"
				rectangles = for rec in objects where (classOf rec == Rectangle) collect rec
				if(rectangles.count == 0) then
				(
					canContinue = false
					messageBox "There is no Rectangle in this scene to calculate the obstacle radius with!" title:"Error!"
				)
				if(canContinue) then
				(
					theRectangle = rectangles[1]	
					if(theRectangle == undefined) then
					(
						canContinue = false
						messageBox "Somehow the Rectangle found in the scene was undefined! Try creating another one!" title:"Error!"
					)
					if(canContinue) then
					(
						outY = RTWTools_RoundFloat (theRectangle.length / 2) 2
						outX = RTWTools_RoundFloat (theRectangle.width / 2) 2
					)
				)
			)
			
			2: -- Ellipse
			(
				outShape = "ellipse"
				ellipses = for el in objects where (classOf el == Ellipse) collect el
				if(ellipses.count == 0) then
				(
					canContinue = false
					messageBox "There is no Ellipse in this scene to calculate the obstacle radius with!" title:"Error!"
				)
				if(canContinue) then
				(
					theEllipse = ellipses[1]	
					if(theEllipse == undefined) then
					(
						canContinue = false
						messageBox "Somehow the Ellipse found in the scene was undefined! Try creating another one!" title:"Error!"
					)
					if(canContinue) then
					(
						outY = RTWTools_RoundFloat (theEllipse.length / 2) 2
						outX = RTWTools_RoundFloat (theEllipse.width / 2) 2
					)
				)
			)
			
			3: -- Drop
			(
				outShape = "drop"
				ellipses = for el in objects where (classOf el == Ellipse) collect el
				if(ellipses.count == 0) then
				(
					canContinue = false
					messageBox "There is no Ellipse in this scene to calculate the obstacle radius with!" title:"Error!"
				)
				if(canContinue) then
				(
					theEllipse = ellipses[1]	
					if(theEllipse == undefined) then
					(
						canContinue = false
						messageBox "Somehow the Ellipse found in the scene was undefined! Try creating another one!" title:"Error!"
					)
					if(canContinue) then
					(
						outY = RTWTools_RoundFloat (theEllipse.length / 2) 2
						outX = RTWTools_RoundFloat (theEllipse.width / 2) 2
					)
				)
			)
		)
		
		if (canContinue) then
		(
			print ("obstacle_shape = " + (outShape as string))
			print ("obstacle_x_radius = " + (outX as string))
			print ("obstacle_y_radius = " + (outY as string))
			output = newScript()
			format "obstacle_shape\t\t%\nobstacle_x_radius\t%\nobstacle_y_radius\t%\n" outShape outX outY to:output
		)
	)
	
	-- Get the proejctile relative offset of a certain object
	on getProjOffset pressed do
	(
		canContinue = true
		global isCollada = false
		
		pointers = for t in objects where (classOf t == Point) collect t
		dummies = for t in objects where (classOf t == Dummy) collect t
		global boneArr = #()
		if (pointers.count == 0 and dummies.count == 0) then
		(
			canContinue = false
			messageBox "There are no bones in this scene!" title:"Error!"
		)
		
		if(pointers.count > 0) then
		(
			isCollada = false
			boneArr = pointers
		)
		if(dummies.count > 0) then
		(
			isCollada = true
			boneArr = dummies
		)
		
		selected = for t in selection collect t
		if(canContinue and selected.count == 0) then
		(
			canContinue = false
			messageBox "You need to select an object or bone to calculate offset with!" title:"Error!"
		)
		if(canContinue and selected.count > 1) then
		(
			canContinue = false
			messageBox "You can only select one object or bone!" title:"Error!"
		)
		
		if(canContinue) then
		(
			global selectedObj = selected[1]
			global boneNameArr = for i in boneArr collect i.name
			
			rollout dialog_projOffset "Calculate Projectile Offset"
			(
				label projPosLabelDialog1 "Select the Bone you want to calculate the" 
				label projPosLabelDialog2 "the projectile's offset with" 
				dropdownlist projPosBoneList "" align:#center items:boneNameArr
				button projOffsetContinue "Continue" width:130 height:30
				
				-- Continue button pressed
				on projOffsetContinue pressed do
				(
					local canContinue = true
					selectedBone = (for b in boneArr where (b.name == projPosBoneList.selected) collect b)[1]
					try (destroydialog dialog_projOffset) catch()
					if(selectedBone == undefined) then
					(
						canContinue = false
						messageBox "The selected bone is invalid" title:"Error!"
					)
					if(canContinue) then
					(
						print ("User selected bone: " + selectedBone.name)
						offSetArr = RTWTools_CalculateOffset selectedBone selectedObj isCollada
						_x = RTWTools_FormatSkeletonEntry (offSetArr[1]) 4
						_y = RTWTools_FormatSkeletonEntry (offSetArr[2]) 4
						_z = RTWTools_FormatSkeletonEntry (offSetArr[3]) 4
						print ("projectile offset x,z,y = " + _x as string + " | " + _z as string + " | " + _y as string)
						output = newScript()
						format "%  %  %\n" _x _z _y to:output	
					)
				)
			)
			createDialog dialog_projOffset 210 100
		)
	)
	
	group "Misc:"
	(
		label groupLodsLabel1 "Group meshes that" 
		label groupLodsLabel2 "intersect ordered by"
		label groupLodsLabel3 "vertex count" 
		button groupLods "Group LOD's" width:130 height:30
		label skelPosLabel1 "Get the relative" 
		label skelPosLabel2 "projectile offset" 
		button getSkelProjOffset "Skeleton Projectile Offset" width:130 height:30
	)
	
	-- Get the proejctile relative offset used in a skeleton (IWTE format)
	on getSkelProjOffset pressed do
	(
		canContinue = true
		global isCollada = false
		
		pointers = for t in objects where (classOf t == Point) collect t
		dummies = for t in objects where (classOf t == Dummy) collect t
		global boneArr = #()
		if (pointers.count == 0 and dummies.count == 0) then
		(
			canContinue = false
			messageBox "There are no bones in this scene!" title:"Error!"
		)
		
		if(pointers.count > 0) then
		(
			isCollada = false
			boneArr = pointers
		)
		if(dummies.count > 0) then
		(
			isCollada = true
			boneArr = dummies
		)
		
		selected = for t in selection collect t
		if(canContinue and selected.count == 0) then
		(
			canContinue = false
			messageBox "You need to select an object or bone to calculate offset with!" title:"Error!"
		)
		if(canContinue and selected.count > 1) then
		(
			canContinue = false
			messageBox "You can only select one object or bone!" title:"Error!"
		)
		
		if(canContinue) then
		(
			global selectedObj = selected[1]
			global boneNameArr = for i in boneArr collect i.name
			
			rollout dialog_projSkelOffset "Calculate Skeleton Projectile Offset"
			(
				label projskelPosLabelDialog1 "Select the Bone you want to calculate the" 
				label projskelPosLabelDialog2 "the skeleton projectile's offset with" 
				dropdownlist projSkelPosBoneList "" align:#center items:boneNameArr
				button projSkelOffsetContinue "Continue" width:130 height:30
				
				-- Continue button pressed
				on projSkelOffsetContinue pressed do
				(
					local canContinue = true
					local selectedBone = (for b in boneArr where (b.name == projSkelPosBoneList.selected) collect b)[1]
					try (destroydialog dialog_projSkelOffset) catch()
					if(selectedBone == undefined) then
					(
						canContinue = false
						messageBox "The selected bone is invalid" title:"Error!"
					)
					if(canContinue) then
					(
						print ("User selected bone: " + selectedBone.name)
						local offSetArr = RTWTools_CalculateOffset selectedBone selectedObj isCollada
						_x = RTWTools_FormatSkeletonEntry (offSetArr[1]) 4
						_y = RTWTools_FormatSkeletonEntry (offSetArr[2]) 4
						_z = selectedObj.pos.z + (selectedObj.pos.z / 2)
						_z = RTWTools_FormatSkeletonEntry _z 4
						print ("projectile offset x,z,y = " + _x as string + " | " + _z as string + " | " + _y as string)
						output = newScript()
						format "%  %  %\n" _x _z _y to:output	
					)
				)
			)
			createDialog dialog_projSkelOffset 210 100
		)
	)
	
	-- Check all objects and check if they intersect with each other, defining multiple LODs
	on groupLods pressed do
	(
		canContinue = true
		
		allObjects = for t in objects where ((classOf t == Editable_Mesh or classOf t == Editable_Poly) and t.isHidden == false) collect t
		if(allObjects.count == 0) then
		(
			canContinue = false
			messageBox "There are no (visible) Editable Meshes and Editable Polys in the scene!" title:"Error!"
		)
		
		if(canContinue) then
		(
			--selected = for t in selection collect t
			--if(canContinue and (selected.count == 0 or selected.count > 1)) then
			--(
			--	canContinue = false
			--	messageBox "You need to select one mesh to check for other lods!" title:"Error!"
			--)
			
			if(canContinue) then
			(
				lod0Arr = #()
				lod1Arr = #()
				lod2Arr = #()
				lod3Arr = #()
				for i = 1 to allObjects.count do
				(
					firstMesh = allObjects[i]
					meshPoints = #()
					
					oPos = firstMesh.center
					
					resultX = RTWTools_RoundFloat oPos.x 1
					resultY = RTWTools_RoundFloat oPos.y 1
					resultZ = RTWTools_RoundFloat oPos.z 1
					append meshPoints resultX
					append meshPoints resultY
					append meshPoints resultZ
					
					--print((resultX as string) +", "+ (resultY as string) +", " + (resultZ as string))
					
					localLodArr = #()
					for i=1 to allObjects.count do
					(
						objCenter = allObjects[i].center
						meshLocalPoints = #()
						
						meshX = RTWTools_RoundFloat objCenter.x 1
						meshY = RTWTools_RoundFloat objCenter.y 1
						meshZ = RTWTools_RoundFloat objCenter.z 1
						append meshLocalPoints meshX
						append meshLocalPoints meshY
						append meshLocalPoints meshZ
						--print (meshLocalPoints as string)
						
						--print (allObjects[i].name + ":" + objCenter as string)
						if((meshLocalPoints as string) == (meshPoints as string)) then
						(
							append localLodArr allObjects[i]
						)
					)
					--print localLodArr
					--g = group localLodArr name:"SAMELOC"
					
					-- Sort by vertex count
					sortedArr = RTWTools_SortByVertex localLodArr
					for i = 1 to sortedArr.count do
					(
						-- Add LOD0
						if i == 1 then
						(
							append lod0Arr sortedArr[i]
						)
						
						-- Add LOD1
						if i == 2 then
						(
							append lod1Arr sortedArr[i]
						)
						
						-- Add LOD2
						if i == 3 then
						(
							append lod2Arr sortedArr[i]
						)
						
						-- Add LOD3
						if i == 4 then
						(
							append lod3Arr sortedArr[i]
						)
					)
				)
				group lod0Arr name:"LOD0"
				group lod1Arr name:"LOD1"
				group lod2Arr name:"LOD2"
				group lod3Arr name:"LOD3"
			)
		)
	)
)