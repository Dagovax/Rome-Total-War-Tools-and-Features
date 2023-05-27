-------------------------------------------
--										 --
--  Rome: Total War Settlement Bone exporter  --
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

-------------------------------------------
--		STANDARD UNIT			--
-------------------------------------------

-- Returns the string info before the coords, based of semi_fast_dagger
fn CreateSoldierStringsTemplate = 
(
	print "...Using Standard Soldier Skeleton Format"
	stringArr = #()
	
	s1 = "  0   0   0  63   0   0   0   0"
	s2 = "114   0 109  97   0   0   0   0"
	s3 = "  0   0   0   0   0   0   0   0"
	s4 = "114   0 109  97   0   0   0   0"
	s5 = " 32   0  32  32   0   0   0   0"
	s6 = " 72   1   0   0   0   0   0   0"
	s7 = " 59   1  59  59   0   0   0   0"
	s8 = " 59   0  59  59   0   0   0   0"
	s9 = " 59   0  59  59   0   0   0   0"
	s10 = " 59   0  32  65   0   0   0   0"
	s11 = " 10   0  59  13   0   0   0   0"
	s12 = " 59   0  59  59   0   0   0   0"
	s13 = " 59   0  59  59   5   0   0   0"
	s14 = " 59   0  59  59   0   0   0   0"
	s15 = " 78   0  95  66   0   0   0   0"
	s16 = "  0   0  65  78   4   0   0   0"
	s17 = " 78   0  32 117   0   0   0   0"
	s18 = " 79   0  32  13   0   0   0   0"
	s19 = "105   0  95 109   0   0   0   0"
	
	append stringArr s1
	append stringArr s2
	append stringArr s3
	append stringArr s4
	append stringArr s5
	append stringArr s6
	append stringArr s7
	append stringArr s8
	append stringArr s9
	append stringArr s10
	append stringArr s11
	append stringArr s12
	append stringArr s13
	append stringArr s14
	append stringArr s15
	append stringArr s16
	append stringArr s17
	append stringArr s18
	append stringArr s19
	
	return stringArr
)

-- Returns the number info after the coords, based of semi_fast_dagger
fn CreateSoldierNumberTemplate = 
(
	nrArr = #()
	
	n1= "-1"
	n2= " 0"
	n3= " 1"
	n4= " 2"
	n5= " 0"
	n6= " 4"
	n7= " 5"
	n8= " 5"
	n9= " 7"
	n10= " 8"
	n11= " 5"
	n12 = "10"
	n13 = "11"
	n14 = " 5"
	n15 = "13"
	n16 = "14"
	n17 = " 0"
	n18 = "16"
	n19 = "17"
	
	append nrArr n1
	append nrArr n2
	append nrArr n3
	append nrArr n4
	append nrArr n5
	append nrArr n6
	append nrArr n7
	append nrArr n8
	append nrArr n9
	append nrArr n10
	append nrArr n11
	append nrArr n12
	append nrArr n13
	append nrArr n14
	append nrArr n15
	append nrArr n16
	append nrArr n17
	append nrArr n18
	append nrArr n19
	
	return nrArr
)

-------------------------------------------
--		SLINGER UNIT			--
-------------------------------------------

fn CreateSlingerStringsTemplate = 
(
	print "...Using Slinger Skeleton Format"
	stringArr = #()
	
	s1 = "  0   0   0  63   0   0   0   0"
	s2 = "  0   0   0   0   0   0   0   0"
	s3 = "  0   0   0   0   0   0   0   0"
	s4 = "  0   0   0   0   0   0   0   0"
	s5 = "  0   0   0   0   0   0   0   0"
	s6 = "  0   1   0   0   0   0   0   0"
	s7 = "  0   1   0   0   0   0   0   0"
	s8 = "  0   0   0   0   0   0   0   0"
	s9 = "  0   0   0   0   0   0   0   0"
	s10 = "  0   0   0   0   0   0   0   0"
	s11 = "  0   0   0   0   0   0   0   0"
	s12 = "  0   0   0   0   0   0   0   0"
	s13 = "  0   0   0   0   5   0   0   0"
	s14 = "  0   0   0   0   0   0   0   0"
	s15 = "  0   0   0   0   0   0   0   0"
	s16 = "  0   0   0   0   0   0   0   0"
	s17 = "  0   0   0   0   4   0   0   0"
	s18 = "  0   0   0   0   0   0   0   0"
	s19 = "  0   0   0   0   0   0   0   0"
	s20 = "  0   0   0   0   0   0   0   0"
	
	append stringArr s1
	append stringArr s2
	append stringArr s3
	append stringArr s4
	append stringArr s5
	append stringArr s6
	append stringArr s7
	append stringArr s8
	append stringArr s9
	append stringArr s10
	append stringArr s11
	append stringArr s12
	append stringArr s13
	append stringArr s14
	append stringArr s15
	append stringArr s16
	append stringArr s17
	append stringArr s18
	append stringArr s19
	append stringArr s20
	
	return stringArr
)

-- Returns the number info after the coords, based of semi_fast_dagger
fn CreateSlingerNumberTemplate = 
(
	nrArr = #()
	
	n1= "-1"
	n2= " 0"
	n3= " 1"
	n4= " 2"
	n5= " 0"
	n6= " 4"
	n7= " 5"
	n8= " 5"
	n9= " 7"
	n10= " 8"
	n11= " 5"
	n12 = "10"
	n13 = "11"
	n14 = "12"
	n15 = " 5"
	n16 = "14"
	n17 = "15"
	n18 = " 0"
	n19 = "17"
	n20 = "18"
	
	append nrArr n1
	append nrArr n2
	append nrArr n3
	append nrArr n4
	append nrArr n5
	append nrArr n6
	append nrArr n7
	append nrArr n8
	append nrArr n9
	append nrArr n10
	append nrArr n11
	append nrArr n12
	append nrArr n13
	append nrArr n14
	append nrArr n15
	append nrArr n16
	append nrArr n17
	append nrArr n18
	append nrArr n19
	append nrArr n20
	
	return nrArr
)

-------------------------------------------
--		HORSE UNIT			--
-------------------------------------------

fn CreateHorseStringsTemplate = 
(
	print "...Using Horse Skeleton Format"
	stringArr = #()
	
	s1 = "  0   0   0   0   1   0   0   0"
	s2 = " 63   0  80  51   0   0   0   0"
	s3 = " 39   0 127  63   0   0   0   0"
	s4 = " 36   0  33 183   0   0   0   0"
	s5 = " 68   0 127  63   0   0   0   0"
	s6 = "106   0 247 183   0   0   0   0"
	s7 = " 59   0 127  63   0   0   0   0"
	s8 = "247   0 211  55   0   0   0   0"
	s9 = " 57   0 127  63   0   0   0   0"
	s10 = " 96   0  14  57   0   0   0   0"
	s11 = "204   0 127  63   0   0   0   0"
	s12 = "195   0 121  56   0   0   0   0"
	s13 = "193   0 127  63   0   0   0   0"
	s14 = "202   0  64  49   0   0   0   0"
	s15 = " 27   0 127  63   0   0   0   0"
	s16 = "117   0 168  49   0   0   0   0"
	s17 = "143   0 127  63   0   0   0   0"
	s18 = "232   0  91  49   0   0   0   0"
	s19 = " 56   0 127  63   0   0   0   0"
	s20 = " 13   0  82  49   0   0   0   0"
	
	append stringArr s1
	append stringArr s2
	append stringArr s3
	append stringArr s4
	append stringArr s5
	append stringArr s6
	append stringArr s7
	append stringArr s8
	append stringArr s9
	append stringArr s10
	append stringArr s11
	append stringArr s12
	append stringArr s13
	append stringArr s14
	append stringArr s15
	append stringArr s16
	append stringArr s17
	append stringArr s18
	append stringArr s19
	append stringArr s20
	
	return stringArr
)

-- Returns the number info after the coords, based of semi_fast_dagger
fn CreateHorseNumberTemplate = 
(
	nrArr = #()
	
	n1= "-1"
	n2= " 0"
	n3= " 1"
	n4= " 2"
	n5= " 1"
	n6= " 4"
	n7= " 5"
	n8= " 6"
	n9= " 1"
	n10= " 8"
	n11= " 9"
	n12 = "10"
	n13 = " 0"
	n14 = "12"
	n15 = "13"
	n16 = " 0"
	n17 = "15"
	n18 = " 0"
	n19 = "17"
	n20 = "18"
	
	append nrArr n1
	append nrArr n2
	append nrArr n3
	append nrArr n4
	append nrArr n5
	append nrArr n6
	append nrArr n7
	append nrArr n8
	append nrArr n9
	append nrArr n10
	append nrArr n11
	append nrArr n12
	append nrArr n13
	append nrArr n14
	append nrArr n15
	append nrArr n16
	append nrArr n17
	append nrArr n18
	append nrArr n19
	append nrArr n20
	
	return nrArr
)

-------------------------------------------
--		AFRICAN ELEPHANT UNIT			--
-------------------------------------------

fn CreateAfricanElephantStringsTemplate = 
(
	print "...Using African Elephant Skeleton Format"
	stringArr = #()
	
	s1 = "  0   0   0   0   2   0   0   0"
	s2 = " 97   0 101 114   0   0   0   0"
	s3 = "  0   0   0   0   0   0   0   0"
	s4 = " 97   0 101 114   0   0   0   0"
	s5 = " 32   0  32  32   0   0   0   0"
	s6 = "188   0   0   0   0   0   0   0"
	s7 = " 41   0  63 188   0   0   0   0"
	s8 = "251   0 227 188   0   0   0   0"
	s9 = "  3   0   6 189   0   0   0   0"
	s10 = " 28   0 173 188   0   0   0   0"
	s11 = " 84   0 190  59   0   0   0   0"
	s12 = "105   0 231  60   0   0   0   0"
	s13 = "254   0   6  61   0   0   0   0"
	s14 = "117   0 219  60   0   0   0   0"
	s15 = " 85   0 158  60   0   0   0   0"
	s16 = " 65   0  92  60   0   0   0   0"
	s17 = "230   0  16  60   0   0   0   0"
	s18 = " 41   0 177  59   0   0   0   0"
	s19 = "154   0  65  59   0   0   0   0"
	s20 = "218   0 174  58   0   0   0   0"
	s21 = "230   0 189  57   0   0   0   0"
	s22 = "188   0   0 185   0   0   0   0"
	s23 = "193   0 151 185   0   0   0   0"
	s24 = "202   0 160 185   0   0   0   0"
	
	append stringArr s1
	append stringArr s2
	append stringArr s3
	append stringArr s4
	append stringArr s5
	append stringArr s6
	append stringArr s7
	append stringArr s8
	append stringArr s9
	append stringArr s10
	append stringArr s11
	append stringArr s12
	append stringArr s13
	append stringArr s14
	append stringArr s15
	append stringArr s16
	append stringArr s17
	append stringArr s18
	append stringArr s19
	append stringArr s20
	append stringArr s21
	append stringArr s22
	append stringArr s23
	append stringArr s24
	
	return stringArr
)

-- Returns the number info after the coords, based of semi_fast_dagger
fn CreateAfricanElephantNumberTemplate = 
(
	nrArr = #()
	
	n1= "-1"
	n2= " 0"
	n3= " 1"
	n4= " 1"
	n5= " 3"
	n6= " 4"
	n7= " 1"
	n8= " 6"
	n9= " 7"
	n10= " 0"
	n11= " 9"
	n12 = "10"
	n13 = "11"
	n14 = "12"
	n15 = " 9"
	n16 = "14"
	n17 = " 9"
	n18 = "16"
	n19 = " 0"
	n20 = "18"
	n21 = "19"
	n22 = " 0"
	n23 = "21"
	n24 = "22"
	
	append nrArr n1
	append nrArr n2
	append nrArr n3
	append nrArr n4
	append nrArr n5
	append nrArr n6
	append nrArr n7
	append nrArr n8
	append nrArr n9
	append nrArr n10
	append nrArr n11
	append nrArr n12
	append nrArr n13
	append nrArr n14
	append nrArr n15
	append nrArr n16
	append nrArr n17
	append nrArr n18
	append nrArr n19
	append nrArr n20
	append nrArr n21
	append nrArr n22
	append nrArr n23
	append nrArr n24
	
	return nrArr
)

-------------------------------------------
--		INDIAN ELEPHANT UNIT			--
-------------------------------------------

fn CreateIndianElephantStringsTemplate = 
(
	print "...Using Indian Elephant Skeleton Format"
	stringArr = #()
	
	s1 = "  0   0   0   0   2   0   0   0"
	s2 = "  0   0   0   0   0   0   0   0"
	s3 = "  0   0   0   0   0   0   0   0"
	s4 = "  0   0   0   0   0   0   0   0"
	s5 = "  0   0   0   0   0   0   0   0"
	s6 = "  0   0   0   0   0   0   0   0"
	s7 = "  0   0   0   0   0   0   0   0"
	s8 = "  0   0   0   0   0   0   0   0"
	s9 = "  0   0   0   0   0   0   0   0"
	s10 = "  0   0   0   0   0   0   0   0"
	s11 = "  0   0   0   0   0   0   0   0"
	s12 = "  0   0   0   0   0   0   0   0"
	s13 = "  0   0   0   0   0   0   0   0"
	s14 = "  0   0   0   0   0   0   0   0"
	s15 = "  0   0   0   0   0   0   0   0"
	s16 = "  0   0   0   0   0   0   0   0"
	s17 = "  0   0   0   0   0   0   0   0"
	s18 = "  0   0   0   0   0   0   0   0"
	s19 = "  0   0   0   0   0   0   0   0"
	s20 = "  0   0   0   0   0   0   0   0"
	s21 = "  0   0   0   0   0   0   0   0"
	s22 = "  0   0   0   0   0   0   0   0"
	s23 = "  0   0   0   0   0   0   0   0"
	s24 = "  0   0   0   0   0   0   0   0"
	
	append stringArr s1
	append stringArr s2
	append stringArr s3
	append stringArr s4
	append stringArr s5
	append stringArr s6
	append stringArr s7
	append stringArr s8
	append stringArr s9
	append stringArr s10
	append stringArr s11
	append stringArr s12
	append stringArr s13
	append stringArr s14
	append stringArr s15
	append stringArr s16
	append stringArr s17
	append stringArr s18
	append stringArr s19
	append stringArr s20
	append stringArr s21
	append stringArr s22
	append stringArr s23
	append stringArr s24
	
	return stringArr
)

-- Returns the number info after the coords, based of semi_fast_dagger
fn CreateIndianElephantNumberTemplate = 
(
	nrArr = #()
	
	n1= "-1"
	n2= " 0"
	n3= " 1"
	n4= " 1"
	n5= " 3"
	n6= " 4"
	n7= " 1"
	n8= " 6"
	n9= " 7"
	n10= " 0"
	n11= " 9"
	n12 = "10"
	n13 = "11"
	n14 = "12"
	n15 = " 9"
	n16 = "14"
	n17 = " 9"
	n18 = "16"
	n19 = " 0"
	n20 = "18"
	n21 = "19"
	n22 = " 0"
	n23 = "21"
	n24 = "22"
	
	append nrArr n1
	append nrArr n2
	append nrArr n3
	append nrArr n4
	append nrArr n5
	append nrArr n6
	append nrArr n7
	append nrArr n8
	append nrArr n9
	append nrArr n10
	append nrArr n11
	append nrArr n12
	append nrArr n13
	append nrArr n14
	append nrArr n15
	append nrArr n16
	append nrArr n17
	append nrArr n18
	append nrArr n19
	append nrArr n20
	append nrArr n21
	append nrArr n22
	append nrArr n23
	append nrArr n24
	
	return nrArr
)

-------------------------------------------
--		HUMAN ELEPHANT UNIT			--
-------------------------------------------

fn CreateElephantAsHumanStringsTemplate = 
(
	print "...Using Indian Elephant Skeleton Format"
	stringArr = #()
	
	s1 = "  0   0   0   0   2   0   0   0"
	s2 = "  0   0   0   0   0   0   0   0"
	s3 = "  0   0   0   0   0   0   0   0"
	s4 = "  0   0   0   0   0   0   0   0"
	s5 = "  0   0   0   0   0   0   0   0"
	s6 = "  0   0   0   0   0   0   0   0"
	s7 = "  0   0   0   0   0   0   0   0"
	s8 = "  0   0   0   0   0   0   0   0"
	s9 = "  0   0   0   0   0   0   0   0"
	s10 = "  0   0   0   0   0   0   0   0"
	s11 = "  0   0   0   0   0   0   0   0"
	s12 = "  0   0   0   0   0   0   0   0"
	s13 = "  0   0   0   0   0   0   0   0"
	s14 = "  0   0   0   0   0   0   0   0"
	s15 = "  0   0   0   0   0   0   0   0"
	s16 = "  0   0   0   0   0   0   0   0"
	s17 = "  0   0   0   0   0   0   0   0"
	s18 = "  0   0   0   0   0   0   0   0"
	s19 = "  0   0   0   0   0   0   0   0"
	s20 = "  0   0   0   0   0   0   0   0"
	s21 = "  0   0   0   0   0   0   0   0"
	s22 = "  0   0   0   0   0   0   0   0"
	s23 = "  0   0   0   0   0   0   0   0"
	s24 = "  0   0   0   0   0   0   0   0"
	
	append stringArr s1
	append stringArr s2
	append stringArr s3
	append stringArr s4
	append stringArr s5
	append stringArr s6
	append stringArr s7
	append stringArr s8
	append stringArr s9
	append stringArr s10
	append stringArr s11
	append stringArr s12
	append stringArr s13
	append stringArr s14
	append stringArr s15
	append stringArr s16
	append stringArr s17
	append stringArr s18
	append stringArr s19
	append stringArr s20
	append stringArr s21
	append stringArr s22
	append stringArr s23
	append stringArr s24
	
	return stringArr
)

-- Returns the number info after the coords, based of dagovax human based elephant
fn CreateElephantAsHumanNumberTemplate = 
(
	nrArr = #()
	
	n1= "-1"
	n2= " 0"
	n3= " 1"
	n4= " 2"
	n5= " 3"
	n6= " 4"
	n7= " 2"
	n8= " 2"
	n9= " 7"
	n10= " 8"
	n11= " 2"
	n12 = "10"
	n13 = "11"
	n14 = " 0"
	n15 = "13"
	n16 = "14"
	n17 = " 0"
	n18 = "16"
	n19 = "17"
	n20 = " 0"
	n21 = " 0"
	n22 = " 0"
	n23 = " 0"
	n24 = " 0"
	
	append nrArr n1
	append nrArr n2
	append nrArr n3
	append nrArr n4
	append nrArr n5
	append nrArr n6
	append nrArr n7
	append nrArr n8
	append nrArr n9
	append nrArr n10
	append nrArr n11
	append nrArr n12
	append nrArr n13
	append nrArr n14
	append nrArr n15
	append nrArr n16
	append nrArr n17
	append nrArr n18
	append nrArr n19
	append nrArr n20
	append nrArr n21
	append nrArr n22
	append nrArr n23
	append nrArr n24
	
	return nrArr
)

utility BonePositionExporter "Bone Coordinate Exporter"
(
	group "Info:"
	(
		label titleLabel1 "Bone Coordinate Exporter"
		label extraLabel "for Rome: Total War"
		label titleLabel2 "v1.0" color:(color 0 20 80)
		label empt " "
		label titleLabel3 "Use this tool to export bone" color:(color 0 180 50)
		label extraLabel2 "coordinates for skeleton files" color:(color 0 180 50)
		HyperLink author "by Sirrianus Dagovax" align:#center address:"mailto:dagovax@gmail.com" color:(color 0 0 170) hoverColor:(color 170 0 0)
	)
	label fillerLabel1 " "
	button export "Export Bone Coordinates" width:130 height:30

	on export pressed do
	(
		useFormat = false		
		
		pointers = for t in objects where (classOf t == Point) and (t.name != "Scene Root") collect t
		dummies = for t in objects where (classOf t == Dummy) and (t.name != "Armature") collect t
		
		--Check if there are bones, otherwise, close message
		if (pointers.count == 0 and dummies.count == 0) then
		(
			messageBox "There are no bones in this scene!"
		)
		else
		(
			counter = 0
			
			--Dialog to let the user select the wanted bone structure
			local boneSelectorDialog = rollout selectorDialog "Choose used base Skeleton"
			(
				local returnID
				
				label lblHeader "In the list below, select the"
				label lblHeader2 "base skeleton you altered"
				label nothing ""
				dropdownlist list "Choose an option:" items:#("Standard Unit (for example fs_dagger)","Slinger (they have an extra bone)","Horse","African Elephant","Indian Elephant","Dagovax's Human bone based Elephant","\nSomething else, just give me the coords per bone please!") selection:1 height:9 
				button btn_test "Continue" height:20

				fn init val:undefined =
				(
					try destroyDialog selectorDialog catch()
					returnID = val
					createDialog selectorDialog modal:true width:250 height:150
					returnID
				)
				
				on selectorDialog open do
				(
					returnID = list.selection
				)
				
				on list selected i do
				(
					returnID = i
				)
				
				on btn_test pressed do
				(
					destroyDialog selectorDialog
				)
			)
			
			result = selectorDialog.init()
			
			if (result >= 7 or result == undefined) then
			(
				useFormat = false
				print "Not using any format"
			)
			else
			(
				useFormat = true
				strResult = "Using format "+ (result as string)
				print strResult
			)
			
			output = newScript()		
			isCollada = false
			boneArr = #()
			if(pointers.count > 0) then
			(
				boneArr = pointers
				isCollada = false
				print "Model imported using CAS importer script"
			) else if (dummies.count > 0) then 
			(
				boneArr = dummies
				isCollada = true
				print "Model imported using Open COLLADA importer"
			)
			
			for i in boneArr do
			(	
				counter = counter + 1
				tempzeros = "000000000000"
				x = i.pos.x
				y = i.pos.y
				z = i.pos.z
				
				-- Loop through parent if it has one and compare the difference
				if i.parent != undefined then
				(
					parent = i.parent
				
					-- Gets the height difference between the parent and child
					if parent.pos.z < z then
					(
						z = (i.pos.z - parent.pos.z)
					) else
					(
						z = (parent.pos.z - i.pos.z) *-1
					)
					
					-- Gets the horizontal 'x' difference between the parent and child
					if parent.pos.x < x then
					(
						x = (i.pos.x - parent.pos.x) *-1
					) else
					(
						x = (parent.pos.x - i.pos.x) 
					)
					
					-- Gets the depth 'y' difference between the parent and child
					if parent.pos.y < y then
					(
						y = (i.pos.y - parent.pos.y) *-1
					) else
					(
						y = (parent.pos.y - i.pos.y) 
					)
					
				) else
				(
					x = (i.pos.x as string)
					y = (i.pos.y as string)
					z = (i.pos.z as string)
				)
				
				if (isCollada) then
				(
					x = x * -1
					y = y * -1
				)
				
				-- git rit of the scientific notation
				if (x > -0.0001) and (x < 0.0001) then
				(
					x = 0.0
				)
				if (y > -0.0001) and (y < 0.0001) then
				(
					y = 0.0
				)
				if (z > -0.0001) and (z < 0.0001) then
				(
					z = 0.0
				)
				
				-- if there is no '-', add a '+'.
				if findString (x as string) "-" == undefined then
				(
					x = "+" + (x as string)
				)
				if findString (y as string) "-" == undefined then
				(
					y = "+" + (y as string)
				)
				if findString (z as string) "-" == undefined then
				(
					z = "+" + (z as string)
				)
				
				-- fill all strings with extra zeros before using substring
				x = (x as string) + tempzeros
				y = (y as string) + tempzeros
				z = (z as string) + tempzeros
				
				-- Set the string length
				x = substring x 1 10
				y = substring y 1 10
				z = substring z 1 10
				
				if useFormat == true then
				(
					--Set the results. Use the format using the different functions
					case of
					(
						(result == 1):
						(
							--Use standard unit format
							stringArr = CreateSoldierStringsTemplate()
							numberArr = CreateSoldierNumberTemplate()
						)
						(result == 2):
						(
							--Use slinger unit format
							stringArr = CreateSlingerStringsTemplate()
							numberArr = CreateSlingerNumberTemplate()
						)
						(result == 3):
						(
							--Use horse unit format
							stringArr = CreateHorseStringsTemplate()
							numberArr = CreateHorseNumberTemplate()
						)
						(result == 4):
						(
							--Use african elephant unit format
							stringArr = CreateAfricanElephantStringsTemplate()
							numberArr = CreateAfricanElephantNumberTemplate()
						)
						(result == 5):
						(
							--Use indian elephant unit format
							stringArr = CreateIndianElephantStringsTemplate()
							numberArr = CreateIndianElephantNumberTemplate()
						)
						(result == 6):
						(
							--Use Dagovax's human pelvis
							stringArr = CreateElephantAsHumanStringsTemplate()
							numberArr = CreateElephantAsHumanNumberTemplate()
						)
						default:
						(
							stringArr = CreateSoldierStringsTemplate()
							numberArr = CreateSoldierNumberTemplate()
						)
					)
					
					format "%   %   %   %    %\n" \
					stringArr[counter] x z y numberArr[counter] to:output
				) else
				(
					format "%:\t\t%   %   %\n" \
					i.name x z y to:output
				)
			)
		)
		print "Succesfully created the bone skeleton coordinates!"
	)
)
