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
--										 --
-------------------------------------------

function RoundFloat val dp = --rounds a float to a set number of decimal places
(
	a = val * (10^dp)
	b = a as integer
	a = b as float / (10^dp)
	return a
)

function FormatSkeletonEntry val zeroes = 
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

function CalculateOffset refObject difObject isCollada = 
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
	
	resultX = RoundFloat offsetX 3
	resultY = RoundFloat offsetY 3
	resultZ = RoundFloat offsetZ 3
	append resultArr resultX
	append resultArr resultY
	append resultArr resultZ
	return resultArr
)

utility RTWTools "RTW Tools"
(
	group "Info:"
	(
		label titleLabel1 "RTW Tools"
		label titleLabel2 "v1.0" color:(color 0 180 80)
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
				offSetArr = CalculateOffset boneEPlatform selected[1] isCollada
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
				outRadius = RoundFloat (theEllipse.length / 2) 2
				outX = RoundFloat (theEllipse.width / 2) 2
				
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
			result = RoundFloat (highestPoint as float) 2
			print ("The heighest vertex Z position = " + (result as string))
			output = newScript()
			format "height\t\t\t\t%\n" result to:output
		)
	)
	
	group "Misc:"
	(
		label projPosLabel1 "Get the relative" 
		label projPosLabel2 "projectile offset" 
		button getProjOffset "Get Projectile Offset" width:130 height:30
		groupBox miscLine1 width: 130 height:2
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
						offSetArr = CalculateOffset selectedBone selectedObj isCollada
						_x = FormatSkeletonEntry (offSetArr[1]) 4
						_y = FormatSkeletonEntry (offSetArr[2]) 4
						_z = FormatSkeletonEntry (offSetArr[3]) 4
						print ("projectile offset x,z,y = " + _x as string + " | " + _z as string + " | " + _y as string)
						output = newScript()
						format "%  %  %\n" _x _z _y to:output	
					)
				)
			)
			createDialog dialog_projOffset 210 100
		)
	)
)