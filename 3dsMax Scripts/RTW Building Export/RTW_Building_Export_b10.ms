-------------------------------------------
--										 --
--  Rome: Total War Building Exporter  --
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
-- v0.5 -- current  					 --
--										 --
-------------------------------------------



utility BuildingExporter "Building Exporter"
(
	group "About:"
	(
		label titleLabel1 "Rome: Total War Settlement"
		label titleLabel2 "Building Export Script, v1.0"
		--label titleLabel3 " "
		HyperLink author "by Sirrianus Dagovax" align:#center address:"mailto:dagovax@gmail.com" color:(color 0 0 170) hoverColor:(color 170 0 0)
	)
	label fillerLabel1 " "
	button export "Export Selected Building(s)" width:150 height:30

	on export pressed do
	(
		tmpSelArr = for t in selection collect t
		questioned = false
		useChildHeight = false
		doForAllGroups = false
		dontAskAgain = false
		
		output = newScript()		
		
		for i in selection where hasProperty i "boxSize" do
		(		
			childrenHeight = 0
			finalHeight = 0
			startHeight = i.pos.z
			
			childrenArr = i.children
		
			counter = childrenArr.count
		
			for c in childrenArr where not isGroupHead c do
			(
				childrenHeight += c.pos.z
			)
		
			case counter of
			(
				0: childenHeight = 0.0
				default: childrenHeight = (childrenHeight / counter)
			)
			
			if questioned == false then
			(
				quesString = "You have selected a group '"+ i.name + "'. Do you want to use the average height (z= "+childrenHeight as string+") of its children objects?"
				quessTitle = i.name + " (x="+i.pos.x as string +", y="+i.pos.y as string +", z="+i.pos.z as string+")"
				if queryBox quesString title:quessTitle beep:false then
				(
					useChildHeight = true
				) else
				(
					useChildHeight = false
				)
				if dontAskAgain == false then
				(
					if queryBox "Do you want to do this for every group that will follow?" title: "Use Children Height for All Groups" beep:false then
					(
						doForAllGroups = true
						questioned = true
						dontAskAgain = true
					) else
					(
						doForAllGroups = false
						dontAskAgain = true
					)
				)
			)
		
			
			if useChildHeight == true then
			(
				finalHeight = childrenHeight
			) else 
			(
				finalHeight = startHeight
			)
			
			x = i.pos.x*-1
			y = i.pos.y*-1
			z = finalHeight
			rot = i.rotation.z_rotation
			format "%,\t\t\t%,\t\t\t%,\t\t\t%,\t\t\t%\n" \
			i.name x y rot z to:output
		)
		
		tmpArr = for o in selection where (not isGroupMember o) and (not isGroupHead o) collect o
		
		for i in tmpArr do
		(			
			x = i.pos.x*-1
			y = i.pos.y*-1
			z = i.pos.z
			rot = i.rotation.z_rotation
			format "%,\t\t\t%,\t\t%,\t\t%,\t\t%\n" \
			i.name x y rot z to:output
		)
		
		select tmpSelArr
	)
)
