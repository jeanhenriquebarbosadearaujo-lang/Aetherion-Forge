--!strict
--[[
  Iluminação é mapa, não afterthought.
  ClockTime sozinho não faz noite de survival: Ambient, Atmosphere e
  ColorCorrection têm que andar junto, senão a noite fica cinza lavado.
  Refs: docs Realistic lighting; Atmosphere esconde FogColor.
]]

local Config = require(script.Parent.Config)

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local LightingRig = {}

type Key = {
	clock: number,
	brightness: number,
	ambient: Color3,
	outdoor: Color3,
	shiftTop: Color3,
	shiftBottom: Color3,
	density: number,
	offset: number,
	haze: number,
	glare: number,
	atmoColor: Color3,
	decay: Color3,
	ccContrast: number,
	ccSat: number,
	ccBright: number,
	sunRays: number,
	exposure: number,
}

-- Noite navegável de propósito: ainda não há lanterna. Escuro hostil, não pitch black.
local KEYS: { Key } = {
	{
		clock = 0,
		brightness = 1,
		ambient = Color3.fromRGB(8, 10, 18),
		outdoor = Color3.fromRGB(18, 22, 38),
		shiftTop = Color3.fromRGB(40, 48, 90),
		shiftBottom = Color3.fromRGB(8, 10, 20),
		density = 0.42,
		offset = 0.12,
		haze = 1.6,
		glare = 0,
		atmoColor = Color3.fromRGB(18, 22, 40),
		decay = Color3.fromRGB(6, 8, 16),
		ccContrast = 0.12,
		ccSat = -0.08,
		ccBright = -0.06,
		sunRays = 0,
		exposure = -0.4,
	},
	{
		clock = 5.4,
		brightness = 1.4,
		ambient = Color3.fromRGB(28, 22, 30),
		outdoor = Color3.fromRGB(70, 52, 48),
		shiftTop = Color3.fromRGB(255, 140, 90),
		shiftBottom = Color3.fromRGB(40, 28, 50),
		density = 0.38,
		offset = 0.18,
		haze = 2.1,
		glare = 0.4,
		atmoColor = Color3.fromRGB(255, 150, 110),
		decay = Color3.fromRGB(90, 40, 40),
		ccContrast = 0.1,
		ccSat = 0.08,
		ccBright = -0.02,
		sunRays = 0.06,
		exposure = -0.15,
	},
	{
		clock = 7.2,
		brightness = 2.4,
		ambient = Color3.fromRGB(22, 24, 28),
		outdoor = Color3.fromRGB(130, 148, 168),
		shiftTop = Color3.fromRGB(255, 214, 170),
		shiftBottom = Color3.fromRGB(40, 50, 70),
		density = 0.32,
		offset = 0.2,
		haze = 1.4,
		glare = 0.25,
		atmoColor = Color3.fromRGB(186, 198, 210),
		decay = Color3.fromRGB(110, 90, 70),
		ccContrast = 0.08,
		ccSat = 0.1,
		ccBright = 0,
		sunRays = 0.08,
		exposure = 0,
	},
	{
		clock = 12,
		brightness = 2.8,
		ambient = Color3.fromRGB(16, 16, 16),
		outdoor = Color3.fromRGB(134, 158, 190),
		shiftTop = Color3.fromRGB(196, 222, 255),
		shiftBottom = Color3.fromRGB(50, 55, 60),
		density = 0.3,
		offset = 0.17,
		haze = 1.1,
		glare = 0.15,
		atmoColor = Color3.fromRGB(199, 209, 220),
		decay = Color3.fromRGB(120, 128, 140),
		ccContrast = 0.06,
		ccSat = 0.06,
		ccBright = 0.02,
		sunRays = 0.05,
		exposure = 0.05,
	},
	{
		clock = 17,
		brightness = 2.2,
		ambient = Color3.fromRGB(24, 20, 22),
		outdoor = Color3.fromRGB(160, 120, 90),
		shiftTop = Color3.fromRGB(255, 170, 110),
		shiftBottom = Color3.fromRGB(50, 32, 28),
		density = 0.34,
		offset = 0.22,
		haze = 2.2,
		glare = 0.55,
		atmoColor = Color3.fromRGB(255, 160, 100),
		decay = Color3.fromRGB(120, 50, 30),
		ccContrast = 0.12,
		ccSat = 0.16,
		ccBright = 0,
		sunRays = 0.12,
		exposure = 0,
	},
	{
		clock = 19.6,
		brightness = 1.3,
		ambient = Color3.fromRGB(20, 16, 28),
		outdoor = Color3.fromRGB(50, 40, 70),
		shiftTop = Color3.fromRGB(120, 80, 160),
		shiftBottom = Color3.fromRGB(20, 16, 32),
		density = 0.4,
		offset = 0.14,
		haze = 1.8,
		glare = 0.15,
		atmoColor = Color3.fromRGB(70, 50, 90),
		decay = Color3.fromRGB(30, 20, 40),
		ccContrast = 0.14,
		ccSat = 0.04,
		ccBright = -0.04,
		sunRays = 0.02,
		exposure = -0.25,
	},
	{
		clock = 24,
		brightness = 1,
		ambient = Color3.fromRGB(8, 10, 18),
		outdoor = Color3.fromRGB(18, 22, 38),
		shiftTop = Color3.fromRGB(40, 48, 90),
		shiftBottom = Color3.fromRGB(8, 10, 20),
		density = 0.42,
		offset = 0.12,
		haze = 1.6,
		glare = 0,
		atmoColor = Color3.fromRGB(18, 22, 40),
		decay = Color3.fromRGB(6, 8, 16),
		ccContrast = 0.12,
		ccSat = -0.08,
		ccBright = -0.06,
		sunRays = 0,
		exposure = -0.4,
	},
}

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

local function lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

local function sampleKeys(clock: number): (Key, Key, number)
	for i = 1, #KEYS - 1 do
		local a, b = KEYS[i], KEYS[i + 1]
		if clock >= a.clock and clock <= b.clock then
			local span = b.clock - a.clock
			local t = if span < 1e-4 then 0 else (clock - a.clock) / span
			return a, b, t
		end
	end
	return KEYS[1], KEYS[2], 0
end

local function applyKey(clock: number)
	local a, b, t = sampleKeys(clock)
	Lighting.ClockTime = clock
	Lighting.Brightness = lerp(a.brightness, b.brightness, t)
	Lighting.Ambient = a.ambient:Lerp(b.ambient, t)
	Lighting.OutdoorAmbient = a.outdoor:Lerp(b.outdoor, t)
	Lighting.ColorShift_Top = a.shiftTop:Lerp(b.shiftTop, t)
	Lighting.ColorShift_Bottom = a.shiftBottom:Lerp(b.shiftBottom, t)
	pcall(function()
		Lighting.ExposureCompensation = lerp(a.exposure, b.exposure, t)
	end)

	local atmo = Lighting:FindFirstChild("Atmosphere")
	if atmo and atmo:IsA("Atmosphere") then
		atmo.Density = lerp(a.density, b.density, t)
		atmo.Offset = lerp(a.offset, b.offset, t)
		atmo.Haze = lerp(a.haze, b.haze, t)
		atmo.Glare = lerp(a.glare, b.glare, t)
		atmo.Color = a.atmoColor:Lerp(b.atmoColor, t)
		atmo.Decay = a.decay:Lerp(b.decay, t)
	end

	local cc = Lighting:FindFirstChild("ColorCorrection")
	if cc and cc:IsA("ColorCorrectionEffect") then
		cc.Contrast = lerp(a.ccContrast, b.ccContrast, t)
		cc.Saturation = lerp(a.ccSat, b.ccSat, t)
		cc.Brightness = lerp(a.ccBright, b.ccBright, t)
	end

	local rays = Lighting:FindFirstChild("SunRays")
	if rays and rays:IsA("SunRaysEffect") then
		rays.Intensity = lerp(a.sunRays, b.sunRays, t)
	end
end

function LightingRig.applyStatic()
	-- Realistic se o engine tiver; senão ShadowMap. Soft lava sombra de survival.
	local ok = pcall(function()
		(Lighting :: any).LightingStyle = Enum.LightingStyle.Realistic
	end)
	if not ok then
		pcall(function()
			Lighting.Technology = Enum.Technology.ShadowMap
		end)
	end

	Lighting.GlobalShadows = true
	Lighting.GeographicLatitude = Config.latitude
	Lighting.EnvironmentDiffuseScale = 0.7
	Lighting.EnvironmentSpecularScale = 0.7
	pcall(function()
		Lighting.ShadowSoftness = 0.2
	end)

	local atmo = ensure("Atmosphere", "Atmosphere") :: Atmosphere
	atmo.Color = Color3.fromRGB(186, 198, 210)
	atmo.Decay = Color3.fromRGB(110, 90, 70)
	atmo.Density = 0.32
	atmo.Offset = 0.2
	atmo.Glare = 0.25
	atmo.Haze = 1.4

	local sky = ensure("Sky", "Sky") :: Sky
	sky.CelestialBodiesShown = true
	sky.MoonAngularSize = 14
	sky.StarCount = 3000
	sky.SunAngularSize = 21

	local cc = ensure("ColorCorrectionEffect", "ColorCorrection") :: ColorCorrectionEffect
	cc.Enabled = true
	cc.TintColor = Color3.fromRGB(255, 255, 255)

	local bloom = ensure("BloomEffect", "Bloom") :: BloomEffect
	bloom.Enabled = true
	bloom.Intensity = 0.25
	bloom.Size = 18
	bloom.Threshold = 1.15

	local rays = ensure("SunRaysEffect", "SunRays") :: SunRaysEffect
	rays.Enabled = true
	rays.Intensity = 0.08
	rays.Spread = 0.2

	-- Blur/DoF deixam mobile ilegível. Não criar.

	applyKey(Config.startClock)
end

function LightingRig.start()
	LightingRig.applyStatic()
	local clock = Config.startClock
	local acc = 0
	RunService.Heartbeat:Connect(function(dt: number)
		clock = (clock + dt * (24 / Config.daySeconds)) % 24
		acc += dt
		-- 10 Hz chega: Atmosphere não precisa de tick a 60.
		if acc >= 0.1 then
			acc = 0
			applyKey(clock)
		end
	end)
end

return LightingRig
