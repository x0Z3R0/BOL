-- ARTIFICIAL VISION
-- Real ward´s vision camp.
-- Version 1.00
-- Best of fun and vision, Whitex22.

local version = 1.01
local sEnemies = GetEnemyHeroes()
local sAllies = GetAllyHeroes()
local wards = {}
local wardNumber = 70

Config = scriptConfig("Artifical Vision", "configuration")
Config:addParam("enabled", "Enabled", SCRIPT_PARAM_ONOFF, true)
Config:addSubMenu("Draws Settings","Draws")
Config.Draws:addParam("draw", "Draw wards", SCRIPT_PARAM_ONOFF, true)
Config.Draws:addParam("drawMinimap", "Draw in minimap", SCRIPT_PARAM_ONOFF, true)
Config.Draws:addParam("qualityMultiplier", "Vision Quality",SCRIPT_PARAM_SLICE, 3,0,10,0)

function PrintMessage(message) print("<font color=\"#339999\"><b>Artificial Vision:</font> </b><font color=\"#FFFFFF\">" .. message) end


function OnLoad()
	PrintMessage("created by Whitex22. Have fun!")
end

function GetDrawPoints(index) 
	local i = 1
	local wardVector = Vector(wards[index][1],wards[index][2],wards[index][3])
	local alpha = 0
	local value = Config.Draws.qualityMultiplier
	while(i <= 36 * value) do
		alpha = alpha + 360 / 36 / value
		wards[index][4+i] = {}
		a = 0.1
		wards[index][4 + i][1] = wardVector.x 
		wards[index][4 + i][2] = wardVector.y
		wards[index][4 + i][3] = wardVector.z + 110
		while (not IsWall(D3DXVECTOR3(wards[index][4 + i][1],wards[index][4 + i][2],wards[index][4 + i][3]))) and a < 0.9 do
			a = a + 0.025
			vc = Vector(1100 * math.sin(alpha / 360 * 6.28),0,1100 * math.cos(alpha / 360 * 6.28))
			vc:normalize()
			vc = vc * 1100 * a
			wards[index][4 + i][1] = wardVector.x + vc.x
			wards[index][4 + i][2] = wardVector.y
			wards[index][4 + i][3] = wardVector.z + vc.z
		end
		i = i + 1
	end
end

function CreateWard(object) 
	if(Config.enabled)then
		if object and(object.name:lower():find("visionward") or object.name:lower():find("sightward")) and object.networkID ~= 0 then
			if object.team ~= myHero.team then
				i = 1
				while i < wardNumber do
					if(wards[i])then
						i = i+1
					else
						break
					end
				end
				wards[i] = {}
				wards[i][1] = object.x
				wards[i][2] = object.y
				wards[i][3] = object.z
				wards[i][4] = object.networkID
				GetDrawPoints(i)
			end
		end
	end
end

function OnCreateObj(object)
	CreateWard(object)
end

function OnDeleteObj(object) 
	if(Config.enabled)then
		if object and object.name and  (object.name:lower():find("visionward") or object.name:lower():find("sightward")) and object.networkID ~= 0 then	
			i = 1
			while i < wardNumber do
				if(wards[i]) then
					if(wards[i][4] == object.networkID) then
						wards[i] = nil
						return
					end
				end
				i = i +1
			end
		end
	end
end

function OnDraw () 
		local num = 1
		if(Config.Draws.draw and Config.enabled) then
			while num < wardNumber do
				if(wards[num]) then
					ward = wards[num]
					i = 1
					DrawCircle(wards[num][1],wards[num][2],wards[num][3],50,ARGB(140,255,0,0))
					DrawCircleMinimap(wards[num][1],0,wards[num][3],200,4,ARGB(255,0,200,0),50)
					while(ward[4+i]) do
						if ward[5+i] then
							DrawLine3D(ward[4+i][1],ward[4+i][2],ward[4+i][3],ward[5+i][1],ward[5+i][2],ward[5+i][3],3,ARGB(128,255,30,30))
						else
							DrawLine3D(ward[4+i][1],ward[4+i][2],ward[4+i][3],ward[5][1],ward[5][2],ward[5][3],3,ARGB(128,255,30,30))
						end
						i = i + 1
					end
				end
				num = num + 1
			end
		end
end

function OnDrawMinimap()
	local num = 1
	if(Config.Draws.draw and Config.enabled and Config.Draws.drawMinimap) then
		while num < wardNumber do
			if(wards[num]) then
				v = Vector(wards[num][1],wards[num][2],wards[num][3])			
			end
			num = num + 1
		end
	end

end
