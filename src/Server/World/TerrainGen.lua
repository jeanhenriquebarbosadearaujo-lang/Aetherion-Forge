--!strict
--[[
  Escreve a ilha em chunks. WriteVoxels numa região só trava o servidor;
  daí o recorte e o task.wait entre fatias.
]]

local Config = require(script.Parent.Config)
local Heightmap = require(script.Parent.Heightmap)

local TerrainGen = {}

local VOX = Config.voxel
local AIR = Enum.Material.Air
local WATER = Enum.Material.Water

local function snap(n: number): number
	return math.floor(n / VOX + 0.5) * VOX
end

local function worldBounds(): (number, number, number, number)
	local reach = Config.halfLength + Config.radius + Config.coastNoise + Config.waterPad
	local minX = snap(-reach)
	local maxX = snap(reach)
	local minZ = snap(-reach)
	local maxZ = snap(reach)
	return minX, maxX, minZ, maxZ
end

local function yBounds(): (number, number)
	local y0 = snap(Config.seaLevel - 24)
	local y1 = snap(Config.baseHeight + Config.hillAmp + 20)
	return y0, y1
end

local function writeChunk(x0: number, z0: number, x1: number, z1: number, y0: number, y1: number)
	local region = Region3.new(Vector3.new(x0, y0, z0), Vector3.new(x1, y1, z1)):ExpandToGrid(VOX)
	local size = region.Size
	local nx = math.floor(size.X / VOX + 0.5)
	local ny = math.floor(size.Y / VOX + 0.5)
	local nz = math.floor(size.Z / VOX + 0.5)
	local origin = region.CFrame.Position - region.Size / 2

	local materials = table.create(nx)
	local occupancy = table.create(nx)
	-- Altura/material por coluna. Noise por voxel travava o servidor.
	local colH = table.create(nx)
	local colMat = table.create(nx)

	for ix = 1, nx do
		colH[ix] = table.create(nz)
		colMat[ix] = table.create(nz)
		local wx = origin.X + (ix - 0.5) * VOX
		for iz = 1, nz do
			local wz = origin.Z + (iz - 0.5) * VOX
			local sample = Heightmap.sample(wx, wz)
			colH[ix][iz] = sample.height
			colMat[ix][iz] = Heightmap.material(wx, wz, sample.height, sample.inland, Heightmap.slope(wx, wz))
		end
	end

	for ix = 1, nx do
		materials[ix] = table.create(ny)
		occupancy[ix] = table.create(ny)
		for iy = 1, ny do
			materials[ix][iy] = table.create(nz)
			occupancy[ix][iy] = table.create(nz)
			local yBottom = origin.Y + (iy - 1) * VOX
			local yTop = yBottom + VOX
			for iz = 1, nz do
				local H = colH[ix][iz]
				local mat = AIR
				local occ = 0

				if H >= yTop then
					occ = 1
					mat = if yTop < Config.seaLevel - 10 then Enum.Material.Slate else colMat[ix][iz]
				elseif H > yBottom then
					occ = (H - yBottom) / VOX
					mat = colMat[ix][iz]
				elseif yBottom < Config.seaLevel and H < Config.seaLevel then
					local waterTop = math.min(yTop, Config.seaLevel)
					if waterTop > yBottom then
						mat = WATER
						occ = (waterTop - yBottom) / VOX
					end
				end

				materials[ix][iy][iz] = mat
				occupancy[ix][iy][iz] = occ
			end
		end
	end

	workspace.Terrain:WriteVoxels(region, VOX, materials, occupancy)
end

function TerrainGen.generate()
	local terrain = workspace.Terrain
	terrain:Clear()
	terrain.Decoration = true
	pcall(function()
		terrain.WaterColor = Color3.fromRGB(10, 38, 46)
		terrain.WaterTransparency = 0.38
		terrain.WaterWaveSize = 0.18
		terrain.WaterWaveSpeed = 11
		terrain.WaterReflectance = 0.2
	end)

	-- Nuvem no Terrain, não no Lighting. Cobre a ilha sem asset de Toolbox.
	local oldClouds = terrain:FindFirstChildOfClass("Clouds")
	if oldClouds then
		oldClouds:Destroy()
	end
	local clouds = Instance.new("Clouds")
	clouds.Cover = 0.42
	clouds.Density = 0.48
	clouds.Color = Color3.fromRGB(210, 214, 220)
	clouds.Parent = terrain

	local minX, maxX, minZ, maxZ = worldBounds()
	local y0, y1 = yBounds()
	local step = Config.chunkVoxels * VOX

	for x0 = minX, maxX - VOX, step do
		for z0 = minZ, maxZ - VOX, step do
			local x1 = math.min(x0 + step, maxX)
			local z1 = math.min(z0 + step, maxZ)
			writeChunk(x0, z0, x1, z1, y0, y1)
			task.wait()
		end
	end
end

function TerrainGen.placeSpawn()
	for _, inst in workspace:GetDescendants() do
		if inst:IsA("SpawnLocation") then
			inst:Destroy()
		end
	end

	local sample = Heightmap.sample(0, 0)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "SpawnLocation"
	spawn.Anchored = true
	spawn.CanCollide = false
	spawn.Transparency = 1
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.CFrame = CFrame.new(0, sample.height + 3, 0)
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Enabled = true
	spawn.Parent = workspace

	workspace.FallenPartsDestroyHeight = Config.seaLevel - 90
end

return TerrainGen
