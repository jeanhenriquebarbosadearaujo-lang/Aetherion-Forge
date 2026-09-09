--[[
	Loadouts R6 + ícones do Catálogo do Roblox (Avatar Shop).
	Não usa Toolbox. Orelhas de cavalo e cabelos públicos do catálogo.
]]

export type Loadout = {
	head: Color3,
	torso: Color3,
	arms: Color3,
	legs: Color3,
	hat: number, -- Horse Ears (Hat)
	hair: number, -- HairAccessory
	icon: number, -- ícone da carta (thumbnail do catálogo)
}

local EARS = {
	102871282497587,
	139195035207985,
	103279528885139,
	70515432025070,
	135953558127627,
	87376765017111,
	98759053200111,
	122087437715412,
}

local HAIR = {
	pal = 63690008,
	brown = 62724852,
	headrow = 62234425,
	anime = 376548738,
	long = 451220849,
}

local function C(r: number, g: number, b: number): Color3
	return Color3.fromRGB(r, g, b)
end

local function L(head: Color3, torso: Color3, arms: Color3, legs: Color3, earIndex: number, hairId: number): Loadout
	local hat = EARS[((earIndex - 1) % #EARS) + 1]
	return {
		head = head,
		torso = torso,
		arms = arms,
		legs = legs,
		hat = hat,
		hair = hairId,
		icon = hat,
	}
end

local Loadouts: { [string]: Loadout } = {
	nami_hayate = L(C(210, 186, 168), C(50, 70, 120), C(210, 186, 168), C(40, 50, 90), 1, HAIR.anime),
	koma_dust = L(C(198, 170, 150), C(92, 78, 70), C(198, 170, 150), C(70, 58, 50), 2, HAIR.brown),
	rin_terrace = L(C(220, 196, 180), C(160, 80, 72), C(220, 196, 180), C(120, 60, 54), 3, HAIR.pal),
	sora_paddock = L(C(228, 210, 198), C(180, 186, 200), C(228, 210, 198), C(150, 156, 170), 4, HAIR.headrow),
	hana_straight = L(C(232, 200, 188), C(198, 86, 120), C(232, 200, 188), C(80, 140, 100), 5, HAIR.long),
	miki_furlong = L(C(214, 188, 170), C(40, 44, 48), C(214, 188, 170), C(32, 36, 40), 6, HAIR.brown),
	yuki_stirrup = L(C(236, 214, 204), C(220, 220, 228), C(236, 214, 204), C(200, 210, 200), 7, HAIR.headrow),
	akira_stretch = L(C(222, 194, 178), C(64, 84, 150), C(222, 194, 178), C(40, 56, 110), 8, HAIR.anime),
	fuyumi_crown = L(C(230, 210, 200), C(176, 196, 220), C(230, 210, 200), C(140, 160, 190), 1, HAIR.long),
	touka_mile = L(C(218, 184, 170), C(120, 52, 64), C(218, 184, 170), C(80, 36, 48), 2, HAIR.pal),
	kagura_eclipse = L(C(196, 168, 160), C(28, 24, 40), C(196, 168, 160), C(18, 14, 28), 3, HAIR.brown),
	reina_overdrive = L(C(232, 198, 186), C(196, 48, 72), C(232, 198, 186), C(120, 28, 50), 4, HAIR.anime),
	aurora_valkyrie = L(C(240, 220, 210), C(210, 180, 90), C(240, 220, 210), C(180, 150, 70), 5, HAIR.long),
	mythos_helios = L(C(238, 216, 200), C(220, 140, 50), C(238, 216, 200), C(180, 100, 30), 6, HAIR.pal),
}

local Avatars = {}

function Avatars.Get(cardId: string): Loadout?
	return Loadouts[cardId]
end

function Avatars.Thumb(assetId: number): string
	return string.format("rbxthumb://type=Asset&id=%d&w=150&h=150", assetId)
end

function Avatars.ToDescription(loadout: Loadout): HumanoidDescription
	local d = Instance.new("HumanoidDescription")
	d.HeadColor = loadout.head
	d.TorsoColor = loadout.torso
	d.LeftArmColor = loadout.arms
	d.RightArmColor = loadout.arms
	d.LeftLegColor = loadout.legs
	d.RightLegColor = loadout.legs
	d.HatAccessory = tostring(loadout.hat)
	d.HairAccessory = tostring(loadout.hair)
	return d
end

return Avatars
