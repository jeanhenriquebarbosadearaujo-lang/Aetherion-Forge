--!strict
--[[
  Fatia 1 do survival: o chão existe e o céu anda.
  Sem HUD, sem bag, sem árvore de Toolbox. Árvores/loot ficam para quando o dono mandar.
]]

local Players = game:GetService("Players")

local World = script.Parent
local Config = require(World.Config)
local TerrainGen = require(World.TerrainGen)
local LightingRig = require(World.LightingRig)

local ATTR = "AetherionWorld"

local function stripBaseplate()
	local base = workspace:FindFirstChild("Baseplate")
	if base then
		base:Destroy()
	end
end

if workspace:GetAttribute(ATTR) == Config.revision then
	LightingRig.start()
	return
end

-- Pad alto: a geração leva uns segundos. Sem isto o jogador cai no vazio.
local pad = Instance.new("Part")
pad.Name = "_WorldGenPad"
pad.Anchored = true
pad.CanCollide = true
pad.Transparency = 1
pad.Size = Vector3.new(48, 2, 48)
pad.Position = Vector3.new(0, 80, 0)
pad.Parent = workspace

local hold = Instance.new("SpawnLocation")
hold.Name = "_WorldGenSpawn"
hold.Anchored = true
hold.CanCollide = false
hold.Transparency = 1
hold.Size = Vector3.new(12, 1, 12)
hold.Position = Vector3.new(0, 82, 0)
hold.Neutral = true
hold.Duration = 0
hold.Enabled = true
hold.Parent = workspace

for _, child in workspace:GetChildren() do
	if child:IsA("SpawnLocation") and child ~= hold then
		(child :: SpawnLocation).Enabled = false
	end
end

LightingRig.applyStatic()
TerrainGen.generate()
stripBaseplate()
TerrainGen.placeSpawn() -- apaga hold e cria o spawn no chão
if pad.Parent then
	pad:Destroy()
end

local spawn = workspace:FindFirstChild("SpawnLocation")
if spawn and spawn:IsA("BasePart") then
	local dest = spawn.CFrame + Vector3.new(0, 4, 0)
	for _, player in Players:GetPlayers() do
		local character = player.Character
		if character then
			character:PivotTo(dest)
		end
	end
end

workspace:SetAttribute(ATTR, Config.revision)
LightingRig.start()
