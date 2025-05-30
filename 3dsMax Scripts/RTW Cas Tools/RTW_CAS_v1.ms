-------------------------------------------
--										 --
--  RTW CAS Importer / Exporter   --
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
-- v1.0 -- intial version with animation				--
-- v1.1 -- Added Grasp/Release; animation frames   --
-- v1.2 -- Fixed errors due to scripts having duplicate functions   --
-- v1.3 -- Fixed rotation quat issue and doubled distance values during export --
-- v1.4 -- Added switch option for animation import: Euler XYZ or default TCB. Note that the export always converts it back to TCB (which is game format)
-- v1.5 -- Added copy/paste animation frames
-- v1.6 -- Fixed some errors when writing animation cas files: double distance values were incorrect, as well as total distance traveled. Also fixed wrong positioning of root bone in export (glitchy anim on strat map)
-- v1.7 -- Added ForcePosition and SkipPosition support, now as UI buttons, as well as reset. Also added textbox for manual bone input. Updated Grasp/Release to work with the updated user property data
----------------------------------------------------------

global useLog = true
global memoryBones = #()
global graspWarning = false

-- Parse string to value
function RTWCas_ParseValue str =
(
	str = trimRight (trimLeft str)
	local lowerStr = toLower str

	-- Handle boolean
	if lowerStr == "true" then return true
	if lowerStr == "false" then return false

	-- Handle quoted strings
	if matchPattern str pattern:"\"*\"" or matchPattern str pattern:"'*'" then
	(
		-- Remove quotes
		return substring str 2 (str.count - 2)
	)

	-- Try to execute as MaxScript value (safe for numbers, arrays, etc.)
	local parsedVal
    try (
        parsedVal = execute str
    ) catch (
        parsedVal = undefined
    )

	-- Check type and return if valid
	if isKindOf parsedVal Float or isKindOf parsedVal Integer or isKindOf parsedVal Array then
		return parsedVal

	-- Fallback: treat as plain string
	return str
)

function RTWCas_ReplaceSpaceWithUnderscore inputString = 
(
	for i = 1 to inputString.count where (findstring inputString[i] " ") != undefined do 
	(
		inputString[i] = "_"
	) 
	return inputString
)

-- Get the root NODE (not bone!), either Armature or Scene Root depending on imported file
function RTWCas_GetRootNode =
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

-- Is currently selected object the armature root?
function RTWCas_IsArmature boner =
(
	if(boner == undefined) then
	(
		return true
	)
	if(boner.name == "Armature") then
	(
		return true
	)
	if(boner.name == "Scene Root") then
	(
		return true
	)
	if(boner.name == "Scene_Root") then
	(
		return true
	)
)

-- Get currently selected bone, but if name is specified, use that instead
function RTWCas_GetSelectedBoneOrByName boneName:undefined =
(
	if (boneName != undefined) then
	(
		-- collect all bones but Armature
		local boneList = RTWCas_GetBones()
		if(boneList == undefined or boneList.count == 0) then
		(
			messageBox "There are no bones in this scene (only Root Bone?)!" title:"Error!"
			return undefined
		)
		for boner in boneList do
		(
			if boner.name == boneName then return boner
		)
		return undefined
	)	
	
	local selected = for t in selection where (classOf t == Point or classOf t == Dummy) collect t
	print selected
	if(selected == undefined or selected.count == 0) then
	(
		messageBox "You need to select a bone!" title:"Error!"
		return undefined
	)
	if(selected.count > 1) then
	(
		messageBox "We need a single bone! You selected multiple objects!" title:"Error!"
		return undefined
	)
	local selectedBone = selected[1]
	if (RTWCas_IsArmature selectedBone == true) then
	(
		messageBox "Armature / Scene Root is not a bone!" title:"Error!"
		return undefined
	)
	return selected[1]
)

-- Check if object has a root node parent with a name
function RTWCas_IsChildOfRootNode boner rNode =
(
	if(boner == undefined or rNode == undefined) then
	(
		return false
	)
	local parentBone = boner
	while(parentBone.parent != undefined) do
	(
		parentBone = parentBone.parent
	)
	if(parentBone.name == rNode.name) then
	(
		return true
	)
	return false
)

-- Return a list of bones (without Armature/Scene Root)
function RTWCas_GetBones =
(
	local armature = RTWCas_GetRootNode()
	if(armature != undefined) then
	(
		local dummies = for t in objects where (classOf t == Dummy and t.name != armature.name and t.parent != undefined and not isGroupHead t and (RTWCas_IsChildOfRootNode t armature)) collect t
		local pointers = for t in objects where (classOf t == Point and t.name != armature.name and t.parent != undefined and not isGroupHead t and (RTWCas_IsChildOfRootNode t armature)) collect t
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

function RTWCas_SceneIsCollada =
(
	local armature = RTWCas_GetRootNode()
	if(armature != undefined) then
	(
		if(armature.name == "Scene Root" or armature.name == "Scene_Root") then
		(
			return false
		)
	)
	return true
)

function RTWCas_GetSkinnedObjectPosition obj frame =
(
	if (frame < 0) then
	(
		local meshCopy = snapshot obj
		local vertCount = meshCopy.numVerts
		
		if vertCount == 0 then
        (
            return undefined -- No vertices found
        )
        
        local center = [0, 0, 0]
        
        -- Sum all vertex positions
        for i = 1 to vertCount do
        (
            center += getVert meshCopy i
        )
        
        -- Compute average position (center of the deformed mesh)
        center /= vertCount
        
        -- Delete the snapshot mesh
        delete meshCopy
        
		center[1] -= obj.position[1]
		center[2] -= obj.position[2]
		center[3] -= obj.position[3]
		
        return center
	)
	else
	(
		at time frame
		(
			local meshCopy = snapshot obj  -- Get the deformed mesh at the specified frame
			local vertCount = meshCopy.numVerts
			
			if vertCount == 0 then
			(
				return undefined -- No vertices found
			)
			
			local center = [0, 0, 0]
			
			-- Sum all vertex positions
			for i = 1 to vertCount do
			(
				center += getVert meshCopy i
			)
			
			-- Compute average position (center of the deformed mesh)
			center /= vertCount
			
			-- Delete the snapshot mesh
			delete meshCopy
			
			local pivotX = obj.position[1]
			local pivotY = obj.position[2]
			local pivotZ = obj.position[3]
			
			-- Correct relative to the object's pivot
			return center
		)
	)
)

function RTWCas_RoundFloat val dp = --rounds a float to a set number of decimal places
(
	a = val * (10^dp)
	b = a as integer
	a = b as float / (10^dp)
	return a
)

function RTWCas_QuatDot q1 q2 =
(
	return q1.x * q2.x + q1.y * q2.y + q1.z * q2.z + q1.w * q2.w
)

function RTWCas_ReverseString inString = (
	outstring = ""
	for i = 1 to inString.count do
	(
		outstring = inString[i] + outstring
	)
	return outstring
)

function RTWCas_BinaryToInt inBinary =
(
	local stringVer = inBinary as string
	local decValue = 0
	local base = 1
	local strLength = stringVer.count
	for i = strLength to 1 by -1 do
	(
		if(stringVer[i] == "1") then
		(
			decValue += base
		)
		base = base * 2
	)
	return decValue
)

function RTWCas_IntToBinary inInt = 
(
	binary = ""
	maskSt = 1;
	for i = 0 to 7 do
	(
		testInt = bit.and maskSt inInt
		if(testInt != 0) then (
			binary = "1" + binary
		) else (
			binary = "0" + binary
		)
		maskSt = bit.shift maskSt 1
	)
	return binary
)

function RTWCas_FormatFloatValue val zeroes = 
(
	tempzeros = "000000000000"
	if(val == undefined) then
	(
		return "undefined"
	)
	if (val > -0.0001) and (val < 0.0001) then
	(
		val = 0.0
	)
	if(val == -0.0) then
	(
		val = 0.0
	)
	
	-- if there is no '-' sign, add empty space 
	if findString (val as string) "-" == undefined then
	(
		val = " " + (val as string)
	)
	
	-- fill string with extra zeros before using substring
	val = (val as string) + tempzeros
	-- Set the string length
	val = substring val 1 (3 + zeroes)
	
	if(val == "-0.0") then
	(
		val = " 0.0"
	)
	return val
)

function RTWCas_FormatIntValue val padding =
(
	if(val == -0) then
	(
		val = 0
	)
	
	local offset = padding - (val as string).count
	if(offset > 0) then
	(
		for i=1 to offset do
		(
			val = " " + (val as string)
		)
	)
	
	return val
)

function RTWCas_LogText logString = 
(
	if(logString != undefined) then
	(
		if(useLog == true) then
		(
			print logString as string	
		)
	)
)

function RTWCas_GetPointerPosition inputFileStream =
(
	if(inputFileStream == undefined) then
	(
		return "\t\t at position = \t\t-1"
	)
	return ("\t\t at position = \t\t" + (ftell inputFileStream) as string)
)

--convert coord sys RTW x = x; RTW z = y; RTW y = z
function RTWCas_MaxToRTWVector inxyz isCollada =
(
	if(isCollada) then
	(
		return (point3 inxyz.x inxyz.z inxyz.y)
	)
	return (point3 -inxyz.x inxyz.z -inxyz.y)
)

--convert coord sys max x = x; max y = z; max z = y
function RTWCas_RTWToMaxVector inxyz isCollada =
(
	if(isCollada) then
	(
		return (point3 inxyz.x inxyz.z inxyz.y)
	)
	return (point3 -inxyz.x -inxyz.z inxyz.y)
)

-- Writes a RTW vector to the .cas file. Always 3 floats
function RTWCas_WriteVector fp outVec =
(
	WriteFloat fp outVec.x
	WriteFloat fp outVec.y
	WriteFloat fp outVec.z
)

-- Store Initial Pivot Offset (before animation)
function RTWCas_StorePivotOffset obj =
(
	if(obj == undefined) then
	(
		return false
	)
	local vert = getVert obj 1 -- get the first vert
	local offset = in coordsys world vert - obj.position
	
	local propValue = ""
	for i = 1 to 3 do
	(
		propValue = propValue + "%" + offset[i] as string
	)
	RTWCas_AddUserProp obj "VertexToPivot" propValue:propValue
)

-- Compute New Pivot Position per Frame
function RTWCas_ComputePivotPosition obj frame =
(
	if(obj == undefined) then
	(
		return false
	)	
	local propValue = RTWCas_GetUserProp obj "VertexToPivot"
	if propValue != undefined then
	(
		local offset = filterString propValue "%"
		local pivotOffset = point3 (offset[1] as float) (offset[2] as float) (offset[3] as float)
		at time frame
		(
			local meshCopy = snapshot obj -- get deformed mesh
			local firstVert = getVert meshCopy 1 -- get first vertex position
			delete meshCopy
			
			-- Compute new pivot position
			local newPivot = firstVert - pivotOffset
			return newPivot
		)
	)
)

-- Get the user properties as string array
function RTWCas_GetUserPropArray boner =
(
	if (boner != undefined) then
	(
		local buffer = replace_LF_with_CRLF (getUserPropBuffer boner)
		local normalizedStr = substituteString buffer "\r\n" "\n"
		
		-- Split on \n
		local linesArray = filterString normalizedStr "\n"
		
		-- Return result
		return linesArray
	)
)

-- Return the value of the defined user property
function RTWCas_GetUserProp boner propName =
(
	if (boner != undefined) then
	(
		local props = RTWCas_GetUserPropArray boner
		for line in props do
		(
			-- Check if the line starts with the property name
			if matchPattern line pattern:(propName + "*") do
			(
				local parts = filterString line "="
				if parts.count > 1 then 
				(
					-- only return the value, trim around the '=' sign
					local result = trimRight (trimLeft parts[2])
					
					-- try to parse the result string into any value
					return RTWCas_ParseValue result
				) else
				(
					-- Return line value if no '=' sign is found
					return line
				)
			)
		)
	)
	return undefined
)

-- Get boolean representation if user property is assigned without a value. Then this method returns true
function RTWCas_GetUserPropBoolean boner propName =
(
	local propResult = RTWCas_GetUserProp boner propName
	if (propResult != undefined) then
	(
		-- If it was parsed to a Boolean true
		if propResult == true then return true
			
		-- If it was parsed to a Boolean false
		if propResult == false then return false
		
		-- If the property was defined without a value (e.g., just "Flag"), it's a string, and we assume it's true
		if isKindOf propResult String then return true
	)
	return false
)

-- Set the user properties buffer using input array
function RTWCas_SetUserPropArray boner arr =
(
	if (boner != undefined and arr != undefined) then
	(
		-- Join the array into a single string with newline separators
        local propString = ""
        for i = 1 to arr.count do
        (
            propString += arr[i]
            if i < arr.count do propString += "\r\n"
        )

        -- Set the user property buffer
        setUserPropBuffer boner propString
	)
)

-- Add a new user property
function RTWCas_AddUserProp boner propString propValue:undefined =
(
	if(boner != undefined) then
	(
		local linesArray = RTWCas_GetUserPropArray boner
		-- Filter out entries containing the propString, to prevent duplicate value
		local filteredArray = for line in linesArray where ((findString line propString) == undefined) collect line
		-- Add the new property to the array
		if (propValue == undefined) then
		(
			append filteredArray propString
		) else
		(
			append filteredArray (propString + " = " + propValue as string)
		)
	
		-- Set the updated array back to the object
		RTWCas_SetUserPropArray boner filteredArray
	)
)

-- Remove both ForcePosition and SkipPosition
function RTWCas_ResetBonePositionFlags boner =
(
	if(boner != undefined) then
	(
		local linesArray = RTWCas_GetUserPropArray boner
		
		-- Filter out entries containing "ForcePosition" or "SkipPosition"
		local filteredArray = for line in linesArray where (
			(findString line "ForcePosition") == undefined and (findString line "SkipPosition") == undefined
		) collect line
		RTWCas_SetUserPropArray boner filteredArray
	)
)

-- Set the ForcePosition flag
function RTWCas_SetBoneForcePosition boner =
(
	if(boner != undefined) then
	(
		RTWCas_ResetBonePositionFlags boner 
		RTWCas_AddUserProp boner "ForcePosition"
	)
)

-- Set the SkipPosition flag
function RTWCas_SetBoneSkipPosition boner =
(
	if(boner != undefined) then
	(
		RTWCas_ResetBonePositionFlags boner
		RTWCas_AddUserProp boner "SkipPosition"
	)
)

-- Set the original parent offset
function RTWCas_SetBoneUserParentProperty boner override =
(
	if(boner == undefined) then
	(
		return false
	)
	local initialPosition = RTWCas_GetUserProp boner "InitialPosition"
	if (initialPosition != undefined and override != true) then
	(
		return false
	)
	local offset = in coordsys boner.parent boner.pos
	local propValue = ""
	for i = 1 to 3 do
	(
		propValue = propValue + "%" + offset[i] as string
	)
	RTWCas_AddUserProp boner "InitialPosition" propValue:propValue
)

-- Get the original parent offset
function RTWCas_GetBoneUserParentProperty boner =
(
	if(boner == undefined) then
	(
		return false
	)
	local initialPosition = RTWCas_GetUserProp boner "InitialPosition"
	if (initialPosition != undefined) then
	(
		local offset = filterString initialPosition "%"
		return point3 (offset[1] as float) (offset[2] as float) (offset[3] as float)
	)
	if(boner.parent != undefined) then
	(
		if(graspWarning == false) then
		(
			graspWarning = true
			messageBox "There is no initial position stored in the properties of the bones.\n\nUse the 'Grasp' and 'Release' tool for best animation export." title:"Warning!"
		)
		return at time 0 in coordsys parent boner.pos	
	)
	return at time 0 boner.pos
)

-- Check if input bone has valid position controller
function RTWCas_BoneHasPositionController boneIdx frameStart frameEnd forceNoTranslation =
(
	if(boneIdx == undefined) then
	(
		return false
	)
	local armature = RTWCas_GetRootNode()
	if(armature == undefined) then
	(
		return false
	)
	if(boneIdx.parent.name == armature.name) then
	(
		return true -- Always add first bone
	)
	if(forceNoTranslation) then
	(
		return false -- Now every other bone should return false. Only first bone should have it!
	)
	local initialPos = RTWCas_GetBoneUserParentProperty boneIdx
	local forcePosition = RTWCas_GetUserPropBoolean boneIdx "ForcePosition"
	local skipPosition = RTWCas_GetUserPropBoolean boneIdx "SkipPosition"
	if (forcePosition != undefined and forcePosition == true) then
	(
		return true
	)
	if (skipPosition != undefined and skipPosition == true) then
	(
		return false
	)
	if(initialPos != undefined) then
	(
		for k = frameStart to frameEnd do
		(
			local framePos = at time (k) in coordsys boneIdx.parent boneIdx.pos
			local differenceX = RTWCas_FormatFloatValue (framePos.x - initialPos[1]) 1
			local differenceY = RTWCas_FormatFloatValue (framePos.y - initialPos[2]) 1
			local differenceZ = RTWCas_FormatFloatValue (framePos.z - initialPos[3]) 1
			if(differenceX as string != " 0.0" or differenceY as string != " 0.0" or differenceZ as string != " 0.0") then
			(
				return true
			)
		)
	)
	for k=(frameStart+1) to frameEnd do
	(
		local previousPos = at time (k-1) in coordsys boneIdx.parent boneIdx.pos
		local currentPos = at time (k) in coordsys boneIdx.parent boneIdx.pos
		local differenceX = RTWCas_FormatFloatValue (currentPos.x - previousPos.x) 1
		local differenceY = RTWCas_FormatFloatValue (currentPos.y - previousPos.y) 1
		local differenceZ = RTWCas_FormatFloatValue (currentPos.z - previousPos.z) 1
		if(differenceX as string != " 0.0" or differenceY as string != " 0.0" or differenceZ as string != " 0.0") then
		(
			return true
		)
	)
	return false
)

-- Return count of bones that have a valid position controller
function RTWCas_GetNumBonesWithPosition boneList frameStart frameEnd forceNoTranslation =
(
	if(boneList == undefined or forceNoTranslation) then
	(
		return 1 -- we always need 1 bone.. Root bone has position
	)
	local counter = 0
	for b in boneList do
	(
		if(counter == 0) then -- always add first bone!
		(
			counter += 1
		) else
		(
			if ((RTWCas_BoneHasPositionController b frameStart frameEnd forceNoTranslation) == true) then
			(
				counter += 1
			)	
		)
	)
	if(counter == 0) then
	(
		return 1 -- we always need 1 bone.. Root bone has position
	)
	return counter
)

-- Get starting frame animation selection
function RTWCas_GetStartFrame =
(
	return [animationRange.start, (animationRange.end - 1), animationRange.start]
)

-- Get end frame animation selection
function RTWCas_GetEndFrame =
(
	return [(animationRange.start + 1), animationRange.end, animationRange.end]
)

-- Loops trough every frame and converts Euler_XYZ rotation controller to TCB which is required by RTW engine. Returns true when sucessfull convertion
function RTWCAS_EulerToQuat b numFrames =
(
	if(b == undefined) then
	(
		return false
	)
	if((classOf b.rotation.controller) == Euler_XYZ) then
	(
		local animSet = #()	
		for k = 1 to numFrames do animate on in coordsys b.parent
		(
			--local frameRotX = at time k b[3][2].rotation.x
			--local frameRotY = at time k b[3][2].rotation.y
			--local frameRotZ = at time k b[3][2].rotation.z
			local frameRotX = at time k b.rotation.controller.x_rotation
			local frameRotY = at time k b.rotation.controller.y_rotation
			local frameRotZ = at time k b.rotation.controller.z_rotation
			
			--local frameRotW = at time k b[3][2].rotation.w
			local localXZYW = #()
			append localXZYW frameRotX
			append localXZYW frameRotZ
			append localXZYW frameRotY
			--append localXZYW frameRotW
			append animSet localXZYW
		)
		b.rotation.controller = TCB_Rotation()
		b.rotation.controller.rotWindup = true
		deletekeys b.rotation.controller #allKeys
		for k = 1 to numFrames do animate on in coordsys b.parent
		(
			local localXZYW = animSet[k]
			addnewkey b.rotation.controller k
			local frameRotX = localXZYW[1]
			local frameRotY = localXZYW[2]
			local frameRotZ = localXZYW[3]
			--local frameRotW = localXZYW[4]
			local objRot = eulerAngles frameRotX frameRotY frameRotZ
			--local quatFound = quat (frameRotX) (frameRotY) (frameRotZ)  ( frameRotW ) -- animate bone
			local quatCalc = EulerToQuat objRot
			local quatInverse = (inverse quatCalc)
			-- MAXScript's implementation of quaternions is slightly problematic. The biggest issue is that a quaternion will rotate a vector clockwise around an axis while it will rotate a geometric object counterclockwise around an axis
			
			
			
			--print quatFound
			--print quatCalc
			at time k b[3][2].rotation = quatInverse
		)
		return true
	)
	return false
)

function RTWCas_GetPath bLeaveLastSlash inString =
(
	lastSlash=0
	outString=""
	for i=1 to inString.count do 
	(
		if(inString[i]=="\\") then
		(
			lastSlash=i
		)
	)
	if (bLeaveLastSlash) then 
	(
		lastSlash-=1
	)
	for i=1 to lastSlash do
	(
		outString += inString[i]
	)
	return outString
)

-- Get texture path
function RTWCas_GetTexturePath textureName filePath = 
(
	if((findString textureName "textures") == undefined) then 
	(
		textureName = "\\textures" + textureName
	)
	local bAlreadySlash= textureName[1]=="\\"
	if(((findString textureName ".dds") == undefined) or ((findString textureName ".DDS") == undefined)) then
	(
		textureName +=".dds"
	)
	local directory = RTWCas_GetPath bAlreadySlash filePath
	-- now check if directory ends with certain sections from settlement overlays etc. Makes life easier for us right?
	if((findString directory "\\settlement_plans\\overlays\\") != undefined) then
	(
		directory = substituteString directory "\\settlement_plans\\overlays\\" "\\models_building\\"
	)
	if((findString directory "\\settlement_plans\\slot_overlays\\") != undefined) then
	(
		directory = substituteString directory "\\settlement_plans\\slot_overlays\\" "\\models_building\\"
	)
	if((findString directory "\\models_building\\models_spot\\") != undefined) then
	(
		directory = substituteString directory "\\models_building\\models_spot\\" "\\models_building\\"
	)
	if((findString directory "\\models_building\\models_walls\\") != undefined) then
	(
		directory = substituteString directory "\\models_building\\models_walls\\" "\\models_building\\"
	)
	if((findString directory "\\models_building\\info\\info_walls\\") != undefined) then
	(
		directory = substituteString directory "\\models_building\\info\\info_walls\\" "\\models_building\\"
	)
	if((findString directory "\\models_building\\info\\") != undefined) then
	(
		directory = substituteString directory "\\models_building\\info\\" "\\models_building\\"
	)
	if not bAlreadySlash and (directory[directory.count]!="\\") then 
	(
		directory+="\\"
	)
	local fullName = directory + (textureName)
	return fullName
)

-- Replaces every space w ith double underscores. Good for IWTE usage
function RTWCas_ReplaceSpaceWithDoubleUnderscore inString =
(
	return substituteString inString " " "__"
)

-- Replaces every double unscore to space. From IWTE
function RTWCas_ReplaceDoubleUnderscoreWithSpace inString =
(
	return substituteString inString "__" " "
)

-- STRUCTS section
struct CASHEADER 
(
	-- Start header
	casFileVersion, -- float
	chunkSize, -- long
	chunkTypeId, -- long
	longFiller1, -- long 0
	animationLength, -- float
	floatFiller1, -- float 0.0
	variableByteValuesSet1, -- array of 3 bytes
	integerFiller1, -- int
	integerFiller2, -- int
	variableByteValuesSet2, -- array of 3 bytes
	
	-- Read Cas Header
	function Read casFile logFile =
	(
		local writeLog = false
		if(logFile != undefined) then
		(
			writeLog = true
		)
		
		casFileVersion = ReadFloat casFile
		if(writeLog == true) then
		(
			format "%\t\t\t\t\t\t\t\t\t\t\t\t\t\t# cas file version\t\t\t\t\t\t\t%\n" casFileVersion (RTWCas_GetPointerPosition casFile) to:logFile
			format " # ------------------------------------------------------------------- \n" to:logFile
		)
		chunkSize = ReadLong casFile
		chunkTypeId = ReadLong casFile
		if(writeLog == true) then
		(
			format "%  %\t\t\t\t\t\t\t\t\t\t\t\t\t# chunksize, chunktypeid expect 38 9\t\t%\n" chunkSize chunkTypeId (RTWCas_GetPointerPosition casFile) to:logFile
		)
		longFiller1 = ReadLong casFile
		if(writeLog == true) then
		(
			format "%\t\t\t\t\t\t\t\t\t\t\t\t\t\t# expect long filler 0\t\t\t\t\t\t%\n" longFiller1 (RTWCas_GetPointerPosition casFile) to:logFile
		)
		animationLength = ReadFloat casFile
		if(writeLog == true) then
		(
			format "\t%\t\t\t\t\t\t\t\t\t\t\t\t# animation length\t\t\t\t\t\t\t%\n" animationLength (RTWCas_GetPointerPosition casFile) to:logFile
		)
		local oneIntegerFiller = ReadLong casFile
		if(writeLog == true) then
		(
			format "%\t\t\t\t\t\t\t\t\t\t\t\t\t\t# expect one integer fillers 1 normally\t\t%\n" oneIntegerFiller (RTWCas_GetPointerPosition casFile) to:logFile
		)	
		floatFiller1 = ReadFloat casFile
		if(writeLog == true) then
		(
			format "%\t\t\t\t\t\t\t\t\t\t\t\t\t\t# expect float filler 0.0\t\t\t\t\t%\n" floatFiller1 (RTWCas_GetPointerPosition casFile) to:logFile
		)
		variableByteValuesSet1  = #()
		append variableByteValuesSet1 (ReadByte casFile)
		append variableByteValuesSet1 (ReadByte casFile)
		append variableByteValuesSet1 (ReadByte casFile)
		if(writeLog == true) then
		(
			format "%  %  %\t\t\t\t\t\t\t\t\t\t\t\t\t# first set of three variable byte values\t%\n" variableByteValuesSet1[1] variableByteValuesSet1[2] variableByteValuesSet1[3] (RTWCas_GetPointerPosition casFile) to:logFile
		)
		integerFiller1 = ReadLong casFile
		integerFiller2 = ReadLong casFile
		if(writeLog == true) then
		(
			format "%  %\t\t\t\t\t\t\t\t\t\t\t\t\t# expect two integer fillers 1 0\t\t\t%\n" integerFiller1 integerFiller2 (RTWCas_GetPointerPosition casFile) to:logFile
		)
		variableByteValuesSet2  = #()
		append variableByteValuesSet2 (ReadByte casFile)
		append variableByteValuesSet2 (ReadByte casFile)
		append variableByteValuesSet2 (ReadByte casFile)
		if(writeLog == true) then
		(
			format "%  %  %\t\t\t\t\t\t\t\t\t\t\t\t\t# second set of three variable byte values\t%\n" variableByteValuesSet2[1] variableByteValuesSet2[2] variableByteValuesSet2[3] (RTWCas_GetPointerPosition casFile) to:logFile
		)
		return true
	)
)

-- RTW Bone
struct RTWBONE
(
	stringLength, -- number of bytes
	boneName, -- bone Name
	quatFrames,
	positionFrames,
	quatOffset,
	positionOffset,
	fillerZero,
	strSize, --usally 1, extra number of bytes and bone string data from 3dsmax
	position, -- point3
	
	-- Reads a bone data
	function Read casFile logFile =
	(
		local writeLog = false
		if(logFile != undefined) then
		(
			writeLog = true
		)
		if(writeLog == true) then
		(
			format " # ------------------------------------------------------------------- \n" to:logFile
		)
		stringLength = ReadLong casFile
		boneName = ReadString casFile
		if(writeLog == true) then
		(
			format "%  %\t\t\t\t\t\t\t\t\t\t\t# number of bytes and bone name\t\t\t\t%\n" stringLength boneName (RTWCas_GetPointerPosition casFile) to:logFile
		)
		quatFrames = ReadLong casFile
		positionFrames = ReadLong casFile
		quatOffset = ReadLong casFile
		positionOffset = ReadLong casFile
		fillerZero = ReadLong casFile
		if(writeLog == true) then
		(
			format "%  %  %  %  %\t\t\t\t\t\t\t\t\t\t\t# five ints - quatframes, positionframes, quatoffset, positionoffset, fillerzero %\n" quatFrames  positionFrames quatOffset positionOffset fillerZero (RTWCas_GetPointerPosition casFile) to:logFile
		)
		strSize = ReadLong casFile
		fseek casFile strSize  #seek_cur
		if(writeLog == true) then
		(
			format "%\t\t\t\t\t\t\t\t\t\t\t\t\t\t# extra number of bytes and bone string data from 3dsmax %\n" strSize (RTWCas_GetPointerPosition casFile) to:logFile
		)
		position = RTWCas_RTWToMaxVector( point3 (ReadFloat casFile) (ReadFloat casFile) (ReadFloat casFile) ) true
		if(writeLog == true) then
		(
			format "\t%\t%\t%\t\t# pose xyz \t\t\t\t\t\t\t\t\t%\n" (RTWCas_FormatFloatValue position.x 10) (RTWCas_FormatFloatValue position.y 10) (RTWCas_FormatFloatValue position.z 10) (RTWCas_GetPointerPosition casFile) to:logFile
		)
		if(writeLog == true) then
		(
			format " # -------------------------  End of bone %   ----------------------------  \n" boneName to:logFile
		)
		
	)
)

-- Bone Chunk struct
struct BONECHUNK
(
	-- Start mesh bone chunk
	vectorBones,
	chunkSize, -- long
	chunkTypeId, -- long (expect 0)
	numBones, -- two byte int
	boneList, -- bone hierarchy list
	numFrames, -- number of time frames in animation
	timeFrames, -- list of time frames
	
	-- Read bone chunk
	function Read casFile logFile =
	(
		local writeLog = false
		if(logFile != undefined) then
		(
			writeLog = true
		)
		chunkSize = ReadLong casFile
		chunkTypeId = ReadLong casFile
		if(writeLog == true) then
		(
			format "%  %\t\t\t\t\t\t\t\t\t\t\t\t\t# chunksize, chunktypeid expect type 0t\t\t%\n" chunkSize chunkTypeId (RTWCas_GetPointerPosition casFile) to:logFile
		)
		numBones = ReadShort casFile
		if(writeLog == true) then
		(
			format "%\t\t\t\t\t\t\t\t\t\t\t\t\t\t# number of bones as two byte int\t\t\t%\n" numBones (RTWCas_GetPointerPosition casFile) to:logFile
		)
		local boneHierarchy = #()
		for i=1 to numBones do
		(
			append boneHierarchy (ReadLong casFile)
		)
		if(writeLog == true) then
		(
			format "%\t\t\t\t\t\t\t\t\t\t\t\t\t# bone hierarchy list\t\t\t\t\t\t%\n" (boneHierarchy as string) (RTWCas_GetPointerPosition casFile) to:logFile
		)
		numFrames = ReadLong casFile
		if(writeLog == true) then
		(
			format "%\t\t\t\t\t\t\t\t\t\t\t\t\t\t# number of time frames in animation\t\t%\n" numFrames (RTWCas_GetPointerPosition casFile) to:logFile
		)
		timeFrames = #()
		for i = 1 to numFrames do
		(
			local timeFrame = ReadFloat casFile
			append timeFrames timeFrame
		)
		if(timeFrames.count > 0) then
		(
			if(writeLog == true) then
			(
				for t in timeFrames do
				(
					format "%\t" (RTWCas_FormatFloatValue t 4) to:logFile
				)
				format "# list of time frames\t%\n" (RTWCas_GetPointerPosition casFile) to:logFile
			)
		)
		
		-- Read bone data
		vectorBones = #()
		for i=1 to numBones do
		(
			tmpBone = RTWBONE 0
			tmpBone.Read casFile logFile
			append vectorBones tmpBone
		)
	)
)

struct RTWMESH
(
	isTextured, --read textureverts?
	isColored, --read vertex colors?
	readVertexAssign, --bool, wheter to read vertex assignments
	verts, --array of point3 floats
	normals, -- array of point3 floats
	faces, -- array of point3 floats
	textureId, -- which texture does it use?
	uvw, -- array of point3 floats
	vertexQuatByte, -- vertex color information
	
	function Read casFile logFile numVerts numFaces =
	(
		verts = #()
		normals = #()
		faces = #()
		uvw = #()
		vertexQuatByte = #()
		
		local writeLog = false
		if(logFile != undefined) then
		(
			writeLog = true
		)
		
		--if(readVertexAssign) then
		--(
		--)
		
		-- Read all vertex position data
		for i=1 to numVerts do
		(
			local posX = ReadFloat casFile
			local posZ = ReadFloat casFile
			local posY = ReadFloat casFile
			local pos = RTWCas_RTWToMaxVector( point3 (posX) (posZ) (posY) ) true
			append verts pos
			if(writeLog == true) then
			(
				format "%\t%\t%\t\t\t# cas mesh vertex position xyz values\t\t%\n" (RTWCas_FormatFloatValue posX 10) (RTWCas_FormatFloatValue posZ 10) (RTWCas_FormatFloatValue posY 10)  (i-1) to:logFile
			)
		)
		if(writeLog == true) then
		(
			format " # -------------------------  end vertices position data   ----------------------------  %\n" (RTWCas_GetPointerPosition casFile) to:logFile
		)
		
		-- Read all vertex normal data
		for i=1 to numVerts do
		(
			local normalX = ReadFloat casFile
			local normalZ = ReadFloat casFile
			local normalY = ReadFloat casFile
			local normal = RTWCas_RTWToMaxVector( point3 (normalX) (normalZ) (normalY) ) true
			append normals normal
			if(writeLog == true) then
			(
				format "%\t%\t%\t\t\t# cas mesh vertex normal xyz values\t\t\t%\n" (RTWCas_FormatFloatValue normalX 10) (RTWCas_FormatFloatValue normalZ 10) (RTWCas_FormatFloatValue normalY 10)  (i-1) to:logFile
			)
		)
		if(writeLog == true) then
		(
			format " # -------------------------  end vertices normal data   ----------------------------  %\n" (RTWCas_GetPointerPosition casFile) to:logFile
		)
		-- Read faces (tirangles)
		for i=1 to numFaces do
		(
			local indexX = ReadShort casFile #unsigned
			local indexY = ReadShort casFile #unsigned
			local indexZ = ReadShort casFile #unsigned
			append faces (point3 (indexZ+1) (indexY+1) (indexX+1))
			if(writeLog == true) then
			(
				format "\t% \t% \t%\t\t\t# cas mesh vertex triangle indexes\t\t\t%\n" (RTWCas_FormatIntValue indexX 3) (RTWCas_FormatIntValue indexY 3) (RTWCas_FormatIntValue indexZ 3)  (i-1) to:logFile
			)
		)
		if(writeLog == true) then
		(
			format " # -------------------------  end triangles data   ----------------------------  %\n" (RTWCas_GetPointerPosition casFile) to:logFile
		)
		
		textureId = (ReadLong casFile) -- 0 based!
		if(writeLog == true) then
		(
			format "%\t\t\t\t\t\t\t\t# texture reference number (int)\t\t\t\t%\n" textureId (RTWCas_GetPointerPosition casFile) to:logFile
		)
		-- Read UVW coordinates
		if(isTextured != 0) then
		(
			for i=1 to numVerts do
			(
				local coordU = ReadFloat casFile
				local coordV = ReadFloat casFile
				if(writeLog == true) then
				(
					format "%\t%\t# cas texture vertex uv values\t\t%\n" (RTWCas_FormatFloatValue coordU 10) (RTWCas_FormatFloatValue coordV 10)  (i-1) to:logFile
				)
				append uvw ((point3 (coordU) (1.0-(coordV)) 0.0))
			)
		)
		if(writeLog == true) then
		(
			format " # -------------------------  end UV data   ----------------------------  %\n" (RTWCas_GetPointerPosition casFile) to:logFile
		)
		
		if(isColored != 0) then
		(
			for i=1 to numVerts do
			(
				local colorR = ReadByte casFile #unsigned
				local colorG = ReadByte casFile #unsigned
				local colorB = ReadByte casFile #unsigned
				local colorAlpha = ReadByte casFile #unsigned
				if(writeLog == true) then
				(
					format "\t%\t\t%\t\t%\t\t%\t\t\t\t\t\t# cas mesh vertex quad byte values\t\t%\n" (RTWCas_FormatIntValue colorR 3) (RTWCas_FormatIntValue colorG 3) (RTWCas_FormatIntValue colorB 3) (RTWCas_FormatIntValue colorAlpha 3) (i-1) to:logFile
				)
				local colorCombined = color colorR colorG colorB
				local colorInfoArray = #()
				append colorInfoArray colorCombined
				append colorInfoArray (color colorAlpha colorAlpha colorAlpha)
				append vertexQuatByte colorInfoArray
			)
		)
		if(writeLog == true) then
		(
			format " # -------------------------  end vertex color quad data   ----------------------------  %\n" (RTWCas_GetPointerPosition casFile) to:logFile
		)
		
		local fillerInt = ReadLong casFile
		if(writeLog == true) then
		(
			format "%\t\t\t\t\t\t\t\t\t\t\t\t\t# filler int 0\t\t\t\t%\n" fillerInt (RTWCas_GetPointerPosition casFile) to:logFile
		)
	)
)

struct MESHCHUNK
(
	type, -- mesh chunk type
	stringLength, -- number of bytes
	meshName, -- Mesh Name
	strSkip, -- possible extra byte count and name
	strSkip2, -- number of bytes and extra mesh name
	boneAttachIndex, -- bone index for prim, sec weapons and shield for RTW (no weights)
	quaternian, -- quat
	position, -- position x y z point3
	numVerts, -- short, number of vertices
	numFaces, -- short. number of triangles
	isTextured, -- textured? (1) or not (0) as byte
	isColored, -- colors?  (1) or not (0) as byte
	meshObj, -- RTW mesh
	createdMesh,
	
	function Read casFile logFile = 
	(
		local writeLog = false
		if(logFile != undefined) then
		(
			writeLog = true
		)
		stringLength = ReadLong casFile
		meshName = ReadString casFile
		if(writeLog == true) then
		(
			format "%  %\t\t\t\t\t\t\t\t# number of bytes and mesh name\t\t\t\t%\n" stringLength meshName (RTWCas_GetPointerPosition casFile) to:logFile
		)
		strSkip=ReadLong casFile--length of extra string
		fseek casFile strSkip #seek_cur
		if(writeLog == true) then
		(
			format "%\t\t\t\t\t\t\t\t\t\t\t\t\t\t# possible extra byte count and name\t\t%\n" strSkip (RTWCas_GetPointerPosition casFile) to:logFile
		)
		strSkip2=ReadLong casFile--length of extra string
		fseek casFile strSkip2 #seek_cur
		if(writeLog == true) then
		(
			format "%\t\t\t\t\t\t\t\t\t\t\t\t\t\t# number of bytes and extra mesh name\t\t%\n" strSkip2 (RTWCas_GetPointerPosition casFile) to:logFile
		)
		boneAttachIndex = ReadLong casFile
		if(writeLog == true) then
		(
			format "%\t\t\t\t\t\t\t\t\t\t\t\t\t\t# bone index for prim, sec weapons and shield for RTW (no weights)%\n" boneAttachIndex (RTWCas_GetPointerPosition casFile) to:logFile
		)
		
		-- quaternian and position
		local quatX = ReadFloat casFile
		local quatY = ReadFloat casFile
		local quatZ = ReadFloat casFile
		local quatW = ReadFloat casFile
		local posX = ReadFloat casFile
		local posY = ReadFloat casFile
		local posZ = ReadFloat casFile
		quaternian = quat (quatX) (quatY) (quatZ)  ( quatW )
		position = RTWCas_RTWToMaxVector( point3 (posX) (posY) (posZ) ) true
		if(writeLog == true) then
		(
			format "%\t%\t%\t%\t%\t%\t%\t# quaternian and position%\n" (RTWCas_FormatFloatValue quatX 10) (RTWCas_FormatFloatValue quatY 10) (RTWCas_FormatFloatValue quatZ 10) (RTWCas_FormatFloatValue quatW 10) (RTWCas_FormatFloatValue position.x 10) (RTWCas_FormatFloatValue position.y 10) (RTWCas_FormatFloatValue position.z 10) (RTWCas_GetPointerPosition casFile) to:logFile
		)
		
		numVerts = ReadShort casFile
		if(writeLog == true) then
		(
			format "%\t\t\t\t\t\t\t\t\t\t\t\t\t\t# number of vertices (short int)\t\t\t%\n" numVerts (RTWCas_GetPointerPosition casFile) to:logFile
		)
		numFaces = ReadShort casFile
		if(writeLog == true) then
		(
			format "%\t\t\t\t\t\t\t\t\t\t\t\t\t\t# number of triangles (short int)\t\t\t%\n" numFaces (RTWCas_GetPointerPosition casFile) to:logFile
		)
		
		isTextured = ReadByte casFile #unsigned
		if(writeLog == true) then
		(
			format "%\t\t\t\t\t\t\t\t\t\t\t\t\t\t# textured? (1) or not (0) as byte\t\t\t%\n" isTextured (RTWCas_GetPointerPosition casFile) to:logFile
		)
		
		isColored = ReadByte casFile #unsigned
		if(writeLog == true) then
		(
			format "%\t\t\t\t\t\t\t\t\t\t\t\t\t\t# colors? (1) or not (0) as byte\t\t\t%\n" isColored (RTWCas_GetPointerPosition casFile) to:logFile
		)		
		
		meshObj = RTWMESH isTextured:isTextured isColored:isColored
		if(type==1) then meshObj.readVertexAssign = false
		else if(type == 2) then meshObj.readVertexAssign = true
		meshObj.Read casFile logFile numVerts numFaces
		
		if(writeLog == true) then
		(
			format " # -------------------------  End of mesh %   ----------------------------  \n" meshName to:logFile
		)
		
		-- Create Mesh
		createdMesh = mesh name:(RTWCas_ReplaceSpaceWithDoubleUnderscore meshName) vertices:meshObj.verts faces:meshObj.faces tverts:meshObj.uvw
		defaultVCFaces createdMesh
		
		-- Setup texture
		if(isTextured != 0) then
		(
			for k=1 to numVerts do
			(
				SetTVert createdMesh k meshObj.uvw[k]
			)
			
			try
			(
				buildTVFaces createdMesh
				local ind = 0
				for k=1 to numFaces do
				( 
					ind += 1
					SetTVFace createdMesh ind meshObj.faces[ind]
				)
			)
			catch
			(
				MessageBox ("Problem occured building faces for object '" + createdMesh.name + "'. \nThis object probably doesn't have any vertices. Ignoring this now")   title:"Warning!" beep:false
			)
		)
		
		-- Setup vertex colors
		if(isColored != 0) then
		(
			ConvertTo createdMesh Editable_Poly
			for i=1 to numVerts do
			(
				polyOp.setVertColor createdMesh 0 i meshObj.vertexQuatByte[i][1]
				polyOp.setVertColor createdMesh -2 i meshObj.vertexQuatByte[i][2] -- Alpha channel
			)
			ConvertTo createdMesh Editable_Mesh
		)
	)
)

struct GEOMETRYCHUNK
(
	chunkSize, -- long
	chunkTypeId, -- long
	numMeshGroups,
	stringLength, -- number of bytes
	boneName, -- bone Name
	meshArray, -- array of meshes
	
	function Read casFile logFile =
	(
		local writeLog = false
		if(logFile != undefined) then
		(
			writeLog = true
		)
		chunkSize = ReadLong casFile
		chunkTypeId = ReadLong casFile
		if(writeLog == true) then
		(
			format "%  %\t\t\t\t\t\t\t\t\t\t\t\t# chunksize, chunktypeid \t\t\t\t\t%\n" chunkSize chunkTypeId (RTWCas_GetPointerPosition casFile) to:logFile
		)
		numMeshGroups = ReadLong casFile
		if(writeLog == true) then
		(
			format "%\t\t\t\t\t\t\t\t\t\t\t\t\t\t# number of mesh groups \t\t\t\t\t%\n" numMeshGroups (RTWCas_GetPointerPosition casFile) to:logFile
			format " # ------------------------------------------------------------------- \n" to:logFile
		)
		
		meshArray = #()
		for i=1 to numMeshGroups do
		(
			tmpMesh = MESHCHUNK 0
			tmpMesh.Read casFile logFile
			append meshArray tmpMesh
		)
	)
)

struct MESHGROUPCHUNK
(
	chunkSize, -- long
	chunkTypeId, -- long
	numMeshGroups,
	numMeshGroupsOrOtherCount,
	
	function Read casFile logFile =
	(
		local writeLog = false
		if(logFile != undefined) then
		(
			writeLog = true
		)
		chunkSize = ReadLong casFile
		chunkTypeId = ReadLong casFile
		if(writeLog == true) then
		(
			format "%  %\t\t\t\t\t\t\t\t\t\t\t\t# chunksize, chunktypeid \t\t\t\t\t%\n" chunkSize chunkTypeId (RTWCas_GetPointerPosition casFile) to:logFile
		)
		numMeshGroups = ReadLong casFile
		if(writeLog == true) then
		(
			format "%\t\t\t\t\t\t\t\t\t\t\t\t\t# number of mesh groups \t\t\t\t\t%\n" numMeshGroups (RTWCas_GetPointerPosition casFile) to:logFile
		)
		numMeshGroupsOrOtherCount = ReadLong casFile
		if(writeLog == true) then
		(
			format "%\t\t\t\t\t\t\t\t\t\t\t\t\t# number of mesh groups (3.2) or other count(<3.2) eg 3.17 \t\t\t\t\t%\n" numMeshGroups (RTWCas_GetPointerPosition casFile) to:logFile
		)
	)
)

struct TEXTURECHUNK
(
	textureIndex, -- integer
	textureFlag, -- long
	embeddedTga, -- byte 0 or 1
	textureName, -- ending with null (0) byte
	opacity, -- float (0,0-1.0)
	ambientArray, -- array 3 floats
	diffuseArray, -- array 3 floats
	emissiveArray, -- array 3 floats
	specularArray, -- array 3 floats
	specularHighlight, --specular highlight sharpness (0.0 or 25.0) is 25 set if group 5 not 0
	backfaceCulling, -- byte 0 or 1
	texturePath, -- formatted path using textureName
	
	function Read casFile logFile casPath =
	(
		local writeLog = false
		if(logFile != undefined) then
		(
			writeLog = true
		)
		ambientArray = #()
		diffuseArray = #()
		emissiveArray = #()
		specularArray = #()
		
		textureFlag = ReadLong casFile
		local textureFlagPos = (RTWCas_GetPointerPosition casFile)
		
		embeddedTga = ReadByte casFile
		local embeddedTgaPos = (RTWCas_GetPointerPosition casFile)
		
		textureName = ReadString casFile
		local textureNamePos = (RTWCas_GetPointerPosition casFile)
		texturePath = RTWCas_GetTexturePath textureName casPath
		
		opacity = ReadFloat casFile
		local opacityPos = (RTWCas_GetPointerPosition casFile)
		
		local ambientFloatOne = ReadFloat casFile
		local ambientFloatTwo = ReadFloat casFile
		local ambientFloatThree = ReadFloat casFile
		append ambientArray ambientFloatOne
		append ambientArray ambientFloatTwo
		append ambientArray ambientFloatThree
		local ambientPos = (RTWCas_GetPointerPosition casFile)
		
		local diffuseFloatOne = ReadFloat casFile
		local diffuseFloatTwo = ReadFloat casFile
		local diffuseFloatThree = ReadFloat casFile
		append diffuseArray diffuseFloatOne
		append diffuseArray diffuseFloatTwo
		append diffuseArray diffuseFloatThree
		local diffusePos = (RTWCas_GetPointerPosition casFile)
		
		local emissiveFloatOne = ReadFloat casFile
		local emissiveFloatTwo = ReadFloat casFile
		local emissiveFloatThree = ReadFloat casFile
		append emissiveArray emissiveFloatOne
		append emissiveArray emissiveFloatTwo
		append emissiveArray emissiveFloatThree
		local emissivePos = (RTWCas_GetPointerPosition casFile)
		
		local specularFloatOne = ReadFloat casFile
		local specularFloatTwo = ReadFloat casFile
		local specularFloatThree = ReadFloat casFile
		append specularArray specularFloatOne
		append specularArray specularFloatTwo
		append specularArray specularFloatThree
		local specularPos = (RTWCas_GetPointerPosition casFile)
		
		specularHighlight = ReadFloat casFile
		local specularHighlightPos = (RTWCas_GetPointerPosition casFile)
		
		backfaceCulling = ReadByte casFile
		local backfaceCullingPos = (RTWCas_GetPointerPosition casFile)
		
		if(writeLog == true) then
		(
			format "%\t\t\t\t\t\t\t\t\t\t\t\t\t# texture flag \t\t\t\t\t\t\t\t%\n" textureFlag textureFlagPos to:logFile
			format "%\t\t\t\t\t\t\t\t\t\t\t\t\t# byte 0 or 1 (indicates embedded TGA) \t\t%\n" embeddedTga embeddedTgaPos to:logFile
			format "%\t\t\t\t\t\t\t\t\t\t# texturename ending with null (0) byte \t\t%\n" textureName textureNamePos to:logFile
			format "%\t\t\t\t\t\t\t\t\t\t# opacity float(0.0-1.0) \t\t\t\t\t%\n" (RTWCas_FormatFloatValue opacity 10) opacityPos to:logFile
			format "%\t%\t%\t\t\t\t\t# ambient  floats (0.0-1.0) often all 1.0 \t%\n" (RTWCas_FormatFloatValue ambientFloatOne 6) (RTWCas_FormatFloatValue ambientFloatTwo 6) (RTWCas_FormatFloatValue ambientFloatThree 6) ambientPos to:logFile
			format "%\t%\t%\t\t\t\t\t# diffuse  floats (0.0-1.0) often same value %\n" (RTWCas_FormatFloatValue diffuseFloatOne 6) (RTWCas_FormatFloatValue diffuseFloatTwo 6) (RTWCas_FormatFloatValue diffuseFloatThree 6) diffusePos to:logFile
			format "%\t%\t%\t\t\t\t\t# emissive  floats (0.0-1.0) often all 0 \t%\n" (RTWCas_FormatFloatValue emissiveFloatOne 6) (RTWCas_FormatFloatValue emissiveFloatTwo 6) (RTWCas_FormatFloatValue emissiveFloatThree 6) emissivePos to:logFile
			format "%\t%\t%\t\t\t\t\t# specular  floats (0.0-1.0) often all 0 \t%\n" (RTWCas_FormatFloatValue specularFloatOne 6) (RTWCas_FormatFloatValue specularFloatTwo 6) (RTWCas_FormatFloatValue specularFloatThree 6) specularPos to:logFile
			format "%\t\t\t\t\t\t\t\t\t\t# specular highlight sharpness (0.0 or 25.0) is 25 set if group 5 not 0\t%\n" (RTWCas_FormatFloatValue specularHighlight 10) specularHighlightPos to:logFile
			format "%\t\t\t\t\t\t\t\t\t\t\t\t\t# 1 (backface culling) or 0 (no culling) \t\t%\n" backfaceCulling backfaceCullingPos to:logFile
		)
	)
)

-- Main Texture section for a cas file
struct TEXTUREHEADER
(
	chunkSize, -- long
	chunkTypeId, -- long
	numTextures, -- long
	textures, -- array
	
	function Read casFile logFile casPath =
	(
		textures = #()
		local writeLog = false
		if(logFile != undefined) then
		(
			writeLog = true
		)
		chunkSize = ReadLong casFile
		chunkTypeId = ReadLong casFile
		if(writeLog == true) then
		(
			format "%  %\t\t\t\t\t\t\t\t\t\t\t\t# chunksize, chunktypeid \t\t\t\t\t%\n" chunkSize chunkTypeId (RTWCas_GetPointerPosition casFile) to:logFile
		)
		numTextures = ReadLong casFile
		if(writeLog == true) then
		(
			format "%\t\t\t\t\t\t\t\t\t\t\t\t\t# number of textures \t\t\t\t\t\t%\n" numTextures (RTWCas_GetPointerPosition casFile) to:logFile
		)
		
		if(writeLog == true) then
		(
			format " # ------------------------------------------------------------------- \n" to:logFile
		)
		
		-- Get texture chunks
		for t=1 to numTextures do
		(
			curTexture = TEXTURECHUNK textureIndex:(t-1)
			curTexture.Read casFile logFile casPath
			append textures curTexture
			if(curTexture.texturePath != undefined) then
			(
				-- Create new material with this bitmap
				tm = bitMapTexture()
				tm.filename = curTexture.texturePath
				mat = getMeditMaterial t
				local materialName = substituteString curTexture.textureName "textures\\" "" 
				if(mat != undefined and mat.name == materialName) then
				(
					mat.diffuseMap=tm
				) else
				(
					mat = standardMaterial diffuseMap:tm
					mat.name = materialName
				)
				
				-- New, also check opacity
				if(curTexture.opacity > 0.0) then
				(
					tm.alphasource = 2 -- None (Opaque for default texture)
					alphaBm = bitMapTexture()
					alphaBm.filename = curTexture.texturePath
					alphaBm.monoOutput = 1
					mat.opacityMap = alphaBm
					mat.diffuseMap=tm
				)
				
				try (showTextureMap mat tm on) catch ()
				setMeditMaterial t mat
				format "Loaded texture ID=% with name:%\n" curTexture.textureIndex curTexture.texturePath
			)
			if(writeLog == true) then
			(
				format " # -------------------------  End texture group\t\t%\t----------------------------  %\n" (t-1) (RTWCas_GetPointerPosition casFile) to:logFile
			)
		)
	)
)

-- GLOBALS
global CasHeaderInstance = CASHEADER 0

-- RTW Cas upgraded version from Dagovax
utility RTWCasTools "RTW Cas Tools"
(
	group "Info:"
	(
		label titleLabel1 "RTW CAS Tools"
		label titleLabel2 "v1.5" color:(color 0 20 80)
		label empt " "
		label titleLabel3 "Use this tool to import" color:(color 0 180 50)
		label titleLabel4 "or export .CAS files." color:(color 0 180 50)
		HyperLink author "by Sirrianus Dagovax" align:#center address:"mailto:dagovax@gmail.com" color:(color 0 0 170) hoverColor:(color 170 0 0)
	)
	
	group "Skeleton"
	(
		label clingLabel1 "Click on the 'Grasp' button"
		label clingLabel2 "to copy current model's"
		label clingLabel3 "bone positions into memory"
		groupBox clingLine1 width: 130 height:2
		button saveBoneState "Grasp" width:100 tooltip:"Store current relative bone positioning into script's memory. You can then switch to another scene"
		button releaseBoneState "Release" width:100 tooltip:"Release saved relative bone positioning and store them in the bones' properties; these properties are helpfull for correct animation export!"
	)
	
	-- Grasp the current scene and save the bone positions
	on saveBoneState pressed do
	(
		-- First get all bones
		local boneArray = RTWCas_GetBones()
		local isCollada = RTWCas_SceneIsCollada()
		memoryBones = #()
		if(boneArray == undefined or boneArray.count == 0) then
		(
			messageBox "There are no bones in this scene (only Root Bone?)!" title:"Error!"
			return null
		)
		
		for i = 1 to boneArray.count do in coordsys parent
		(
			local b = boneArray[i]
			RTWCas_SetBoneUserParentProperty b true
			
			local oldPos = RTWCas_GetBoneUserParentProperty b
			print oldPos
			append memoryBones oldPos
		)
		
		print "Grasped the current bone positions!"
	)
	
	-- Release the grasped bone state to the current model
	on releaseBoneState pressed do
	(
		if(memoryBones == undefined or memoryBones.count == 0) then
		(
			messageBox "You need to grasp initial bone positions first!\n\nLoad the model without animations and hit 'Grasp'" title:"Error!"
			return null
		)
		
		local boneArray = RTWCas_GetBones()
		local isCollada = RTWCas_SceneIsCollada()
		if(boneArray == undefined or boneArray.count == 0) then
		(
			messageBox "There are no bones in this scene (only Root Bone?)!" title:"Error!"
			return null
		)
		
		if(boneArray.count != memoryBones.count) then
		(
			messageBox "The grasped bone positions {"+ (memoryBones.count as string) +"} differ from the current scene bone count {"+ (boneArray.count as string) +"}!" title:"Error!"
			return null
		)
		
		for i = 1 to boneArray.count do
		(
			local offset = memoryBones[i]
			local propValue = ""
			for p=1 to 3 do
			(
				propValue = propValue + "%" + offset[p] as string
			)
			RTWCas_AddUserProp boneArray[i] "InitialPosition" propValue:propValue
		)
		
		print "Released the grasped bone positions into current scene!"
	)
	
	group "Bone Flags"
	(
		label bsclingLabel1 "Functions below only"
		label bsclingLabel2 "work on currently"
		label bsclingLabel3 "selected bone"
		groupBox bsclingLine1 width:130 height:2
		checkbox bsBoneInputCheckbox "Manual Input" width:130 height:15 checked:false tooltip:"Checking this will only apply buttons below on the name of the entered bone in the textbox below."
		edittext bsBoneInput wdith:130 text:"bone_Magazine" bold:false enabled:false tooltip:"Bone name to be used if above checkbox is ticked."
		groupBox bsclingLine2 width:100 height:2 align:#center
		button bsForcePosition "Force Transform" width:100 tooltip:"For animation export: always includes this bone’s transform position data in the exported .cas file."
		button bsSkipPosition "Skip Transform" width:100 tooltip:"For animation export: excludes this bone’s transform position data from the .cas animation file."
		button bsReset "Reset" width:100 tooltip:"Removes any export flag previously assigned to this bone from this section."
	)
	
	-- On checkbox state change
	on bsBoneInputCheckbox changed state do
	(
		bsBoneInput.enabled = bsBoneInputCheckbox.checked
		if (bsBoneInputCheckbox.checked == true) then
		(
			bsclingLabel3.text = "entered bone"
		) else
		(
			bsclingLabel3.text = "selected bone"
		)
	)
	
	-- Add the ForcePosition flag to selected bone. 
	on bsForcePosition pressed do
	(		
		local editboxText = bsBoneInput.text
		local boner
		if(bsBoneInput.enabled and editboxText != undefined) then
		(
			boner = RTWCas_GetSelectedBoneOrByName boneName:bsBoneInput.text
			if boner == undefined then
			(
				messageBox ("Bone does not exist in scene: " + editboxText)  title:"Error!"
				return null
			)
		) else
		(
			boner = RTWCas_GetSelectedBoneOrByName()
		)
		if(boner == undefined) then
		(
			return null
		)
		
		local selectedBone = boner
		RTWCas_SetBoneForcePosition selectedBone
		return null
	)

	-- Add the SkipPosition flag to selected bone. 
	on bsSkipPosition pressed do
	(		
		local editboxText = bsBoneInput.text
		local boner
		if(bsBoneInput.enabled and editboxText != undefined) then
		(
			boner = RTWCas_GetSelectedBoneOrByName boneName:bsBoneInput.text
			if boner == undefined then
			(
				messageBox ("Bone does not exist in scene: " + editboxText)  title:"Error!"
				return null
			)
		) else
		(
			boner = RTWCas_GetSelectedBoneOrByName()
		)
		if(boner == undefined) then
		(
			return null
		)
		
		local selectedBone = boner
		local setSkipper = RTWCas_SetBoneSkipPosition selectedBone
	)

	-- Reset (remove) both ForcePosition and SkipPosition flags if present
	on bsReset pressed do
	(		
		local editboxText = bsBoneInput.text
		local boner
		if(bsBoneInput.enabled and editboxText != undefined) then
		(
			boner = RTWCas_GetSelectedBoneOrByName boneName:bsBoneInput.text
			if boner == undefined then
			(
				messageBox ("Bone does not exist in scene: " + editboxText)  title:"Error!"
				return null
			)
		) else
		(
			boner = RTWCas_GetSelectedBoneOrByName()
		)
		if(boner == undefined) then
		(
			return null
		)
		
		local selectedBone = boner
		RTWCas_ResetBonePositionFlags selectedBone
	)
	
	global animImportFrameChanged = false
	group "Import"
	(
		checkbox writeImportLogCheckbox "Create import logfile" width:130 height:15 checked:false tooltip:"Checking this will create a .importlog.txt file at the import location."
		button importCAS "Import CAS" width:130 height:30 tooltip:"Import .CAS Mesh"
		label meshImportSection " === MESHES ===" height:15 tooltip:"The first section applies for importing meshes!" align:#center
		label animationImportSection " === ANIMATIONS ===" height:15 tooltip:"The section below only applies for animation import!" align:#center
		radiobuttons importRotationController labels:#("Euler XYZ", "TCB Rotation") width: 140 height:30 tooltip:"Import animation rotation quaternian frames using this controller. Euler XYZ is the newest and most useful when using the 'Curve Editor'"
		button importAnimation "Import Animation" width:130 height:30 tooltip:"Import .CAS Animation"
	)
	
	-- Start CAS mesh import
	on importCAS pressed do
	(
		local importFileName = getOpenFileName types:"CAS (*.cas)|*.cas|"
		if (importFileName == undefined) then
		(
			return null
		)
		
		RTWCas_LogText("Starting Mesh Import...")
		RTWCas_LogText("Reading mesh from file: " + (getFilenameFile importFileName))
		
		local logFileName = (getFilenameFile importFileName) + ".importlog.txt"
		local logFilePath = (getFilenamePath importFileName)
		local logFileImport = logFilePath + logFileName
		local logFile = undefined
		local writeLog = writeImportLogCheckbox.checked
			
		if(writeLog==true) then
		(
			logFile = openFile logFileImport mode:"wt"
			format " # -------------------------\tMesh {%} Imported using [RTW Cas Tool] for 3ds Max by Sirrianus Dagovax\t------------------------- #\n\n" (getFilenameFile importFileName) to:logFile
			RTWCas_LogText("Check the log file for details: " + (logFileImport as string))
		)
		
		local casFile = fopen importFileName "rb"
		
		-- Catch all exceptions and close the files
		try
		(
			-- Read cas header	
			if not (CasHeaderInstance.Read casFile logFile) then return 1
			if(writeLog == true) then
			(
				format " # =========================  End of chunk   ============================  \t\t%\n" (RTWCas_GetPointerPosition casFile) to:logFile
			)
			
			-- Read bone chunk
			boneChunk = BONECHUNK()
			boneChunk.Read casFile logFile
			if(writeLog == true) then
			(
				format " # =========================  End of chunk   ============================  \t\t%\n" (RTWCas_GetPointerPosition casFile) to:logFile
			)
			
			-- Geometry Chunk. Actual meshes
			geometryChunk = GEOMETRYCHUNK()
			geometryChunk.Read casFile logFile
			if(writeLog == true) then
			(
				format " # =========================  End of chunk   ============================  \t\t%\n" (RTWCas_GetPointerPosition casFile) to:logFile
			)
			
			local indicator = ReadShort casFile
			if(writeLog == true) then
			(
				format "%\t\t\t\t\t\t\t\t\t\t\t\t\t# indicator\t\t\t\t\t%\n" indicator (RTWCas_GetPointerPosition casFile) to:logFile
			)
			
			local numMeshGroups = ReadLong casFile
			if(writeLog == true) then
			(
				format "%\t\t\t\t\t\t\t\t\t\t\t\t\t# number of mesh groups (3.2) or other count(<3.2) eg 3.17\t%\n" numMeshGroups (RTWCas_GetPointerPosition casFile) to:logFile
				format " # =========================  End of chunk   ============================  \t\t%\n" (RTWCas_GetPointerPosition casFile) to:logFile
			)
			
			-- Some more chunks based on num of meshgroups above?? Read anyway
			for m=1 to numMeshGroups do
			(
				meshGroupChunk1 = MESHGROUPCHUNK()
				meshGroupChunk1.Read casFile logFile
				if(writeLog == true) then
				(
					format " # =========================  End of chunk   ============================  \t\t%\n" (RTWCas_GetPointerPosition casFile) to:logFile
				)
			)
			
			-- Read the Textures
			textureSectionChunk = TEXTUREHEADER()
			textureSectionChunk.Read casFile logFile importFileName
			if(writeLog == true) then
			(
				format " # =========================  End of chunk   ============================  \t\t%\n" (RTWCas_GetPointerPosition casFile) to:logFile
			)
			
			-- Bind meshes to materials
			for k=1 to geometryChunk.meshArray.count do
			(
				if(geometryChunk.meshArray[k].meshObj != undefined) then
				(
					local textureId = geometryChunk.meshArray[k].meshObj.textureId
					if(textureId != -1) then
					(
						if(geometryChunk.meshArray[k].createdMesh != undefined) then
						(
							geometryChunk.meshArray[k].createdMesh.material = getMeditMaterial (textureId + 1)
						)
					)
				)
			)
			
			-- Close and finish all files used
			if(writeLog == true) then
			(
				format " # +++++++++++++++++++++++++ CAS MESH IMPORT TASK END  ++++++++++++++++++++++++++++ \n" to:logFile
				close logFile
			)
			fclose casFile
		)
		catch
		(
			-- Close
			if(writeLog == true) then
			(
				format " # -------------------------  MESH IMPORT FAILED WITH ERROR  ---------------------------- \n=> %\n" (getCurrentException())  to:logFile
				close logFile
			)
			fclose casFile
			throw()
		)
		redrawViews() 	
		print("Mesh Import -> Completed")
	)
	
	on importAnimation pressed do
	(	
		local importAsEuler = false
		if importRotationController.state == 1 then
		(
			importAsEuler = true
		)
		
		-- Then check if Armature is present, thus rootbone
		local armature = RTWCas_GetRootNode()
		local isCollada = RTWCas_SceneIsCollada()
		
		-- Set parental offset to the bone properties
		-- collect all bones but Armature
		local boneList = RTWCas_GetBones()
		if(boneList == undefined or boneList.count == 0) then
		(
			messageBox "There are no bones in this scene (only Root Bone?)!" title:"Error!"
			return null
		)
		local boneListCount = boneList.count
		-- First reset the model from any previous animation
		for i = 1 to boneListCount do in coordsys parent
		(
			local b = boneList[i]
			deletekeys b.rotation.controller #allKeys
			deletekeys b.position.controller #allKeys
			b.rotation.controller = Euler_XYZ()
			b.position.controller = Position_XYZ()
			RTWCas_SetBoneUserParentProperty b false
			
			local oldPos = RTWCas_GetBoneUserParentProperty b
			b.pos = oldPos
			b.rotation = quat (0.0) (0.0) (0.0)  ( 0.0 ) 
		)
		
		local importFileName = getOpenFileName types:"CAS (*.cas)|*.cas|"
		if (importFileName == undefined) then
		(
			return null
		)
		RTWCas_LogText("Starting Animation Import...")
		RTWCas_LogText("Reading animation from file: " + (getFilenameFile importFileName))
		
		local logFileName = (getFilenameFile importFileName) + ".importlog.txt"
		local logFilePath = (getFilenamePath importFileName)
		local logFileImport = logFilePath + logFileName
		local logFile = undefined
		local writeLog = writeImportLogCheckbox.checked
			
		if(writeLog==true) then
		(
			logFile = openFile logFileImport mode:"wt"
			format " # -------------------------\tAnimation {%} Imported using [RTW Cas Tool] for 3ds Max by Sirrianus Dagovax\t------------------------- #\n\n" (getFilenameFile importFileName) to:logFile
			RTWCas_LogText("Check the log file for details: " + (logFileImport as string))
		)
		
		local casFile = fopen importFileName "rb"
		-- Catch all exceptions and close the files
		try
		(
			-- First get list line so to check later
			fseek casFile 0 #seek_end
			local endOfFile = ftell casFile
			fseek casFile 0 #seek_set			
			
			-- Read first 3 entries
			local numFrames = ReadShort casFile
			if(writeLog == true) then
			(
				format "%\t\t\t\t\t\t\t\t\t\t\t\t\t# self.nframe \t = number of frames as two byte int\t\t%\n" numFrames (RTWCas_GetPointerPosition casFile) to:logFile
			)
			local numBones = ReadShort casFile
			if(writeLog == true) then
			(
				format "%\t\t\t\t\t\t\t\t\t\t\t\t\t# self.nqbones \t = number of bones as two byte int\t\t%\n" numBones (RTWCas_GetPointerPosition casFile) to:logFile
			)
			if(numBones > boneList.count) then
			(
				local errorMessage = ("Number of bones in animation file {" + (numBones as string) + "} exceeds number of bones in this scene {" + (boneList.count as string) + "}!\n\nUnable to import this animation.")
				messageBox errorMessage title:"Error!"
				-- Close and finish all files used
				if(writeLog == true) then
				(
					format " # -------------------------  ANIMATION IMPORT FAILED  ---------------------------- \n" to:logFile
					close logFile
				)
				fclose casFile
				return null
			)
			
			
			local numBonesWithPosition = ReadByte casFile
			if(writeLog == true) then
			(
				format "%\t\t\t\t\t\t\t\t\t\t\t\t\t# self.npbones \t = number of bones as single byte\t\t%\n" numBonesWithPosition (RTWCas_GetPointerPosition casFile) to:logFile
			)
			
			frameRate = 20 -- Set the framerate to 20
			animationRange = interval 1 numFrames
			animImportFrameChanged = true			
			
			-- Read rotation quaternian per frame
			for b in boneList do
			(
				b.rotation.controller = TCB_Rotation()
				b.rotation.controller.rotWindup = true
			)
			local boneVecs = #()
			for k = 1 to numFrames do
			(
				local animSet = #()
				for i=1 to numBones do animate on in coordsys boneList[i].parent
				(					
					local frameRotX = ReadFloat casFile
					local frameRotZ = ReadFloat casFile
					local frameRotY = ReadFloat casFile
					local frameRotW = ReadFloat casFile
					addnewkey boneList[i].rotation.controller k
					
					if(isCollada) then
					(
						at time k boneList[i][3][2].rotation = quat (frameRotX) (frameRotY) (frameRotZ)  ( -frameRotW ) -- animate bone
					)
					else
					(
						at time k boneList[i][3][2].rotation = quat (-frameRotX) (-frameRotY) (frameRotZ)  ( -frameRotW ) -- animate bone
					)
						
					-- write values to the log
					if(writeLog == true) then
					(
						format "\t\t%\t\t%\t\t%\t\t%\t\t# rotation quaternian frame =\t%\t\tbone index = \t\t%\n" (RTWCas_FormatFloatValue frameRotX 5) (RTWCas_FormatFloatValue frameRotZ 5) (RTWCas_FormatFloatValue frameRotY 5) (RTWCas_FormatFloatValue frameRotW 5) (k-1) (i-1) to:logFile
					)
				)
			)
			if(importAsEuler == true) then
			(
				for b in boneList do
				(
					b.rotation.controller = Euler_XYZ()
				)
			)
			if(writeLog == true) then
			(
				format " # -------------------------  End quats   ----------------------------  \t\t%\n" (RTWCas_GetPointerPosition casFile) to:logFile
			)
			
			-- Read all position data. We can't animate that yet!
			local bonePos = #()
			for i = 1 to numFrames do
			(
				for k = 1 to numBonesWithPosition do
				(
					local relPosX = ReadFloat casFile
					local relPosY = ReadFloat casFile
					local relPosZ = ReadFloat casFile
					
					-- write values to the log
					if(writeLog == true) then
					(
						format "\t\t%\t\t%\t\t%\t\t# position xyz(bone idx refer to bottom of file) frame =\t%\t\tbone index = \t\t%\n" (RTWCas_FormatFloatValue relPosX 5) (RTWCas_FormatFloatValue relPosY 5) (RTWCas_FormatFloatValue relPosZ 5)  (i-1) (k-1) to:logFile
					)
					append bonePos (point3 (relPosX) (relPosY) (relPosZ))
				)
			)
			if(writeLog == true) then
			(
				format " # -------------------------  End frame pos   ----------------------------  \t\t%\n" (RTWCas_GetPointerPosition casFile) to:logFile
			)
			
			-- Doubled xyz incements
			local ulim = ( numFrames - 1 ) / 2
			for i=1 to ulim do
			(
				local val1 = ReadFloat casFile
				local val2 = ReadFloat casFile
				local val3 = ReadFloat casFile
				if(writeLog == true) then
				(
					format "\t\t%\t\t%\t\t%\t\t# doubled xyz increments\t\t\t\t%\n" (RTWCas_FormatFloatValue val1 5) (RTWCas_FormatFloatValue val2 5) (RTWCas_FormatFloatValue val3 5)  (i-1) to:logFile
				)
			)
			if(writeLog == true) then
			(
				format " # -------------------------  End doubled xyz increments  ----------------------------  \t\t%\n" (RTWCas_GetPointerPosition casFile) to:logFile
			)

			-- Doubled distance values
			local doubleDistanceValue = ""
			for i = 1 to ulim do
			(
				local theFloat = ReadFloat casFile
				if(writeLog == true) then
				(
					format "\t\t%\t\t\t\t\t\t\t\t\t\t# doubled distance values\t\t\t\t%\n" (RTWCas_FormatFloatValue theFloat 5)  (i-1) to:logFile
				)
				doubleDistanceValue = doubleDistanceValue + "%" + theFloat as string
			)
			setUserProp armature "mysteryfloats" doubleDistanceValue	
			if(writeLog == true) then
			(
				format " # -------------------------  End doubled distance vals  ----------------------------  \t\t%\n" (RTWCas_GetPointerPosition casFile) to:logFile
			)
			
			-- Read Control Bone Position, and animate first bone
			local originalPos = RTWCas_GetBoneUserParentProperty boneList[1]
			local originalPosX = originalPos[1]
			local originalPosY = originalPos[3] -- Y in max is Z in RTW
			local originalPosZ = originalPos[2] -- Z in max is Y in RTW
			for k=1 to numFrames do animate on in coordsys world
			(
				local rootPosX = ReadFloat casFile
				local rootPosY = ReadFloat casFile
				local rootPosZ = ReadFloat casFile
				local tmpPos = point3 (originalPosX + rootPosX) (originalPosY + rootPosY) (originalPosZ + rootPosZ)
				at time (k) boneList[1].position = RTWCas_RTWToMaxVector (tmpPos) isCollada
				
				if(writeLog == true) then
				(
					format "\t\t%\t\t%\t\t%\t\t# control bone position xyz at frame =\t%\n" (RTWCas_FormatFloatValue rootPosX 5) (RTWCas_FormatFloatValue rootPosY 5) (RTWCas_FormatFloatValue rootPosZ 5)  (k-1) to:logFile
				)
			)
			if(writeLog == true) then
			(
				format " # -------------------------  End control bone position  ----------------------------  \t\t%\n" (RTWCas_GetPointerPosition casFile) to:logFile
			)
			
			-- Read the 8 mysterious floats
			local rTime = ReadFloat casFile
			local rZxvecdist = ReadFloat casFile
			local rXDiff = ReadFloat casFile
			local rYDiff = ReadFloat casFile
			local rZDiff = ReadFloat casFile
			local rAvDistSeconds = ReadFloat casFile
			local rTenths = ReadFloat casFile
			local rAfterFrames = ReadFloat casFile
			if(writeLog == true) then
			(
				format "\t\t%\t\t%\t\t%\t\t%\t\t%\t\t%\t\t%\t\t%\t\t#\t time, xzvecdist, xdiff, ydiff, zdiff, avdistseconds, then tenths, then after 21 frames, 0\n" (RTWCas_FormatFloatValue rTime 5) (RTWCas_FormatFloatValue rZxvecdist 5) (RTWCas_FormatFloatValue rXDiff 5) (RTWCas_FormatFloatValue rYDiff 5) (RTWCas_FormatFloatValue rZDiff 5) (RTWCas_FormatFloatValue rAvDistSeconds 5) (RTWCas_FormatFloatValue rTenths 5) (RTWCas_FormatFloatValue rAfterFrames 5)to:logFile
				format " # -------------------------  End positions last bit almost movements  ----------------------------  \t\t%\n" (RTWCas_GetPointerPosition casFile) to:logFile
			)
			local eightFloats = rTime as string + "%" + rZxvecdist as string + "%" + rXDiff as string + "%" + rYDiff as string + "%" + rZDiff as string + "%" + rAvDistSeconds as string + "%" + rTenths as string + "%" + rAfterFrames as string
			setUserProp armature "eightfloats" eightFloats
			
			-- Read all bones if they have position anims
			local enableAnimPos = #()
			local minCounter = 0
			local allBonesPositions = ""
			while not (ftell casFile == endOfFile) do
			(
				local nextByte = ReadByte(casFile) #unsigned
				local byteString = RTWCas_ReverseString(RTWCas_IntToBinary(nextByte))
					
				if(writeLog == true) then
				(
					format "%  %  %  %  %  %  %  %\t\t\t\t\t\t\t\t\t # bit bone positions (%-% switched for ease of reading) \t\t%\n" byteString[1] byteString[2] byteString[3] byteString[4] byteString[5] byteString[6] byteString[7] byteString[8] minCounter (minCounter + 7) (RTWCas_GetPointerPosition casFile) to:logFile
				)
				minCounter = minCounter + 8
				append allBonesPositions byteString
			)
			if(writeLog == true) then
			(
				format " # -------------------------  End bone position enablers (end of animation read)  ----------------------------  \t\t%\n" (RTWCas_GetPointerPosition casFile) to:logFile
			)
			
			bonesPositionEnabled = #()
			for i = 1 to numBones do
			(
				if(allBonesPositions[i] == "1") then
				(
					if(boneList[i] != undefined) then
					(
						append bonesPositionEnabled boneList[i]
					)
				)
			)
			
			-- Something bad! animation import fails
			if(bonesPositionEnabled.count != numBonesWithPosition) then
			(
				local errorMessage = ("Animation file broken: number of bones with position at end of file {" + (bonesPositionEnabled.count as string) + "} does not match the third float {" + (numBonesWithPosition as string) + "}!")
				messageBox (errorMessage + "\n\nOnly the first occurences will be animated now!") title:"Warning!"
				if(writeLog == true) then
				(
					format "WARNING =>\t\t%\n" errorMessage to:logFile
				)
				if(numBonesWithPosition == 1 and allBonesPositions[1] == "0") then
				(
					local oneBoneMessage = ("Because animation file is broken, it tells that the first bone does not have positioning enabled, yet it only has one bone with positioning!\n\nDo you want to apply the positioning the first bone?")
					if (queryBox oneBoneMessage beep:true) then
					(
						bonesPositionEnabled = #()
						append bonesPositionEnabled boneList[1]
					)
				)
			)
			if(writeLog == true) then
			(
				format "\tList of bones that have position animation enabled:\n" to:logFile
				local counter = 1
				for b in bonesPositionEnabled do
				(
					if(counter <= numBonesWithPosition) then
					(
						format "\t >  %\n" b.name to:logFile
					) else
					(
						format "\t >  %\t ( IGNORED )\n" b.name to:logFile
					)
					counter += 1
				)
			)

			local posCounter = 1
			for k = 1 to numFrames do animate on coordsys parent
			(
				local boneIndex = 1
				for i = 1 to numBonesWithPosition do
				(
					local relRTWPos = bonePos[posCounter]
					local newPosX = relRTWPos[1]
					local newPosY = relRTWPos[2]
					local newPosZ = relRTWPos[3]

					-- We do something different for the root bone (relative stuff)
					if(i == 0) then -- TODO: Dagovax disabled this whole section for root bone because it failed!!
					(
						local oldPos = RTWCas_GetBoneUserParentProperty bonesPositionEnabled[i]
						local originalPosX = oldPos[1]
						local originalPosY = oldPos[3] -- Y in max is Z in RTW
						local originalPosZ = (at time (k-1) bonesPositionEnabled[i].position)[2] -- Z in max is Y in RTW
						if(k == 1) then
						(
							originalPosZ = oldPos[2]
						)
						local tmpPos = point3 0.0 0.0 0.0
						
						local calcPosX = originalPosX
						local calcPosZ = originalPosZ
						if(isCollada) then
						(
							calcPosX = originalPosX + newPosX
							calcPosZ = originalPosZ + newPosZ
						)
						else
						(
							calcPosX = originalPosX - newPosX
							calcPosZ = originalPosZ - newPosZ
						)
						
						if(isCollada) then
						(
							tmpPos = point3 (originalPosX + newPosX) (originalPosY + newPosY) calcPosZ	
						)
						else
						(
							tmpPos = point3 -calcPosX (originalPosY + newPosY) -calcPosZ
						)
						--print tmpPos
						at time (k) bonesPositionEnabled[i].position = RTWCas_RTWToMaxVector (tmpPos) isCollada
					)
					
					-- All other bones seems to be absolute offset from the parent
					if(i != 1) then
					(
						local tmpPos = point3 (newPosX) (newPosY) (newPosZ)
						at time (k) bonesPositionEnabled[i].position = RTWCas_RTWToMaxVector (tmpPos) isCollada
					)
					posCounter = posCounter + 1
					boneIndex = boneIndex + 1
				)
			)
			
			-- Close and finish all files used
			if(writeLog == true) then
			(
				format " # -------------------------  ANIMATION IMPORT TASK END  ---------------------------- \n" to:logFile
				close logFile
			)
			fclose casFile
		)
		catch
		(
			-- Close
			if(writeLog == true) then
			(
				format " # -------------------------  ANIMATION IMPORT FAILED WITH ERROR  ---------------------------- \n=> %\n" (getCurrentException())  to:logFile
				close logFile
			)
			fclose casFile
			throw()
		)
		redrawViews() 	
		print("Animation Import -> Completed")
	)
	
	group "Export"
	(		
		checkbox writeLogCheckbox "Create export logfile" width:130 height:15 checked:false tooltip:"Checking this will create a .exportlog.txt file at the export location."
		checkbox noTranslations "Force no translations" width:130 height:15 checked:false tooltip:"If checked, any bone with bone translation will be ignored for positioning export. Except first bone!"
		label meshExportSection " === MESHES ===" height:15 tooltip:"The first section applies for exporting meshes!" align:#center
		label animationExportSection " === ANIMATIONS ===" height:15 tooltip:"The section below only applies for animation export!" align:#center
		spinner startFrame "Start Frame:" range:(RTWCas_GetStartFrame()) type:#integer tooltip:"Set the start frame for animation to export" align:#center width:75 scale:1
		spinner endFrame "End Frame:" range:(RTWCas_GetEndFrame()) type:#integer tooltip:"Set the end frame for animation to export" align:#center width:75 scale:1
		button syncFrames "Sync" width:30 height:40 offset:[57,-43] tooltip:"Sync the spinners with active scene animation range"
		checkbox inversedQuaternian "Inverse Quaternian" width:130 height:15 checked:false tooltip:"Inverse quaternian rotation by multiplying it by -1."
		checkbox autoConvertTCB "Convert to TCB" width:130 height:15 checked:false tooltip:"Checking this will convert Euler XYZ Rotation controller to TCB Rotation"
		button exportAnimation "Export Animation" width:130 height:30 tooltip:"Export .CAS Animation"
	)
	
	on syncFrames pressed do
	(
		startFrame.range = RTWCas_GetStartFrame()
		endFrame.range = RTWCas_GetEndFrame()
	)
	
	on exportAnimation pressed do
	(		
		-- Check if Armature is present, thus rootbone
		local armature = RTWCas_GetRootNode()
		if(armature == undefined) then
		(
			messageBox "There is no root node in this scene!" title:"Error!"
			return null
		)
		local isCollada = RTWCas_SceneIsCollada()
		
		-- Set parental offset to the bone properties
		-- collect all bones but Armature
		local boneList = RTWCas_GetBones()
		if(boneList == undefined or boneList.count == 0) then
		(
			messageBox "There are no bones in this scene (only Root Bone?)!" title:"Error!"
			return null
		)
		
		if((animationRange.start > startFrame.value as integer) or (animationRange.end < endFrame.value)) then
		(
			if(animImportFrameChanged == true) then
			(
				startFrame.range = RTWCas_GetStartFrame()
				endFrame.range = RTWCas_GetEndFrame()
				animImportFrameChanged = false
			) else
			(
				messageBox "You need to Sync the animation frame start and end first!" title:"Error!"
				return null
			)
		)
		
		local firstBoneTempChecker = RTWCas_GetBoneUserParentProperty boneList[1] -- HACK, simply gives warning if Grasp/Release tool was not used (or InitialPos not set in bone properties)		
		
		local numFrames = 1 + (endFrame.value - startFrame.value)
		if(mod numFrames 2 == 0) then
		(
			messageBox "Rome requires an odd count of frames for the unpacked format. The last frame will be dropped!" title:"Warning!"
			numFrames = numFrames - 1
		)
		
		-- First we need to set it to TCB_Rotation for each bone!
		local convertionCounter = 0
		if(autoConvertTCB.checked) do
		(
			for b in boneList do
			(
				local result = RTWCAS_EulerToQuat b numFrames
				if(result == true) then
				(
					convertionCounter += 1
				)
			)
		)
		if(convertionCounter >= 1) then
		(
			RTWCas_LogText("Converted {"+ (convertionCounter as string) +"} rotation controllers from Euler_XYZ to TCB controller!")
		)
		
		local frameStart = startFrame.value as integer
		local frameEnd = frameStart + (numFrames-1)
		
		local sceneName = ""
		if(maxFileName != "") then
		(
			sceneName = maxFileName
			local sceneNameCount = sceneName.count
			sceneNameCount += 1
			local maxSectionIndex = findString sceneName ".max"
			local sceneNameLength = sceneNameCount - maxSectionIndex
			sceneName = RTWCas_ReplaceSpaceWithUnderscore (replace sceneName maxSectionIndex sceneNameLength "")
		)
		
		local exportFileName = getSaveFileName types:"CAS (*.cas)|*.cas|" filename:(toLower sceneName)
		
		if (exportFileName == undefined) then
		(
			return null
		)
		
		RTWCas_LogText("Starting Animation Export...")
		RTWCas_LogText("Writing animation to file: " + (getFilenameFile exportFileName))
		
		local logFileName = (getFilenameFile exportFileName) + ".exportlog.txt"
		local logFilePath = (getFilenamePath exportFileName)
		local logFileExport = logFilePath + logFileName
		local logFile = undefined
		local writeLog = writeLogCheckbox.checked
		
		local forceNoTranslation = noTranslations.checked
			
		if(writeLog==true) then
		(
			logFile = openFile logFileExport mode:"wt"
			format " # -------------------------\tAnimation {%} Exported using [RTW Cas Tool] for 3ds Max by Sirrianus Dagovax\t------------------------- #\n\n" (getFilenameFile exportFileName) to:logFile
			RTWCas_LogText("Check the log file for details: " + (logFileExport as string))
		)
			
		local casFile = fopen exportFileName "wb"
		-- Catch all exceptions and close the files
		try
		(
			frameRate = 20 -- Set the framerate to 20
				
			local numBones = boneList.count		
			local numBonesWithPosition = RTWCas_GetNumBonesWithPosition boneList frameStart frameEnd forceNoTranslation
			
			-- Write first 3 entries
			WriteShort casFile numframes
			if(writeLog == true) then
			(
				format "%\t\t\t\t\t\t\t\t\t\t\t\t\t# self.nframe \t = number of frames as two byte int\t\t%\n" numFrames (RTWCas_GetPointerPosition casFile) to:logFile
			)
			WriteShort casFile numBones
			if(writeLog == true) then
			(
				format "%\t\t\t\t\t\t\t\t\t\t\t\t\t# self.nqbones \t = number of bones as two byte int\t\t%\n" numBones (RTWCas_GetPointerPosition casFile) to:logFile
			)
			WriteByte casFile numBonesWithPosition
			if(writeLog == true) then
			(
				format "%\t\t\t\t\t\t\t\t\t\t\t\t\t# self.npbones \t = number of bones as single byte\t\t%\n" numBonesWithPosition (RTWCas_GetPointerPosition casFile) to:logFile
			)
			
			-- Write rotation quaternian per frame
			local rotCounter = 0
			local prevQuat = for i = 1 to numBones collect (quat 0 0 0 1)
			for k=frameStart to frameEnd do
			(				
				rotCounter += 1
				for i=1 to numBones do in coordsys boneList[i].parent
				(
					local quaternian = at time k -boneList[i][3][2].rotation
					
					-- Ensure consistent quaternion sign with previous frame
					if rotCounter > 1 do
					(
						local prev = prevQuat[i]
						if (RTWCas_QuatDot quaternian prev < 0) do
							quaternian = -quaternian
					)
					
					-- Store current quaternion for next frame
					prevQuat[i] = quaternian
					
					-- Then continue with rounding and processing
					local frameRotX = RTWCas_RoundFloat quaternian.x 5
					local frameRotZ = RTWCas_RoundFloat quaternian.z 5
					local frameRotY = RTWCas_RoundFloat quaternian.y 5
					local frameRotW = RTWCas_RoundFloat -quaternian.w 5
					
					if(isCollada == false) then
					(
						frameRotX = frameRotX*-1
						frameRotY = frameRotY*-1
					)
					
					if inversedQuaternian.checked or classof boneList[i][3][2].rotation.controller == TCB_rotation then
					(
						frameRotX = frameRotX * -1
						frameRotZ = frameRotZ * -1
						frameRotY = frameRotY * -1
						frameRotW = frameRotW * -1
					)
					
					-- Write floats to the cas file
					WriteFloat casFile frameRotX
					WriteFloat casFile frameRotZ
					WriteFloat casFile frameRotY
					WriteFloat casFile frameRotW
					
					-- write values to the log
					if(writeLog == true) then
					(
						format "\t\t%\t\t%\t\t%\t\t%\t\t# rotation quaternian frame =\t%\t\tbone index = \t\t%\n" (RTWCas_FormatFloatValue frameRotX 5) (RTWCas_FormatFloatValue frameRotZ 5) (RTWCas_FormatFloatValue frameRotY 5) (RTWCas_FormatFloatValue frameRotW 5) (rotCounter-1) (i-1) to:logFile
					)
				)
			)
			-- Convert rotation controller back to Euler_XYZ (for every bone!)
			if(convertionCounter >= 1) then
			(
				for b in boneList do
				(
					b.rotation.controller = Euler_XYZ()
				)
			)
			if(writeLog == true) then
			(
				format " # -------------------------  End quats   ----------------------------  \t\t%\n" (RTWCas_GetPointerPosition casFile) to:logFile
			)
			
			-- Write bone positioning
			local bonesWithPosition = #()
			for i=1 to numBones do
			(
				if ((RTWCas_BoneHasPositionController boneList[i] frameStart frameEnd forceNoTranslation) == true) then
				(
					append bonesWithPosition boneList[i]
				)
			)				
			
			local frameCounter = 0
			for k=frameStart to frameEnd do
			(
				frameCounter += 1
				for i=1 to numBonesWithPosition do in coordsys bonesWithPosition[i].parent
				(
					local diffPos = null						
					local framePosX = (at time k bonesWithPosition[i].position)[1]
					local framePosY = (at time k bonesWithPosition[i].position)[3]
					local framePosZ = (at time k bonesWithPosition[i].position)[2]
					
					-- We do something different for the root bone (relative stuff)
					if(i == 1) then
					(
						local rootPos = RTWCas_GetBoneUserParentProperty bonesWithPosition[i] -- original root bone pos at frame 0
						local oldPos = (at time (k-1) bonesWithPosition[i].position)
						local originalPosX = oldPos[1]
						local originalPosY = rootPos[3] -- Z in max is Y in RTW (height. Absolute offset from the ground (zero))
						local originalPosZ = oldPos[2] 
						if(k == 1) then
						(
							originalPosZ = oldPos[2]
						)
						
						diffPos = point3 (framePosX - originalPosX) (framePosY - originalPosY) (framePosZ - originalPosZ)
					) else
					(
						-- All other bones seems to be absolute offset from the parent
						diffPos = point3 (framePosX) (framePosY) (framePosZ)
					)					
					
					if(isCollada == false) then
					(
						diffPos.x = diffPos.x * -1
						diffPos.z = diffPos.z * -1
					)
					
					RTWCas_WriteVector casFile diffPos
					
					-- write values to the log
					if(writeLog == true) then
					(
						format "\t\t%\t\t%\t\t%\t\t# position xyz(bone idx refer to bottom of file) frame =\t%\t\tbone index = \t\t%\n" (RTWCas_FormatFloatValue diffPos.x 5) (RTWCas_FormatFloatValue diffPos.y 5) (RTWCas_FormatFloatValue diffPos.z 5)  (frameCounter-1) (i-1) to:logFile
					)
				)
			)
			if(writeLog == true) then
			(
				format " # -------------------------  End frame pos   ----------------------------  \t\t%\n" (RTWCas_GetPointerPosition casFile) to:logFile
			)
			
			-- Doubled xyz incements
			local doubleCounter = 0
			for i=frameStart to ((frameEnd-1)) by 2 do
			(
				local transit = RTWCas_MaxToRTWvector( (at time (i+2) in coordsys world boneList[1].pos)  - (at time i in coordsys world boneList[1].pos) ) isCollada
				RTWCas_WriteVector casFile transit
				if(writeLog == true) then
				(
					format "\t\t%\t\t%\t\t%\t\t# doubled xyz increments\t\t\t\t%\n" (RTWCas_FormatFloatValue transit.x 5) (RTWCas_FormatFloatValue transit.y 5) (RTWCas_FormatFloatValue transit.z 5)  doubleCounter to:logFile
				)
				doubleCounter = doubleCounter + 1
			)
			if(writeLog == true) then
			(
				format " # -------------------------  End doubled xyz increments  ----------------------------  \t\t%\n" (RTWCas_GetPointerPosition casFile) to:logFile
			)
			
			-- Total X offset from frame 1 to end frame 
			local wXDiff = 0.0
			if(numFrames > 1) then
			(
				wXDiff = ((at time frameEnd in coordsys world boneList[1].pos)[1] - (at time 1 in coordsys world boneList[1].pos)[1])
			)
			if(isCollada == false) then
			(
				wXDiff = wXDiff * -1
			)
			
			-- Total Y offset from frame 1 to end frame 
			local wYDiff = 0.0
			if(numFrames > 1) then
			(
				wYDiff = ((at time frameEnd in coordsys world boneList[1].pos)[3] - (at time 1 in coordsys world boneList[1].pos)[3])
			)
			
			-- Total Z offset from frame 1 to end frame
			local wZDiff = 0.0
			if(numFrames > 1) then
			(
				wZDiff = ((at time frameEnd in coordsys world boneList[1].pos)[2] - (at time 1 in coordsys world boneList[1].pos)[2])
			)
			if(isCollada == false) then
			(
				wZDiff = wZDiff * -1
			)
			
			-- 2D distance on the XZ plane (horizontal displacement) xzvecdist=sqrt(xdiff 2 +zdiff 2))
			local wZxvecdist = sqrt(wXDiff^2 + wZDiff^2)
			
			-- Doubled distance vals
			local doubleDistanceCounter = 0
			local halfFrameCount = ((numFrames-1)/2)
			local totalDistAccum = 0.0
			
			for k=1 to halfFrameCount do
			(
				local idx1 = (k - 1) * 2 + 1
				local idx2 = idx1 + 2
				
				local vecx = at time idx1 in coordsys world boneList[1].pos[1]
				local vecz = at time idx1 in coordsys world boneList[1].pos[2]
				local dist = sqrt(vecx * vecx + vecz * vecz)
				    
				-- Compute valremain
				local doubleDistance = wZxvecdist - dist
				if doubleDistance < 0.0 then 
				(
					doubleDistance = 0.0
				)
				WriteFloat casFile doubleDistance
				if(writeLog == true) then
 				(
 					format "\t\t%\t\t\t\t\t\t\t\t\t\t# doubled distance values\t\t\t\t%\n" (RTWCas_FormatFloatValue doubleDistance 5)  doubleDistanceCounter to:logFile
 				)
				
				doubleDistanceCounter += 1
			)
			
-- 			for k=frameStart to (halfFrameCount-1) by 2 do
-- 			(
-- 				local xEnd = at time (k+1) in coordsys world boneList[1].pos[1]
-- 				local xStart = at time k in coordsys world boneList[1].pos[1]
-- 				local zEnd = at time (k+1) in coordsys world boneList[1].pos[2]
-- 				local zStart = at time k in coordsys world boneList[1].pos[2]
-- 				
-- 				
-- 				local xDiff = xEnd - xStart
-- 				local zDiff = zEnd - zStart
-- 				if(isCollada == false) then
-- 				(
-- 					xDiff = xDiff * -1
-- 					zDiff = zDiff * -1
-- 				)
-- 				
-- 				local vectorDist = sqrt(xDiff^2 + zDiff^2)
-- 				totalDistAccum += vectorDist
-- 				local doubleDistance = wZxvecdist - totalDistAccum
-- 				WriteFloat casFile doubleDistance
-- 				if(writeLog == true) then
-- 				(
-- 					format "\t\t%\t\t\t\t\t\t\t\t\t\t# doubled distance values\t\t\t\t% \n" (RTWCas_FormatFloatValue doubleDistance 5)  doubleDistanceCounter to:logFile
-- 				)
-- 				--RTWCas_LogText("double distance for: frame " + (logFileExport as string))
-- 				format "double distance for: frame % to % | xEnd % - xStart % = xDiff % | zEnd % - zStart % = zDiff % || vectorDist = %\n" k (k+2) xEnd xStart xDiff zEnd zStart zDiff vectorDist
-- 				
-- 				doubleDistanceCounter += 1
-- 			)
			
			
			
-- 			for k=frameEnd to frameStart by -2 do
-- 			(
-- 				if(k > 1) then
-- 				(
-- 					local doubleDistance = (at time k in coordsys world boneList[1].pos)[2]
-- 					if(isCollada == false) then
-- 					(
-- 						doubleDistance = doubleDistance * -1
-- 					)
-- 					WriteFloat casFile doubleDistance
-- 					if(writeLog == true) then
-- 					(
-- 						format "\t\t%\t\t\t\t\t\t\t\t\t\t# doubled distance values\t\t\t\t%\n" (RTWCas_FormatFloatValue doubleDistance 5)  doubleDistanceCounter to:logFile
-- 					)
-- 					doubleDistanceCounter += 1
-- 				)
-- 			)
			
			if(writeLog == true) then
			(
				format " # -------------------------  End doubled distance vals  ----------------------------  \t\t%\n" (RTWCas_GetPointerPosition casFile) to:logFile
			)
			
			-- Write control bone position
			--print("Adding control bone position to root bone " + boneList[1].name)
			local oldPos = RTWCas_GetBoneUserParentProperty boneList[1]
			local oldRootPos = RTWCas_MaxToRTWVector(oldPos) isCollada
			local controlPosCounter = 0
			for k=frameStart to frameEnd do
			(
				controlPosCounter += 1
				local newRootPos = RTWCas_MaxToRTWVector(at time k in coordsys parent boneList[1].pos) isCollada
				local posDifference = newRootPos - oldRootPos
				RTWCas_WriteVector casFile posDifference
				if(writeLog == true) then
				(
					format "\t\t%\t\t%\t\t%\t\t# control bone position xyz at frame =\t%\n" (RTWCas_FormatFloatValue posDifference.x 5) (RTWCas_FormatFloatValue posDifference.y 5) (RTWCas_FormatFloatValue posDifference.z 5)  (controlPosCounter-1) to:logFile
				)
			)
			if(writeLog == true) then
			(
				format " # -------------------------  End control bone position  ----------------------------  \t\t%\n" (RTWCas_GetPointerPosition casFile) to:logFile
			)
			
			-- Write the 8 floats about anim stuff
			-- First value is Time in seconds the whole anim is playing
			local wTime = 0.0
			if(numFrames > 1) then
			(
				wTime = ((numFrames-1) as float / 20 as float)	
			)		
			
			-- Average distance traveled in seconds
			local wAvDistSeconds = 0.0 
			if(wTime > 0.0) then -- Stop zero devision exception
			(
				wAvDistSeconds = (wZxvecdist / wTime)
			)
			
			-- Average distance in thenths of seconds
			local wTenths = (wAvDistSeconds / 10 as float)
			
			-- Average Distance per frame (val_2 / (Val_1 + 0.05) / 20)
			local wAvgFrames = (wZxvecdist / (wTime + 0.05) / 20)
	
			
			-- Now write all the floats!
			WriteFloat casFile wTime
			WriteFloat casFile wZxvecdist
			WriteFloat casFile wXDiff
			WriteFloat casFile wYDiff
			WriteFloat casFile wZDiff
			WriteFloat casFile wAvDistSeconds
			WriteFloat casFile wTenths
			WriteFloat casFile wAvgFrames
			
			if(writeLog == true) then
			(
				format "\t\t%\t\t%\t\t%\t\t%\t\t%\t\t%\t\t%\t\t%\t\t#\t time, xzvecdist, xdiff, ydiff, zdiff, avdistseconds, then tenths, then after 21 frames, 0\n" (RTWCas_FormatFloatValue (wTime as Float) 5) (RTWCas_FormatFloatValue (wZxvecdist as Float)  5) (RTWCas_FormatFloatValue (wXDiff as Float)  5) (RTWCas_FormatFloatValue (wYDiff as Float)  5) (RTWCas_FormatFloatValue (wZDiff as Float)  5) (RTWCas_FormatFloatValue (wAvDistSeconds as Float)  5) (RTWCas_FormatFloatValue (wTenths as Float)  5) (RTWCas_FormatFloatValue (wAvgFrames as Float)  5)to:logFile
				format " # -------------------------  End positions last bit almost movements  ----------------------------  \t\t%\n" (RTWCas_GetPointerPosition casFile) to:logFile
			)
			
			-- Write bit bone positions
			local bitBonePositions = #()
			for b = 0 to 63 do
			(
				if(boneList[b+1] != undefined) then
				(
					if ((RTWCas_BoneHasPositionController boneList[b+1] frameStart frameEnd forceNoTranslation) == true) then
					(
						append bitBonePositions 1
					) else
					(
						append bitBonePositions 0
					)
				) else
				(
					append bitBonePositions 0
				)
			)
			--print bitBonePositions as string
			if(bitBonePositions.count == 64) then
			(
				local outPutString = ""
				local bitArr = #()
				local minCounter = 0
				for p=0 to 63 do
				(
					local bitPos = bitBonePositions[p+1]
					append bitArr bitPos
					outPutString = outPutString + bitPos as string
					if(p == 7 or p == 15 or p == 23 or p == 31 or p == 39 or p == 47 or p == 55 or p == 63) then
					(
						local bitString = RTWCas_ReverseString(outPutString)
						local resultInt = (RTWCas_BinaryToInt(bitString))
						WriteByte casFile resultInt #unsigned
						if (writeLog == true) then
						(
							format "%  %  %  %  %  %  %  %\t\t\t\t\t\t\t\t\t # bit bone positions (%-% switched for ease of reading) \t\t%\n" bitArr[1] bitArr[2] bitArr[3] bitArr[4] bitArr[5] bitArr[6] bitArr[7] bitArr[8] minCounter p (RTWCas_GetPointerPosition casFile) to:logFile
						)
						bitArr = #()
						outPutString = ""
						minCounter = minCounter + 8
					)
				)
			) else -- fallback. Only first bone can position!
			(
				WriteLong casFile 1
				WriteLong casFile 0
			)
			if(writeLog == true) then
			(
				format " # -------------------------  End bone position enablers (end of animation write)  ----------------------------  \t\t%\n" (RTWCas_GetPointerPosition casFile) to:logFile
			)
			
			if(writeLog == true) then
			(
				format "\tList of bones that have position animation enabled:\n" to:logFile
				for b in bonesWithPosition do
				(
					format "\t >  %\n" b.name to:logFile
				)
			)
			
			-- Close
			if(writeLog == true) then
			(
				format " # -------------------------  ANIMATION EXPORT TASK END  ---------------------------- \n" to:logFile
				close logFile
			)
			fclose casFile
			graspWarning = false
		)
		catch 
		(
			-- Close
			if(writeLog == true) then
			(
				format " # -------------------------  ANIMATION EXPORT FAILED WITH ERROR  ---------------------------- \n=> %\n" (getCurrentException())  to:logFile
				close logFile
			)
			fclose casFile
			graspWarning = false
			throw()
			--format "*** % ***\n%\n" (getCurrentException()) (getCurrentExceptionCallStack())
		)
		print("Animation Export -> Completed")
	)
	
	global casAnimationRange = #() -- whole animation range
	global casAnimationFrames = #() -- whole animation frames copy/paste
	global casAnimationFrameData = #() -- single frame copy/paste
	group "Animations"
	(
		checkbox onlyCurrentFrameCheckBox "Current frame only" width:130 height:15 checked:false tooltip:"Only paste copied animation at the exact current frame. Note that if you have already an animation, it will probably glitch a bit."
		button copyFrame "Copy Frame" width:130 height:30 tooltip:"Copies the current frame's position and rotation for every bone in the scene into memory. Can even be copied among multiple scenes!"
		button pasteFrame "Paste Frame" width:130 height:30 tooltip:"Pastes the saved position and rotation from previously copied memory into current time frame for every bone."
		groupBox animationClingLine1 width: 130 height:2
		button syncBoneFrame "Sync Bone" width:130 height:30 tooltip:"Sync a bone to current selected object. Each frame in current animation of the selected object will be synced in world coordination to the bone."
	)
	
	-- Copy a frame
	on copyFrame pressed do
	(
		local isCollada = RTWCas_SceneIsCollada()
		
		-- Collect all bones but Armature
		local boneList = RTWCas_GetBones()
		if(boneList == undefined or boneList.count == 0) then
		(
			messageBox "There are no bones in this scene (only Armature / Scene Root?)!" title:"Error!"
			return null
		)
		
		casAnimationFrameData = #() -- reset array
		
		append casAnimationFrameData boneList.count -- first array item is bone list count
		
		-- Get the current frame in the animation range
		local currentFrame = int(currentTime.frame)

		for k=currentFrame to currentFrame do in coordsys parent -- single for loop!
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
			append casAnimationFrameData frameArray
		)

		print("Copied animation for frame " + currentFrame as string + "!")
	)
	
	-- Paste a frame
	on pasteFrame pressed do
	(
		local isCollada = RTWCas_SceneIsCollada() -- need to do something with this later!
		
		-- Collect all bones but Armature
		local boneList = RTWCas_GetBones()
		if(boneList == undefined or boneList.count == 0) then
		(
			messageBox "There are no bones in this scene (only Armature / Scene Root?)!" title:"Error!"
			return null
		)
		
		if(casAnimationFrameData == undefined or casAnimationFrameData.count != 2) then
		(
			messageBox "You need to 'Copy Frame' from another animation first!" title:"Error!"
			return null
		)
		
		local numBones = casAnimationFrameData[1]
		local frameArray = casAnimationFrameData[2]
		
		-- Number of saved bones differ from current bones in the scene!
		if(numBones != boneList.count) then
		(
			local boneDifferMessage = ("Number of bones in copied animation {" + (numBones as string) + "} differs from number of bones in this scene {" + (boneList.count as string) + "}!\n\nContinue anyway?")
			if ((queryBox boneDifferMessage beep:true) == false) then
			(
				messageBox "Animation copy failed!" title:"Error!"
				return null
			)
		)
		
		local saveBonePos = #()
		for b=1 to boneList.count do
		(
			local pos = at time 1 boneList[b].position
			append saveBonePos pos
		)
		
		-- Get the current frame in the animation range
		local currentFrame = int(currentTime.frame)
		
		if(onlyCurrentFrameCheckBox.checked) then
		(
			for k=currentFrame to currentFrame do animate on in coordsys parent
			(
				for b=1 to numBones do
				(
					local posArray = frameArray[b]
					at time k boneList[b].rotation = posArray[1]
					at time k boneList[b].position = posArray[2]
				)
			)
		)
		else -- No animate on, only set positions + rotation at current time (will apply to all frames then)
		(
			for k=currentFrame to currentFrame do in coordsys parent
			(
				for b=1 to numBones do
				(
					local posArray = frameArray[b]
					boneList[b].rotation = posArray[1]
					boneList[b].position = posArray[2]
				)
			)
		)
	)
	
	-- Sync bone in world coord position + rotation to selected object
	on syncBoneFrame pressed do
	(
		global syncBoneArray = RTWCas_GetBones()
		if (syncBoneArray.count == 0) then
		(
			messageBox "There are no bones in this scene!" title:"Error!"
			return null
		)
		
		local selected = for t in selection collect t
		if(selected == undefined or selected.count == 0) then
		(
			messageBox "You need to select an object! Without it we can not sync a bone" title:"Error!"
			return null
		)
		if(selected.count > 1) then
		(
			messageBox "We need a single object! You selected multiple objects" title:"Error!"
			return null
		)
		global selectedSyncObj = selected[1]
		global syncBoneNameArray = for i in syncBoneArray collect i.name	
		
		rollout dialog_selBone "Select a bone from the list"
		(
			label syncBoneObjLabelDialog1 "Select the bone you want to sync to" 
			label syncBoneObjLabelDialog2 ""
			dropdownlist syncBoneObjBoneList "" align:#center items:syncBoneNameArray
			button syncBoneObjContinue "Continue" width:130 height:30
			
			-- Change label text dynamically
			on dialog_selBone open do
			(
				syncBoneObjLabelDialog2.text = ("' "+ selectedSyncObj.name +" '")
			)
			
			-- Continue button pressed
			on syncBoneObjContinue pressed do
			(
				local selectedBone = (for b in syncBoneArray where (b.name == syncBoneObjBoneList.selected) collect b)[1]
				if(selectedBone == undefined) then
				(
					messageBox "The selected bone is invalid" title:"Error!"
					return false
				)
				try (destroydialog dialog_selBone) catch() -- kill dialog
				print ("User selected bone: " + selectedBone.name)
				
				local numFrames = 1 + (animationRange.end - animationRange.start)
				
				local continueMessage = ("Continue overwriting any existing animation keys for bone '" + selectedBone.name + "'?\n For a total of {" + (numFrames as string) + "} frames, we will copy all position and rotation from object '"+ selectedSyncObj.name + "'\n\nContinue?")
				if ((queryBox continueMessage beep:true) == false) then
				(
					return false
				)
				
				-- First reset the model from any previous animation
				deletekeys selectedBone.rotation.controller #allKeys
				deletekeys selectedBone.position.controller #allKeys
				
				print("Sync Bone to Object -> Started")
				for k = 1 to numFrames do animate on in coordsys world
				(
					at time (k) selectedBone.rotation = at time (k) selectedSyncObj.rotation
					at time (k) selectedBone.position = at time (k) selectedSyncObj.position
				)
				redrawViews()
				
				print("Sync Bone to Object -> Completed!")
			)
		)
		createDialog dialog_selBone 210 100
		
	)
)