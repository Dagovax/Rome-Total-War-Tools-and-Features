-------------------------------------------
--										 --
--  Vertex Weights to 1,0 --
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

utility VertexWeightsToSingleBone "RTW Single Vertex Weight"
(
	group "Info:"
	(
		label titleLabel1 "Single Vertex Weight"
		label extraLabel "for Rome: Total War"
		label titleLabel2 "v1.0" color:(color 0 20 80)
		label empt " "
		label titleLabel3 "Reads the Skin mod and sets" color:(color 0 180 50)
		label extraLabel2 "multiple vertex weights" color:(color 0 180 50)
		HyperLink author "by Sirrianus Dagovax" align:#center address:"mailto:dagovax@gmail.com" color:(color 0 0 170) hoverColor:(color 170 0 0)
	)
	button setWeights "Single Vertex Weights" width:150 height:30
	
	on setWeights pressed do
	(
		canContinue = true
		allObjects = for b in objects where (classOf b == Editable_Mesh)  collect b
		
		-- First get all bones
		pointers = makeUniqueArray (for t in objects where (classOf t == Dummy) collect t)
		if pointers.count == 0 then
		(
			messageBox "There are no bones in this scene!" title:"Error!"
			canContinue = false
		)
		
		-- Then check if Armature is present, thust rootbone
		armature = getNodeByName "Armature" exact:true
		if (armature == undefined) and canContinue == true then 
		(
			messageBox "There is no Armature root bone!" title:"Error!"
			canContinue = false
		)
		
		-- Check Skin modifier and if all vertices for each objects are weighted
		if (canContinue == true) then
		(
			skinChecked = false
			for obj in allObjects do
			(
				theMods = for m in obj.modifiers where (classOf m == Skin) collect m
				if(theMods == undefined) or (theMods.count == 0) then
				(
					messageBox ("There is no Skin modifier present for object " + obj.name as string) title:"Error!"
					canContinue = false
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
							MessageBox ("Problem occured while reading the vertex weights of vertex " + ( (i-1) as string) +" in mesh " +obj.name + ". Make sure each vertex has a bone weight") title:"Error!"
							canContinue = false
							exit
						)
					)
					max create mode
					deselect obj
				)
			)
		)
		
		-- Main script now
		if(canContinue == true) then 
		(
			-- Only add the modifier to the lod1 (to speed up things)
			print "Setting Vertex Weights of all objects to 1.0"
			for curr in allObjects do
			(
				numVerts = getNumVerts curr
				select curr
				max modify mode
				for i=1 to numVerts do 
				(
					boneArray = #()
					weightArray = #()
					newWeightArray = #()
					newBoneArray = #()
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
				deselect curr
			)
		)
	)
)