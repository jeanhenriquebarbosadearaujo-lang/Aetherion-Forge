--!strict
--[[
  Números do mundo. Mudou a ilha? Sobe `revision` para o bootstrap gerar de novo.
  Seed fixa de propósito: survival precisa de um chão que o dono reconheça.
]]

export type Config = {
	revision: number,
	seed: number,
	voxel: number,
	halfLength: number,
	radius: number,
	coastNoise: number,
	seaLevel: number,
	baseHeight: number,
	hillAmp: number,
	waterPad: number,
	chunkVoxels: number,
	daySeconds: number,
	startClock: number,
	latitude: number,
}

local Config: Config = {
	revision = 1,
	seed = 275626,

	voxel = 4,

	-- Ilha em estádio (pílula): dois raios + reta. Não é um quadrado de baseplate.
	halfLength = 240,
	radius = 200,
	coastNoise = 34,

	seaLevel = 0,
	baseHeight = 16,
	hillAmp = 38,
	waterPad = 72,

	-- 32 voxels * 4 studs = 128 studs por chunk. WriteVoxels odeia região gigante.
	chunkVoxels = 32,

	-- 12 min reais / dia. Noite tem que aparecer numa sessão de teste.
	daySeconds = 720,
	startClock = 7.15,
	latitude = 28,
}

return Config
