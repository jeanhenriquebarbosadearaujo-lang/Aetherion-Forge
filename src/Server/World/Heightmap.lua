--!strict
--[[
  Altura contínua + classificação de material.
  Occupancy no gerador usa esta altura para não virar terraço de voxel.
]]

local Config = require(script.Parent.Config)

export type Sample = {
	height: number,
	inland: number,
}

local Heightmap = {}

local function fbm(x: number, z: number): number
	local value, amp, freq, norm = 0, 1, 1, 0
	local base = 150
	for _ = 1, 5 do
		value += math.noise(x / (base / freq) + Config.seed, z / (base / freq) + Config.seed * 0.41) * amp
		norm += amp
		freq *= 2
		amp *= 0.5
	end
	return value / math.max(norm, 1e-4)
end

-- Distância ao segmento central do estádio (eixo X).
local function stadiumDistance(x: number, z: number): number
	local ax = math.clamp(x, -Config.halfLength, Config.halfLength)
	local dx, dz = x - ax, z
	return math.sqrt(dx * dx + dz * dz)
end

local function coastRadius(x: number, z: number): number
	local n = math.noise(x / 92 + Config.seed, z / 92 + Config.seed * 1.63)
	return Config.radius + n * Config.coastNoise
end

function Heightmap.sample(x: number, z: number): Sample
	local dist = stadiumDistance(x, z)
	local radius = coastRadius(x, z)
	local inland = radius - dist

	local spawnDist = math.sqrt(x * x + z * z)
	local spawnFlat = math.clamp(1 - spawnDist / 78, 0, 1)
	local hills = fbm(x, z) * (1 - spawnFlat * 0.88)
	local land = Config.baseHeight + hills * Config.hillAmp

	local height: number
	if inland < -28 then
		height = Config.seaLevel - 18
	elseif inland < 0 then
		local t = math.clamp(inland / -28, 0, 1)
		height = land * (1 - t) + (Config.seaLevel - 18) * t
	elseif inland < 30 then
		local t = inland / 30
		local beach = Config.seaLevel + 1.5 + t * 5
		height = beach + (land - beach) * (t * t)
	else
		height = land
	end

	return { height = height, inland = inland }
end

function Heightmap.slope(x: number, z: number): number
	local step = Config.voxel
	local h = Heightmap.sample(x, z).height
	local hx = Heightmap.sample(x + step, z).height
	local hz = Heightmap.sample(x, z + step).height
	local dx, dz = hx - h, hz - h
	return math.sqrt(dx * dx + dz * dz) / step
end

function Heightmap.material(x: number, z: number, height: number, inland: number, slope: number): Enum.Material
	if inland < 18 or height < Config.seaLevel + 3.5 then
		return Enum.Material.Sand
	end
	if slope > 0.85 or height > Config.baseHeight + Config.hillAmp * 0.62 then
		return Enum.Material.Rock
	end
	local patch = math.noise(x / 48 + 20, z / 48 + Config.seed)
	if patch > 0.38 then
		return Enum.Material.Ground
	end
	if patch < -0.32 then
		return Enum.Material.LeafyGrass
	end
	return Enum.Material.Grass
end

return Heightmap
