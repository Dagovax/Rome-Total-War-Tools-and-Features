-------------------------------------------
--										 --
--  Rome: Total War Settlement Tools  --
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
-- 		  Revision history:			 --
--										 --
-- v1.1 -- current  					 --
-- * Added import wall layout system

global RTWSettlementTools_colorBlindMode = false

function RTWSettlementTools_RoundFloat val dp = --rounds a float to a set number of decimal places
(
	a = val * (10^dp)
	b = a as integer
	a = b as float / (10^dp)
	return a
)

function RTWSettlementTools_RotatePivot obj x y z absolute:true =
(
	-- Store the object's position for later
	local p = obj.pos
	
	if (absolute) then
	(
		-- store the object's rotation as an offset from the
		-- identity matrix (aka zero world transform)
		local offsetRot = inverse (obj.rotation * inverse (matrix3 1))
		
		-- use the stored offset to zero the pivot rotation
		-- in world coords. after this step, the supplied x y z 
		-- will be an absolute offset from world coords:)
		obj.rotation *= offsetRot
		obj.objectoffsetrot *= offsetRot
	)
	
	-- get the supplied x y z degrees as a quaternion offset.
	-- the inversion changes the rotation from a right-handed 
	-- coordinate system to the expected left-handed system.
	-- Rotation in Maxscript sure is tricky!
	local rot = inverse ((eulerangles x y z) as quat)
	
	-- finally, apply the final offset to the object's pivot.
	-- Basically, we're transforming the whole object, and then
	-- using .objectoffsetrot to backtransform just the object's 
	-- geometry.  Pretty neat, huh?
	obj.rotation *= rot
	obj.objectoffsetrot *= rot
	
	-- set the object to it's original position
	obj.pos = p
	
	return ok
)

-- Add rotation method
function RTWSettlementTools_AddRotation rot degreesToAdd =
(
	local result = rot + degreesToAdd
    -- Ensure the result is within the range of 0 to 360 degrees
    result = mod result 360
    if result < 0 do result += 360
    return result
)

-- Trim string left and right
function RTWSettlementTools_TrimString value =
(
	if(value == undefined) then
	(
		return ""
	)
	local result = trimLeft value
	result = trimRight result
	return result
)

-- Create a wall object by name
function RTWSettlementTools_CreatePlaneByName wallName =
(
	if(wallName == undefined or wallName == "") then
	(
		return null
	)
	local newPlane = null
	
	if(wallName == "gateway") then
	(
		-- Middle plane
		newPlane = Plane length:8 width:20 name:wallName
		convertTo newPlane Editable_Poly
		polyop.extrudeFaces newPlane #all 12
		
		-- Towers
		local tower1 = Plane length:12 width:12 name:"tempTower1"
		tower1.position.x = -16
		convertTo tower1 Editable_Poly
		polyop.extrudeFaces tower1 #all 16
		local tower2 = Plane length:12 width:12 name:"tempTower2"
		tower2.position.x = 16
		convertTo tower2 Editable_Poly
		polyop.extrudeFaces tower2 #all 16
		
		-- Side platforms
		local side1 = Plane length:4 width:16 name:"tempSide1"
		side1.position.x = -30
		convertTo side1 Editable_Poly
		polyop.extrudeFaces side1 #all 8
		local side2 = Plane length:4 width:16 name:"tempSide2"
		side2.position.x = 30
		convertTo side2 Editable_Poly
		polyop.extrudeFaces side2 #all 8
		
		polyop.attach newPlane tower1
		polyop.attach newPlane tower2
		polyop.attach newPlane side1
		polyop.attach newPlane side2
		if(RTWSettlementTools_colorBlindMode == true) then
		(
			newPlane.wirecolor = color 135 110 8
		) 
		else
		(
			newPlane.wirecolor = color 6 135 6
		)
	)
	else if(wallName == "straight") then
	(
		newPlane = Plane length:4 width:52 name:wallName
		newPlane.wirecolor = color 86 86 86
		convertTo newPlane Editable_Poly
		polyop.extrudeFaces newPlane #all 8
		update newPlane
	)
	else if(wallName == "tower_straight") then
	(
		newPlane = Plane length:4 width:52 name:wallName
		newPlane.wirecolor = color 135 6 6
		convertTo newPlane Editable_Poly
		polyop.extrudeFaces newPlane #all 8
		local towerPlane = Plane length:12 width:12 name:"tempTowerPlane"
		convertTo towerPlane Editable_Poly
		polyop.extrudeFaces towerPlane #all 16
		polyop.attach newPlane towerPlane
	)
	else if(wallName == "tower_external_corner_link") then
	(
		newPlane = Plane length:12 width:12 name:wallName
		newPlane.wirecolor = color 135 6 6
		convertTo newPlane Editable_Poly
		polyop.extrudeFaces newPlane #all 16
		
		local supportPlane = Plane length:4 width:4
		convertTo supportPlane Editable_Poly
		polyop.extrudeFaces supportPlane #all 6
		supportPlane.position.x = -5
		supportPlane.position.y = -5
		polyop.attach newPlane supportPlane
	)
	else if(wallName == "tower_internal_corner_link") then
	(
		newPlane = Plane length:12 width:12 name:wallName
		newPlane.wirecolor = color 135 6 6
		convertTo newPlane Editable_Poly
		polyop.extrudeFaces newPlane #all 16
		
		local supportPlane = Plane length:4 width:4
		convertTo supportPlane Editable_Poly
		polyop.extrudeFaces supportPlane #all 6
		supportPlane.position.x = 5
		supportPlane.position.y = 5
		polyop.attach newPlane supportPlane
	)
	else if(wallName == "straight_link") then
	(
		newPlane = Plane length:4 width:12 name:wallName
		newPlane.wirecolor = color 28 28 28
		convertTo newPlane Editable_Poly
		polyop.extrudeFaces newPlane #all 8
		
		local supportPlane = Plane length:6 width:4 name:"tempSupportPlane"
		supportPlane.wirecolor = color 28 28 28
		convertTo supportPlane Editable_Poly
		polyop.extrudeFaces supportPlane #all 6
		
		polyop.attach newPlane supportPlane
	)
	else if (wallName == "internal_corner_link") then
	(
		newPlane = Plane length:4 width:8 name:wallName
		newPlane.wirecolor = color 28 28 28
		convertTo newPlane Editable_Poly
		polyop.extrudeFaces newPlane #all 8
		newPlane.position.x = 2
		
		local platPlane = Plane length:8 width:4 name:"tempSupportPlane"
		platPlane.wirecolor = color 28 28 28
		convertTo platPlane Editable_Poly
		polyop.extrudeFaces platPlane #all 8
		platPlane.position.y = 2
		
		local supportPlane = Plane length:4 width:4
		convertTo supportPlane Editable_Poly
		polyop.extrudeFaces supportPlane #all 6
		supportPlane.position.x = -1
		supportPlane.position.y = -1
		
		polyop.attach newPlane platPlane
		polyop.attach newPlane supportPlane
		newPlane.pivot = [0, 0 ,0]
	)
	else if (wallName == "external_corner_link") then
	(
		newPlane = Plane length:4 width:8 name:wallName
		newPlane.wirecolor = color 28 28 28
		convertTo newPlane Editable_Poly
		polyop.extrudeFaces newPlane #all 8
		newPlane.position.x = -2
		
		local platPlane = Plane length:8 width:4 name:"tempSupportPlane"
		platPlane.wirecolor = color 28 28 28
		convertTo platPlane Editable_Poly
		polyop.extrudeFaces platPlane #all 8
		platPlane.position.y = -2
		
		local supportPlane = Plane length:4 width:4
		convertTo supportPlane Editable_Poly
		polyop.extrudeFaces supportPlane #all 6
		supportPlane.position.x = -2
		supportPlane.position.y = -2
		
		polyop.attach newPlane platPlane
		polyop.attach newPlane supportPlane
		newPlane.pivot = [0, 0 ,0]
	)
	else if(wallName == "diagonal_link") then
	(
		newPlane = Plane length:4 width:38.5 name:wallName
		newPlane.wirecolor = color 28 28 28
		convertTo newPlane Editable_Poly
		polyop.extrudeFaces newPlane #all 8
		
		local supportPlane = Plane length:6 width:4 name:"tempSupportPlane"
		supportPlane.wirecolor = color 28 28 28
		convertTo supportPlane Editable_Poly
		polyop.extrudeFaces supportPlane #all 6
		
		polyop.attach newPlane supportPlane
	)
	else if(wallName == "external_left_link") then
	(
		newPlane = SplineShape()
		addNewSpline newPlane
		local knotPositions = #(
			[-6, 2, 0],
			[-6, -2, 0],
			[-1, -2, 0],
			[12.201, -15.029, 0],
			[15.029, -12.201, 0],
			[1, 2, 0]
		)
		
		-- Loop through the knot positions and add them to the SplineShape
		for pos in knotPositions do
		(
			addKnot newPlane 1 #corner #line pos
		)
		-- Close the spline if needed
		close newPlane 1

		updateShape newPlane
		convertTo newPlane Editable_Poly	
		newPlane.pivot = [0, 0 ,0]
		newPlane.wirecolor = color 28 28 28	
		polyop.extrudeFaces newPlane #all 8

		local splineSupport = SplineShape()
		addNewSpline splineSupport
		local knotPositionsSupport = #(
			[-2, 2.5, 0],
			[-2, 0, 0],
			[2.5, -1, 0],
			[4, 0, 0],
			[1.5, 2.5, 0]
		)
		-- Loop through the knot positions and add them to the SplineShape
		for pos in knotPositionsSupport do
		(
			addKnot splineSupport 1 #corner #line pos
		)
		-- Close the spline if needed
		close splineSupport 1
		updateShape splineSupport
		convertTo splineSupport Editable_Poly	
		polyop.extrudeFaces splineSupport #all 6
		
		polyop.attach newPlane splineSupport
		newPlane.pivot = [0, 0 ,0]
		newPlane.name = wallName
	)
	else if(wallName == "internal_left_link") then
	(
		newPlane = SplineShape()
		addNewSpline newPlane
		local knotPositions = #(
			[-6, 2, 0],
			[-6, -2, 0],
			[1, -2, 0],
			[15.029, 12.201, 0],
			[12.201, 15.029, 0],
			[-1, 2, 0]
		)
		
		-- Loop through the knot positions and add them to the SplineShape
		for pos in knotPositions do
		(
			addKnot newPlane 1 #corner #line pos
		)
		-- Close the spline if needed
		close newPlane 1

		updateShape newPlane
		convertTo newPlane Editable_Poly
		newPlane.pivot = [0, 0 ,0]
		newPlane.wirecolor = color 28 28 28	
		polyop.extrudeFaces newPlane #all 8	
		
		local splineSupport = SplineShape()
		addNewSpline splineSupport
		local knotPositionsSupport = #(
			[-3, 1, 0],
			[-3, 2.5, 0],
			[-1.5, 2.5, 0],
			[1, 5, 0],
			[2.0, 4.0, 0],
			[-1.0, 1.0, 0]
		)
		-- Loop through the knot positions and add them to the SplineShape
		for pos in knotPositionsSupport do
		(
			addKnot splineSupport 1 #corner #line pos
		)
		-- Close the spline if needed
		close splineSupport 1
		updateShape splineSupport
		convertTo splineSupport Editable_Poly	
		polyop.extrudeFaces splineSupport #all 6
		
		polyop.attach newPlane splineSupport
		newPlane.pivot = [0, 0 ,0]
		newPlane.name = wallName
	)
	else if(wallName == "external_right_link") then
	(
		newPlane = SplineShape()
		addNewSpline newPlane
		local knotPositions = #(
			[-15.029, -12.201, 0],
			[-12.201, -15.029, 0],
			[1, -2, 0],
			[6, -2, 0],
			[6, 2, 0],
			[-1, 2, 0]
		)
		
		-- Loop through the knot positions and add them to the SplineShape
		for pos in knotPositions do
		(
			addKnot newPlane 1 #corner #line pos
		)
		-- Close the spline if needed
		close newPlane 1

		updateShape newPlane
		convertTo newPlane Editable_Poly	
		newPlane.pivot = [0, 0 ,0]
		newPlane.wirecolor = color 28 28 28		
		polyop.extrudeFaces newPlane #all 8
		
		local splineSupport = SplineShape()
		addNewSpline splineSupport
		local knotPositionsSupport = #(
			[2, 2.5, 0],
			[2, 0, 0],
			[-2.5, -1, 0],
			[-4, 0, 0],
			[-1.5, 2.5, 0]
		)
		-- Loop through the knot positions and add them to the SplineShape
		for pos in knotPositionsSupport do
		(
			addKnot splineSupport 1 #corner #line pos
		)
		-- Close the spline if needed
		close splineSupport 1
		updateShape splineSupport
		convertTo splineSupport Editable_Poly	
		polyop.extrudeFaces splineSupport #all 6
		
		polyop.attach newPlane splineSupport
		newPlane.pivot = [0, 0 ,0]
		newPlane.name = wallName
	)
	else if(wallName == "internal_right_link") then
	(
		newPlane = SplineShape()
		addNewSpline newPlane
		local knotPositions = #(
			[-15.029, 12.201, 0],
			[-1, -2, 0],
			[6, -2, 0],
			[6, 2, 0],
			[1, 2, 0],
			[-12.201, 15.029, 0]
		)
		
		-- Loop through the knot positions and add them to the SplineShape
		for pos in knotPositions do
		(
			addKnot newPlane 1 #corner #line pos
		)
		-- Close the spline if needed
		close newPlane 1

		updateShape newPlane
		convertTo newPlane Editable_Poly
		newPlane.pivot = [0, 0 ,0]
		newPlane.wirecolor = color 28 28 28
		polyop.extrudeFaces newPlane #all 8
		
		local splineSupport = SplineShape()
		addNewSpline splineSupport
		local knotPositionsSupport = #(
			[3, 1, 0],
			[3, 2.5, 0],
			[1.5, 2.5, 0],
			[-1, 5, 0],
			[-2.0, 4.0, 0],
			[1.0, 1.0, 0]
		)
		-- Loop through the knot positions and add them to the SplineShape
		for pos in knotPositionsSupport do
		(
			addKnot splineSupport 1 #corner #line pos
		)
		-- Close the spline if needed
		close splineSupport 1
		updateShape splineSupport
		convertTo splineSupport Editable_Poly	
		polyop.extrudeFaces splineSupport #all 6
		
		polyop.attach newPlane splineSupport
		newPlane.pivot = [0, 0 ,0]
		newPlane.name = wallName
	)
	
	if(newPlane != undefined) then
	(
		convertTo newPlane Editable_Mesh
	)
	return newPlane
)

function RTWSettlementTools_CreateWallSectionPlane inputString iwte =
(
	if(inputString == undefined or inputString == "") then
	(
		return null
	)
	
	-- Remove comments by splitting the string based on the ";" symbol
	local sectionsWithoutComments = filterString inputString ";"
	
	-- Take the first section as the actual data (without comments)
	if sectionsWithoutComments.count > 0 do
	(
		local dataString = trimRight sectionsWithoutComments[1]
		
		-- Split the string into sections
		local sections = filterString dataString ","
		if sections.count == 5 do
		(
			local pName = sections[1]
			local xPosition = sections[2] as float 
			local yPosition = sections[3] as float
			local rot = sections[4] as float 
			local zPosition = sections[5] as float 
			
			if(iwte == true) then
			(
				rot = (RTWSettlementTools_AddRotation rot 180)
			) else
			(
				xPosition *= -1
				yPosition *= -1
			)
			
			local newPlane = RTWSettlementTools_CreatePlaneByName pName
			if(newPlane != undefined) then
			(
				newPlane.rotation.z_rotation = rot
				newPlane.position.x = xPosition
				newPlane.position.y = yPosition
				newPlane.position.z = zPosition
				--print inputString
				--format "Name: %, x: %, y: %, rotation: %, z: %\n" pName xPosition yPosition rot zPosition
			)
			return newPlane
		)
	)
	return null
)

utility RTWSettlementTools "RTW Settlement Tools"
(
	group "Info:"
	(
		label titleLabel1 "RTW Settlement Tools"
		label titleLabel2 "v1.1" color:(color 0 20 80)
		HyperLink author "by Sirrianus Dagovax" align:#center address:"mailto:dagovax@gmail.com" color:(color 0 0 170) hoverColor:(color 170 0 0)
	)
	
	group "Settlement Plan"
	(
		checkbox iwteExported "IWTE" width:130 height:15 checked:true tooltip:"If your scene contains overlay + underlay converted with IWTE, there is no need to 'flip' the X, Y positions. If you used old Max script for import, turn this off."
		groupBox clingLine1 width: 130 height:2
		button exportSelectedBuildings "Export Scene Plan" width:130 height:30 tooltip:"Exports (selected) meshes/groups and their relative position to be used inside the plan. Best to import items and set Pivot to 0,0,0 before moving buildings around."
		groupBox splitLine1 width: 130 height:2
		checkbox colorBlindMode "Colorblind mode" width:130 height:15 checked:false tooltip:"By default gates will be shown as green and towers as red. Checking this will make gates yellow instead."
		button importWallLayout "Import Wall Layout" width:130 height:30 tooltip:"Select a settlement plan .txt file and if it has borders defined, the border will be drawn using wall sections (planes)."
	)
	
	-- Export (selection) to a plan
	on exportSelectedBuildings pressed do
	(
		local useSelection = true
		local usedIWTE = iwteExported.checked
		local selectionArr = for t in selection collect t
		if(selectionArr == undefined or selectionArr.count == 0) then
		(
			selectionArr = for t in objects collect t
			useSelection = false
		)
		
		-- Filter out anything that is not top level, and only groups and meshes
		local outputArr = for b in selectionArr where ((classOf b == Editable_Mesh or classOf b == Editable_Poly or classOf b == plane or isGroupHead b)) collect b
		if(outputArr == undefined or outputArr.count == 0) then
		(
			return null
		)
		if(not useSelection) then -- If nothing was selected, filter out anything with a parent
		(
			outputArr = for b in outputArr where (b.parent == undefined) collect b
		)
		-- Filter out anything that has a parent in the outputArr
		outputArr = for b in outputArr where ((findItem outputArr b.parent == 0) and (not b.isFrozen)) collect b
		
		output = newScript()
		for b in outputArr do
		(
			local posX = 0.0
			local posY = 0.0
			local posZ = RTWSettlementTools_RoundFloat (b.pos.z) 2
			local rot = 0.0
			if(usedIWTE) then
			(
				posX = RTWSettlementTools_RoundFloat (b.pos.x) 2
				posY = RTWSettlementTools_RoundFloat (b.pos.y) 2
				rot = RTWSettlementTools_RoundFloat (RTWSettlementTools_AddRotation b.rotation.z_rotation 180) 2
			) else
			(
				posX = RTWSettlementTools_RoundFloat (b.pos.x *-1) 2
				posY = RTWSettlementTools_RoundFloat (b.pos.y *-1) 2
				rot = RTWSettlementTools_RoundFloat b.rotation.z_rotation 2
			)
			format "%,\t\t\t%,\t\t\t%,\t\t\t%,\t\t\t%\n" \
			b.name posX posY rot posZ to:output
		)
	)
	
	-- Import wall layout
	on importWallLayout pressed do
	(
		local usedIWTE = iwteExported.checked
		RTWSettlementTools_colorBlindMode = colorBlindMode.checked
		local importFileName = getOpenFileName types:"Settlement Plan (*.txt)|*.txt|"
		if (importFileName == undefined) then
		(
			return null
		)
		local planFile = openFile importFileName
		
		-- Catch all exceptions and close the files
		try
		(
			local bordersRead = false
			while not eof planFile and (bordersRead == false) do
			(
				local newLine = readline planFile
				local trimmedString = RTWSettlementTools_TrimString newLine
				if((findString trimmedString "borders") != undefined) then 
				(
					local skipFirstLine = false
					local wallsRead = false
					-- We have border section now
					if((findString trimmedString "{") == undefined) then 
					(
						-- We starting { at the same line. Don't skip next line
						skipFirstLine = true
					)
					if(skipFirstLine) then
					(
						local starter = readline planFile -- read empty line
						local trimmedStarter = RTWSettlementTools_TrimString starter
						if((findString trimmedStarter "{") == undefined) then 
						(
							-- We don't have any walls here
							local message = "Settlement Plan "+ (filenameFromPath importFileName as string) +" does not have any walls!\n\n Probably border/limit .cas file?"
							print message
							messageBox message title:"No Walls!"
							exit
						)
					)
					local objArray = #()
					while not eof planFile and (wallsRead == false) do
					(
						local sectionLine = readline planFile
						local trimmedSection = RTWSettlementTools_TrimString sectionLine
						if((findString trimmedSection "}") != undefined) then 
						(
							wallsRead = true
							exit
						)
						if(trimmedSection != "" and trimmedSection[1] != ";") then
						(
							-- We now have a wall section entry
							local wallPlane = RTWSettlementTools_CreateWallSectionPlane trimmedSection usedIWTE
							if(wallPlane != undefined) then
							(
								append objArray wallPlane
							)
						)
					)
					bordersRead = true
					
					if(objArray.count > 0) then
					(
						local groupWall = group objArray
						groupWall.name = "borders_wall_layout"
						groupWall.pivot = [0,0,0]
					)
				)
			)
			
			-- Close file stream
			close planFile
		)
		catch
		(
			-- Close file stream
			close planFile
			throw()
		)
		
		redrawViews() 	
		print("Wall Layout imported")
	)
	
	group "Street Plan"
	(
		button resetPivots "Reset Pivots" width:130 height:30 tooltip:"Resets all Pivots to 0,0,0 for (selected) objects"
		button resetTrans "Apply Transform" width:130 height:30 tooltip:"Reset the applied Transformation for (selected) objects"
	)
	
	-- Reset Pivot to x:0 y:0 z:0
	on resetPivots pressed do
	(
		local useSelection = true
		local selectionArr = for t in selection collect t
		if(selectionArr == undefined or selectionArr.count == 0) then
		(
			local questionMessage = ("Are you sure you want to reset the Pivot for all (unfrozen) objects?")
			if (queryBox questionMessage beep:true) then
			(
				selectionArr = for t in objects collect t
				useSelection = false
			) else
			(
				return null
			)
		)
		-- Filter out anything that has a parent in the outputArr
		local outputArr = for b in selectionArr where (not b.isFrozen) collect b
		for b in outputArr do
		(
			RTWSettlementTools_RotatePivot b 0 0 0
			b.pivot = [0,0,0]
		)
		redrawViews() 	
		print("Reset Pivots -> Completed")
	)
	
	on resetTrans pressed do
	(
		local useSelection = true
		local selectionArr = for t in selection collect t
		if(selectionArr == undefined or selectionArr.count == 0) then
		(
			local questionMessage = ("Are you sure you want to apply the transformation for all (unfrozen) objects?")
			if (queryBox questionMessage beep:true) then
			(
				selectionArr = for t in objects collect t
				useSelection = false
			) else
			(
				return null
			)
		)
		-- Filter out anything that has a parent in the outputArr
		local outputArr = for b in selectionArr where (not b.isFrozen) collect b
		for b in outputArr do
		(
			ResetXForm b -- Adds the modifier
			local theMods = for m in b.modifiers collect m
			for m in theMods where classOf m == XForm do
			(
				addModifier b m before:theMods.count --instance it to the bottom of the stack
				deleteModifier b m --and remove the original instance from where it was on the stack
			)
			maxOps.CollapseNodeTo b 1 true -- Collapse To the first modifier stack item
		)
		redrawViews() 	
		print("Apply Transformation -> Completed")
	)
	
	group "Strat Residences"
	(
		button scaleDown "Scale Down" width:130 height:30 tooltip:"Scale down (selected) objects to strat map scale (2,5%)"
	)
	
	-- Scale down selected objects to 2,5% for campaign map usage
	on scaleDown pressed do
	(
		local selectionArr = for b in selection where ((classOf b == Editable_Mesh or classOf b == Editable_Poly or classOf b == plane or isGroupHead b)) collect b
		if(selectionArr == undefined or selectionArr.count == 0) then
		(
			messageBox "You need to select some object(s) first!" title:"Error!"
			return null
		)
		-- Filter out anything that has a parent in the outputArr
		selectionArr = for b in selectionArr where ((findItem selectionArr b.parent == 0) and (not b.isFrozen)) collect b
		for b in selectionArr do
		(
			b.scale = [0.025, 0.025, 0.025]
		)
	)
)