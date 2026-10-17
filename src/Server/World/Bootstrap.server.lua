--!strict
--[[
  Fatia 1 do survival: o chão existe e o céu anda.
  Sem HUD, sem bag, sem árvore de Toolbox. Árvores/loot ficam para quando o dono mandar.
]]

local World = script.Parent
local Config = require(World.Config)
local TerrainGen = require(World.TerrainGen)
local LightingRig = require(World.LightingRig)

local ATTR = "AetherionWorld"

local function stripDefaults()
	for _, child in workspace:GetChildren() do
		if child.Name == "Baseplate" or child:IsA("SpawnLocation") then
			child:Destroy()
		end
	end
end

if workspace:GetAttribute(ATTR) == Config.revision then
	LightingRig.start()
	return
end

stripDefaults()
LightingRig.applyStatic()
TerrainGen.generate()
TerrainGen.placeSpawn()
workspace:SetAttribute(ATTR, Config.revision)
LightingRig.start()
