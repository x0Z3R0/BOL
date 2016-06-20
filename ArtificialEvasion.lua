
local version = 0.12
local sEnemies = GetEnemyHeroes()
local sAllies = GetAllyHeroes()
local lastRemove = 0
local count = 0
local going = 0
local spells = {}
local spells_number = 50
local nextTick = 0
local nextTick2 = 0
local sEnemiesName = {}
local enemiesData = {}
local QenemiesNames = {}
local WenemiesNames = {}
local EenemiesNames = {}
local RenemiesNames = {}
local EX_SECS = 50
local myPath
local evading = false
local bestEvadePoint
local ep
local currentDirectory = "Default"
local configsDir = {}
local configIndex = 1
local savedPos 
local running_Evasion = false

function Print(message) print("<font color=\"#3399FF\"><b>Artificial Evasion (Alpha):</font> </b><font color=\"#FFFFFF\">" .. message) end

function PrintError(message) print("<font color=\"#FF2222\"><b>MISCRIPT ERROR:</font> </b><font color=\"#AA2222\">" .. message) end


function DrawLineA(x1, y1, x2, y2, color)
  DrawLine(x1, y1, x2, y2, 1, color)
end


--------------------[Credits: remembermyhentai and HeRoBaNd]--------------------
function DrawFPSCircle(x, z, radius, color, quality)
  	for i = -radius * math.cos(math.pi/4), radius * math.cos(math.pi/4) - 1, radius * math.cos(math.pi/4)/quality do
	    local v = WorldToScreen(D3DXVECTOR3((x + i), myHero.y, (z + math.sqrt(radius * radius - i * i))))
	    local c = WorldToScreen(D3DXVECTOR3((x + i), myHero.y, (z - math.sqrt(radius * radius - i * i))))
	    local k = WorldToScreen(D3DXVECTOR3((x + i + radius * math.cos(math.pi/4)/quality), myHero.y, (z + math.sqrt(radius * radius - (i + radius * math.cos(math.pi/4)/quality) * (i + radius * math.cos(math.pi/4)/quality)))))
    	local n = WorldToScreen(D3DXVECTOR3((x + i + radius * math.cos(math.pi/4)/quality), myHero.y, (z - math.sqrt(radius * radius - (i + radius * math.cos(math.pi/4)/quality) * (i + radius * math.cos(math.pi/4)/quality)))))
    	if (v.x > 0 and v.x < WINDOW_W) and (v.y > 0 and v.y < WINDOW_H) and (k.x > 0 and k.x < WINDOW_W) and (k.y > 0 and k.y < WINDOW_H) then
      		DrawLineA(v.x, v.y, k.x, k.y, color)
    	end
    	if (c.x > 0 and c.x < WINDOW_W) and (c.y > 0 and c.y < WINDOW_H) and (n.x > 0 and n.x < WINDOW_W) and (n.y > 0 and n.y < WINDOW_H) then
      		DrawLineA(c.x, c.y, n.x, n.y, color)
    	end
  	end

  	for i = -radius * math.cos(math.pi/4), radius * math.cos(math.pi/4) - 1, radius * math.cos(math.pi/4)/quality do
	    local v = WorldToScreen(D3DXVECTOR3((x + math.sqrt(radius * radius - i * i)), myHero.y, (z + i)))
	    local c = WorldToScreen(D3DXVECTOR3((x - math.sqrt(radius * radius - i * i)), myHero.y, (z + i)))
	    local k = WorldToScreen(D3DXVECTOR3((x + math.sqrt(radius * radius - (i + radius * math.cos(math.pi/4)/quality) * (i + radius * math.cos(math.pi/4)/quality))), myHero.y, (z + i + radius * math.cos(math.pi/4)/quality)))
    	local n = WorldToScreen(D3DXVECTOR3((x - math.sqrt(radius * radius-(i + radius * math.cos(math.pi/4)/quality) * (i + radius * math.cos(math.pi/4)/quality))), myHero.y, (z + i + radius*  math.cos(math.pi/4)/quality)))
   		if (v.x > 0 and v.x < WINDOW_W) and (v.y > 0 and v.y < WINDOW_H) and (k.x > 0 and k.x < WINDOW_W) and (k.y > 0 and k.y < WINDOW_H) then
      		DrawLineA(v.x, v.y, k.x, k.y, color)
    	end
    	if (c.x > 0 and c.x < WINDOW_W) and (c.y > 0 and c.y < WINDOW_H) and (n.x > 0 and n.x < WINDOW_W) and (n.y > 0 and n.y < WINDOW_H) then
      		DrawLineA(c.x, c.y, n.x, n.y, color)
    	end
  	end
end

--------------------[Credits: remembermyhentai and HeRoBaNd]--------------------


function split(str, pat)
   local t = {} 
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function LoadChampData()
	Print("Loaded " .. currentDirectory .. " spells config")

	Config = scriptConfig("ArtificalEvasion", "configuration")
	Config:addParam("evade", "Evade", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("draw", "Draw", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("drawCT", "Draw Collision Trigger", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("optCircle", "Optimize Circles", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("msg", "Print msg", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("goUpDirectory", "Next Config", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("N"))
	Config:addParam("goDownDirectory", "Before Config", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("M"))
	Config:addSubMenu("Spells","enemySpells")
	for i, enemy in pairs(sEnemies) do
		if enemy and enemy.charName then
			print(enemy.charName .. ":")
			local err = false
			sEnemiesName[i] = enemy.charName
			enemiesData[i] = {}
			enemyData = ReadFile("./Data/" .. currentDirectory .. "/" .. enemy.charName .. "Q.dat")
			if(enemyData) then
				t = split(enemyData,' ')
				enemiesData[i][1] = {}
				if(t[1]) then
					if(t[1] == "Circular" or t[1] == "Linear") then
						enemiesData[i][1][1] = t[1]
					else
						print("Error loading " .. enemy.charName .. " Q type data")
						err = true
					end
				else
					print("Error loading " .. enemy.charName .. " Q type data")
					err = true
				end
				if(t[2]) then
					enemiesData[i][1][2] = t[2]
				else
					print("Error loading " .. enemy.charName .. " Q size data")
					err = true
				end
				if(t[3] and t[3] ~= "-1" and t[3] ~= "0") then
					enemiesData[i][1][3] = t[3]
					print(enemy.charName .. " Q loaded timing extra data")
				end
				if(t[4]) then
					enemiesData[i][1][4] = t[4]
					print(enemy.charName .. " Q loaded range extra data")
				end
				if(err == false) then
					print(enemy.charName .. " Q data has been loaded")
					--Config.enemySpells:addParam(enemy.charName.. "Q",enemy.charName.. "Q",SCRIPT_PARAM_ONOFF, true)
					Config.enemySpells:addSubMenu(enemy.charName.. "Q",enemy.charName.. "Q")
					Config.enemySpells[enemy.charName.. "Q"]:addParam("evade","Evade",SCRIPT_PARAM_ONOFF, true)
					Config.enemySpells[enemy.charName.. "Q"]:addParam("minHealth","Min Health",SCRIPT_PARAM_SLICE, 85,0,100,0)
					--Config.enemySpells[enemy.charName.. "Q"]:addParam("difChamps","Difference of allies/enemies",SCRIPT_PARAM_SLICE, 0,-5,5,0)
					Config.enemySpells[enemy.charName.. "Q"]:addParam("minDistance","Min Distance",SCRIPT_PARAM_SLICE, 250,0,1000,0)
				end
			else
				enemiesData[i][1] = "NoLoaded"
			end
			err = false
			enemyData = ReadFile("./Data/" .. currentDirectory .. "/" .. enemy.charName .. "W.dat")
			if(enemyData) then
				t = split(enemyData,' ')
				enemiesData[i][2] = {}
				if(t[1]) then
					if(t[1] == "Circular" or t[1] == "Linear") then
						enemiesData[i][2][1] = t[1]
					else
						err = true
						print("Error loading " .. enemy.charName .. " W type data")
					end
				else
					err = true
					print("Error loading " .. enemy.charName .. " W type data")
				end
				if(t[2]) then
					enemiesData[i][2][2] = t[2]
				else
					err = true
					print("Error loading " .. enemy.charName .. " W size data")
				end
				if(t[3] and t[3] ~= "-1" and t[3] ~= "0") then
					enemiesData[i][2][3] = t[3]
					print(enemy.charName .. " W loaded timing extra data")
				end
				if(t[4]) then
					enemiesData[i][2][4] = t[4]
					print(enemy.charName .. " W loaded range extra data")
				end
				if(err == false) then
					print(enemy.charName .. " W data has been loaded")
					--Config.enemySpells:addParam(enemy.charName.. "W",enemy.charName.. "W",SCRIPT_PARAM_ONOFF, true)
					Config.enemySpells:addSubMenu(enemy.charName.. "W",enemy.charName.. "W")
					Config.enemySpells[enemy.charName.. "W"]:addParam("evade","Evade",SCRIPT_PARAM_ONOFF, true)
					Config.enemySpells[enemy.charName.. "W"]:addParam("minHealth","Min Health",SCRIPT_PARAM_SLICE, 85,0,100,0)
				--	Config.enemySpells[enemy.charName.. "W"]:addParam("difChamps","Difference of allies/enemies",SCRIPT_PARAM_SLICE, 0,-5,5,0)
					Config.enemySpells[enemy.charName.. "W"]:addParam("minDistance","Min Distance",SCRIPT_PARAM_SLICE, 250,0,1000,0)
				end
			else
				enemiesData[i][2] = "NoLoaded"
			end
			err = false
			enemyData = ReadFile("./Data/" .. currentDirectory .. "/" .. enemy.charName .. "E.dat")
			if(enemyData) then
				t = split(enemyData,' ')
				enemiesData[i][3] = {}
				if(t[1]) then
					if(t[1] == "Circular" or t[1] == "Linear") then
						enemiesData[i][3][1] = t[1]
					else
						err = true
						print("Error loading " .. enemy.charName .. " E  typedata")
					end
				else
					err = true
					print("Error loading " .. enemy.charName .. " E type data")
				end
				if(t[2]) then
					enemiesData[i][3][2] = t[2]
				else
					err = true
					print("Error loading " .. enemy.charName .. " E size data")
				end
				if(t[3] and t[3] ~= "-1" and t[3] ~= "0") then
					enemiesData[i][3][3] = t[3]
					print(enemy.charName .. " E loaded timing extra data")
				end
				if(t[4]) then
					enemiesData[i][3][4] = t[4]
					print(enemy.charName .. " E loaded range extra data")
				end
				if(err == false) then
					print(enemy.charName .. " E data has been loaded")
					--Config.enemySpells:addParam(enemy.charName.. "E",enemy.charName.. "E",SCRIPT_PARAM_ONOFF, true)
					Config.enemySpells:addSubMenu(enemy.charName.. "E",enemy.charName.. "E")
					Config.enemySpells[enemy.charName.. "E"]:addParam("evade","Evade",SCRIPT_PARAM_ONOFF, true)
					Config.enemySpells[enemy.charName.. "E"]:addParam("minHealth","Min Health",SCRIPT_PARAM_SLICE, 85,0,100,0)
					--Config.enemySpells[enemy.charName.. "E"]:addParam("difChamps","Difference of allies/enemies",SCRIPT_PARAM_SLICE, 0,-5,5,0)
					Config.enemySpells[enemy.charName.. "E"]:addParam("minDistance","Min Distance",SCRIPT_PARAM_SLICE, 250,0,1000,0)
				end
			else
				enemiesData[i][3] = "NoLoaded"
			end
			err = false
			enemyData = ReadFile("./Data/" .. currentDirectory .. "/" .. enemy.charName .. "R.dat")
			if(enemyData) then
				t = split(enemyData,' ')
				enemiesData[i][4] = {}
				if(t[1]) then
					if(t[1] == "Circular" or t[1] == "Linear") then
						enemiesData[i][4][1] = t[1]
					else
						err = true
						print("Error loading " .. enemy.charName .. " R type data")
					end
				else
					err = true
					print("Error loading " .. enemy.charName .. " R type data")
				end
				if(t[2]) then
					enemiesData[i][4][2] = t[2]
				else
					err = true
					print("Error loading " .. enemy.charName .. " R size data")
				end
				if(t[3] and t[3] ~= "-1" and t[3] ~= "0") then
					enemiesData[i][4][3] = t[3]
					print(enemy.charName .. " R loaded timing extra data")
				end
				if(t[4]) then
					enemiesData[i][4][4] = t[4]
					print(enemy.charName .. " R loaded range extra data")
				end
				if(err == false) then
					print(enemy.charName .. " R data has been loaded")
					--Config.enemySpells:addParam(enemy.charName.. "R",enemy.charName.. "R",SCRIPT_PARAM_ONOFF, true)
					Config.enemySpells:addSubMenu(enemy.charName.. "R",enemy.charName.. "Q")
					Config.enemySpells[enemy.charName.. "R"]:addParam("evade","Evade",SCRIPT_PARAM_ONOFF, true)
					Config.enemySpells[enemy.charName.. "R"]:addParam("minHealth","Min Health",SCRIPT_PARAM_SLICE, 85,0,100,0)
					--Config.enemySpells[enemy.charName.. "R"]:addParam("difChamps","Difference of allies/enemies",SCRIPT_PARAM_SLICE, 0,-5,5,0)
					Config.enemySpells[enemy.charName.. "R"]:addParam("minDistance","Min Distance",SCRIPT_PARAM_SLICE, 250,0,1000,0)
				end
			else
				enemiesData[i][4] = "NoLoaded"
			end
		end
	end

end
function AutoUpdater()
	_version = GetWebResult("raw.github.com", "https://raw.githubusercontent.com/x0Z3R0/BOL/master/ArtificialEvasion.version")
	if(tonumber(_version) > version) then 
		Print("Downloading last version " .. _version .. " . Dont press F9 till update is done.")
		DelayAction(function() DownloadFile(https://raw.githubusercontent.com/x0Z3R0/BOL/master/ArtificialEvasion.lua, SCRIPT_PATH.. "ArtificialEvasion.lua", function () Print("Successfully updated to ".. _version.." press F9 twice to reload.") end) end, 3)
	else
		Print("You have the last version " .. version)
	end
end

AddLoadCallback(function ()
	Print("Hi Alpha Testers, remember we are in Alpha so try to feedback in the official post")
	LoadChampData()
	AutoUpdater()
	configs = ReadFile("./Data/Configs.dat")
	
	if(configs) then
		t = split(configs,' ')
		configsDir = t
	else	
		currentDirectory = "Default"
		PrintError("Please create Scripts/Data/Config.dat file")
	end
	
	--AutoUpdaterData()
	--[[
	spells[1] = {}
						spells[1][1] = 3000
						spells[1][2] = myHero.y
						spells[1][3] = 3000
						spells[1][4] = 3000
						spells[1][5] = myHero.y
						spells[1][6] = 3000
						spells[1][7] = "Circular"

						spells[1][8] ="TestR"
						spells[1][9] = 300
						
						spells[2] = {}
						spells[2][1] = 2700
						spells[2][2] = myHero.y
						spells[2][3] = 2700
						spells[2][4] = 2700
						spells[2][5] = myHero.y
						spells[2][6] = 2700
						spells[2][7] = "Circular"
						spells[2][8] ="TestR"
						spells[2][9] = 400

						spells[3] = {}
						spells[3][1] = 2000
						spells[3][2] = myHero.y
						spells[3][3] = 2000
						spells[3][4] = 2800
						spells[3][5] = myHero.y
						spells[3][6] = 2000
						spells[3][7] = "Linear"
						spells[3][8] ="TestR"
						spells[3][9] = 80
	]]
end)

function GetClosestAlly(distance) 
	closest = nil
	for a, Ally in ipairs(sAllies) do
		if (Ally ~= myHero) then
			if GetDistance(myHero,Ally) <= distance then
				if closest == nil then
					closest = Ally
				elseif not closest.dead and (GetDistance(myHero,Ally) < GetDistance(myHero,ClosestAlly)) then
					closest = Ally
				end
			end
		end
	end
	return closest
end

function isSafePoint(point)
	if(IsWall(D3DXVECTOR3(point.x,point.y,point.z))) then
		return false
	end
	for i, spell in ipairs(spells) do
		if(spell) then
			if(spell[7] == "Circular") then
				v = Vector(point.x-spell[4],point.y,point.z-spell[6])
				if(v:len() < spell[9] + myHero.boundingRadius + 50) then
					return false
				end
			end
			if(spell[7] == "Linear") then
				if not (((myHero.x - spell[1] > 0 and myHero.x - spell[4] > 0) or (myHero.x - spell[1] < 0 and myHero.x - spell[4] < 0))and((myHero.z - spell[3] > 0 and myHero.z - spell[6] > 0) or (myHero.z - spell[3] < 0 and myHero.z - spell[6] < 0))) then   
					v1 = Vector(spell[1],spell[2],spell[3])
					v2 = Vector(spell[4],spell[5],spell[6])

					heroPosition = Vector(point.x,point.y,point.z)
					point = VectorPointProjectionOnLine(v1,v2, heroPosition)
					v3 = point:dist(heroPosition)

					if(v3 < myHero.boundingRadius + spell[9]/2 + 10)    then
						return false
					end
				end
			end
		end
	end
	return true
end

function evade()
	evading = true
	local v
	--if(myPath) then
		--v = Vector(myPathDirection.x,0,myPathDirection.y)
	--else 
	v = Vector(mousePos.x-myHero.x,0,mousePos.z-myHero.z)
	v:normalize()
	mouseScannerRight = v:clone()
	mouseScannerLeft = v:clone()
	--end
	local c = 1
	while(v:len() < 600) do
		local i = 0
		while(i <= 36) do
			mouseScannerRight:normalize()
			mouseScannerRight:rotate(0,2*3.14/36,0)
			mouseScannerRight:normalize()
			mouseScannerRight = mouseScannerRight * c * 125 -- as= p original size
			i = i + 1
			if(isSafePoint(Vector(mouseScannerRight.x + myHero.x,myHero.y,myHero.z + mouseScannerRight.z))) then
				savedPos = Vector(myHero.x,myHero.y,myHero.z)
				evading = false
				return Vector(mouseScannerRight.x + myHero.x,myHero.y,myHero.z + mouseScannerRight.z)
			end
			
			mouseScannerLeft:normalize()
			mouseScannerLeft:rotate(0,-2*3.14/36,0)
			mouseScannerLeft:normalize()
			mouseScannerLeft = mouseScannerLeft * c * 125 -- as= p original size
			i = i + 1
			if(isSafePoint(Vector(mouseScannerLeft.x + myHero.x,myHero.y,myHero.z + mouseScannerLeft.z))) then
				savedPos = Vector(myHero.x,myHero.y,myHero.z)
				evading = false
				return Vector(mouseScannerLeft.x + myHero.x,myHero.y,myHero.z + mouseScannerLeft.z)
			end
			
		end
		c = c + 1
	end
	evading = false
	return Vector(myHero.x,myHero.y,myHero.z)
end

AddTickCallback(function ()
	if(Config.evade) then
		local predictPos
		if(myHero.hasMovePath) then
			if myHero.path.count > 1 then
				myPath = myHero.path:Path(2)
				myPathDirection = Vector(myPath.x - myHero.x,myPath.z-myHero.z)
				myPathDirection:normalize()
				predictPos = Vector(myHero.x + myPathDirection.x * myHero.ms /1000 * EX_SECS * 3,myHero.y,myHero.z + myPathDirection.y * myHero.ms /1000 * EX_SECS * 3)
			end
		else
			myPath = nil
		end
		local tick=GetTickCount()
		if (tick-nextTick >0) then
			nextTick = tick+EX_SECS
			if not isSafePoint(Vector(myHero.x,myHero.y,myHero.z)) then 
				_G.Evade = true
				if not evading then
					bestEvadePoint = evade()
					if(myHero.charName == "Lucian" and myHero:CanUseSpell(_E) == READY and GetDistance(Vector(myHero.x,0,myHero.z),Vector(bestEvadePoint.x,0,bestEvadePoint.z)) > 350) then
						CastSpell(_E,bestEvadePoint.x,bestEvadePoint.z)
					else
					
					myHero:MoveTo(bestEvadePoint.x,bestEvadePoint.z)
					end
				end
			else
				_G.Evade = false
				evading = false
			end
			for i, spell in ipairs(spells) do
				if(spell and spells[i][10]) then
					spells[i][10] = spells[i][10] - EX_SECS
					if(spells[i][10] <= 0) then
						spells[i] = nil
					end
				end
			end			
		end
	end
end)

     
AddIssueOrderCallback(function (unit,orderType,endP,target)
	if(Config.evade) then
		if(bestEvadePoint and orderType == 2) then
			if not isSafePoint(Vector(myHero.x,myHero.y,myHero.z)) then
				if math.abs(endP.x - bestEvadePoint.x) > 2 or math.abs(endP.z - bestEvadePoint.z) > 2 then
					BlockOrder()
				end
			end
		end
	end
end)

function AddAsheW(startPos,endPos,width,name,range,tipe,timing) 
	direction = Vector(endPos.x-startPos.x,0,endPos.z-startPos.z)
	direction:normalize()
	direction.x = direction.x * range
	direction.z = direction.z * range
 	directiono = direction:clone()
	direction:rotate(0,3.14/35,0)
	AddSpell(startPos,Vector(direction.x+startPos.x,endPos.y,direction.z+startPos.z),width,name,range,tipe,timing)
	direction:rotate(0,3.14/35,0)
	AddSpell(startPos,Vector(direction.x+startPos.x,endPos.y,direction.z+startPos.z),width,name,range,tipe,timing)
	direction:rotate(0,3.14/35,0)
	AddSpell(startPos,Vector(direction.x+startPos.x,endPos.y,direction.z+startPos.z),width,name,range,tipe,timing)
	direction:rotate(0,3.14/35,0)
	AddSpell(startPos,Vector(direction.x+startPos.x,endPos.y,direction.z+startPos.z),width,name,range,tipe,timing)
	directiono:rotate(0,-3.14/35,0)
	AddSpell(startPos,Vector(directiono.x+startPos.x,endPos.y,directiono.z+startPos.z),width,name,range,tipe,timing)
	directiono:rotate(0,-3.14/35,0)
	AddSpell(startPos,Vector(directiono.x+startPos.x,endPos.y,directiono.z+startPos.z),width,name,range,tipe,timing)
	directiono:rotate(0,-3.14/35,0)
	AddSpell(startPos,Vector(directiono.x+startPos.x,endPos.y,directiono.z+startPos.z),width,name,range,tipe,timing)
	directiono:rotate(0,-3.14/35,0)
	AddSpell(startPos,Vector(directiono.x+startPos.x,endPos.y,directiono.z+startPos.z),width,name,range,tipe,timing)
end

function AddBlitzcrankQ(startPos,endPos,width,name,range,tipe,timing) 
	realEndPos = Vector(endPos.x-startPos.x,0,endPos.z-startPos.z)
	realEndPos:normalize()
	realEndPos = realEndPos * 1000
	direction = Vector(endPos.x-startPos.x,0,endPos.z-startPos.z)
	direction:normalize()
	direction:rotate(0,3.14/2,0)
	direction:normalize()
	direction = direction * 40
	newStartPos = Vector(startPos.x+direction.x,startPos.y,startPos.z+direction.x) 
	newEndPos = Vector(realEndPos.x+startPos.x,endPos.y,realEndPos.z+startPos.z)
	AddSpell(newStartPos,newEndPos,width,name,range,tipe,timing)
end

--[[
self.spell = {"Q" = 0, "W" = 1, "E" = 2, "R" = 3}
self.DashSpellData = {
    {charName = "Ahri", dangerlevel = 5, name = "AhriTumble", spellname = "AhriTumble", Range = 500, spellDelay = 50, Speed = 1575, spellKey = "R", evadeType = "Dash", castType = "Position"},
    {charName = "Caitlyn", dangerlevel = 4, name = "CaitlynEntrapment", spellname = "CaitlynEntrapment", Range = 490, spellDelay = 50, Speed = 1000, IsReversed = true, FixedRange = true, spellKey = "E", evadeType = "Dash", castType = "Position"},
    {charName = "Corki", dangerlevel = 4, name = "CarpetBomb", spellname = "CarpetBomb", Range = 790, spellDelay = 50, Speed = 975, spellKey = "W", evadeType = "Dash", castType = "Position"},
    {charName = "Ekko", dangerlevel = 4, name = "PhaseDive", spellname = "EkkoE", Range = 350, FixedRange = true, spellDelay = 50, Speed = 1150, spellKey = "E", evadeType = "Dash", castType = "Position"},
    {charName = "Ekko", dangerlevel = 4, name = "PhaseDive2", spellname = "EkkoEAttack", Range = 490, spellDelay = 250, InfrontTarget = true, spellKey = "Recall", evadeType = "Blink", castType = "target", spellTargets = { "Enemy", "EnemyMinions" }, IsSpecial = true},
    {charName = "Ekko", dangerlevel = 5, name = "Chronobreak", spellname = "EkkoR", Range = 20000, spellDelay = 50, spellKey = "R", evadeType = "Blink", castType = "Self", IsSpecial = true},
    {charName = "Ezreal", dangerlevel = 3, name = "ArcaneShift", spellname = "EzrealArcaneShift", Range = 450, spellDelay = 250, spellKey = "E", evadeType = "Blink", castType = "Position"},
    {charName = "Gragas", dangerlevel = 3, name = "BodySlam", spellname = "GragasBodySlam", Range = 600, spellDelay = 50, Speed = 900, spellKey = "E", evadeType = "Dash", castType = "Position"},
    {charName = "Gnar", dangerlevel = 4, name = "GnarE", spellname = "GnarE", Range = 475, spellDelay = 50, Speed = 900, Checkspellname = true, spellKey = "E", evadeType = "Dash", castType = "Position"},
    {charName = "Gnar", dangerlevel = 5, name = "GnarE", spellname = "gnarbige", Range = 475, spellDelay = 50, Speed = 800, Checkspellname = true, spellKey = "E", evadeType = "Dash", castType = "Position"},
    {charName = "Graves", dangerlevel = 3, name = "QuickDraw", spellname = "GravesMove", Range = 425, spellDelay = 50, Speed = 1250, spellKey = "E", evadeType = "Dash", castType = "Position"},
    {charName = "Kassadin", dangerlevel = 2, name = "RiftWalk", Range = 450, spellDelay = 250, spellKey = "R", evadeType = "Blink", castType = "Position"},
    {charName = "Kayle", dangerlevel = 5, name = "Intervention", spellname = "JudicatorIntervention", spellDelay = 250, spellKey = "R", evadeType = "Shield", castType = "target", spellTargets = { "Ally" }},
    {charName = "Leblanc", dangerlevel = 3, name = "Distortion", spellname = "LeblancSlide", Range = 600, spellDelay = 50, Speed = 1600, spellKey = "W", evadeType = "Dash", castType = "Position"},
    {charName = "Leblanc", dangerlevel = 3, name = "DistortionR", spellname = "LeblancSlideM", Checkspellname = true, Range = 600, spellDelay = 50, Speed = 1600, spellKey = "R", evadeType = "Dash", castType = "Position"},
    {charName = "LeeSin", dangerlevel = 4, name = "LeeSinW", spellname = "BlindMonkWOne", Range = 700, Speed = 1400, spellDelay = 50, spellKey = "W", evadeType = "Dash", castType = "target", spellTargets = { "Ally", "AllyMinions" }},
    {charName = "Lucian", dangerlevel = 2, name = "RelentlessPursuit", spellname = "LucianE", Range = 425, spellDelay = 50, Speed = 1350, spellKey = "E", evadeType = "Dash", castType = "Position"},
    {charName = "Morgana", dangerlevel = 4, name = "BlackShield", spellname = "BlackShield", spellDelay = 50, spellKey = "E", evadeType = "Shield", castType = "target", spellTargets = { "Ally" }},
    {charName = "Nocturne", dangerlevel = 4, name = "ShroudofDarkness", spellname = "NocturneShroudofDarkness", spellDelay = 50, spellKey = "W", evadeType = "Shield", castType = "Self"},
    {charName = "Fiora", dangerlevel = 4, name = "FioraW", spellname = "FioraW", Range = 750, spellDelay = 100, spellKey = "W", evadeType = "WindWall", castType = "Position"},
    {charName = "Fizz", dangerlevel = 4, name = "FizzPiercingStrike", spellname = "FizzPiercingStrike", Range = 550, Speed = 1400, FixedRange = true, spellDelay = 50, spellKey = "Q", evadeType = "Dash", castType = "target", spellTargets = { "EnemyMinions", "Enemy" }},
    {charName = "Fizz", dangerlevel = 4, name = "FizzJump", spellname = "FizzJump", Range = 400, Speed = 1400, FixedRange = true, spellDelay = 50, spellKey = "E", evadeType = "Dash", castType = "Position"},
    {charName = "Riven", dangerlevel = 2, name = "BrokenWings", spellname = "RivenTriCleave", Range = 260, FixedRange = true, spellDelay = 50, Speed = 560, spellKey = "Q", evadeType = "Dash", castType = "Position"},
    {charName = "Riven", dangerlevel = 2, name = "Valor", spellname = "RivenFeint", Range = 325, FixedRange = true, spellDelay = 50, Speed = 1200, spellKey = "E", evadeType = "Dash", castType = "Position"},
    {charName = "Sivir", dangerlevel = 3, name = "SivirE", spellname = "SivirE", spellDelay = 50, spellKey = "E", evadeType = "Shield", castType = "Self"},
    {charName = "Shaco", dangerlevel = 4, name = "Deceive", spellname = "Deceive", Range = 400, spellDelay = 250, spellKey = "Q", evadeType = "Blink", castType = "Position"},
    {charName = "Tristana", dangerlevel = 4, name = "RocketJump", spellname = "RocketJump", Range = 900, spellDelay = 250, Speed = 1100, spellKey = "W", evadeType = "Dash", castType = "Position"},
    {charName = "Tryndamare", dangerlevel = 4, name = "SpinningSlash", spellname = "Slash", Range = 660, spellDelay = 50, Speed = 900, spellKey = "E", evadeType = "Dash", castType = "Position"},
    {charName = "Vayne", dangerlevel = 2, name = "Tumble", spellname = "VayneTumble", Range = 300, FixedRange = true, Speed = 900, spellDelay = 50, spellKey = "Q", evadeType = "Dash", castType = "Position"},
    {charName = "Yasuo", dangerlevel = 3, name = "SweepingBlade", spellname = "YasuoDashWrapper", Range = 475, FixedRange = true, Speed = 1000, spellDelay = 50, spellKey = "E", evadeType = "Dash", castType = "target", spellTargets = { "Enemy", "EnemyMinions" }},
    {charName = "Yasuo", dangerlevel = 4, name = "WindWall", spellname = "YasuoWMovingWall", Range = 400, spellDelay = 250, spellKey = "W", evadeType = "WindWall", castType = "Position"},
    {charName = "MasterYi", dangerlevel = 4, name = "AlphaStrike", spellname = "AlphaStrike", Range = 600, Speed = math.huge, spellDelay = 100, spellKey = "Q", evadeType = "Blink", castType = "target", spellTargets = { "Enemy", "EnemyMinions" }},
    {charName = "Katarina", dangerlevel = 4, name = "KatarinaE", spellname = "KatarinaE", Range = 700, Speed = math.huge, spellDelay = 50, spellKey = "E", evadeType = "Blink", castType = "target", spellTargets = { "Targetable" }},
    {charName = "Talon", dangerlevel = 4, name = "Cutthroat", spellname = "TalonCutthroat", Range = 700, Speed = math.huge, spellDelay = 50, spellKey = "E", evadeType = "Blink", castType = "target", spellTargets = { "Enemy", "EnemyMinions" }},
    {charName = "Kindred", dangerlevel = 3, name = "KindredQ", spellname = "KindredQ", Range = 500, FixedRange = true, Speed = 900, spellDelay = 50, spellKey = "Q", evadeType = "Dash", castType = "Position"},
    {charName = "AllChamps", dangerlevel = 5, name = "Flash", spellname = "summonerflash", Range = 400, FixedRange = true, spellDelay = 50, IsSummonerSpell = true, spellKey = "R", evadeType = "Blink", castType = "Position"},
    {charName = "AllChamps", dangerlevel = 5, name = "Hourglass", spellname = "ZhonyasHourglass", spellDelay = 50, spellKey = "Q", evadeType = "Shield", castType = "Self", IsItem = true, ItemId = 3157},
    {charName = "AllChamps", dangerlevel = 5, name = "Witchcap", spellname = "Witchcap", spellDelay = 50, spellKey = "Q", evadeType = "Shield", castType = "Self", IsItem = true, ItemId = 3090}
  }]]
function AddSpell(startPos,endPos,width,name,range,tipe,timing) 
	for i = 1, spells_number do
		if(spells[i] == nil) then
			spells[i] = {}

			spells[i][1] = startPos.x
			spells[i][2] = startPos.y
			spells[i][3] = startPos.z
			spells[i][4] = endPos.x
			spells[i][5] = endPos.y
			spells[i][6] = endPos.z
			spells[i][7] = tipe
			spells[i][8] = name
			spells[i][9] = width
			if(timing) then
				spells[i][10] = timing
			end
			if(range) then
				spells[i][11] = range
				vector = Vector(endPos.x - startPos.x,endPos.y-startPos.y,endPos.z - startPos.z)
				vector:normalize()
				vector = vector * spells[i][11]
				spells[i][4] = startPos.x + vector.x
				spells[i][5] = startPos.y + vector.y
				spells[i][6] = startPos.z + vector.z
			end
			if(tipe=="Linear")then
				local direction = Vector(endPos.x-startPos.x,0,endPos.z-startPos.z) 
				local dir2 = direction:clone()
				dir2:normalize()
				dir2:rotate(0,3.14/2,0)
				dir2 = dir2 * width
				spells[i][12] = startPos.x + dir2.x
				spells[i][13] = startPos.z + dir2.z
				spells[i][14] = startPos.x - dir2.x
				spells[i][15] = startPos.z - dir2.z
				spells[i][16] = spells[i][4] + dir2.x
				spells[i][17] = spells[i][6] + dir2.z
				spells[i][18] = spells[i][4] - dir2.x
				spells[i][19] = spells[i][6] - dir2.z
			end
			
			if(myHero.charName == "Sivir") then
				if(GetDistance(startPos,Vector(myHero.x,myHero.y,myHero.z)) < 450 or (name == "MalphiteR" and GetDistance(endPos,Vector(myHero.x,myHero.y,myHero.z)) < width + 10)) then
					if(CanUseSpell(_E))then
						CastSpell(_E)
					end
				end
			end
			break;
		end
	end
end

AddProcessSpellCallback(function (unit,spell)
		bool = -1
		if(Config.evade) then
			for i, currentEnemy in pairs(sEnemies) do
				if currentEnemy and currentEnemy.name == unit.name then
					bool = i
					break;
				end
			end
			if(bool > -1) then
				local nskill = -1
				for j, enemy in pairs(sEnemies) do
					if enemy and enemy.charName then
						if(enemiesData[bool][1] and not(enemiesData[bool][1] == "NoLoaded" ) and enemy:GetSpellData(_Q).name == spell.name) then
							if(Config.enemySpells[enemy.charName.. "Q"].evade and Config.enemySpells[enemy.charName.. "Q"].minHealth > (myHero.health/myHero.maxHealth * 100) and GetDistance(Vector(myHero),spell.startPos ) >  Config.enemySpells[enemy.charName.. "Q"].minDistance)then
								nskill = 1
							end	
							break
						end
						if(enemiesData[bool][2] and not(enemiesData[bool][2] == "NoLoaded" ) and  enemy:GetSpellData(_W).name == spell.name) then
							if(Config.enemySpells[enemy.charName.. "W"].evade and Config.enemySpells[enemy.charName.. "W"].minHealth > (myHero.health/myHero.maxHealth * 100) and GetDistance(Vector(myHero),spell.startPos ) >  Config.enemySpells[enemy.charName.. "W"].minDistance)then
								nskill = 2
							end	
							break
						end
						if(enemiesData[bool][3] and not(enemiesData[bool][3] == "NoLoaded" ) and  enemy:GetSpellData(_E).name == spell.name) then
							if(Config.enemySpells[enemy.charName.. "E"].evade and Config.enemySpells[enemy.charName.. "E"].minHealth > (myHero.health/myHero.maxHealth * 100) and GetDistance(Vector(myHero),spell.startPos ) >  Config.enemySpells[enemy.charName.. "E"].minDistance)then
								nskill = 3
							end
							break
						end
						if(enemiesData[bool][4] and not(enemiesData[bool][4] == "NoLoaded" ) and  enemy:GetSpellData(_R).name == spell.name) then
							if not (spell.name:find("XerathLocus")) then
								if(Config.enemySpells[enemy.charName.. "R"].evade and Config.enemySpells[enemy.charName.. "R"].minHealth > (myHero.health/myHero.maxHealth * 100) and GetDistance(Vector(myHero),spell.startPos ) >  Config.enemySpells[enemy.charName.. "R"].minDistance)then
									nskill = 4
								end	
							end
							break
						end
					end
				end
				if(nskill > -1) then
					if(Config.msg) then				
						print(unit.charName .. " has casted " .. spell.name)
					end
					if(nskill == 1) then
						name = unit.charName .. "Q"
					end
					if(nskill == 2) then
						name = unit.charName .. "W"
					end
					if(nskill == 3) then
						name = unit.charName .. "E"
					end
					if(nskill == 4) then
						name = unit.charName .. "R"
					end
					if(spell.name:lower():find("volley")) then
						AddSpell(spell.startPos,spell.endPos,tonumber(enemiesData[bool][nskill][2]),name,tonumber(enemiesData[bool][nskill][4]),enemiesData[bool][nskill][1],tonumber(enemiesData[bool][nskill][3]))
						AddAsheW(spell.startPos,spell.endPos,tonumber(enemiesData[bool][nskill][2]),name,tonumber(enemiesData[bool][nskill][4]),enemiesData[bool][nskill][1],tonumber(enemiesData[bool][nskill][3]))
					elseif(name == "BlitzcrankQ") then
						AddBlitzcrankQ(spell.startPos,spell.endPos,tonumber(enemiesData[bool][nskill][2]),name,tonumber(enemiesData[bool][nskill][4]),enemiesData[bool][nskill][1],tonumber(enemiesData[bool][nskill][3]))
					else
						AddSpell(spell.startPos,spell.endPos,tonumber(enemiesData[bool][nskill][2]),name,tonumber(enemiesData[bool][nskill][4]),enemiesData[bool][nskill][1],tonumber(enemiesData[bool][nskill][3]))
					end
				end	
			end
		end
end)

--[[function OnCreateObj(object)
	if(object and object.name and not object.name:find("missile") and object.name:find("Ashe"))then
		
	end
end]]


AddDrawCallback(function ()
	if(Config.draw and myHero.health > 0) then
		if(Config.drawCT) then
			DrawCircle(myHero.x,myHero.y,myHero.z,myHero.boundingRadius,ARGB(128,20,255,140))
			DrawLine3D(myHero.x+myHero.boundingRadius,myHero.y,myHero.z,myHero.x+myHero.boundingRadius,myHero.y+200,myHero.z,2,ARGB(128,20,255,140))
			DrawLine3D(myHero.x-myHero.boundingRadius,myHero.y,myHero.z,myHero.x-myHero.boundingRadius,myHero.y+200,myHero.z,2,ARGB(128,20,255,140))
			DrawLine3D(myHero.x,myHero.y,myHero.z+myHero.boundingRadius,myHero.x,myHero.y+200,myHero.z+myHero.boundingRadius,2,ARGB(128,20,255,140))
			DrawLine3D(myHero.x,myHero.y,myHero.z-myHero.boundingRadius,myHero.x,myHero.y+200,myHero.z-myHero.boundingRadius,2,ARGB(128,20,255,140))
			DrawCircle(myHero.x,myHero.y+200,myHero.z,myHero.boundingRadius,ARGB(128,20,255,140))
		end
		if(myPath)then
			DrawLine3D(myHero.x,myHero.y,myHero.z,myHero.x + myPathDirection.x * myHero.ms /1000 * EX_SECS * 3,myHero.y,myHero.z + myPathDirection.y * myHero.ms /1000 * EX_SECS * 3,3,ARGB(128,20,255,140))

		end
		--DrawLine3D(myHero.x,myHero.y,myHero.z,myHero.x + 500,myHero.y,myHero.z,3,ARGB(128,20,120,140))
		--DrawLine3D(myHero.x,myHero.y,myHero.z,mousePos.x,mousePos.y,mousePos.z,3,ARGB(128,20,120,140))
			v = Vector(mousePos.x-myHero.x,0,mousePos.z-myHero.z)
			v:normalize()
			v = v * 150
			--DrawLine3D(myHero.x,myHero.y,myHero.z,myHero.x + v.x,myHero.y,myHero.z+v.z,3,ARGB(128,55,120,140))

			p = Vector(0,0,150)--v:rotated(0, 3.14/4,0 )
			p:normalize()
			p = p * 150
			--DrawLine3D(myHero.x,myHero.y,myHero.z,myHero.x + p.x,myHero.y,myHero.z+p.z,3,ARGB(128,255,120,140))
			
		
		if(bestEvadePoint) then
			ep = bestEvadePoint
		end
		if(ep) then
			DrawCircle(ep.x,myHero.y,ep.z,50,ARGB(255,0,255,0))
			DrawCircle(ep.x,myHero.y,ep.z,45,ARGB(255,0,255,0))
			DrawCircle(ep.x,myHero.y,ep.z,40,ARGB(255,0,255,0))
			DrawCircle(ep.x,myHero.y,ep.z,35,ARGB(255,0,255,0))
	
		end
		for i = 1, spells_number do		
			spell = spells[i]
			if(spell ~= nil) then
				if spell[9] then
					if(spell[7] and spell[7] == "Circular") then
						if(Config.optCircle)then
							if(spell[4] - spell[1] == 0 and spell[6] - spell[3] == 0) then
								DrawFPSCircle(spell[1], spell[3], spell[9], ARGB(170,255,60,60), 3)
							else
								DrawFPSCircle(spell[4], spell[6],spell[9],ARGB(170,255,60,60),3)
							end
						else
							if(spell[4] - spell[1] == 0 and spell[6] - spell[3] == 0) then
								DrawCircle(spell[1], spell[2], spell[3],spell[9],ARGB(170,255,60,60))
							else
								DrawCircle(spell[4], spell[5], spell[6],spell[9],ARGB(170,255,60,60))
							end
						end
					end
					if(spell[7] == "Linear") then
						DrawLine3D(spell[12],spell[2],spell[13],spell[14],spell[5],spell[15],2,ARGB(170,255,60,60))
						DrawLine3D(spell[16],spell[2],spell[17],spell[18],spell[5],spell[19],2,ARGB(170,255,60,60))
						DrawLine3D(spell[12],spell[2],spell[13],spell[16],spell[5],spell[17],2,ARGB(170,255,60,60))
						DrawLine3D(spell[14],spell[2],spell[15],spell[18],spell[5],spell[19],2,ARGB(170,255,60,60))
						--[[print("P1 X:" .. spell[10] .. " Y:" .. spell[11])
						print("P2 X:" .. spell[12] .. " Y:" .. spell[13])
						print("P3 X:" .. spell[14] .. " Y:" .. spell[15])
						print("P4 X:" .. spell[16] .. " Y:" .. spell[17])]]
						DrawLineBorder3D(spell[1],spell[2],spell[3],spell[4],spell[5],spell[6],spell[9]*2,ARGB(170,255,60,60),2)
						--DrawLineBorder(spell[1],spell[3],spell[4],spell[6],1,ARGB(170,255,60,60),2)
					end
				
				end
			else

			end
		end
	end
end)

AddDeleteObjCallback(function (object)
		if(object and object.name) then
			if not(object.name:find("SRU") or object.name:find("missile") or object.name:find("Draw") or object.name:find("Minion")) then
				for i, enemy in pairs(sEnemies) do
					if(object.name:find(enemy.charName)) then
						if(object.name:find("_Q_") or object.name:find("_" .. string.sub(enemy:GetSpellData(_Q).name:lower(),enemy.charName:len()+1)))then
							for j = 0, spells_number do
								if(spells[j+1]) then 
									if not(spells[j+1][10])then
										if(spells[j+1][8] == enemy.charName .. "Q") then
											spells[j+1] = nil
											break
										end
									end
								end
							end
						end
						if(object.name:find("_W_") or object.name:find(enemy:GetSpellData(_W).name:lower()))then
							for j = 0, spells_number do
								if(spells[j+1]) then 
									if not(spells[j+1][10])then
										if(spells[j+1][8] == enemy.charName .. "W") then
											if not(object.name:find("Ziggs_Base_W_mis")) then
												spells[j+1] = nil
											else
											end
											break
										end
									end
								end
							end
						end
						if(object.name:find("_E_") or object.name:find(enemy:GetSpellData(_E).name:lower()))then
							if(object.name:find("_mis"))then
							for j = 0, spells_number do
								if(spells[j+1]) then 
									if not(spells[j+1][10])then
										if(spells[j+1][8] == enemy.charName .. "E") then
											spells[j+1] = nil
											break
										end
									end
								end
							end
							end
						end
						if(object.name:find("_R_") or object.name:find(enemy:GetSpellData(_R).name:lower())) then
							for j = 0, spells_number do
								if(spells[j+1]) then 
									if not(spells[j+1][10])then
										if(spells[j+1][8] == enemy.charName .. "R") then
											spells[j+1] = nil
											break
										end
									end
								end
							end
						end
	
				end
			end
		end
	end
end)
