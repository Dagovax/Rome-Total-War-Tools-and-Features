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
-- v1.2 -- current
-- * Added SpeedTree setup
-- * Added collision plane creator
-- v1.1
-- * Added import wall layout system

global RTWSettlementTools_colorBlindMode = false
global RTWSettlementTools_rotationIWTE = false

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

-- Get sub materials of an object
function RTWSettlementTools_GetMaterialIDs obj =
(
	local idArr = #()
	
	for i in 1 to 99 do
	(
		obj.selectByMaterial i
		local theFaces = getFaceSelection obj
		if (theFaces as array).count != 0 do
		(
			append idArr i
		)
	)
	return idArr
)

-- Set all vertices' vertex color to white
function RTWSettlementTools_AllVertexColorsWhite obj =
(
	if(obj == undefined) then 
	(
		return null
	)
	convertToPoly obj
	for i=1 to (getNumVerts obj) do
	(
		polyOp.setVertColor obj 0 i [255,255,255]	
	)
	convertToMesh obj
)

-- Detach materials by their IDs. Returns the detached objects
function RTWSettlementTools_DetachMaterials obj =
(
	if(obj == undefined) then 
	(
		return null
	)
	if(obj.material != undefined) then
	(
		try
		(
			convertToPoly obj
		) 
		catch 
		(
			messageBox "Detach by material failed at obj conversion!" title:"Error!"
			exit
		)
		local newObjArr = #()
		
		local original = obj
		local polyObj = copy original
		
		local theMat = original.material
		local idCount = theMat.numSubs
		local idList = RTWSettlementTools_GetMaterialIDs polyObj
		
		-- start detaching
		for i in idList do
		(
			polyObj.selectByMaterial i
			local theFaces = getFaceSelection polyObj
			local matName = theMat[i].name
			
			polyOp.detachFaces polyObj theFaces asnode:true name:matName
			local theDetachedObj = (getNodeByName matName)
			
			if isValidNode theDetachedObj do
			(
				if classof theMat[i] == Material then
				(
					theDetachedObj.material = theMat[i]
				) 
				else
				(
					theDetachedObj.material = theMat
				)
				convertToMesh theDetachedObj
				append newObjArr theDetachedObj
			)
		)
		delete polyObj
		delete original
		return newObjArr
	)
)

-- Creates a collision box
function RTWSettlementTools_CreateBoundingBox obj =
(
	local isMesh = (classof obj == Editable_Mesh)
	if(isMesh) then
	(
		convertToPoly obj
	)
	local vertCount = polyOp.getNumVerts obj
	local xVals = #()
	local yVals = #()
	local zVals = #()
	
	for v=1 to vertCount do
	(
		local vertPos = polyop.getVert obj v
		append xVals vertPos.x
		append yVals vertPos.y
		append zVals vertPos.z
	)
 		
	local theWidth = (amax xVals) - (amin xVals)
	local theLength = (amax yVals) - (amin yVals)
	local theHeight = (amax zVals) - (amin zVals)
	
	local avgPos = [(((amax xVals) + (amin xVals)) / 2.),(((amax yVals) + (amin yVals)) / 2.),(((amax zVals) + (amin zVals)) / 2.)]
	local theBox = box length:theLength width:theWidth height:theHeight xray:true
	theBox.pivot = theBox.center
	theBox.pos = avgPos
	if(isMesh) then
	(
		convertToMesh obj
	)
	return theBox
)

utility RTWSettlementTools "RTW Settlement Tools"
(
	group "Info:"
	(
		label titleLabel1 "RTW Settlement Tools"
		label titleLabel2 "v1.2" color:(color 0 20 80)
		HyperLink author "by Sirrianus Dagovax" align:#center address:"mailto:dagovax@gmail.com" color:(color 0 0 170) hoverColor:(color 170 0 0)
	)
	
	group "Settlement Plan"
	(
		checkbox iwteExported "IWTE" width:60 height:15 checked:true tooltip:"If your scene contains overlay + underlay converted with IWTE, there is no need to 'flip' the X, Y positions. If you used old Max script for import, turn this off." across:2
		checkbox noRotation "No Rotation" width:70 height:15 checked:false tooltip:"If IWTE option is checked, by default rotation will be added + 180 degrees. Turning this off will simply export current scene settings." 
		groupBox clingLine1 width: 130 height:2
		button exportSelectedBuildings "Export Scene Plan" width:130 height:30 tooltip:"Exports (selected) meshes/groups and their relative position to be used inside the plan. Best to import items and set Pivot to 0,0,0 before moving buildings around."
		groupBox splitLine1 width: 130 height:2
		checkbox colorBlindMode "Colorblind mode" width:130 height:15 checked:false tooltip:"By default gates will be shown as green and towers as red. Checking this will make gates yellow instead."
		button importWallLayout "Import Wall Layout" width:130 height:30 tooltip:"Select a settlement plan .txt file and if it has borders defined, the border will be drawn using wall sections (planes)."
	)
	
	on iwteExported changed val do
	(
		if(iwteExported.checked) then
		(
			noRotation.enabled = true
			if(RTWSettlementTools_rotationIWTE) then
			(
				noRotation.checked = true
			)
		) else
		(
			noRotation.enabled = false
			noRotation.checked = false
		)
	)
	
	on noRotation changed val do
	(
		RTWSettlementTools_rotationIWTE = noRotation.checked
	)
	
	-- Export (selection) to a plan
	on exportSelectedBuildings pressed do
	(
		local useSelection = true
		local usedIWTE = iwteExported.checked
		local skipRotation =  noRotation.checked
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
				if(skipRotation) then
				(
					rot = RTWSettlementTools_RoundFloat b.rotation.z_rotation 2
				) else
				(
					rot = RTWSettlementTools_RoundFloat (RTWSettlementTools_AddRotation b.rotation.z_rotation 180) 2	
				)
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
	
	group "Buildings"
	(
		button detachByMaterial "Detach by Materials" width:130 height:30 tooltip:"Checks the selected (imported) object for any sub-materials, and split the faces by their materials into seperate objects."
		button vertexColorWhite "Set Vertex Color White" width:130 height:30 tooltip:"Set the vertex color of the selected object(s) to white."
		groupBox buildingClingLine1 width: 130 height:2
		checkbox useZZeroBounding "Use At Zero Collision" width:130 height:15 checked:false tooltip:"When checked, the script will slice the object along the Z=0 axis, and use only those vertices that are at Z=0. Not recommended when your object is small at Z=0, but wider above the ground!"
		button createCollisionPlane "Create Collision Plane" width:130 height:30 tooltip:"Automatically creates a simple collision plane that covers selected object."
		groupBox buildingClingLine2 width: 130 height:2
		button createCollision3dBox "Create Collision3d Box" width:130 height:30 tooltip:"Automatically creates a bounding box as collision3d around the selected object."
	)
	
	-- Detach by materials
	on detachByMaterial pressed do
	(
		local selectionArr = for b in selection where ((classOf b == Editable_Mesh or classOf b == Editable_Poly or classOf b == plane or isGroupHead b)) collect b
		if(selectionArr == undefined or selectionArr.count == 0 or selectionArr.count > 1) then
		(
			messageBox "You need to select a single mesh first!" title:"Error!"
			return null
		)
		RTWSettlementTools_DetachMaterials selectionArr[1]
	)
	
	-- Set vertex colors to white of selected objects
	on vertexColorWhite pressed do
	(
		local selectionArr = for b in selection where ((classOf b == Editable_Mesh or classOf b == Editable_Poly or classOf b == plane or isGroupHead b)) collect b
		if(selectionArr == undefined or selectionArr.count == 0) then
		(
			messageBox "You need to select at least one mesh!" title:"Error!"
			return null
		)
		
		for b in selectionArr do
		(
			RTWSettlementTools_AllVertexColorsWhite b
		)
	)
	
	-- Automatically creates a simple collision plane that covers selected object
	on createCollisionPlane pressed do
	(
		local useAtZeroCollision = useZZeroBounding.checked
		local selectionArr = for b in selection where ((classOf b == Editable_Mesh or classOf b == Editable_Poly or classOf b == plane or isGroupHead b)) collect b
		if(selectionArr == undefined or selectionArr.count == 0 or selectionArr.count > 1) then
		(
			messageBox "You need to select a mesh first!" title:"Error!"
			return null
		)
		local selectedObj = selectionArr[1]
		local copyObj = copy selectedObj
		local collisionPlane = Plane length:2 width:2 lengthsegs:1 widthsegs:1 name:"collision"
		
		local collisionBox = RTWSettlementTools_CreateBoundingBox selectedObj
		if(collisionBox == undefined) then
		(
			delete copyObj
			return null
		)
		collisionPlane.width = collisionBox.width
		collisionPlane.length = collisionBox.length
		collisionPlane.pos.x = collisionBox.pos.x
		collisionPlane.pos.y = collisionBox.pos.y
		delete collisionBox
		
		if(useAtZeroCollision) then
		(
			local sliceMod = SliceModifier slice_type:4
			addModifier copyObj sliceMod
			sliceMod.slice_plane.pos = [0, 0, 0]
			sliceMod.slice_plane.rotation = eulerAngles -90 0 0
			convertTo copyObj Editable_Mesh
			-- Update the viewport
			update copyObj
			
			local numVertsAtZero = getNumVerts copyObj
			-- Initialize an array to store vertices at Z=0
			local verticesAtZZero = #()
			
			-- Iterate through vertices to find those at Z=0
			for i=1 to numVertsAtZero do
			(
				local vertPos = getVert copyObj i
				if abs(vertPos.z) < 0.001 do
				(
					append verticesAtZZero i
				)
			)
			
			if(verticesAtZZero != undefined and verticesAtZZero.count > 0) then
			(
				-- Initialize variables to store extreme positions
				local minX = 1e9 -- Initializing with a large number
				local minY = 1e9
				local maxX = -1e9 -- Initializing with a small number
				local maxY = -1e9
				
				for i in verticesAtZZero do
				(
					local vertPos = getVert copyObj i
					-- Record extreme positions
					if vertPos.x < minX do minX = vertPos.x
					if vertPos.y < minY do minY = vertPos.y
					if vertPos.x > maxX do maxX = vertPos.x
					if vertPos.y > maxY do maxY = vertPos.y
				)
				-- Calculate the width and height of the plane based on extreme positions
				local width = abs(maxX - minX)
				local height = abs(maxY - minY)
				
				-- Set the plane's width and height
				collisionPlane.length = height
				collisionPlane.width = width
				
				-- Calculate the center position
				local centerX = (maxX + minX) / 2.0
				local centerY = (maxY + minY) / 2.0
				
				collisionPlane.position.x = centerX
				collisionPlane.position.y = centerY
			)
		)
		collisionPlane.pivot = [0,0,0]
		resetXForm collisionPlane
		-- Apply the transformation permanently
		convertToMesh collisionPlane
		collisionPlane.material = selectedObj.material
		
		delete copyObj
		redrawViews() 
	)
	
	-- Create collision3d box
	on createCollision3dBox pressed do
	(
		local selectionArr = for b in selection where ((classOf b == Editable_Mesh or classOf b == Editable_Poly or classOf b == plane or isGroupHead b)) collect b
		if(selectionArr == undefined or selectionArr.count == 0 or selectionArr.count > 1) then
		(
			messageBox "You need to select a mesh first!" title:"Error!"
			return null
		)
		local selectedObj = selectionArr[1]
		local collisionBox = RTWSettlementTools_CreateBoundingBox selectedObj
		if(collisionBox == undefined) then
		(
			return null
		)
		collisionBox.name = "collision3d"
		collisionBox.pivot = [0,0,0]
		resetXForm collisionBox
		-- Apply the transformation permanently
		convertToMesh collisionBox
		collisionBox.material = collisionBox.material
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
	
	group "SpeedTree"
	(
		checkbox rotateSpeedTree "Rotate -90" width:130 height:15 checked:true tooltip:"Rotate the tree -90 degrees along the x-axis (to have it standing up)."
		checkbox detachSpeedTreeMaterials "Detach from Materials" width:130 height:15 checked:true tooltip:"Automatically detach object's elements using materials."
		button setUpSpeedTree "Set Up .SRT Tree" width:130 height:30 tooltip:"scale up, rotate and detach selected imported SpeedTree tree objects to building scale (125%). Note that these .srt files are exported using UnrealEngine!"
	)
	
	-- Scale up imported SpeedTree (selected) tree objects to building scale (125%)
	on setUpSpeedTree pressed do
	(
		local selectionArr = for b in selection where ((classOf b == Editable_Mesh or classOf b == Editable_Poly or classOf b == plane or isGroupHead b)) collect b
		-- Filter out anything that has a parent in the outputArr
		selectionArr = for b in selectionArr where ((findItem selectionArr b.parent == 0) and (not b.isFrozen)) collect b
		if(selectionArr == undefined or selectionArr.count == 0 or selectionArr.count > 1) then
		(
			messageBox "You need to select a SpeedTree first!" title:"Error!"
			return null
		)
		local speedTree = selectionArr[1]
		
		-- Scale
		speedTree.scale = [1.25, 1.25, 1.25]
		
		if(rotateSpeedTree.checked) then
		(
			-- Rotate -90 degrees
			speedTree.rotation = eulerAngles 90 0 0
		)
		
		if(detachSpeedTreeMaterials.checked) then
		(
			local resultArr = RTWSettlementTools_DetachMaterials speedTree
			if(resultArr != undefined and resultArr.count > 0) then
			(
				for b in resultArr do
				(
					print b
					RTWSettlementTools_AllVertexColorsWhite b
				)
			)
		)
	)
)