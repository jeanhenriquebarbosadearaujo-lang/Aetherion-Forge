--!strict
--[[
  Fatia relevo — um Script só (v237 Folder+require não rodou).
  Heightmap + WriteVoxels (ReadVoxels pra array com Size).
  Árvore/pedra autorais (Part). Sem Toolbox, sem bag.
  Se voxel falhar, cai no Fill* da v238 pra não voltar baseplate.
]]

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

print("[Aetherion] World v242 start")

local DAY_SECONDS = 720
local START_CLOCK = 7.15
local ATTR = "AetherionWorld"
local REV = 3

local SEED = 275626
local VOX = 4
local HALF_LEN = 240
local RADIUS = 200
local COAST = 42
local SEA = 0
local BASE_H = 14
local HILL_AMP = 34
local WATER_PAD = 64
local CHUNK = 32

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

local function fbm(x: number, z: number): number
	local value, amp, freq, norm = 0, 1, 1, 0
	local base = 150
	for _ = 1, 5 do
		value += math.noise(x / (base / freq) + SEED, z / (base / freq) + SEED * 0.41) * amp
		norm += amp
		freq *= 2
		amp *= 0.5
	end
	return value / math.max(norm, 1e-4)
end

local function stadiumDist(x: number, z: number): number
	local ax = math.clamp(x, -HALF_LEN, HALF_LEN)
	local dx, dz = x - ax, z
	return math.sqrt(dx * dx + dz * dz)
end

local function heightOnly(x: number, z: number): number
	local dist = stadiumDist(x, z)
	local coastR = RADIUS + math.noise(x / 88 + SEED, z / 88 + SEED * 1.63) * COAST
	local inland = coastR - dist
	local spawnFlat = math.clamp(1 - math.sqrt(x * x + z * z) / 78, 0, 1)
	local hills = fbm(x, z) * (1 - spawnFlat * 0.9)
	local land = BASE_H + hills * HILL_AMP
	if inland < -28 then
		return SEA - 18
	elseif inland < 0 then
		local t = math.clamp(inland / -28, 0, 1)
		return land * (1 - t) + (SEA - 18) * t
	elseif inland < 32 then
		local t = inland / 32
		local beach = SEA + 1.5 + t * 5
		return beach + (land - beach) * (t * t)
	end
	return land
end

local function inlandOf(x: number, z: number): number
	local dist = stadiumDist(x, z)
	local coastR = RADIUS + math.noise(x / 88 + SEED, z / 88 + SEED * 1.63) * COAST
	return coastR - dist
end

local function slopeOf(x: number, z: number): number
	local step = VOX
	local h = heightOnly(x, z)
	local dx = heightOnly(x + step, z) - h
	local dz = heightOnly(x, z + step) - h
	return math.sqrt(dx * dx + dz * dz) / step
end

local function groundMat(x: number, z: number, height: number, inland: number, slope: number): Enum.Material
	if inland < 20 or height < SEA + 3.2 then
		return Enum.Material.Sand
	end
	if slope > 0.82 or height > BASE_H + HILL_AMP * 0.58 then
		return Enum.Material.Rock
	end
	local patch = math.noise(x / 48 + 20, z / 48 + SEED)
	if patch > 0.36 then
		return Enum.Material.Ground
	end
	if patch < -0.3 then
		return Enum.Material.LeafyGrass
	end
	return Enum.Material.Grass
end

local function snap(n: number): number
	return math.floor(n / VOX + 0.5) * VOX
end

local function writeChunk(terrain: Terrain, x0: number, z0: number, x1: number, z1: number, y0: number, y1: number)
	if x1 <= x0 or z1 <= z0 or y1 <= y0 then
		return
	end
	local region = Region3.new(Vector3.new(x0, y0, z0), Vector3.new(x1, y1, z1)):ExpandToGrid(VOX)
	local materials, occupancy = terrain:ReadVoxels(region, VOX)
	local size = materials.Size
	local origin = region.CFrame.Position - region.Size / 2
	for ix = 1, size.X do
		local wx = origin.X + (ix - 0.5) * VOX
		for iz = 1, size.Z do
			local wz = origin.Z + (iz - 0.5) * VOX
			local H = heightOnly(wx, wz)
			local inland = inlandOf(wx, wz)
			local sl = slopeOf(wx, wz)
			local colMat = groundMat(wx, wz, H, inland, sl)
			for iy = 1, size.Y do
				local yBottom = origin.Y + (iy - 1) * VOX
				local yTop = yBottom + VOX
				local mat = Enum.Material.Air
				local occ = 0
				if H >= yTop then
					occ = 1
					mat = if yTop < SEA - 10 then Enum.Material.Slate else colMat
				elseif H > yBottom then
					occ = (H - yBottom) / VOX
					mat = colMat
				elseif yBottom < SEA and H < SEA then
					local waterTop = math.min(yTop, SEA)
					if waterTop > yBottom then
						mat = Enum.Material.Water
						occ = (waterTop - yBottom) / VOX
					end
				end
				materials[ix][iy][iz] = mat
				occupancy[ix][iy][iz] = occ
			end
		end
	end
	terrain:WriteVoxels(region, VOX, materials, occupancy)
end

local function fallbackFill(terrain: Terrain)
	warn("[Aetherion] voxels failed — Fill* fallback")
	terrain:FillBlock(CFrame.new(0, -6, 0), Vector3.new(1600, 12, 1600), Enum.Material.Water)
	terrain:FillBlock(CFrame.new(0, 4, 0), Vector3.new(HALF_LEN * 2, 22, 228 * 2), Enum.Material.Sand)
	terrain:FillCylinder(CFrame.new(-HALF_LEN, 4, 0), 22, 228, Enum.Material.Sand)
	terrain:FillCylinder(CFrame.new(HALF_LEN, 4, 0), 22, 228, Enum.Material.Sand)
	terrain:FillBlock(CFrame.new(0, 8, 0), Vector3.new(HALF_LEN * 2, 24, RADIUS * 2), Enum.Material.Grass)
	terrain:FillCylinder(CFrame.new(-HALF_LEN, 8, 0), 24, RADIUS, Enum.Material.Grass)
	terrain:FillCylinder(CFrame.new(HALF_LEN, 8, 0), 24, RADIUS, Enum.Material.Grass)
	terrain:FillBall(Vector3.new(-90, 22, -55), 48, Enum.Material.Grass)
	terrain:FillBall(Vector3.new(130, 28, 80), 56, Enum.Material.Rock)
end

local function buildTerrain(): boolean
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
	clouds.Cover = 0.45
	clouds.Density = 0.5
	clouds.Parent = terrain

	local reach = HALF_LEN + RADIUS + COAST + WATER_PAD
	local minX, maxX = snap(-reach), snap(reach)
	local minZ, maxZ = snap(-reach), snap(reach)
	local y0, y1 = snap(SEA - 24), snap(BASE_H + HILL_AMP + 20)
	local step = CHUNK * VOX
	local okAll = true
	for x0 = minX, maxX - VOX, step do
		for z0 = minZ, maxZ - VOX, step do
			local x1 = math.min(x0 + step, maxX)
			local z1 = math.min(z0 + step, maxZ)
			local ok, err = pcall(writeChunk, terrain, x0, z0, x1, z1, y0, y1)
			if not ok then
				okAll = false
				warn("[Aetherion] chunk fail ", x0, z0, err)
			end
			task.wait()
		end
	end
	if not okAll then
		fallbackFill(terrain)
	end
	print("[Aetherion] World v242 terrain done", okAll)
	return okAll
end

local function mkPart(parent: Instance, shape: Enum.PartType, size: Vector3, cf: CFrame, material: Enum.Material, color: Color3, collide: boolean): Part
	local p = Instance.new("Part")
	p.Shape = shape
	p.Size = size
	p.CFrame = cf
	p.Material = material
	p.Color = color
	p.Anchored = true
	p.CanCollide = collide
	p.CanQuery = collide
	p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.CastShadow = true
	p.Parent = parent
	return p
end

local function plantPine(folder: Instance, at: Vector3, yaw: number, scale: number)
	local model = Instance.new("Model")
	model.Name = "Pine"
	local up = CFrame.new(at) * CFrame.Angles(0, yaw, 0)
	local trunkH = 11 * scale
	-- Cilindro do engine deita no X; gira pra ficar em pé.
	mkPart(
		model,
		Enum.PartType.Cylinder,
		Vector3.new(trunkH, 1.15 * scale, 1.15 * scale),
		up * CFrame.new(0, trunkH * 0.45, 0) * CFrame.Angles(0, 0, math.pi / 2),
		Enum.Material.Wood,
		Color3.fromRGB(68, 48, 34),
		true
	)
	local needle = Color3.fromRGB(32, 56, 30)
	mkPart(model, Enum.PartType.Ball, Vector3.new(9, 8, 9) * scale, up * CFrame.new(0, trunkH * 0.55, 0), Enum.Material.Grass, needle, false)
	mkPart(model, Enum.PartType.Ball, Vector3.new(7, 6.5, 7) * scale, up * CFrame.new(0.4 * scale, trunkH * 0.78, -0.2 * scale), Enum.Material.Grass, needle, false)
	mkPart(model, Enum.PartType.Ball, Vector3.new(5, 5, 5) * scale, up * CFrame.new(0, trunkH * 0.98, 0), Enum.Material.Grass, needle, false)
	model.Parent = folder
end

local function plantOak(folder: Instance, at: Vector3, yaw: number, scale: number)
	local model = Instance.new("Model")
	model.Name = "Oak"
	local up = CFrame.new(at) * CFrame.Angles(0, yaw, 0)
	local trunkH = 7.5 * scale
	mkPart(
		model,
		Enum.PartType.Cylinder,
		Vector3.new(trunkH, 1.5 * scale, 1.5 * scale),
		up * CFrame.new(0, trunkH * 0.42, 0) * CFrame.Angles(0, 0, math.pi / 2),
		Enum.Material.Wood,
		Color3.fromRGB(78, 56, 38),
		true
	)
	local leaf = Color3.fromRGB(46, 78, 36)
	mkPart(model, Enum.PartType.Ball, Vector3.new(10, 8, 10) * scale, up * CFrame.new(0, trunkH * 0.85, 0), Enum.Material.Grass, leaf, false)
	mkPart(model, Enum.PartType.Ball, Vector3.new(7, 6, 7) * scale, up * CFrame.new(3.2 * scale, trunkH * 0.78, 1.4 * scale), Enum.Material.Grass, leaf, false)
	mkPart(model, Enum.PartType.Ball, Vector3.new(6.5, 5.5, 6.5) * scale, up * CFrame.new(-2.8 * scale, trunkH * 0.8, -1.6 * scale), Enum.Material.Grass, leaf, false)
	model.Parent = folder
end

local function plantRock(folder: Instance, at: Vector3, yaw: number, scale: number)
	local model = Instance.new("Model")
	model.Name = "Rock"
	local up = CFrame.new(at) * CFrame.Angles(0, yaw, 0.15)
	local col = Color3.fromRGB(96, 94, 88)
	mkPart(model, Enum.PartType.Block, Vector3.new(6.5, 4.2, 5.2) * scale, up * CFrame.Angles(0.1, 0.4, -0.08), Enum.Material.Rock, col, true)
	mkPart(
		model,
		Enum.PartType.Block,
		Vector3.new(4.2, 3.4, 4.8) * scale,
		up * CFrame.new(2.1 * scale, 0.4 * scale, 0.6 * scale) * CFrame.Angles(-0.2, 0.7, 0.12),
		Enum.Material.Rock,
		Color3.fromRGB(84, 82, 76),
		true
	)
	model.Parent = folder
end

local function scatter()
	local old = workspace:FindFirstChild("WorldScenery")
	if old then
		old:Destroy()
	end
	local folder = Instance.new("Folder")
	folder.Name = "WorldScenery"
	folder.Parent = workspace

	local ray = RaycastParams.new()
	ray.FilterType = Enum.RaycastFilterType.Include
	ray.FilterDescendantsInstances = { workspace.Terrain }
	ray.IgnoreWater = true

	local function hitAt(x: number, z: number): RaycastResult?
		return workspace:Raycast(Vector3.new(x, 140, z), Vector3.new(0, -280, 0), ray)
	end

	local trees, rocks = 0, 0
	for x = -420, 420, 26 do
		for z = -340, 340, 26 do
			local jx = x + math.noise(x * 0.07, z * 0.07, SEED) * 10
			local jz = z + math.noise(x * 0.07 + 9, z * 0.07, SEED * 0.5) * 10
			local inland = inlandOf(jx, jz)
			local n = math.noise(jx * 0.031 + SEED, jz * 0.031)
			if jx * jx + jz * jz >= 72 * 72 and inland >= 28 then
				local hit = hitAt(jx, jz)
				if hit and hit.Material ~= Enum.Material.Water and hit.Material ~= Enum.Material.Sand and hit.Normal.Y >= 0.72 then
					local yaw = n * math.pi * 4
					if n > 0.12 and trees < 90 then
						local scale = 0.85 + (n + 1) * 0.18
						if n > 0.28 then
							plantPine(folder, hit.Position, yaw, scale)
						else
							plantOak(folder, hit.Position, yaw, scale)
						end
						trees += 1
					elseif n < -0.34 and rocks < 40 then
						plantRock(folder, hit.Position, yaw, 0.7 + (-n) * 0.4)
						rocks += 1
					end
				end
			end
		end
		task.wait()
	end
	print("[Aetherion] World v242 scenery", trees, "trees", rocks, "rocks")
end

local function placeSpawn()
	for _, inst in workspace:GetChildren() do
		if inst:IsA("SpawnLocation") or inst.Name == "Baseplate" or inst.Name == "_WorldGenPad" then
			inst:Destroy()
		end
	end
	local y = heightOnly(0, 0) + 4
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "SpawnLocation"
	spawn.Anchored = true
	spawn.CanCollide = false
	spawn.Transparency = 1
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.CFrame = CFrame.new(0, y, 0)
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Enabled = true
	spawn.Parent = workspace
	workspace.FallenPartsDestroyHeight = -80
	for _, player in Players:GetPlayers() do
		if player.Character then
			player.Character:PivotTo(CFrame.new(0, y + 4, 0))
		end
	end
end

applyLighting()

if workspace:GetAttribute(ATTR) ~= REV then
	local pad = Instance.new("Part")
	pad.Name = "_WorldGenPad"
	pad.Anchored = true
	pad.CanCollide = true
	pad.Transparency = 1
	pad.Size = Vector3.new(48, 2, 48)
	pad.Position = Vector3.new(0, 90, 0)
	pad.Parent = workspace
	local hold = Instance.new("SpawnLocation")
	hold.Name = "_WorldGenSpawn"
	hold.Anchored = true
	hold.Transparency = 1
	hold.CanCollide = false
	hold.Size = Vector3.new(12, 1, 12)
	hold.Position = Vector3.new(0, 92, 0)
	hold.Neutral = true
	hold.Duration = 0
	hold.Enabled = true
	hold.Parent = workspace

	local okT, errT = pcall(buildTerrain)
	if not okT then
		warn("[Aetherion] terrain FAIL ", errT)
		pcall(fallbackFill, workspace.Terrain)
	end
	local okS, errS = pcall(scatter)
	if not okS then
		warn("[Aetherion] scenery FAIL ", errS)
	end
	placeSpawn()
	if pad.Parent then
		pad:Destroy()
	end
	workspace:SetAttribute(ATTR, REV)
else
	print("[Aetherion] World v242 already generated")
end

startCycle()
print("[Aetherion] World v242 ready")
