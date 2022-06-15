--------------------------------------------------------------
--                                                          --
-- Rome:Total War import/export script for CAS file format  --
-- by Vercingetorix (vercingetorix11@gmail.com)             --
--                                                          --
--------------------------------------------------------------

--------------------------------------------------------------
--Please do not distribute in part or full any code without --
--my permission. If you have found a bug and writtin a fix  --
--please email me so I may include the fix in future release--
--															--
--------------------------------------------------------------
--Current version: 0.79b--
--Last Updated: 4/4/06--
--Notes: cas import in beta  --
--Notes: cas export in beta  --
--Notes: animation in beta   --
--Notes: item import in beta --
--Notes: item export in beta --
--------------------------------------------------------------
--TODO:
--	write a sanity check fn
--	add multires export
--	add ini file (rtw path, texture path for item & cas, multires settings)
--	add dialog box to edit global settings
--	finish loading/exporting animations within .cas files

fn roundFloat val dp =  --rounds a float to a set number of decimal places
(
	a = val * (10^dp)
	b = a as integer
	a = b as float / (10^dp)
	return a
)
fn getPath bLeaveLastSlash inString=(
	lastSlash=0
	outString=""
	for i=1 to inString.count do if(inString[i]=="\\") then lastSlash=i
	if bLeaveLastSlash then lastSlash-=1
	for i=1 to lastSlash do
	outString += inString[i]
	return outString
)
fn checkParentNodeExist nodeParent = (
	if (nodeParent == undefined) then (
		rootBone = getNodeByName "Scene Root"
		if rootBone==undefined then (
			rootBone = getNodeByName "Scene_Root"
			if rootBone==undefined then (
				rootBone = getNodeByName "Armature"
			)
		)
		return rootBone
	) else (
		return nodeParent
	)
)
fn stripExt  inString=(
	lastDot=0
	outString=""
	for i=1 to inString.count do if(inString[i]==".") then lastDot=i
	for i=1 to lastDot-1 do
	outString += inString[i]
	return outString
)
fn getName inString=(
	lastSlash = 0
	outString=""
	for i=1  to inString.count do if(inString[i]=="\\") then lastSlash=i
	for i=lastSlash+1 to inString.count do
	outString += inString[i]
	return outString
)
fn intToBinary inInt = (
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
fn stringToCharArray inString maxLength = (
	newArray = #()
	print ("stringToCharArray: inString = " + inString)
	print ("stringToCharArray: inString.count = " + inString.count as string)
	print ("stringToCharArray: maxLength = " + maxLength as string)
	for i = 1 to inString.count do (
		if i <= maxLength then (
			append newArray inString[i]
		)
	)
	print ("stringToCharArray: newArray.count = " + newArray.count as string)
	return newArray
)
fn reverseString inString = (
	outstring = ""
	for i = 1 to inString.count do(
		outstring = inString[i] + outstring
	)
	return outstring
)
fn uppercase instring = ( 
	local upper, lower, outstring -- 
	upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ" 
	lower="abcdefghijklmnopqrstuvwxyz" 
	outstring=copy instring 
	for i=1 to outstring.count do 
	(
		j=findString lower outstring[i]  
			if (j != undefined) do outstring[i]=upper[j] 
	)
	outstring 
) 
fn padBytes fp num=(
  for i=1 to num do WriteByte fp 0
)
fn WriteVector fp outVec=(
	WriteFloat fp outVec.x
	WriteFloat fp outVec.y
	WriteFloat fp outVec.z
)
struct RTWBonelist ( name, parent, pos,rpos)

fn recursiveHeir rchild blist=(
	numBones=0
	k=1

	if ( findString rchild.name "bone" )!=undefined or ( findString rchild.name "Scene Root" )!=undefined
	then append blist ( RTWBonelist name:rChild.name  )
	if(rchild!=undefinded) then
	while(rChild.children[k]!=undefined ) do (
	numBones+=(recursiveHeir rChild.children[k] bList) +1
	k+=1
	)
	
	return numBones
			
)
struct CASHEADER(
--Start Header--
fileversion,--float, most recent is 3.20 down to 2.14
fileH,
offsetTillNextChunk1,
offsetTillNextChunk2,

	fn Read fp =(
		fileversion	= ReadFloat fp
		if fileVersion<3.05 then ( MessageBox ("Importer has detected that the file you are importing is an older version of the format is is likly to cause problems. ")   title:"Warning" beep:false
								if (queryBox "Continue anyway?")==false then return false
								)
		offsetTillNextChunk1 = ReadLong fp
		fseek fp (offsetTillNextChunk1-4)  #seek_cur -- unkown
		holdpos = ftell fp
		fseek fp 16 #seek_set
		fileH = ReadLong fp
		fseek fp holdpos #seek_set
		offsetTillNextChunk2= ReadLong fp
		fseek fp 4  #seek_cur -- unkown
		return true
	),
	fn Write fp =(
	WriteFloat fp 3.18
	WriteLong fp 38
	WriteLong fp 9
	WriteLong fp 0
	WriteFloat fp 3.3333
	WriteLong fp 1
	WriteLong fp 0
	WriteLong fp 23619688
	PadBytes fp 10
	)
	
)
-- 
--declare it global cuz it's got usefull info--
global GlobalHeader = CASHEADER 0
global MINSUPPORTEDFILEVERSION = 3.12 --what i've tested for
global SceneTextures = #() --holds the textures of the scene that are used
--convert coord sys max x = -x; max y = -z; max z = y
fn rtw2maxVector inxyz=
(
	rootBone = getNodeByName "Armature"
	if(rootBone != undefined) then
	(
		return (point3 inxyz.x inxyz.z inxyz.y)
	)
	return (point3 -inxyz.x -inxyz.z inxyz.y)
)
fn max2RtwVector inxyz=(
		return (point3 -inxyz.x inxyz.z -inxyz.y)
		)


struct RTWMESH (
bReadTv, --read textureverts?
bReadVc, --read vertex colors?
readVertAsign,--bool, wheter to read vertex assignments
verts,--array of point3 float's
normals,--array of point3 float's
faces1,--array of point3 short's
textureid,--which texture does it use?
uvw1,--array of point3 float's
vc1,--vertex colors
vertAssign,
	
	fn Read fp numVerts numFaces=(
	vertAssign = #()
	verts = #()
	faces1 = #()
 	normals = #()
	uvw1	= #()
	vc1		= #()
	
	if (readVertAsign) then
	for i=1 to numverts do append vertAssign (ReadLong fp)
	
	for k=1 to numVerts do
	append verts (rtw2maxVector( ( point3 (ReadFloat fp) (ReadFloat fp) (ReadFloat fp) ) ) )
	for k=1 to numVerts do 
	append normals ( rtw2maxVector( (point3 (ReadFloat fp) (ReadFloat fp) (ReadFloat fp) ) ) )
	
	--print "verts"
	--print verts
	--print "normals"
	--print normals
	print ("Numfaces read " + (ftell fp) as string)
	for k=1 to numFaces do 
	append faces1 (point3 ((ReadShort fp)+1) ((ReadShort fp)+1) ((ReadShort fp)+1) )
	--reverse
	for k=1 to numFaces do(
	tmp = faces1[k].x
	faces1[k].x = faces1[k].z
	faces1[k].z = tmp
	)
	textureid = ReadLong fp
	
	if bReadTv!=0 then for k=1 to numVerts do append uvw1 ( (point3 (ReadFloat fp) (1.0-(ReadFloat fp)) 0.0) )
	
	--FFcheck = ReadLong fp --another hack, damn :p
	--fseek fp -4 #seek_cur
	--if(GlobalHeader.fileVersion >= MINSUPPORTEDFILEVERSION) then 
	if(bReadVc!=0)then --FFcheck<=-1
	for k=1 to numVerts do --colors 
		append vc1  (color (ReadByte fp #unsigned) (ReadByte fp #unsigned)  (ReadByte fp #unsigned) (ReadByte fp #unsigned) )
	
	)
)
struct GEOM_CHUNK_T(--type 
type,--1 or 2
nameLength,--dword
name,--null terminated string
boneAttached,--dword, bone attached to
numVerts,--short, number of vertices
numFaces,--short, number of triangles
mesh1,--RTWMESH
newObj,

	fn Read fp  =(
	
	nameLength=ReadLong fp
	name = ReadString fp
	print ("At offset " + (ftell fp) as string)
	print ("Importing mesh " +name)
	
	if(GlobalHeader.fileVersion >= 3.05 or type==1) then (
	strSkip=ReadLong fp--length of extra string
	fseek fp strSkip #seek_cur
		)
	 
	if (type ==1) then (--fseek fp 6 #seek_cur--3 shorts?
				if(GlobalHeader.fileVersion >= 3.05) then(
				   strSkip2=ReadLong fp--length of extra string
				   fseek fp strSkip2 #seek_cur
				   )
				   boneAttached=ReadLong fp
				   fseek fp 28 #seek_cur)--7 floats likly minBox maxBox radius
	else if(type==2) then fseek fp 28 #seek_cur
	
	numVerts=ReadShort fp
	numFaces=ReadShort fp
	print("numverts: " +numverts as string )
	print("numfaces: " +numfaces as string )
	bReadTv = ReadByte fp #unsigned
	bReadVc = ReadByte fp #unsigned
	mesh1 = RTWMESH bReadTv:bReadTv  bReadVc:bReadVc
	if(type==1) then mesh1.readVertAsign = false
	else if(type == 2) then mesh1.readVertAsign = true
	mesh1.read fp numVerts numFaces
	
	--create mesh
	 newObj = mesh name:name   vertices:mesh1.verts faces:mesh1.faces1 tverts:mesh1.uvw1
		--for i=1 to mesh1.normals.count do setNormal newObj i mesh1.normals[i]
		
		--setup vert colors
		defaultVCFaces newObj
		if bReadVc != 0 then(
			for i=1 to numverts do setVertColor newObj i mesh1.vc1[i]
		)
		
		if bReadTv!=0 then 
		(
			for k=1 to numverts do
			SetTVert newObj k mesh1.uvw1[k]
			
			try
			(
				buildTVFaces newObj
				ind = 0
				for k=1 to numfaces do( 
				ind += 1
				SetTVFace newObj ind mesh1.faces1[ind]
				--SetVCFace newObj ind vc1[ind]
				)
			)
			catch
			(
				MessageBox ("Problem occured building faces for object '" + newObj.name + "'. \nThis object probably doesn't have any vertices. Ignoring this now")   title:"Warning!" beep:false
			)
		)
	),
	
	fn Write fp gemT bList =(
	print ("Exporting mesh " +gemT.name)
	WriteLong fp (gemT.name.count+1)
	WriteString fp gemT.name
	WriteLong fp 1
		WriteByte fp 0
		if(type==1) then (
		WriteLong fp 1
		WriteByte fp 0
		boneAttached=-1
		for i=1 to bList.count do if bList[i].name==gemT.parent.name then boneAttached=i-1
		
			if(boneAttached==-1) then ( 
			MessageBox ("Mesh " + gemT.name + " Must have a bone as it's parent")   title:"Error!" beep:false
			return false 
			)

		WriteLong fp boneAttached
		)
		tmpMesh = snapshot gemT
		if(type==1) then(
		minBox = max2RtwVector(gemT.min-gemT.parent.pos)
		maxBox = max2RtwVector(gemT.max-gemT.parent.pos)
			)
		else (
			minBox = point3 0 0 0
			maxBox = point3 0 0 0
			)
		WriteVector fp minBox
		WriteVector fp maxBox
		WriteFloat fp ( (distance minBox maxBox)/2.0)
		numVerts = getNumVerts tmpMesh
		numFaces = getNumFaces tmpMesh
		cfgShort = 257
		
		WriteShort fp numVerts
		WriteShort fp numFaces
		WriteShort fp cfgShort
		
		vertAssign = #()
		verts = #()
		faces1 = #()
 		normals = #()
		uvw1	= #()


		if(type==2) then(
			if gemT.modifiers["Skin"]==undefined or gemT.modifiers[1].name!="Skin" then ( MessageBox ("Mesh " + gemT.name + " must have the skin modifier at the top of the stack. If it is static then it must have a bone as it's parent")   title:"Error!" beep:false
			delete tmpMesh
			return false )
			
			select gemT
			max modify mode
			for i=1 to numVerts do for k=1 to (skinOps.GetVertexWeightCount gemT.modifiers[1] i) do if((skinOps.GetVertexWeight gemT.modifiers[1] i k)>0.9) then append vertAssign (skinOps.GetVertexWeightBoneId gemT.modifiers[1] i k)
			--print vertassign --for k=1 to (skinOps.GetNumberbones gemT.modifiers[1]) do
			vertAssign1 = #()
			
			for i=1 to numVerts do if vertAssign[i]==undefined then ( MessageBox ("Problem occured while reading the vertex wieghts of vertex " + ( (i-1) as string) +" in mesh " + gemT.name + " . Make sure each vertex has exactly 1 bone weight")   title:"Error!" beep:false
			delete tmpMesh
			return false )
			
			for i=1 to numVerts do  for j=1 to bList.count do if bList[j].name==(skinOps.getBoneName gemT.modifiers[1] vertAssign[i] 1) then  append vertAssign1 (j-1)
			

			for i=1 to numVerts do WriteLong fp vertAssign1[i]
			)
			
		if (type==2) then for i=1 to numVerts do WriteVector fp (  max2RtwVector ( in coordsys world (getVert tmpMesh i) - bList[vertAssign1[i]+1].pos) )
		if type==1 then for i=1 to numVerts do WriteVector fp (  max2RtwVector ( (in coordsys world (getVert tmpMesh i) ) - gemT.parent.pos) )
		
		for i=1 to numVerts do WriteVector fp (  max2RtwVector (  getNormal tmpMesh i) )
		
		for k=1 to numFaces do(
		tface = getFace tmpMesh k
		WriteShort fp (tface.z-1)
		WriteShort fp (tface.y-1)
		WriteShort fp (tface.x-1)
		)
		
		textureid = 0
		for i=1 to SceneTextures.count do(
		if gemT.material!=undefined and gemT.material.diffuseMap!=undefined and gemT.material.diffuseMap.filename!=undefined then if gemT.material.diffuseMap.filename==SceneTextures[i] then textureid = i-1
		)
		
		WriteLong fp textureid
		
		for i=1 to numVerts do(
			ttVert = point3 0.0 0.0 0.0
			for k=1 to numFaces do(
			tface = getFace tmpMesh k
			--check that there actually is a TFace and TVert
			--or (gettvert tmpMesh (getTVFace tmpMesh k)) == undefined
			--if( getNumTVerts tmpMesh < k ) then continue
			try( (getTVFace tmpMesh k) ) catch( continue )
			
			if tface.x==i then ttVert = gettvert tmpMesh (getTVFace tmpMesh k).x
			else if tface.y==i then ttVert = gettvert tmpMesh (getTVFace tmpMesh k).y
			else if tface.z==i then ttVert = gettvert tmpMesh (getTVFace tmpMesh k).z

			)

			--ttVert = gettvert tmpMesh i
			WriteFloat fp ttVert.x
			WriteFloat fp (1.0-ttVert.y)
		)
		for i=1 to numVerts do(
			vc = color 255 255 255 255
			try(
				vc = getVertColor tmpMesh i
			)
			catch()
			
			WriteByte fp (vc.r) #unsigned
			WriteByte fp (vc.g) #unsigned
			WriteByte fp (vc.b) #unsigned
			WriteByte fp (vc.a) #unsigned
		)
		delete tmpMesh
		return true
	)
		
)
struct GEOM_CHUNK(
offsetTillNextChunk3,
chunkType,--dword
numMeshes,--dword
geomChunks,--array of meshes
tmpMesh,
	
	fn Read fp  =(
	offsetTillNextChunk3 = ReadLong fp
	chunkType= ReadLong fp
	print chunkType
	numMeshes= ReadLong fp
   print( "numMeshes = " + numMeshes as string )
	--if(numMeshes==0) then  fseek fp 6 #seek_cur
	tmpMesh = #()
	geomChunks = #()
		for i=1 to numMeshes do(
		if(chunktype==2 ) then tmpMesh = GEOM_CHUNK_T 2 
		else if(chunktype==1) then tmpMesh = GEOM_CHUNK_T 1
		else return 0
		
		tmpMesh.Read fp
		append geomChunks tmpMesh
		if(GlobalHeader.fileVersion > 3.16) then zeroMarker = ReadLong fp else zeroMarker = ReadByte fp
		
		
		
		)
	print ("End read" + (ftell fp) as string)
	return true
	),
	
	fn Write fp gemSet bList =(
	posSave = ftell fp
	WriteLong fp -1 --save spot 
	WriteLong fp chunkType
	WriteLong fp gemSet.count
	for i=1 to gemSet.count do(
		if(chunktype==2 ) then tmpMesh = GEOM_CHUNK_T 2 
		else if(chunktype==1) then tmpMesh = GEOM_CHUNK_T 1
		else return 0
		
		if(tmpMesh.Write fp gemset[i] bList)==false then return false
		PadBytes fp 4
		)
	if(chunktype==1)then WriteShort fp 0
	WriteLong fp gemSet.count
	currentPos = ftell fp
	fseek fp posSave #seek_set
	WriteLong fp (currentPos-posSave)
	fseek fp currentPos #seek_set
	return true
	)
)
struct FRAMEVECTOR(
rot,--point3 rotation x y z, 
scale,--float
quat1,--quat rotation
	fn Read fp=(
		val1 = ReadFloat fp
		val2 = ReadFloat fp
		val3 = ReadFloat fp
		val1 = roundFloat val1 5
		val2 = roundFloat val2 5
		val3 = roundFloat val3 5
		rot = point3 (val1) (val2) (val3)  --)--rtw2maxVector( 
		--scale=RadToDeg(ReadFloat fp)
		scale=ReadFloat fp
		quat1 = quat rot.x rot.z -rot.y scale-- scale (point3 rot.x -rot.z rot.y)  --scale --scale rot--
		--print ("\t" + rot.x as string + "\t" + rot.z as string + "\t" + -rot.y as string + "\t\t#\trotation quaternian frame = \t\t" + k as string + "\tbone idx = \t\t\n")
		--quat1.w=scale
		--quat1.x= rot.x
		--quat1.y= rot.z
		--quat1.z= -rot.y
	),
	fn GetQuat = (
		return quat1
	)
)

struct RTWBONE(
strLen, --dword
boneName, --null terminated
numFrames,--numberOfFrames stored
unknownL1, --usally 0
offsetStart,--where it's vectors start
offsetEnd,--offset untill the bone position?
strSize,--usally 1, for storing extra info i think
unkownL2,--usally 0
position, --point3
fn Read1 fp =(--phase1 read
	strLen = ReadLong fp
	boneName 	= ReadString fp
	numFrames	= ReadLong fp
	unkownL1	= ReadLong fp
	offsetStart	= ReadLong fp
	offsetEnd	= ReadLong fp
	unkownL2	= ReadLong fp
	if(GlobalHeader.fileVersion >= 3.16) then(
	strSize		= ReadLong fp
	fseek fp strSize  #seek_cur
	)
	print (ftell fp) 
	),
	fn Read2 fp =(--phase2 read
	position = rtw2maxVector( point3 (ReadFloat fp) (ReadFloat fp) (ReadFloat fp) )
	--scale=(ReadFloat fp)
	)

)

struct BONESCHUNK (
vbones,
pBones,--or point bone list
numBones,
boneList, --list of the bone names
animation, --are we importing/exporting animation?

	fn Read fp =(
		numBones = ReadLong fp
		if(GlobalHeader.fileVersion >= 3.05) then
		fseek fp 2  #seek_cur --usally 0
		else fseek fp 1  #seek_cur
		
		print numBones
		print (ftell fp)
		boneHier = #()
		for i=1 to numbones-1 do
		append boneHier (ReadLong fp )
		numFrames = ReadLong fp
		fseek fp (numFrames*4) #seek_cur--frame info, time
			
		vbones = #()
		for i=1 to numbones do(
		tmpBone = RTWBONE 0 
		tmpBone.Read1 fp
		append vbones tmpBone
		print tmpBone.boneName
		)
		--fseek fp 24  #seek_cur -- unkown, usally 0's
		boneVectors = #()
		animationSet = #()
		
		--append boneVectors (point3 0.0 0.0 0.0)
		angles  = FRAMEVECTOR (point3 0.0 0.0 0.0) 1.0
		append animationSet angles
		append boneVectors animationSet[1]
		
		for i=2 to numbones do(
		animationSet = #()
		if (vbones[i].numFrames>0) then (
		for k=1 to vbones[i].numFrames do (
		tmpFVector = FRAMEVECTOR 0
		tmpFVector.Read fp
		append animationSet tmpFVector
		--angles = rtw2maxVector( point3 (ReadFloat fp) (ReadFloat fp) (ReadFloat fp) )	
		
		--fseek fp (((numFrames-1)*16)+4) #seek_cur --skip all the bone info for now
			 )
		   )--if
		append boneVectors animationSet
		)
		
		movement = #()
		
		rootAnims = (ftell fp)
		--read in position changes
		if(numbones>1) then for i=1 to (vbones[2].numFrames) do append movement ( point3 (ReadFloat fp) (ReadFloat fp) (ReadFloat fp) )

		else for i=1 to (vbones[1].numFrames) do append movement ( point3 (ReadFloat fp) (ReadFloat fp) (ReadFloat fp) )
		
		--print ("pos" + (ftell fp) as string)
		
		for i=1 to numbones do
			vbones[i].Read2 fp
			pbones= #()
			p = point pos:vbones[1].position --
			p.size = 0.1
			p.showLinks=true
			p.name = vbones[1].boneName 
			append pbones p
			bSwitch=false--change in heirarchy
		for i=2 to numbones do(
			--boneSys.createBone  vbones[index].position vbones[i].position (point3 0 0 0)
			index=boneHier[i-1]+1
			
			--print index
			
			in pbones[index] p = point pos:(vbones[i].position+pbones[index].pos)
			p.name = vbones[i].boneName 
			p.size = 0.1
			p.showLinks=true
			append pbones p
			)
			
		--LOAD ANIMATION
		 if( animation ) then (
		 ProgressStart( "Importing Animation" )
		 animate on for i=2 to numBones do (
			
			deletekeys pbones[i].rotation.controller #allKeys
			if(i>2) then deletekeys pbones[i].position.controller #allKeys
		
			pbones[i].rotation.controller = TCB_Rotation()
		
			for k=1 to vbones[i].numFrames do in coordsys pbones[i].parent(							
				addnewkey pbones[i].rotation.controller k
				--print vbones[i].numFrames as string
				--print ( "i: " + (i as string) )
				--print ( "k: " + (k as string) )
				at time k pbones[i][3][2].rotation = quat (boneVectors[i][k].rot.x) (boneVectors[i][k].rot.z) (-boneVectors[i][k].rot.y)  ( boneVectors[i][k].scale)
				local cont = progressUpdate ( ( ( ((i-2)*numFrames)+k as float)/(numFrames*numBones) )* 100)
				if NOT cont then return true
			)					
		   )--end animate
		  
		   if( numBones == 0 ) then AnimationRange = interval 1 vbones[1].numFrames
		   else AnimationRange = interval 1 vbones[2].numFrames
		  
		   rbone = 2
		   if( numBones == 0 ) then rbone = 1
		   for i=1 to vbones[rbone].numFrames do(
		   		animate on at time i pbones[1].position = rtw2maxVector( movement[i] )
	     	)
		   ProgressEnd()
		  )--end if
			
		),--End Read
		
	fn Write fp =(
	rootBone = getNodeByName "Scene Root"
	if rootBone==undefined then (
		MessageBox "Cannot export without the Scene Root bone. Verify it exists." title:"Error!" beep:false
		return false
		)
	WriteLong fp -1 --offset to the geometry chunk. i'll beh back =)
	WriteLong fp 0 
	numBones =1
	boneList = #()
	numBones = recursiveHeir rootBone boneList
	numBones = boneList.count
	
	boneList[1].parent=1 
	boneList[1].rpos=(point3 0.0 0.0 0.0) 
	
	for i=2 to boneList.count do 
	for k=1 to boneList.count do if (getNodeByName boneList[i].name).parent.name == boneList[k].name then boneList[i].parent = k
	for i=2 to boneList.count do (boneList[i].pos = (getNodeByName boneList[i].name).pos 
					boneList[i].rpos = boneList[i].pos-(getNodeByName boneList[boneList[i].parent].name).pos
					)
	print ("Numbones: " + boneList.count as string)
	print boneList
	
	numFrames = 1 + (animationRange.end - animationRange.start)
	
	WriteShort fp numBones 
	for i=1 to boneList.count do WriteLong fp (boneList[i].parent-1)
	
	
	WriteLong fp numFrames
	for i=0 to numFrames-1 do WriteFloat fp (i*0.05)
	for i=1 to numBones do (
		WriteLong fp (boneList[i].name.count+1)
		WriteString fp  boneList[i].name
		if( animation ) then (
			offsetStart = (i - 2) * 16 * numFrames
			if( i == 1 ) then offsetStart = 0
			
			offsetEnd = numFrames*(numBones-1)*16 + (numFrames * 12)
			
			if( i==1 ) then WriteLong fp 0
			else WriteLong fp numFrames
			if( i==2 ) then WriteLong fp numFrames
			else WriteLong fp 0
			
			WriteLong fp offsetStart
			WriteLong fp offsetEnd
			WriteLong fp 0
		)
		else(
			padBytes fp 20
		)
		WriteLong fp 1
		WriteByte fp 0
		)
		
	if( animation ) do(
		sceneBones = #()
		for i=1 to numBones  do append sceneBones ( getNodeByName boneList[i].name )

		for i=2 to numBones do (
			sceneBones[i].rotation.controller = TCB_Rotation()
			for k=1 to numFrames do in coordsys sceneBones[i].parent (
				WriteFloat fp (at time k  sceneBones[i].rotation.x)
				WriteFloat fp (at time k  -sceneBones[i].rotation.z)
				WriteFloat fp (at time k  sceneBones[i].rotation.y)		
				WriteFloat fp (at time k  sceneBones[i].rotation.w)
			)			
		)
		

		
		for k=1 to numframes do (
			WriteVector fp (max2rtwvector(at time k in coordsys world sceneBones[1].pos))
		)
	)


	for i=1 to numBones do (
	boneList[i].rpos = max2RtwVector boneList[i].rpos
	WriteFloat fp boneList[i].rpos.x
	WriteFloat fp boneList[i].rpos.y
	WriteFloat fp boneList[i].rpos.z
		)
	currentPos=ftell fp
	fseek fp 42 #seek_set
	WriteLong fp (currentPos-42)
	fseek fp currentPos #seek_set
	return true--all is well
	)
		
)

utility CASIE "R:TW Import/Export" silentErrors:false rolledup:true(
group "About:"
	(
		label titleLabel	"Rome:Total War script v0.79b"
		HyperLink addy "by Vercingetorix" align:#center address:"mailto:vercingetorix11@gmail.com" color:(color 0 0 170) hoverColor:(color 170 0 0)
	)
group "Web Links:"
	(	
		HyperLink link0 "Get Latest Version" align:#center address:"ftp://europabarbarorum.org/vercingetorix/tools/" color:(color 0 0 160) hoverColor:(color 170 0 0)	
		HyperLink link1 "TWCenter" align:#center address:"http://www.twcenter.net" color:(color 0 0 160) hoverColor:(color 170 0 0)
		HyperLink link2 "TW.Org" align:#center address:"http://www.totalwar.org" color:(color 0 0 160) hoverColor:(color 170 0 0)
		HyperLink link3 "TW.Com" align:#center address:"http://www.totalwar.com" color:(color 0 0 160) hoverColor:(color 170 0 0)

	)
------------------------
--Begin Export rollout--
------------------------
rollout CASExport "R:TW Export"  rolledUp:false

(
	 	
	--------------------
	-- User Interface --
	--------------------

	
	
	group "Options:"
	(
		radiobuttons tagAction "Objects:" labels:#("Export Selection", "Export all") default:2
		checkbox exportAnimation "Export animation" checked:false
	)
	
	group "Export:"
	(
		
		button exportButton "Export CAS..."	
		button exportItemButton "Export ITEM..."	
		button exportAnimButton "Export Animation..."	
	)
	
	fn WriteItem fp meshes=(
	
	WriteShort fp meshes.count
	
	ProgressStart ("Exporting meshes...")
	
	for ol=1 to meshes.count do(
		curmesh = snapshot (getnodebyname meshes[ol])
		texname = #()
		
		if curmesh.material!=undefined and curmesh.material.diffuseMap!=undefined and curmesh.material.diffuseMap.filename!=undefined
			then texname = stripExt(getName(curmesh.material.diffuseMap.filename))
		if(texname.count!=0) then WriteShort fp (texname.count+1) else WriteShort fp 0
		if(texname.count!=0) then WriteString fp texname
		
		PadBytes fp 72
		numVerts = (getNumVerts curmesh)
		WriteShort fp numVerts #unsigned 
		numFaces= (GetNumFaces curmesh)
		
		for i=1 to numVerts do(
		
			WriteVector fp  ( max2rtwvector( GetVert curmesh i ) )
			WriteVector fp  ( max2rtwvector( GetNormal curmesh i ) )
			
			
			ttVert = point3 0.0 0.0 0.0
			for k=1 to numFaces do(
			tface = getFace curmesh k
			if tface.x==i then ttVert = gettvert curmesh (getTVFace curmesh k).x
			else if tface.y==i then ttVert = gettvert curmesh (getTVFace curmesh k).y
			else if tface.z==i then ttVert = gettvert curmesh (getTVFace curmesh k).z 			
			)
			WriteFloat fp ttVert.x
			WriteFloat fp (1.0-ttVert.y)
			WriteLong fp -1
			
					
		)
		
		
		WriteShort fp (numFaces*3) #unsigned
		
		for k=1 to numFaces do (
		tmp = GetFace curmesh k
	   	WriteShort fp (tmp.z-1)
		WriteShort fp (tmp.y-1)
		WriteShort fp (tmp.x-1)
		)
		delete curmesh
		PadBytes fp 41
		local cont = progressUpdate ( ( (ol as float)/(meshes.count) )* 100)
		if NOT cont then return true
		)
		ProgressEnd()

		PadBytes fp 47	
	)
	
	-------------
	-- UI Bits --
	-------------
	on exportItemButton pressed do(
		local importPly fname = getSaveFileName types:"ITEM (*.item)|*.item|All (*.*)|*.*|"
		if fname == undefined then return NULL
		fp =  fopen fname "wb"
		lod1_group = #()
		lod2_group = #()
		lod3_group = #()
		lod4_group = #()
		lodcount = 0
		
		if $LOD_1!= undefined and isGroupHead $LOD_1 then(
		for i=1 to $LOD_1.children.count do append lod1_group $LOD_1.children[i].name
		lodcount+=1
		)
		
		if $LOD_2 != undefined and isGroupHead $LOD_2 then(
		for i=1 to $LOD_2.children.count do append lod2_group $LOD_2.children[i].name
		lodcount+=1
		)
		
		if $LOD_3!= undefined and isGroupHead $LOD_3 then(

		for i=1 to $LOD_3.children.count do append lod3_group $LOD_3.children[i].name
		lodcount+=1
		)
		
		if $LOD_4!= undefined and isGroupHead $LOD_4 then(
		for i=1 to $LOD_4.children.count do append lod4_group $LOD_4.children[i].name
		lodcount+=1
		)
		
		WriteFloat fp 1.0
		if(lodcount==0) then WriteShort fp 1 else WriteShort fp lodcount
		WriteFloat fp 1.0
		
		print ("lod: " + lodcount as string)
		if(lodcount==0) then (
		
		meshlist = #()
		for i=1 to geometry.count do append meshlist geometry[i].name
		WriteItem fp meshlist
		)
		else(		
		if(lod1_group.count!=0) then WriteItem fp lod1_group
		if(lod2_group.count!=0) then WriteItem fp lod2_group
		if(lod3_group.count!=0) then WriteItem fp lod3_group
		if(lod4_group.count!=0) then WriteItem fp lod4_group
		)
		PadBytes fp 36
		fclose fp
		print "Item Export successfull"
		
	)
	
	on exportAnimButton pressed do 
	(
		
		local importPly fname = getSaveFileName types:"CAS (*.cas)|*.cas|All (*.*)|*.*|"
		if fname == undefined then return NULL
		fp =  fopen fname "wb"
		
		--frameRate =  20
		
		rootBone = getNodeByName "Scene Root"
		if rootBone==undefined then (
		MessageBox "Cannot export animation without the Scene Root bone. Verify it exists." title:"Error!" beep:false
		fclose fp
		return false
		)
		boneList0 = #()
		numBones = recursiveHeir rootBone boneList0
		boneList = #()
		print bonelist0
		for i=1 to bonelist0.count do append boneList (getNodeByName bonelist0[i].name)
		
		numbones = bonelist.count
		numframes= 1 + (animationRange.end - animationRange.start)
		WriteShort fp numframes 
		WriteShort fp (numbones-1)
		WriteByte fp 1
		for k=1 to numframes do 
		for i=2 to numbones  do in coordsys boneList[i].parent(
		
		boneList[i].rotation.controller = TCB_Rotation()
		
		--if i == 14 or i == 17 then n = 1 else n = 1
		WriteFloat fp (at time k  boneList[i][3][2].rotation.x)
		WriteFloat fp (at time k  -boneList[i][3][2].rotation.z)
		WriteFloat fp (at time k  boneList[i][3][2].rotation.y)		
		WriteFloat fp (at time k  boneList[i][3][2].rotation.w)
		)
		
      -- -------------------------------------
      -- Code commented out by KnightErrant. |
      -- -------------------------------------
--		for k=1 to numframes do (
--		pos = max2rtwvector(at time k in coordsys world boneList[2].pos)
--		WriteVector fp pos
--		)

      -- -------------------------------------
      -- Code added by KnightErrant.         |
      -- -------------------------------------
  		oldpos = max2rtwvector(at time 1 in coordsys world boneList[1].pos)
  		WriteVector fp oldpos
         print( "very first oldpos : " + oldpos as string )
      for k = 2 to numframes do
         (
         newpos            = max2rtwvector(at time k in coordsys world boneList[1].pos)
         posdif            = newpos - oldpos
  		   writefloat fp posdif.x
  		   writefloat fp newpos.y
  		   writefloat fp posdif.z
         print( "newpos : " + newpos as string )
         print( "oldpos : " + oldpos as string )
         oldpos            = newpos
         )
      -- -------------------------------------
      -- End of code added by KnightErrant.  |
      -- -------------------------------------

		
		
		for i=1 to ((numframes-1)) by 2 do
		(  
	 	 transit = max2rtwvector( (at time (i+2) in coordsys world boneList[1].pos)  - (at time i in coordsys world boneList[1].pos)  )
		 WriteVector fp transit
	 	)


      -- -------------------------------------
      -- Code commented out by KnightErrant. |
      -- -------------------------------------
--		for k=1 to ((numframes-1)/2) do WriteFloat fp 0.0

      -- -------------------------------------
      -- Code added by KnightErrant.         |
      -- -------------------------------------
      valuestring          = getUserProp rootBone "mysteryfloats"
      ulim                 = ((numframes-1)/2)
      if valuestring == undefined then
         (
         for k=1 to ((numframes-1)/2) do WriteFloat fp 0.0
         )
      else
         (
         tokens            = filterstring valuestring "%"
         ntokens           = tokens.count
         if ntokens != ulim then
            (
            -- Must linear interpolate the data.
            num            = ( ntokens - 1 ) as Float
            den            = ( ulim - 1 ) as Float
            dt             = num / den
            print( " dt = " + dt as string )
            thefloat       = tokens[1] as Float
            WriteFloat fp thefloat
            t              = 0.0
            for k = 2 to ulim-1 do
               (
               t           = t + dt
               tlow        = floor t
               idx         = tlow as Integer
               idx         = idx + 1
               low         = tokens[idx] as Float
               high        = tokens[idx+1] as Float
               a           = t - tlow
               b           = tlow + 1.0 - t
               thefloat    = a * high + b * low
               WriteFloat fp thefloat
               )
            thefloat       = tokens[ntokens] as Float
            WriteFloat fp thefloat
            )
         else
            (
            for k = 1 to ulim do
               (
               thefloat    = tokens[k] as Float
               WriteFloat fp thefloat
               )
            )
         )
      -- -------------------------------------
      -- End of code added by KnightErrant.  |
      -- -------------------------------------


		
		for k=1 to numframes do (
		pos = max2rtwvector(at time k in coordsys world boneList[1].pos)
		WriteVector fp pos
		)
      -- -------------------------------------
      -- Code added by KnightErrant.         |
      -- -------------------------------------
      valuestring          = getUserProp rootBone "eightfloats"
      if valuestring == undefined then
         (
         for k=1 to 8 do WriteFloat fp 0.0
         )
      else
         (
         tokens            = filterstring valuestring "%"
         for k = 1 to 8 do
            (
            thefloat       = tokens[k] as Float
            WriteFloat fp thefloat
            )
         )
      -- -------------------------------------
      -- End of code added by KnightErrant.  |
      -- -------------------------------------


      -- -------------------------------------
      -- Code commented out by KnightErrant. |
      -- -------------------------------------
--		for k=1 to 8 do WriteFloat fp 0.0
		WriteLong fp 1
		WriteLong fp 0
		fclose fp
		print "Animation export completed..."

	)
	
	
	on exportButton pressed do 
	(
	
		local importPly fname = getSaveFileName types:"CAS (*.cas)|*.cas|All (*.*)|*.*|"
		if fname == undefined then return NULL
		fp =  fopen fname "wb"
		--Write Out header
		header = CASHEADER()
		header.write fp
		bChunk = BONESCHUNK animation:(exportAnimation.state)

		if (bchunk.write fp)==false then (
			fclose fp
			return 1
		)
		if( exportAnimation.state ) then(
			WriteLong fp 18
			WriteLong fp 1
			PadBytes fp 10
			WriteLong fp 16
			WriteLong fp 2
			PadBytes fp 8
			WriteLong fp 16
			WriteLong fp 3
			PadBytes fp 8
			WriteLong fp 16
			WriteLong fp 8
			PadBytes fp 8
			WriteLong fp 16
			WriteLong fp 10
			PadBytes fp 8
			WriteLong fp 12
			WriteLong fp 5
			WriteLong fp 0
			fclose fp
			return 1
		)
		--gather textures
		SceneTextures = #()
		if (tagAction.state==2) then tCheck=geometry else tCheck=selection
		
		for i=1 to tcheck.count do if tCheck[i]!=undefined and tCheck[i].material!=undefined and tCheck[i].material.diffuseMap!=undefined and tCheck[i].material.diffuseMap.filename!=undefined then (
			exists=false
			for k=1 to SceneTextures.count do if SceneTextures[k]==tCheck[i].material.diffuseMap.filename then exists=true
 			if not exists then append SceneTextures tCheck[i].material.diffuseMap.filename
		)
		
		if (SceneTextures.count==0) then(
		 messageBox "Failed to locate texture(s). Make sure each mesh has a material assigned to it and has a diffuse map bitmap" title:"Error!" beep:false
		 fclose fp
		 return 1
		)
		
		for i=1 to SceneTextures.count do print SceneTextures[i]
		
		staticmArray = #()
		dynamicArray = #()
		if(tagAction.state==2) then
		for i=1 to geometry.count do if(geometry[i].parent!=undefined) then append staticmArray geometry[i] else append dynamicArray geometry[i]
		else if(tagAction.state==1) then
		for i=1 to selection.count do if(selection[i].parent!=undefined) then append staticmArray selection[i] else append dynamicArray selection[i]
		
		if(staticmArray.count>0) then (
		gChunk1= GEOM_CHUNK chunktype:1

		if(gChunk1.write fp staticmArray bChunk.boneList)==false then return 1
		)
		if(dynamicArray .count>0) then(
		gChunk2= GEOM_CHUNK chunktype:2
		if(gChunk2.write fp dynamicArray bChunk.boneList)==false then return 1
		)
		
		--write textures
		
		WriteLong fp 16
		WriteLong fp 3
		padBytes fp 8
		WriteLong fp 16
		WriteLong fp 8
		padBytes fp 8
		WriteLong fp 16
		WriteLong fp 10
		padBytes fp 8
		
		holdOffset = ftell fp
		
		WriteLong fp -1
		WriteLong fp 5
		WriteLong fp SceneTextures.count
		for i=1 to SceneTextures.count do(
			texName = "\\textures\\" + (getName SceneTextures[i])
			if (findString texName ".DDS")!=undefined then texName = stripExt texName		
			WriteLong fp 1
			WriteByte fp 0
			WriteString fp texName
			for i=1 to 7 do WriteFloat fp 1.0
			padBytes fp 28
			WriteByte fp 1
		)
		texOffset = (ftell fp) - holdOffset
		fseek fp holdOffset #seek_set
		WriteLong fp texOffset
		--end write textures
		
		fclose fp
		print "Export completed successfully!"	
		
    )
	
)


------------------------
--Begin Import rollout--
------------------------
rollout CASImport "R:TW Import"  rolledUp:false

(
	

	

	global g_gameDataPath = ""
	global g_defaultGameDataPath = "D:\\Program Files\\Activision\\Rome - Total War\\Data\\models_unit"
	--global GlobalHeader = CASHEADER 0
	-- Useful file information
	local modelFilename
	local modelPath



	--------------------
	-- User Interface --
	--------------------

	
	
	group "Options:"
	(
		edittext pakDirEdit "Textures Path:" text:"** Not Set **" readonly:true
		button setPakRootButton "Set Textures Folder Path"
	)
	
	group "Import:"
	(
		radiobuttons tagAction "Textures:" labels:#("Ignore all", "Load all") default:2

		checkbox promptForMissing "Force textures path" checked:false
		checkbox importAnimation "Import animation" checked:false

		
		button importButton "Import CAS..."	
		button importItemButton "Import ITEM..."	
		button importAnimButton "Import Animation..."	
	)
	

	local recentFile

	fn AddRecentFile fname=
	(
		recentFile = fname
		ok
	)
	
	

	-------------
	-- UI Bits --
	-------------
	
	fn UpdateUI=
	(
		local theDir = g_gameDataPath
		if theDir == undefined do
		(
			theDir = "** Not Set **"
		)
		pakDirEdit.text = theDir
	
	)
		
	on CASImport open do
	(
				
		if g_gameDataPath == "" then
		(
			g_gameDataPath = g_defaultGameDataPath
		)
	
		UpdateUI()
	)
	on pakDirEdit entered newText do
	(
		g_gameDataPath = newText
	)
	
 	on setPakRootButton pressed do
	(
		local newPakDir = getSavePath caption:"Set Game Data Path"
		if newPakDir != undefined do
		(
			g_gameDataPath = newPakDir
			UpdateUI()
		)
	)

on importItemButton pressed do 
	( 

		local importPly fname = getOpenFileName types:"ITEM (*.ITEM)|*.ITEM|All (*.*)|*.*|"
		if fname == undefined then return NULL
		fp =  fopen fname "rb"
		
		ReadFloat fp
		numGroups = ReadShort fp
		ReadFloat fp
		
		
		LoadedTextures = #()
		
		for i=1 to currentMaterialLibrary.count do deleteItem currentMaterialLibrary 1
		for i=1 to 24 do setMeditMaterial i (standardMaterial()) 
		
		for ml=1 to  numGroups  do (
		numMeshes = ReadShort fp
		for il = 1 to numMeshes do (
		strlen1 = ReadShort fp
		if(strlen1 != 0) then texName = ReadString fp else texName =""
		fseek fp 72 #seek_cur
		numVerts = ReadShort fp #unsigned



		
		verts1= #()
		normals=#()
		tverts1= #()
		vcolor = #()
		faces1 = #()
		
		for i=1 to numVerts do(
			append verts1  ( rtw2maxvector( (point3 (ReadFloat fp) (ReadFloat fp) (ReadFloat fp)) ) )
			append normals ( rtw2maxvector((point3 (ReadFloat fp) (ReadFloat fp) (ReadFloat fp)) ) )
			append tverts1 (point3 (ReadFloat fp) (1.0-(ReadFloat fp)) 0) 
			append vcolor (ReadFloat fp) 			
		)
		
		numFaces= (ReadShort fp #unsigned)/3 
		for k=1 to numFaces do 
	    append faces1 (point3 ((ReadShort fp)+1) ((ReadShort fp)+1) ((ReadShort fp)+1) )
		
		for k=1 to numFaces do(
		tmp = faces1[k].x
		faces1[k].x = faces1[k].z
		faces1[k].z = tmp
		)
		
		newObj = mesh name:("mesh" + ml as string + "_" + il as string)  vertices:verts1 faces:faces1 tverts:tverts1
		
		defaultVCFaces newObj --buildVCFaces newObj
		
		for k=1 to numverts do
		SetTVert newObj k tverts1[k]
			
		buildTVFaces newObj
		ind = 0
		for k=1 to numfaces do( 
		ind += 1
		SetTVFace newObj ind faces1[ind]
		)
		--/*
		if(tagAction.state==2) do(
		alreadyLoaded = 0
		
		for i=1 to LoadedTextures.count do if LoadedTextures[i] == texname then alreadyLoaded = i
		
		if(alreadyLoaded!=0  ) then if(alreadyLoaded>24) then newObj.material = currentMaterialLibrary[alreadyLoaded] else newObj.material = getMeditMaterial alreadyLoaded
		else (
			cmat = LoadedTextures.count+1
			
			
			if (promptForMissing.checked==false) then pathName = (getPath false fname) + "..\\MODELS_BUILDING\\TEXTURES\\"
			else pathName = g_gameDataPath 
			
			if (pathName[pathName.count]!="\\") then pathName+="\\"
			
			fullname = pathname + (texName) + ".dds" 			
			tm = bitMapTexture()
			tm.filename = fullname
			print fullname
			if cmat <= 24 then mat = getMeditMaterial cmat  -- we may run out of our 24 max slots..
			if mat==undefined then mat=standardMaterial diffuseMap:tm
			else mat.diffuseMap=tm
			try (showTextureMap mat tm on) catch ( try (showTextureMap mat mat.diffuseMap on on) catch() )
			if cmat <= 24 then (
				append currentMaterialLibrary mat
				setMeditMaterial cmat mat
				newObj.material = getMeditMaterial cmat
				)
			else (
			append currentMaterialLibrary mat
			newObj.material = currentMaterialLibrary[cmat]
			)
			append LoadedTextures texname
			)
			
		  )
			
			--*/

		fseek fp (40 + 1) #seek_cur
		 print newobj.material
		 selectMore newObj
		 )--mesh loop
		 fseek  fp 47 #seek_cur
		group selection name:("LOD_" + ml as string)
		clearSelection()
		)--Main group loop
		print (ftell fp)
		fclose fp
		print "ITEM import successfull"

)

on importAnimButton pressed do --import Animation. Dagovax -> I am trying to fix bone position import as well for all bones
	(
		-- Dagovax -> why framRate commented out! Need to set to 20!
		frameRate=20
		--/*--ANIMATION ON HOLD
		local importPly fname = getOpenFileName types:"CAS (*.cas)|*.cas|All (*.*)|*.*|"
		if fname == undefined then return NULL
		fp2 =  fopen fname "rb"
		
		numFrames=ReadShort fp2
		print ("Number of frames as two byte int: " + numFrames as string + ". At position " + (ftell fp2) as string)
		numBones1=ReadShort fp2
		print ("Number of bones as two byte int: " + numBones1 as string + ". At position " + (ftell fp2) as string)
		numBonesWithPosition=ReadByte fp2
		print ("Number of bones with position data as single byte: " + numBonesWithPosition as string + ". At position " + (ftell fp2) as string)
		--fseek fp2 1 #seek_cur
		boneVecs = #()
		for i=1 to numFrames do 
		(
			animSet = #()
			for k=1 to numBones1 do 
			(
				tmpFVector = FRAMEVECTOR 0
				tmpFVector.Read fp2 		
				append animSet tmpFVector
				quat1 = tmpFVector.quat1
				print((quat1.x as string + "\t\t" +quat1.y as string + "\t\t" + quat1.z as string + "\t\t" + quat1.w as string  + "\t\t# rotation quaternian frame =\t" + i as string + "\t\tbone idx = " + k as string))
			)
			--print animSet
			append boneVecs  animSet
		)
		-- We now have all frames and rotations
		--print boneVecs
		
		--fseek fp2 4 #seek_cur
		print ("# ------------------------- End quats " + (ftell fp2) as string)
		
		rootBone = getNodeByName "Scene Root"
		if rootBone==undefined then (
			rootBone = getNodeByName "Scene_Root"
			if rootBone==undefined then (
				rootBone = getNodeByName "Armature"
				if rootBone==undefined then (
					MessageBox "Cannot import animation without the Scene Root, Scene_Root or Armature bone! Verify it exists." title:"Error!" beep:false
					return false	
				)
			)
		)
		boneList0 = #()
		numBones = 0
		if (rootBone.name == "Armature") then
		(
			append boneList0 rootBone
			numBones = recursiveHeir rootBone boneList0
		) else 
		(
			numBones = recursiveHeir rootBone boneList0
		)

		boneList = #()
		--print bonelist0

		for i=1 to boneList0.count do append boneList (getNodeByName boneList0[i].name)
		print boneList
		
		orgpos = at time 0 boneList[2].pos
		print ("Original position at time 0 of bone " + boneList[2].name + ": " + orgpos as string)
		--PelvisPos = #()
		bonePos = #()
		
		-- ------------------------------------
		-- Code added by Dagovax.        		|
		-- ------------------------------------
		
		for k = 1 to numBonesWithPosition do
		(
			for i = 1 to numFrames do
			(
				val1 = ReadFloat fp2
				val2 = ReadFloat fp2
				val3 = ReadFloat fp2
				print((val1 as string + "\t\t" +val2 as string + "\t\t" + val3 as string + "\t\t# position xyz(bone idx refer to bottom of file) frame =\t" + i as string + "\t\tbone idx = " + k as string))
				append bonePos (rtw2MaxVector (point3 (val1) (val3) (val2) ) )
			)
		)
		
		--for i=1 to numFrames do 
		--(
			--animSet = #()
			--for k=1 to numBones1 do 
			--(
				--val1 = ReadFloat fp2
				--val2 = ReadFloat fp2
				--val3 = ReadFloat fp2
				--print((val1 as string + "\t\t" +val2 as string + "\t\t" + val3 as string + "\t\t# position xyz(bone idx refer to bottom of file) frame =\t" + i as string + "\t\tbone idx = " + k as string))
				--append bonePos (rtw2MaxVector (point3 (val1) (val2) (val3) ) )
			--)
			----print animSet
			--append boneVecs  animSet
		--)
		
		--animate on for k=1 to numFrames do  (
		--	val1 = ReadFloat fp2
		--	val2 = ReadFloat fp2
		--	val3 = ReadFloat fp2
		--	print((val1 as string + "\t\t" +val2 as string + "\t\t" + val3 as string + "\t\t# position xyz(bone idx refer to bottom of file) frame =\t" + k as string + "\t\tbone idx = " + 0 as string))
		--	append PelvisPos (rtw2MaxVector (point3 (val1) (val2) (val3) ) )
		--)
		print ("# ------------------------- End frame pos " + (ftell fp2) as string)
		
		-- ------------------------------------
		-- End of code added by Dagovax.        		|
		-- ------------------------------------
		
      -- --------------------------------------------
      -- Code commented out by KnightErrant.        |
      -- --------------------------------------------
--		globrot = #()
--		for k=1 to (numFrames-1) do animate on in coordsys world(--in coordsys bChunk.pbones[k].parent (
--		append globrot (ReadFloat fp2)
--		
--		--at time k boneList[1].rotation.x_rotation = radtodeg((readfloat fp2)-(readfloat fp2)) 
--		readfloat(fp2)
--		)

      -- ------------------------------------
      -- Code added by KnightErrant.        | MODIFIED BY DAGOVAX
      -- ------------------------------------
      -- We want to read and store the "mystery floats" that come after
      -- the "double deltas" data.
		ulim                 = ( numFrames - 1 ) / 2
		for k = 1 to ulim do
		(
			val1 = readfloat fp2
			val2 = readfloat fp2
			val3 = readfloat fp2
			print((val1 as string + "\t\t" +val2 as string + "\t\t" + val3 as string + "\t\t# doubled xyz increments " + k as string))
		)
		print ("# ------------------------- End doubled xyz increments " + (ftell fp2) as string)
		valuestring          = ""
		for i = 1 to ulim do
		(
			thefloat          = readfloat fp2
			print((thefloat as string + "\t\t\t\t\t\t# doubled distance values " + (i - 1) as string))
			valuestring       = valuestring + "%" + thefloat as string
		)
		setUserProp rootBone "mysteryfloats" valuestring
		print ("# ------------------------- End doubled distance vals " + (ftell fp2) as string)
		  -- ------------------------------------
		  -- End of code added by KnightErrant. | MODIFIED BY DAGOVAX
		  -- ------------------------------------

		--for k=1 to (numFrames-1) do animate on in coordsys world()
		
		progressstart("Importing animation")
		deletekeys boneList[1].position.controller
		deletekeys boneList[2].position.controller
	
		--point name:"pelvis" size:0.1
		--point name:"root" size:0.1
		--deletekeys $root.position.controller
		--deletekeys $pelvis.position.controller

		-- Animate Scene Root
		for k=1 to numFrames do animate on in coordsys world 
		(
			tmpV= point3 (readfloat fp2) (readfloat fp2) (readfloat fp2)
			print((tmpV[1] as string + "\t\t" +tmpV[2] as string + "\t\t" + tmpV[3] as string + "\t\t# control bone position xyz at frame = " + k as string))
			at time (k) boneList[1].position = rtw2MaxVector (tmpv)-- pelvisPos[k] --rtw2MaxVector (tmpv)	
			--at time (k) $root.position = rtw2MaxVector (tmpv)	
		)
		print ("# ------------------------- End control bone position " + (ftell fp2) as string)
		
		--for k=1 to numFrames do animate on (
		--at time (k) in coordsys parent $pelvis.position = pelvisPos[k]
		--at time (k) in coordsys world boneList[2].position = pelvisPos[k]
		--at time (k) in coordsys world  boneList[2].position.y = boneList[1].position.y --+ (at time k boneList[1].position.y)
		--)	
			
      -- ------------------------------------
      -- Code added by KnightErrant.        |
      -- ------------------------------------
      -- We want to read and store the 8 floats that come after
      -- the bone_pelvis (or Scene_Root) position animations.
      thefloat             = readfloat fp2
		print (thefloat as string + "\t\t\t#\ttime")
      valuestring          = thefloat as string
      for i = 1 to 7 do
		(
			thefloat          = readfloat fp2
			if (i == 1) then
			(
				print (thefloat as string + "\t\t\t#\t xzvecdist")
			)
			if (i == 2) then
			(
				print (thefloat as string + "\t\t\t#\t xdiff")
			)
			if (i == 3) then
			(
				print (thefloat as string + "\t\t\t#\t ydiff")
			)
			if (i == 4) then
			(
				print (thefloat as string + "\t\t\t#\t zdiff")
			)
			if (i == 5) then
			(
				print (thefloat as string + "\t\t\t#\t avdistseconds")
			)
			if (i == 6) then
			(
				print (thefloat as string + "\t\t\t#\t then after 21 frames")
			)
			if (i == 7) then
			(
				print (thefloat as string + "\t\t\t#\t 0")
			)
			valuestring       = valuestring + "%" + thefloat as string
		)
	  print ("# ------------------------- End positions last bit almost movements " + (ftell fp2) as string)
      setUserProp rootBone "eightfloats" valuestring
      -- ------------------------------------
      -- End of code added by KnightErrant. |
      -- ------------------------------------

	  -- ------------------------------------
      -- Code added by Dagovax.        |
      -- ------------------------------------
		
		enableAnimPos = #()
		byte1 = ReadByte(fp2) #unsigned
		byte1string = reverseString(intToBinary(byte1))
		print (byte1string as string + "\t\t\t# bit bone positions (0-7 switched for ease of reading) at position = " + (ftell fp2) as string)
		byte2 = ReadByte(fp2) #unsigned
		byte2string = reverseString(intToBinary(byte2))
		print (byte2string as string + "\t\t\t# bit bone positions (8-15 switched for ease of reading) at position = " + (ftell fp2) as string)
		byte3 = ReadByte(fp2) #unsigned
		byte3string = reverseString(intToBinary(byte3))
		print (byte3string as string + "\t\t\t# bit bone positions (16-23 switched for ease of reading) at position = " + (ftell fp2) as string)
		allBonesPositions = append byte1string (append byte2string byte3string)

		byte4 = ReadByte(fp2) #unsigned
		byte4string = reverseString(intToBinary(byte4))
		if (byte4string != "00000000") then (
			print (byte4string as string + "\t\t\t# bit bone positions (unknown bones) at position = " + (ftell fp2) as string)
			allBonesPositions = allBonesPositions append byte4string
		)
		
		bonesPositionEnabled = #()
		bonesPositionEnabled = stringToCharArray allBonesPositions numBones1
		
		print (allBonesPositions as string + "\t\t\t# full set of postition bones at position = " + (ftell fp2) as string)
		
		singleByte = ReadByte(fp2)
		print (singleByte as string + "\t\t\t# single byte ( 0 ) " + (ftell fp2) as string)
		singleInteger = ReadByte(fp2)
		print (singleInteger as string + "\t\t\t# single integer = 0" + (ftell fp2) as string)
		
		print ("# ------------------------- End of file after reading full set of position bones " + (ftell fp2) as string)
	  -- ------------------------------------
      -- End of code added by Dagovax.        |
      -- ------------------------------------
		
		numBonesSet = numBones1+1
		
--		animate on for i=2 to numBones1  do (
		animate on for i=2 to numBonesSet  do 
		(
			deletekeys boneList[i].rotation.controller #allKeys
			if(i>2) then deletekeys boneList[i].position.controller #allKeys
			
			--boneList[i].rotation.controller = TCB_Rotation()
			boneList[i].rotation.controller = Euler_XYZ()
			
			-- ------------------------------------
			-- Code changed by Dagovax.        |
			-- ------------------------------------
			
			for k=1 to numFrames  do in coordsys boneList[i].parent 
			(						
				addnewkey boneList[i].rotation.controller k
				
				if(rootBone.name == "Armature") then
				(
					at time k boneList[i][3][2].rotation = quat (boneVecs[k][i-1].rot.x) (boneVecs[k][i-1].rot.z) (boneVecs[k][i-1].rot.y)  ( -boneVecs[k][i-1].scale )
				)
				else
				(
					at time k boneList[i][3][2].rotation = quat (-boneVecs[k][i-1].rot.x) (-boneVecs[k][i-1].rot.z) (boneVecs[k][i-1].rot.y)  ( -boneVecs[k][i-1].scale )
				)
				print("Set rotation of bone '" + boneList[i].name as string + "' of frame " + k as string + " to " + boneList[i][3][2].rotation as string)
				
				local cont = progressUpdate ( ( ( ((i-2)*numFrames)+k as float)/(numFrames*numBones1) )* 100)
				if NOT cont then return true
			)
			print ("# ------------------------- End of setting rotation bone \t\t" + boneList[i].name as string)
			
			-- ------------------------------------
			-- End of code changed by Dagovax.        |
			-- ------------------------------------
		)--end bones
		print ("# ------------------------- End of setting rotation of all bones")
		
		bonePosLinesRead = 1
		
		defaultBonePosArr = #()
		for i = 1 to numBonesSet do  (
			append defaultBonePosArr boneList[i].pos
		)
		
		animate on for k = 1 to numFrames do  (
			for i = 1 to numBonesSet do  (
				parentOrRootBone = checkParentNodeExist(boneList[i].parent)
				--print parentOrRootBone as string
				in coordsys parentOrRootBone

				-- ADDED
				if (bonesPositionEnabled[i] == "1") then (
					print ("-- bone "+ boneList[i].name as string + " has a position animation! Adding the position controller now!")
					boneList[i].position.controller = Position_XYZ()
					
					if i > 1 then
					(
						addnewkey boneList[i].position.controller k
						--print("Frame " + k as string + " xyz pos of bone " + boneList[i].name as string + " should be " + bonePos[bonePosLinesRead] as string)
						print("Calculating position coords for bone "+ boneList[i].name as string + ". Default pos: \t" + defaultBonePosArr[i] as string + "\tcas file coords:" + bonePos[bonePosLinesRead] as string)
						at time k boneList[i].position.controller.x_position = bonePos[bonePosLinesRead].x
						at time k boneList[i].position.controller.y_position = bonePos[bonePosLinesRead].y
						at time k boneList[i].position.controller.z_position = defaultBonePosArr[i].z +bonePos[bonePosLinesRead].z 
					)

					bonePosLinesRead += 1
				) else (
					boneList[i].position.controller = TCB_Position()
					deletekeys boneList[i].position.controller #allKeys
				)
			)
		)
		
		progressEnd()
		print "Animation import successfully"
		
		--print ("pos" + (ftell fp) as string)
		fclose fp2
		animationRange =  interval 1 numFrames
		--frameRate = 20
		return 0 		--*/--ANIMATION ON HOLD OVER
)
	
on importButton pressed do --import
	(
local importPly fname = getOpenFileName types:"CAS (*.cas)|*.cas|All (*.*)|*.*|"
		if fname == undefined then return NULL
		fp =  fopen fname "rb"
		
		--Read Header--
		
		if not (GlobalHeader.read fp) then return 1
		--Read Bones--
		bChunk = BONESCHUNK animation:(importAnimation.state)
		bChunk.Read fp 
		
			--frames
		/* i dunno what this is really  -will need to get back to it
		if(numbones>1) then (
		fseek fp rootAnims #seek_set
		animate on for i=1 to vbones[2].numFrames do
		at time i pbones[2].pos =  point3 (ReadFloat fp) (ReadFloat fp) (ReadFloat fp)
		--fseek fp (vbones[2].numFrames*12) #seek_cur --unkown point3's
		)
		*/
		--local importPly fname2 = getOpenFileName types:"CAS (*.cas)|*.cas|All (*.*)|*.*|"
		--if fname2 == undefined then return NULL
		
		
		
		geomSet = GEOM_CHUNK 0		
		geomSet.Read fp
		
		--if(GlobalHeader.fileVersion >= 3.16) then 

		fseek fp 6 #seek_cur --3 shorts?
		--else fseek fp 3 #seek_cur --
		
		grabPos = ftell fp
		fseek fp 0 #seek_end
		secondMeshes =false

		if( ( (ftell fp) - grabPos) > 1024 ) then (--is this a hack or what
		secondMeshes = true
		fseek fp grabPos #seek_set
		geomSet1 = GEOM_CHUNK 0		
		geomSet1.Read fp
		)
		
		sliderTime = AnimationRange.start
		progressStart ("Setting up Mesh...")
		--print ("11111111:" + geomSet.geomChunks[2].newObj.numverts as string)
		for k= 1 to geomSet.geomChunks.count do(
		geomSet.geomChunks[k].newObj.pos +=bChunk.pbones[geomset.geomChunks[k].boneAttached+1].position
		--for i=1 to geomSet.geomChunks[k].newObj.numverts do 
		--setVert geomSet.geomChunks[k].newObj i ( (getvert  geomSet.geomChunks[k].newObj i)+pbones[geomset.geomChunks[k].boneAttached+1].position)
		convertToMesh( geomSet.geomChunks[k].newObj )
		geomSet.geomChunks[k].newObj.parent = bChunk.pbones[geomset.geomChunks[k].boneAttached+1]
		print geomSet.geomChunks[k].mesh1.textureid
		if geomSet.geomChunks[k].mesh1!=undefined and geomSet.geomChunks[k].mesh1.textureid!=-1 then geomSet.geomChunks[k].newObj.material= getMeditMaterial (geomSet.geomChunks[k].mesh1.textureid + 1)

		)
		if secondMeshes==true then
		for k= 1 to geomSet1.geomChunks.count do(
		for i=1 to geomSet1.geomChunks[k].newObj.numverts do 
		setVert geomSet1.geomChunks[k].newObj i ( (getvert  geomSet1.geomChunks[k].newObj i)+bChunk.pbones[geomset1.geomChunks[k].mesh1.vertAssign[i]+1 ].position)
		
		convertToMesh( geomSet1.geomChunks[k].newObj )
		update geomSet1.geomChunks[k].newObj geometry:true normals:true

		--add skin
		sm = skin()
		sm.rigid_vertices = true
		select geomSet1.geomChunks[k].newObj
		max modify mode
		addModifier geomSet1.geomChunks[k].newObj sm
		for j=2 to bChunk.pbones.count do
		skinOps.addbone sm ( getNodeByName bChunk.pbones[j].name) 1
		
		for i=1 to geomSet1.geomChunks[k].newObj.numverts do(
		skinOps.SetVertexWeights sm i (geomset1.geomChunks[k].mesh1.vertAssign[i]) 1.0
		local cont = progressUpdate ( ( (i as float)/(geomSet1.geomChunks[k].newObj.numverts) )* 100)
		if NOT cont then return true
			)
		
		)
		progressEnd()
		
		--

		--Read Textures...hack
		if(tagAction.state==2) then (
		fseek fp -12 #seek_end
		extraOffset = ReadLong fp
		if extraOffset>12 or extraOffset<0 then extraOffset=0
		fileSize = (ftell fp) + 8 - extraOffset 
		while ( (ReadLong fp)-4 != (filesize-(ftell fp)) ) do if (filesize-(ftell fp)) > 1024 then return 1 else fseek fp -5 #seek_cur  --find that sucker
		print ("texture@ " +(ftell fp) as string)
		fseek fp 4 #seek_cur
		numTextures=ReadLong fp
		strSkip=ReadLong fp
		fseek fp strSkip #seek_cur
		for i=1 to numTextures do(
			print (ftell fp)
			bmpName = ReadString fp

			if( (findString bmpName "textures") == undefined) then bmpName = "\\textures" +bmpName

			bAlreadySlash= bmpName[1]=="\\"
			if( (findString bmpName ".DDS") == undefined) then bmpName+=".DDS"
			fseek fp 62 #seek_cur
			
			if (promptForMissing.checked==false) then pathName = getPath bAlreadySlash fname
			else ( if( (findString g_gameDataPath "textures") != undefined) then pathname = getPath bAlreadySlash g_gameDataPath
					else pathName = g_gameDataPath )
			
			if not bAlreadySlash and (pathName[pathName.count]!="\\") then pathName+="\\"
			fullname = pathName + (bmpName)

			tm = bitMapTexture()
			tm.filename = fullname
			print fullname
			mat = getMeditMaterial i -- -- --
			if mat==undefined then mat=standardMaterial diffuseMap:tm
			else mat.diffuseMap=tm
			try (showTextureMap mat tm on) catch ()
			setMeditMaterial i mat
			--mat1 = getMeditMaterial i
			
			)

		)
		--We're Done, yay!
		print ("Import finished, End Pos: "  + (ftell fp) as string)
		fclose fp
		CompleteRedraw()
	)
 
 )--End Import
 on CASIE open do (
 
 	if CASExport!=undefined and CASExport.open==true then (
	removeRollout CASExport
 	addRollout CASExport rolledup:false
	)
	else addRollout CASExport rolledup:true
	
	if CASImport!=undefined and CASImport.open==true then (
	removeRollout CASImport 
	addRollout CASImport rolledup:false

	)
	else addRollout CASImport rolledup:true
	
  )
  on CASIE close do (
	removeRollout CASImport --rolledup:true
	removeRollout CASExport --rolledup:true

	
  )
)--End Utility


