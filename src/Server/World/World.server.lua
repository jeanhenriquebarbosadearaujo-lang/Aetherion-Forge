--!strict
--[[
  Fatia 1b — um Script só, sem require.
  v237: ModuleScript no XML não rodou; ficou baseplate. Aqui a ilha nasce
  com FillBlock/FillCylinder/FillBall (API antiga, difícil falhar).
  Heightmap ruidoso fica pra melhorar depois — simples primeiro.
]]

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

print("[Aetherion] World v238 start")

local DAY_SECONDS = 720
local START_CLOCK = 7.15
local ATTR = "AetherionWorld"
local REV = 2

local function ensure(className: string, name: string): Instance
	local inst = Lighting:FindFirstChild(name)
	if inst and inst.ClassName ~= className then
		inst:Destroy()
		inst = nil
	end
	if not inst then
		inst = Instance.new(className)
		inst.Name = name
		inst.Parent = Lighting
	end
	return inst
end

local function applyLighting()
	pcall(function()
		(Lighting :: any).LightingStyle = Enum.LightingStyle.Realistic
	end)
	pcall(function()
		Lighting.Technology = Enum.Technology.ShadowMap
	end)
	Lighting.GlobalShadows = true
	Lighting.GeographicLatitude = 28
	Lighting.EnvironmentDiffuseScale = 0.7
	Lighting.EnvironmentSpecularScale = 0.7
	Lighting.ClockTime = START_CLOCK
	Lighting.Brightness = 2.4
	Lighting.Ambient = Color3.fromRGB(22, 24, 28)
	Lighting.OutdoorAmbient = Color3.fromRGB(130, 148, 168)
	Lighting.ColorShift_Top = Color3.fromRGB(255, 214, 170)
	Lighting.ColorShift_Bottom = Color3.fromRGB(40, 50, 70)

	local atmo = ensure("Atmosphere", "Atmosphere") :: Atmosphere
	atmo.Density = 0.32
	atmo.Offset = 0.2
	atmo.Haze = 1.4
	atmo.Glare = 0.25
	atmo.Color = Color3.fromRGB(186, 198, 210)
	atmo.Decay = Color3.fromRGB(110, 90, 70)

	local sky = ensure("Sky", "Sky") :: Sky
	sky.CelestialBodiesShown = true
	sky.MoonAngularSize = 14
	sky.StarCount = 3000

	local cc = ensure("ColorCorrectionEffect", "ColorCorrection") :: ColorCorrectionEffect
	cc.Enabled = true
	cc.Contrast = 0.08
	cc.Saturation = 0.1

	local bloom = ensure("BloomEffect", "Bloom") :: BloomEffect
	bloom.Enabled = true
	bloom.Intensity = 0.25
	bloom.Size = 18
	bloom.Threshold = 1.15

	local rays = ensure("SunRaysEffect", "SunRays") :: SunRaysEffect
	rays.Enabled = true
	rays.Intensity = 0.08
	rays.Spread = 0.2
end

local function startCycle()
	local clock = START_CLOCK
	RunService.Heartbeat:Connect(function(dt: number)
		clock = (clock + dt * (24 / DAY_SECONDS)) % 24
		Lighting.ClockTime = clock
		-- Noite mais escura sem HUD/lanterna ainda: só OutdoorAmbient.
		if clock >= 20 or clock < 5.5 then
			Lighting.Brightness = 1
			Lighting.OutdoorAmbient = Color3.fromRGB(18, 22, 38)
			Lighting.Ambient = Color3.fromRGB(8, 10, 18)
		elseif clock >= 17 then
			Lighting.Brightness = 2.2
			Lighting.OutdoorAmbient = Color3.fromRGB(160, 120, 90)
			Lighting.ColorShift_Top = Color3.fromRGB(255, 170, 110)
		else
			Lighting.Brightness = 2.4
			Lighting.OutdoorAmbient = Color3.fromRGB(130, 148, 168)
			Lighting.ColorShift_Top = Color3.fromRGB(255, 214, 170)
		end
	end)
end

local function stadium(material: Enum.Material, halfLen: number, radius: number, centerY: number, height: number)
	local terrain = workspace.Terrain
	-- Retângulo do meio + dois cilindros nas pontas = pílula. Não é baseplate.
	terrain:FillBlock(CFrame.new(0, centerY, 0), Vector3.new(halfLen * 2, height, radius * 2), material)
	terrain:FillCylinder(CFrame.new(-halfLen, centerY, 0), height, radius, material)
	terrain:FillCylinder(CFrame.new(halfLen, centerY, 0), height, radius, material)
end

local function buildIsland()
	local terrain = workspace.Terrain
	terrain:Clear()
	pcall(function()
		terrain.Decoration = true
		terrain.WaterColor = Color3.fromRGB(10, 38, 46)
		terrain.WaterTransparency = 0.38
		terrain.WaterWaveSize = 0.18
		terrain.WaterWaveSpeed = 11
	end)

	local oldClouds = terrain:FindFirstChildOfClass("Clouds")
	if oldClouds then
		oldClouds:Destroy()
	end
	local clouds = Instance.new("Clouds")
	clouds.Cover = 0.42
	clouds.Density = 0.48
	clouds.Parent = terrain

	-- Mar primeiro, ilha por cima.
	terrain:FillBlock(CFrame.new(0, -6, 0), Vector3.new(1600, 12, 1600), Enum.Material.Water)

	-- Areia um pouco maior = praia visível na borda.
	stadium(Enum.Material.Sand, 240, 228, 4, 22)
	-- Grama por cima, recuada.
	stadium(Enum.Material.Grass, 240, 200, 8, 24)

	-- Morros. Bolas grandes de propósito — tem que se ver de longe.
	terrain:FillBall(Vector3.new(-90, 22, -55), 48, Enum.Material.Grass)
	terrain:FillBall(Vector3.new(130, 28, 80), 56, Enum.Material.Rock)
	terrain:FillBall(Vector3.new(40, 20, -110), 40, Enum.Material.Grass)
	terrain:FillBall(Vector3.new(-160, 18, 90), 36, Enum.Material.Ground)

	print("[Aetherion] World v238 island filled")
end

local function placeSpawn()
	for _, inst in workspace:GetChildren() do
		if inst:IsA("SpawnLocation") or inst.Name == "Baseplate" or inst.Name == "_WorldGenPad" then
			inst:Destroy()
		end
	end

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "SpawnLocation"
	spawn.Anchored = true
	spawn.CanCollide = false
	spawn.Transparency = 1
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.CFrame = CFrame.new(0, 22, 0)
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Enabled = true
	spawn.Parent = workspace

	workspace.FallenPartsDestroyHeight = -80

	for _, player in Players:GetPlayers() do
		local character = player.Character
		if character then
			character:PivotTo(CFrame.new(0, 26, 0))
		end
	end
end

applyLighting()

if workspace:GetAttribute(ATTR) ~= REV then
	local ok, err = pcall(buildIsland)
	if not ok then
		warn("[Aetherion] island FAIL: ", err)
	end
	placeSpawn()
	workspace:SetAttribute(ATTR, REV)
else
	print("[Aetherion] World v238 already generated")
end

startCycle()
print("[Aetherion] World v238 ready")
