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
----------------------------------------------------------

global useLog = true

function RoundFloat val dp = --rounds a float to a set number of decimal places
(
	a = val * (10^dp)
	b = a as integer
	a = b as float / (10^dp)
	return a
)

function ReverseString inString = (
	outstring = ""
	for i = 1 to inString.count do
	(
		outstring = inString[i] + outstring
	)
	return outstring
)

function BinaryToInt inBinary =
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

function IntToBinary inInt = 
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

function FormatFloatValue val zeroes = 
(
	tempzeros = "000000000000"
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

function LogText logString = 
(
	if(logString != undefined) then
	(
		if(useLog == true) then
		(
			print logString as string	
		)
	)
)

-- Check if input bone has valid position controller
function BoneHasPositionController boneIdx frameCount =
(
	if(boneIdx == undefined) then
	(
		return false
	)
	local intialPos = GetBoneUserParentProperty boneIdx
	if(intialPos != undefined) then
	(
		for k = 1 to frameCount do
		(
			local framePos = at time (k) in coordsys boneIdx.parent boneIdx.pos
			local differenceX = FormatFloatValue (framePos.x - intialPos[1]) 1
			local differenceY = FormatFloatValue (framePos.y - intialPos[2]) 1
			local differenceZ = FormatFloatValue (framePos.z - intialPos[3]) 1
			if(differenceX as string != " 0.0" or differenceY as string != " 0.0" or differenceZ as string != " 0.0") then
			(
				return true
			)
		)
	)
	
	for k = 2 to frameCount do
	(
		local previousPos = at time (k-1) in coordsys boneIdx.parent boneIdx.pos
		local currentPos = at time (k) in coordsys boneIdx.parent boneIdx.pos
		local differenceX = FormatFloatValue (currentPos.x - previousPos.x) 1
		local differenceY = FormatFloatValue (currentPos.y - previousPos.y) 1
		local differenceZ = FormatFloatValue (currentPos.z - previousPos.z) 1
		if(differenceX as string != " 0.0" or differenceY as string != " 0.0" or differenceZ as string != " 0.0") then
		(
			return true
		)
	)
	return false
)

-- Return count of bones that have a valid position controller
function GetNumBonesWithPosition boneList frameCount =
(
	if(boneList == undefined) then
	(
		return 1 -- we always need 1 bone.. Root bone has position
	)
	local counter = 0
	for b in boneList do
	(
		if ((BoneHasPositionController b frameCount) == true) then
		(
			counter = counter + 1
		)
	)
	if(counter == 0) then
	(
		return 1 -- we always need 1 bone.. Root bone has position
	)
	return counter
)

function GetPointerPosition inputFileStream =
(
	if(inputFileStream == undefined) then
	(
		return "\t\t at position = \t\t-1"
	)
	return ("\t\t at position = \t\t" + (ftell inputFileStream) as string)
)

--convert coord sys RTW x = x; RTW z = y; RTW y = z
function MaxToRTWVector inxyz isCollada =
(
	if(isCollada) then
	(
		return (point3 inxyz.x inxyz.z inxyz.y)
	)
	return (point3 -inxyz.x inxyz.z -inxyz.y)
)

--convert coord sys max x = x; max y = z; max z = y
function RTWToMaxVector inxyz isCollada =
(
	if(isCollada) then
	(
		return (point3 inxyz.x inxyz.z inxyz.y)
	)
	return (point3 -inxyz.x -inxyz.z inxyz.y)
)

-- Writes a RTW vector to the .cas file. Always 3 floats
function WriteVector fp outVec =
(
	WriteFloat fp outVec.x
	WriteFloat fp outVec.y
	WriteFloat fp outVec.z
)

-- Set the original parent offset
function SetBoneUserParentProperty boner =
(
	if(boner == undefined) then
	(
		return null
	)
	local initialPosition = getUserProp boner "InitialPosition"
	if initialPosition != undefined then
	(
		return null
	)
	local offset = in coordsys parent boner.pos
	local propValue = ""
	for i = 1 to 3 do
	(
		propValue = propValue + "%" + offset[i] as string
	)
	setUserProp boner "InitialPosition" propValue
)

-- Get the original parent offset
function GetBoneUserParentProperty boner =
(
	if(boner == undefined) then
	(
		return null
	)
	local initialPosition = getUserProp boner "InitialPosition"
	if initialPosition != undefined then
	(
		local offset = filterString initialPosition "%"
		return point3 (offset[1] as float) (offset[2] as float) (offset[3] as float)
	)
	if(boner.parent != undefined) then
	(
		return at time 0 in coordsys parent boner.pos	
	)
	return at time 0 boner.pos
)

-- RTW Cas upgraded version from Dagovax
utility RTWCasTools "RTW Cas Tools"
(
	group "Info:"
	(
		label titleLabel1 "RTW CAS Tools"
		label titleLabel2 "v1.0" color:(color 0 20 80)
		label empt " "
		label titleLabel3 "Use this tool to import" color:(color 0 180 50)
		label titleLabel4 "or export .CAS files." color:(color 0 180 50)
		HyperLink author "by Sirrianus Dagovax" align:#center address:"mailto:dagovax@gmail.com" color:(color 0 0 170) hoverColor:(color 170 0 0)
	)
	label fillerLabel1 " "
	
	group "Import"
	(
		checkbox writeImportLogCheckbox "Create import logfile" width:130 height:15 checked:false
		button importAnimation "Import Animation" width:130 height:30
	)
	
	on importAnimation pressed do
	(
		-- First get all bones
		local isCollada = true
		local dummies = for t in objects where (classOf t == Dummy) collect t
		local pointers = for t in objects where (classOf t == Point) collect t
		if (dummies == undefined or dummies.count == 0) then
		(
			if(pointers == undefined or pointers.count == 0) then
			(
				messageBox "There are no bones in this scene!" title:"Error!"
				return null	
			)
		)
		
		-- Then check if Armature is present, thust rootbone
		local armature = getNodeByName "Armature" exact:true
		if (armature == undefined) then 
		(			
			armature = getNodeByName "Scene_Root" exact:true
			if(armature == undefined) then
			(
				armature = getNodeByName "Scene Root" exact:true
				if(armature == undefined) then
				(
					messageBox "There is no Armature or Scene Root root bone!" title:"Error!"
					return null
				)
			)
			isCollada = false
		)
		
		-- Set parental offset to the bone properties
		-- collect all bones but Armature
		local boneList = #()
		if(isCollada) then
		(
			boneList = for b in objects where (classOf b == Dummy and b.name != armature.name) collect b
		) 
		else
		(
			boneList = for b in objects where (classOf b == Point and b.name != armature.name) collect b
		)
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
			SetBoneUserParentProperty b
			
			local oldPos = GetBoneUserParentProperty b
			b.pos = oldPos
			b.rotation = quat (0.0) (0.0) (0.0)  ( 0.0 ) 
		)
		
		local importFileName = getOpenFileName types:"CAS (*.cas)|*.cas|"
		if (importFileName == undefined) then
		(
			return null
		)
		LogText("Starting Animation Import...")
		LogText("Reading animation from file: " + (getFilenameFile importFileName))
		
		local logFileName = (getFilenameFile importFileName) + ".importlog.txt"
		local logFilePath = (getFilenamePath importFileName)
		local logFileImport = logFilePath + logFileName
		local logFile = undefined
		local writeLog = writeImportLogCheckbox.checked
			
		if(writeLog==true) then
		(
			logFile = openFile logFileImport mode:"wt"
			format " # -------------------------\tAnimation {%} Imported using [RTW Cas Tool] for 3ds Max by Sirrianus Dagovax\t------------------------- #\n\n" (getFilenameFile importFileName) to:logFile
			LogText("Check the log file for details: " + (logFileImport as string))
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
				format "%\t\t\t\t\t\t\t\t\t\t\t\t\t# self.nframe \t = number of frames as two byte int\t\t%\n" numFrames (GetPointerPosition casFile) to:logFile
			)
			local numBones = ReadShort casFile
			if(writeLog == true) then
			(
				format "%\t\t\t\t\t\t\t\t\t\t\t\t\t# self.nqbones \t = number of bones as two byte int\t\t%\n" numBones (GetPointerPosition casFile) to:logFile
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
				format "%\t\t\t\t\t\t\t\t\t\t\t\t\t# self.npbones \t = number of bones as single byte\t\t%\n" numBonesWithPosition (GetPointerPosition casFile) to:logFile
			)
			
			frameRate = 20 -- Set the framerate to 20
			animationRange = interval 1 numFrames
			
			-- Read rotation quaternian per frame
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
						format "\t\t%\t\t%\t\t%\t\t%\t\t# rotation quaternian frame =\t%\t\tbone index = \t\t%\n" (FormatFloatValue frameRotX 5) (FormatFloatValue frameRotZ 5) (FormatFloatValue frameRotY 5) (FormatFloatValue frameRotW 5) (k-1) (i-1) to:logFile
					)
				)
			)
			if(writeLog == true) then
			(
				format " # -------------------------  End quats   ----------------------------  \t\t%\n" (GetPointerPosition casFile) to:logFile
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
						format "\t\t%\t\t%\t\t%\t\t# position xyz(bone idx refer to bottom of file) frame =\t%\t\tbone index = \t\t%\n" (FormatFloatValue relPosX 5) (FormatFloatValue relPosY 5) (FormatFloatValue relPosZ 5)  (i-1) (k-1) to:logFile
					)
					append bonePos (point3 (relPosX) (relPosY) (relPosZ))
				)
			)
			if(writeLog == true) then
			(
				format " # -------------------------  End frame pos   ----------------------------  \t\t%\n" (GetPointerPosition casFile) to:logFile
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
					format "\t\t%\t\t%\t\t%\t\t# doubled xyz increments\t\t\t\t%\n" (FormatFloatValue val1 5) (FormatFloatValue val2 5) (FormatFloatValue val3 5)  (i-1) to:logFile
				)
			)
			if(writeLog == true) then
			(
				format " # -------------------------  End doubled xyz increments  ----------------------------  \t\t%\n" (GetPointerPosition casFile) to:logFile
			)

			-- Doubled distance values
			local doubleDistanceValue = ""
			for i = 1 to ulim do
			(
				local theFloat = ReadFloat casFile
				if(writeLog == true) then
				(
					format "\t\t%\t\t\t\t\t\t\t\t\t\t# doubled distance values\t\t\t\t%\n" (FormatFloatValue theFloat 5)  (i-1) to:logFile
				)
				doubleDistanceValue = doubleDistanceValue + "%" + theFloat as string
			)
			setUserProp armature "mysteryfloats" doubleDistanceValue	
			if(writeLog == true) then
			(
				format " # -------------------------  End doubled distance vals  ----------------------------  \t\t%\n" (GetPointerPosition casFile) to:logFile
			)
			
			-- Read Control Bone Position, and animate first bone
			local originalPos = GetBoneUserParentProperty boneList[1]
			local originalPosX = originalPos[1]
			local originalPosY = originalPos[3] -- Y in max is Z in RTW
			local originalPosZ = originalPos[2] -- Z in max is Y in RTW
			for k=1 to numFrames do animate on in coordsys world
			(
				local rootPosX = ReadFloat casFile
				local rootPosY = ReadFloat casFile
				local rootPosZ = ReadFloat casFile
				local tmpPos = point3 (originalPosX + rootPosX) (originalPosY + rootPosY) (originalPosZ + rootPosZ)
				at time (k) boneList[1].position = RTWToMaxVector (tmpPos) isCollada
				
				if(writeLog == true) then
				(
					format "\t\t%\t\t%\t\t%\t\t# control bone position xyz at frame =\t%\n" (FormatFloatValue rootPosX 5) (FormatFloatValue rootPosY 5) (FormatFloatValue rootPosZ 5)  (k-1) to:logFile
				)
			)
			if(writeLog == true) then
			(
				format " # -------------------------  End control bone position  ----------------------------  \t\t%\n" (GetPointerPosition casFile) to:logFile
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
				format "\t\t%\t\t%\t\t%\t\t%\t\t%\t\t%\t\t%\t\t%\t\t#\t time, xzvecdist, xdiff, ydiff, zdiff, avdistseconds, then tenths, then after 21 frames, 0\n" (FormatFloatValue rTime 5) (FormatFloatValue rZxvecdist 5) (FormatFloatValue rXDiff 5) (FormatFloatValue rYDiff 5) (FormatFloatValue rZDiff 5) (FormatFloatValue rAvDistSeconds 5) (FormatFloatValue rTenths 5) (FormatFloatValue rAfterFrames 5)to:logFile
				format " # -------------------------  End positions last bit almost movements  ----------------------------  \t\t%\n" (GetPointerPosition casFile) to:logFile
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
				local byteString = ReverseString(IntToBinary(nextByte))
					
				if(writeLog == true) then
				(
					format "%  %  %  %  %  %  %  %\t\t\t\t\t\t\t\t\t # bit bone positions (%-% switched for ease of reading) \t\t%\n" byteString[1] byteString[2] byteString[3] byteString[4] byteString[5] byteString[6] byteString[7] byteString[8] minCounter (minCounter + 7) (GetPointerPosition casFile) to:logFile
				)
				minCounter = minCounter + 8
				append allBonesPositions byteString
			)
			if(writeLog == true) then
			(
				format " # -------------------------  End bone position enablers (end of animation read)  ----------------------------  \t\t%\n" (GetPointerPosition casFile) to:logFile
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
				messageBox "Animation import failed: {bonesPositionEnabled.count != numBonesWithPosition}!" title:"Error!"
				if(writeLog == true) then
				(
					format "\nERROR :>\t\t%\n" "Animation import failed: {bonesPositionEnabled.count != numBonesWithPosition}!" to:logFile
				)
			) else
			(
				if(writeLog == true) then
				(
					format "\tList of bones that have position animation enabled:\n" to:logFile
					for b in bonesPositionEnabled do
					(
						format "\t >  %\n" b.name to:logFile
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
						if(i == 1) then
						(
							local oldPos = GetBoneUserParentProperty bonesPositionEnabled[i]
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
							at time (k) bonesPositionEnabled[i].position = RTWToMaxVector (tmpPos) isCollada
						)
						
						-- All other bones seems to be absolute offset from the parent
						if(i != 1) then
						(
							local tmpPos = point3 (newPosX) (newPosY) (newPosZ)
							at time (k) bonesPositionEnabled[i].position = RTWToMaxVector (tmpPos) isCollada
						)
						posCounter = posCounter + 1
						boneIndex = boneIndex + 1
					)
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
		checkbox writeLogCheckbox "Create export logfile" width:130 height:15 checked:false
		button exportAnimation "Export Animation" width:130 height:30
	)
	
	on exportAnimation pressed do
	(
		-- First get all bones
		local isCollada = true
		local dummies = for t in objects where (classOf t == Dummy) collect t
		local pointers = for t in objects where (classOf t == Point) collect t
		if (dummies == undefined or dummies.count == 0) then
		(
			if(pointers == undefined or pointers.count == 0) then
			(
				messageBox "There are no bones in this scene!" title:"Error!"
				return null	
			)
		)
		
		-- Then check if Armature is present, thust rootbone
		local armature = getNodeByName "Armature" exact:true
		if (armature == undefined) then 
		(			
			armature = getNodeByName "Scene_Root" exact:true
			if(armature == undefined) then
			(
				armature = getNodeByName "Scene Root" exact:true
				if(armature == undefined) then
				(
					messageBox "There is no Armature or Scene Root root bone!" title:"Error!"
					return null
				)
			)
			isCollada = false
		)
		
		-- collect all bones but Armature
		local boneList = #()
		if(isCollada) then
		(
			boneList = for b in objects where (classOf b == Dummy and b.name != armature.name) collect b
		) 
		else
		(
			boneList = for b in objects where (classOf b == Point and b.name != armature.name) collect b
		)
		if(boneList == undefined or boneList.count == 0) then
		(
			messageBox "There are no bones in this scene (only Root Bone?)!" title:"Error!"
			return null
		)
		
		local numFrames = 1 + (animationRange.end - animationRange.start)
		if(mod numFrames 2 == 0) then
		(
			messageBox "Rome requires an odd count of frames for the unpacked format. The last frame will be dropped!" title:"Warning!"
			numFrames = numFrames - 1
		)
		
		local exportFileName = getSaveFileName types:"CAS (*.cas)|*.cas|"
		
		if (exportFileName == undefined) then
		(
			return null
		)
		
		LogText("Starting Animation Export...")
		LogText("Writing animation to file: " + (getFilenameFile exportFileName))
		
		local logFileName = (getFilenameFile exportFileName) + ".exportlog.txt"
		local logFilePath = (getFilenamePath exportFileName)
		local logFileExport = logFilePath + logFileName
		local logFile = undefined
		local writeLog = writeLogCheckbox.checked
		
		if(writeLog==true) then
		(
			logFile = openFile logFileExport mode:"wt"
			format " # -------------------------\tAnimation {%} Exported using [RTW Cas Tool] for 3ds Max by Sirrianus Dagovax\t------------------------- #\n\n" (getFilenameFile exportFileName) to:logFile
			LogText("Check the log file for details: " + (logFileExport as string))
		)
			
		local casFile = fopen exportFileName "wb"
		-- Catch all exceptions and close the files
		try
		(
			frameRate = 20 -- Set the framerate to 20
				
			local numBones = boneList.count		
			local numBonesWithPosition = GetNumBonesWithPosition boneList numFrames
			
			-- Write first 3 entries
			WriteShort casFile numframes
			if(writeLog == true) then
			(
				format "%\t\t\t\t\t\t\t\t\t\t\t\t\t# self.nframe \t = number of frames as two byte int\t\t%\n" numFrames (GetPointerPosition casFile) to:logFile
			)
			WriteShort casFile numBones
			if(writeLog == true) then
			(
				format "%\t\t\t\t\t\t\t\t\t\t\t\t\t# self.nqbones \t = number of bones as two byte int\t\t%\n" numBones (GetPointerPosition casFile) to:logFile
			)
			WriteByte casFile numBonesWithPosition
			if(writeLog == true) then
			(
				format "%\t\t\t\t\t\t\t\t\t\t\t\t\t# self.npbones \t = number of bones as single byte\t\t%\n" numBonesWithPosition (GetPointerPosition casFile) to:logFile
			)

			-- Write rotation quaternian per frame
			for k = 1 to numFrames do
			(
				for i=1 to numBones do in coordsys boneList[i].parent
				(
					local frameRotX = RoundFloat (at time k -boneList[i][3][2].rotation.x) 5
					local frameRotZ = RoundFloat(at time k -boneList[i][3][2].rotation.z) 5
					local frameRotY = RoundFloat(at time k -boneList[i][3][2].rotation.y) 5
					local frameRotW = RoundFloat(at time k boneList[i][3][2].rotation.w) 5
					
					if(isCollada == false) then
					(
						frameRotX = frameRotX*-1
						frameRotY = frameRotY*-1
					)
					
					
					-- Write floats to the cas file
					WriteFloat casFile frameRotX
					WriteFloat casFile frameRotZ
					WriteFloat casFile frameRotY
					WriteFloat casFile frameRotW
					
					-- write values to the log
					if(writeLog == true) then
					(
						format "\t\t%\t\t%\t\t%\t\t%\t\t# rotation quaternian frame =\t%\t\tbone index = \t\t%\n" (FormatFloatValue frameRotX 5) (FormatFloatValue frameRotZ 5) (FormatFloatValue frameRotY 5) (FormatFloatValue frameRotW 5) (k-1) (i-1) to:logFile
					)
				)
			)
			if(writeLog == true) then
			(
				format " # -------------------------  End quats   ----------------------------  \t\t%\n" (GetPointerPosition casFile) to:logFile
			)
			
			-- Write bone positioning
			local bonesWithPosition = #()
			for i=1 to numBones do
			(
				if ((BoneHasPositionController boneList[i] numFrames) == true) then
				(
					append bonesWithPosition boneList[i]
				)
			)				
			
			for k=1 to numFrames do
			(
				for i=1 to numBonesWithPosition do in coordsys bonesWithPosition[i].parent
				(
					local diffPos = null						
					local framePosX = (at time k bonesWithPosition[i].position)[1]
					local framePosY = (at time k bonesWithPosition[i].position)[3]
					local framePosZ = (at time k bonesWithPosition[i].position)[2]
					
					-- We do something different for the root bone (relative stuff)
					if(i == 1) then
					(
						local oldPos = GetBoneUserParentProperty bonesWithPosition[i] -- original root bone pos at frame 0
						local originalPosX = oldPos[1]
						local originalPosY = oldPos[3] -- Y in max is Z in RTW
						local originalPosZ = (at time (k-1) bonesWithPosition[i].position)[2] 
						if(k == 1) then
						(
							originalPosZ = oldPos[2]
						)
						
						diffPos = point3 (framePosX - originalPosX) (framePosY - originalPosY) (framePosZ - originalPosZ)
					)
						
					-- All other bones seems to be absolute offset from the parent
					if(i != 1) then
					(
						diffPos = point3 (framePosX) (framePosY) (framePosZ)
						--local tmpPos = point3 (newPosX) (newPosY) (newPosZ)
						--at time (k) bonesPositionEnabled[i].position = RTWToMaxVector (tmpPos)
					)
					
					if(isCollada == false) then
					(
						diffPos.x = diffPos.x * -1
						diffPos.z = diffPos.z * -1
					)
					
					WriteVector casFile diffPos
					
					-- write values to the log
					if(writeLog == true) then
					(
						format "\t\t%\t\t%\t\t%\t\t# position xyz(bone idx refer to bottom of file) frame =\t%\t\tbone index = \t\t%\n" (FormatFloatValue diffPos.x 5) (FormatFloatValue diffPos.y 5) (FormatFloatValue diffPos.z 5)  (k-1) (i-1) to:logFile
					)
				)
			)
			if(writeLog == true) then
			(
				format " # -------------------------  End frame pos   ----------------------------  \t\t%\n" (GetPointerPosition casFile) to:logFile
			)
			
			-- Doubled xyz incements
			local doubleCounter = 0
			for i=1 to ((numframes-1)) by 2 do
			(
				local transit = MaxToRTWvector( (at time (i+2) in coordsys world boneList[1].pos)  - (at time i in coordsys world boneList[1].pos) ) isCollada
				WriteVector casFile transit
				if(writeLog == true) then
				(
					format "\t\t%\t\t%\t\t%\t\t# doubled xyz increments\t\t\t\t%\n" (FormatFloatValue transit.x 5) (FormatFloatValue transit.y 5) (FormatFloatValue transit.z 5)  doubleCounter to:logFile
				)
				doubleCounter = doubleCounter + 1
			)
			if(writeLog == true) then
			(
				format " # -------------------------  End doubled xyz increments  ----------------------------  \t\t%\n" (GetPointerPosition casFile) to:logFile
			)
			
			-- Doubled distance vals
			local doubleDistanceCounter = 0
			local ulim = ((numFrames-1)/2)
			for k=ulim to 1 by -1 do
			(
				local frameTest = k*2
				local frameZ = (at time frameTest in coordsys world boneList[1].pos)[2]
				local frameZA = (at time (frameTest-1) in coordsys world boneList[1].pos)[2]
				local diffZ = frameZ - frameZA
				local doubleDistance = (frameZ + (diffZ/2))
				if(isCollada == false) then
				(
					doubleDistance = doubleDistance * -1
				)
				WriteFloat casFile doubleDistance
				if(writeLog == true) then
				(
					format "\t\t%\t\t\t\t\t\t\t\t\t\t# doubled distance values\t\t\t\t%\n" (FormatFloatValue doubleDistance 5)  doubleDistanceCounter to:logFile
				)
				doubleDistanceCounter += 1
			)
			if(writeLog == true) then
			(
				format " # -------------------------  End doubled distance vals  ----------------------------  \t\t%\n" (GetPointerPosition casFile) to:logFile
			)
			
			-- Write control bone position
			print("Adding control bone position to root bone " + boneList[1].name)
			local oldRootPos = MaxToRTWVector(at time 0 in coordsys parent boneList[1].pos) isCollada
			for k=1 to numFrames do
			(
				local newRootPos = MaxToRTWVector(at time k in coordsys parent boneList[1].pos) isCollada
				local posDifference = newRootPos - oldRootPos
				WriteVector casFile posDifference
				if(writeLog == true) then
				(
					format "\t\t%\t\t%\t\t%\t\t# control bone position xyz at frame =\t%\n" (FormatFloatValue posDifference.x 5) (FormatFloatValue posDifference.y 5) (FormatFloatValue posDifference.z 5)  (k-1) to:logFile
				)
			)
			if(writeLog == true) then
			(
				format " # -------------------------  End control bone position  ----------------------------  \t\t%\n" (GetPointerPosition casFile) to:logFile
			)
			
			-- Write the 8 floats about anim stuff
			-- First value is Time in seconds the whole anim is playing
			local wTime = 0.0
			if(numFrames > 1) then
			(
				wTime = ((numFrames-1) as float / 20 as float)	
			)
			WriteFloat casFile wTime
			-- Not sure about this value, but seems to be same as Z difference
			local wZxvecdist = 0.0
			if(numFrames > 1) then
			(
				wZxvecdist = ((at time numFrames in coordsys world boneList[1].pos)[2] - (at time 1 in coordsys world boneList[1].pos)[2])
			)
			if(isCollada == false) then
			(
				wZxvecdist = wZxvecdist * -1
			)
			WriteFloat casFile wZxvecdist
			-- Total X offset from frame 1 to end frame 
			local wXDiff = 0.0
			if(numFrames > 1) then
			(
				wXDiff = ((at time numFrames in coordsys world boneList[1].pos)[1] - (at time 1 in coordsys world boneList[1].pos)[1])
			)
			if(isCollada == false) then
			(
				wXDiff = wXDiff * -1
			)
			WriteFloat casFile wXDiff
			
			-- Total Y offset from frame 1 to end frame 
			local wYDiff = 0.0
			if(numFrames > 1) then
			(
				wYDiff = ((at time numFrames in coordsys world boneList[1].pos)[3] - (at time 1 in coordsys world boneList[1].pos)[3])
			)
			WriteFloat casFile wYDiff
			
			-- Total Z offset from frame 1 to end frame
			local wZDiff = wZxvecdist
			WriteFloat casFile wZDiff
			
			-- Average distance traveled in seconds
			local wAvDistSeconds = 0.0 
			if(wTime > 0.0) then -- Stop zero devision exception
			(
				wAvDistSeconds = (wZDiff / wTime)
			)
			WriteFloat casFile wAvDistSeconds
			
			-- Average distance in thenths of seconds
			local wTenths = (wAvDistSeconds / 10 as float)
			WriteFloat casFile wTenths
			
			-- Average Distance per frame (val_2 / (Val_1 + 0.05) / 20)
			local wAvgFrames = (wZxvecdist / (wTime + 0.05) / 20)
			WriteFloat casFile wAvgFrames
			
			if(writeLog == true) then
			(
				format "\t\t%\t\t%\t\t%\t\t%\t\t%\t\t%\t\t%\t\t%\t\t#\t time, xzvecdist, xdiff, ydiff, zdiff, avdistseconds, then tenths, then after 21 frames, 0\n" (FormatFloatValue (wTime as Float) 5) (FormatFloatValue (wZxvecdist as Float)  5) (FormatFloatValue (wXDiff as Float)  5) (FormatFloatValue (wYDiff as Float)  5) (FormatFloatValue (wZDiff as Float)  5) (FormatFloatValue (wAvDistSeconds as Float)  5) (FormatFloatValue (wTenths as Float)  5) (FormatFloatValue (wAvgFrames as Float)  5)to:logFile
				format " # -------------------------  End positions last bit almost movements  ----------------------------  \t\t%\n" (GetPointerPosition casFile) to:logFile
			)
			
			-- Write bit bone positions
			local bitBonePositions = #()
			for b = 0 to 63 do
			(
				if(boneList[b+1] != undefined) then
				(
					if ((BoneHasPositionController boneList[b+1] numFrames) == true) then
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
						local bitString = ReverseString(outPutString)
						local resultInt = (BinaryToInt(bitString))
						WriteByte casFile resultInt #unsigned
						if (writeLog == true) then
						(
							format "%  %  %  %  %  %  %  %\t\t\t\t\t\t\t\t\t # bit bone positions (%-% switched for ease of reading) \t\t%\n" bitArr[1] bitArr[2] bitArr[3] bitArr[4] bitArr[5] bitArr[6] bitArr[7] bitArr[8] minCounter p (GetPointerPosition casFile) to:logFile
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
				format " # -------------------------  End bone position enablers (end of animation write)  ----------------------------  \t\t%\n" (GetPointerPosition casFile) to:logFile
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
			throw()
			--format "*** % ***\n%\n" (getCurrentException()) (getCurrentExceptionCallStack())
		)
		print("Animation Export -> Completed")
	)
)