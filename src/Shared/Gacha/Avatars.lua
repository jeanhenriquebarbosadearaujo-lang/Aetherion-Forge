--[[
	Loadouts R6 — Catálogo do Roblox (Avatar Shop), não Toolbox.
	Orelhas de cavalo, cabelo, laço, camisa e calça por personagem.
]]

export type Loadout = {
	head: Color3,
	torso: Color3,
	arms: Color3,
	legs: Color3,
	hat: number, -- Horse Ears
	bow: number, -- laço / ribbon (Hat extra)
	hair: number,
	shirt: number,
	pants: number,
	icon: number,
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

local BOW = {
	1073690,
	24112667,
	6365682,
	33170515,
}

local HAIR = {
	pal = 63690008,
	brown = 62724852,
	headrow = 62234425,
	anime = 376548738,
	long = 451220849,
}

local SHIRT = {
	a = 144076358,
	b = 20167190,
}

local PANTS = {
	a = 144076760,
	b = 38253025,
}

local function C(r: number, g: number, b: number): Color3
	return Color3.fromRGB(r, g, b)
end

local function L(
	head: Color3,
	torso: Color3,
	arms: Color3,
	legs: Color3,
	earIndex: number,
	hairId: number,
	bowIndex: number,
	shirtId: number,
	pantsId: number
): Loadout
	local hat = EARS[((earIndex - 1) % #EARS) + 1]
	local bow = BOW[((bowIndex - 1) % #BOW) + 1]
	return {
		head = head,
		torso = torso,
		arms = arms,
		legs = legs,
		hat = hat,
		bow = bow,
		hair = hairId,
		shirt = shirtId,
		pants = pantsId,
		icon = hat,
	}
end

local Loadouts: { [string]: Loadout } = {
	nami_hayate = L(C(210, 186, 168), C(50, 70, 120), C(210, 186, 168), C(40, 50, 90), 1, HAIR.anime, 1, SHIRT.b, PANTS.a),
	koma_dust = L(C(198, 170, 150), C(92, 78, 70), C(198, 170, 150), C(70, 58, 50), 2, HAIR.brown, 2, SHIRT.a, PANTS.b),
	rin_terrace = L(C(220, 196, 180), C(160, 80, 72), C(220, 196, 180), C(120, 60, 54), 3, HAIR.pal, 3, SHIRT.b, PANTS.a),
	sora_paddock = L(C(228, 210, 198), C(180, 186, 200), C(228, 210, 198), C(150, 156, 170), 4, HAIR.headrow, 4, SHIRT.a, PANTS.a),
	hana_straight = L(C(232, 200, 188), C(198, 86, 120), C(232, 200, 188), C(80, 140, 100), 5, HAIR.long, 1, SHIRT.b, PANTS.b),
	miki_furlong = L(C(214, 188, 170), C(40, 44, 48), C(214, 188, 170), C(32, 36, 40), 6, HAIR.brown, 2, SHIRT.a, PANTS.b),
	yuki_stirrup = L(C(236, 214, 204), C(220, 220, 228), C(236, 214, 204), C(200, 210, 200), 7, HAIR.headrow, 3, SHIRT.a, PANTS.a),
	akira_stretch = L(C(222, 194, 178), C(64, 84, 150), C(222, 194, 178), C(40, 56, 110), 8, HAIR.anime, 4, SHIRT.b, PANTS.a),
	fuyumi_crown = L(C(230, 210, 200), C(176, 196, 220), C(230, 210, 200), C(140, 160, 190), 1, HAIR.long, 1, SHIRT.a, PANTS.a),
	touka_mile = L(C(218, 184, 170), C(120, 52, 64), C(218, 184, 170), C(80, 36, 48), 2, HAIR.pal, 2, SHIRT.b, PANTS.b),
	kagura_eclipse = L(C(196, 168, 160), C(28, 24, 40), C(196, 168, 160), C(18, 14, 28), 3, HAIR.brown, 3, SHIRT.a, PANTS.b),
	reina_overdrive = L(C(232, 198, 186), C(196, 48, 72), C(232, 198, 186), C(120, 28, 50), 4, HAIR.anime, 4, SHIRT.b, PANTS.a),
	aurora_valkyrie = L(C(240, 220, 210), C(210, 180, 90), C(240, 220, 210), C(180, 150, 70), 5, HAIR.long, 1, SHIRT.a, PANTS.a),
	mythos_helios = L(C(238, 216, 200), C(220, 140, 50), C(238, 216, 200), C(180, 100, 30), 6, HAIR.pal, 2, SHIRT.b, PANTS.b),
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
	-- orelhas + laço no mesmo slot de hat (IDs separados por vírgula)
	d.HatAccessory = string.format("%d,%d", loadout.hat, loadout.bow)
	d.HairAccessory = tostring(loadout.hair)
	d.Shirt = loadout.shirt
	d.Pants = loadout.pants
	return d
end

return Avatars
