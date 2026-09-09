--[[
	Loadouts R6 de alta fidelidade — Catálogo pago/UGC (não Toolbox).
	Peças genéricas (Pal Hair, Headrow, camisa/calça default) removidas.
	Orelhas + cauda + cabelo anime + jaqueta escolar 3D + saia 3D.
]]

export type Loadout = {
	head: Color3,
	torso: Color3,
	arms: Color3,
	legs: Color3,
	hat: number,
	hair: number,
	tail: number,
	jacket: number,
	skirt: number,
	icon: number,
	labels: { [string]: string },
}

local function C(r: number, g: number, b: number): Color3
	return Color3.fromRGB(r, g, b)
end

local function L(head, torso, arms, legs, hat, hair, tail, jacket, skirt, labels): Loadout
	return {
		head = head,
		torso = torso,
		arms = arms,
		legs = legs,
		hat = hat,
		hair = hair,
		tail = tail,
		jacket = jacket,
		skirt = skirt,
		icon = hat,
		labels = labels,
	}
end

local E = {
	A = 102871282497587,
	B = 139195035207985,
	C = 103279528885139,
	D = 70515432025070,
	E = 135953558127627,
	F = 87376765017111,
	G = 98759053200111,
	H = 122087437715412,
	I = 73660369771317,
	J = 99465307697128,
}
local T = {
	A = 97381878272194,
	B = 117853202425013,
	C = 98064396309972,
	D = 133698075321084,
	E = 80742548627272,
	F = 131077655971542,
	G = 118644962636841,
	H = 121350304694867,
	I = 84985181877405,
	J = 109373635749037,
	Rainbow = 88982400427363,
	Teal = 107282144085820,
}
local H = {
	blackMessy = 8088927244,
	blackPony = 8207626927,
	blackAnime = 164482468,
	whiteWavy = 6594921063,
	whiteBow = 1425141074,
	blondePony = 398673196,
	blondeStar = 73790841,
	blondePigtails = 5945071617,
	blondePink = 6211691607,
	brownPigtails = 9726556203,
	blueAnime = 164482409,
	goldAnime = 185812297,
	pinkQueen = 323419816,
}
local J = {
	animeSchool = 122174365549433,
	whiteHigh = 18873471947,
	gakuranGreen = 125113262459983,
	gakuranWhite = 84920618372474,
	gakuranBlack = 99092259355266,
	pinkBunny = 9170282735,
	cuteSchool = 135824868023229,
}
local S = {
	blueSchool = 104060477000876,
	blackSchool = 95162684798644,
}

local Loadouts: { [string]: Loadout } = {
	nami_hayate = L(C(210,186,168), C(48,64,110), C(210,186,168), C(40,50,90), E.A, H.blueAnime, T.Teal, J.whiteHigh, S.blueSchool, {
		ears="Horse Ears", hair="Blue Anime Girl Hair", tail="Miku Teal Horse Tail",
		jacket="Anime High School White Jacket Cosplay Uniform", skirt="School Uniform (Blue)",
	}),
	koma_dust = L(C(198,170,150), C(90,72,60), C(198,170,150), C(70,56,48), E.B, H.brownPigtails, T.E, J.gakuranGreen, S.blackSchool, {
		ears="Horse Ears", hair="Swirly Half Up Anime Pigtails (Brown)", tail="Horse Tail",
		jacket="Gakuran Japanese Green School Uniform Jacket", skirt="School Uniform Outfit (Black)",
	}),
	rin_terrace = L(C(220,196,180), C(150,78,70), C(220,196,180), C(120,58,52), E.C, H.blondePony, T.C, J.cuteSchool, S.blueSchool, {
		ears="Horse Ears", hair="Blonde Action Ponytail", tail="Horse Tail",
		jacket="Cute School Uniform", skirt="School Uniform (Blue)",
	}),
	sora_paddock = L(C(228,210,198), C(186,190,200), C(228,210,198), C(160,166,176), E.D, H.whiteWavy, T.A, J.gakuranWhite, S.blueSchool, {
		ears="Horse Ears", hair="White Messy Wavy Middle Part", tail="Horse Tail",
		jacket="Gakuran Japanese White School Uniform Jacket", skirt="School Uniform (Blue)",
	}),
	hana_straight = L(C(232,200,188), C(186,80,118), C(232,200,188), C(80,130,96), E.E, H.pinkQueen, T.Rainbow, J.pinkBunny, S.blueSchool, {
		ears="Horse Ears", hair="Glorious Pink Party Queen", tail="Stylish Rainbow Horse Tail",
		jacket="Adorable Pink Bunny School Uniform Jacket", skirt="School Uniform (Blue)",
	}),
	miki_furlong = L(C(214,188,170), C(36,38,42), C(214,188,170), C(28,30,34), E.F, H.blackMessy, T.F, J.gakuranBlack, S.blackSchool, {
		ears="Horse Ears", hair="Black Messy Anime Hair", tail="Horse Tail",
		jacket="Gakuran Japanese Black School Uniform Jacket", skirt="School Uniform Outfit (Black)",
	}),
	yuki_stirrup = L(C(236,214,204), C(220,220,226), C(236,214,204), C(200,208,200), E.G, H.whiteBow, T.B, J.gakuranWhite, S.blueSchool, {
		ears="Horse Ears", hair="Ghostly White Hair with Black Bow", tail="Horse Tail",
		jacket="Gakuran Japanese White School Uniform Jacket", skirt="School Uniform (Blue)",
	}),
	akira_stretch = L(C(222,194,178), C(60,80,140), C(222,194,178), C(40,54,108), E.H, H.blueAnime, T.H, J.animeSchool, S.blueSchool, {
		ears="Horse Ears", hair="Blue Anime Girl Hair", tail="Horse Tail",
		jacket="Japanese Anime School Uniform Jacket", skirt="School Uniform (Blue)",
	}),
	fuyumi_crown = L(C(230,210,200), C(176,196,220), C(230,210,200), C(140,160,190), E.I, H.whiteWavy, T.I, J.whiteHigh, S.blueSchool, {
		ears="Horse Ears", hair="White Messy Wavy Middle Part", tail="Horse Tail",
		jacket="Anime High School White Jacket Cosplay Uniform", skirt="School Uniform (Blue)",
	}),
	touka_mile = L(C(218,184,170), C(118,48,60), C(218,184,170), C(80,36,46), E.J, H.blondePink, T.J, J.gakuranBlack, S.blackSchool, {
		ears="Horse Ears", hair="Blonde to Pink Dollie Popstar Pigtails", tail="Horse Tail",
		jacket="Gakuran Japanese Black School Uniform Jacket", skirt="School Uniform Outfit (Black)",
	}),
	kagura_eclipse = L(C(196,168,160), C(24,20,36), C(196,168,160), C(16,12,26), E.A, H.blackAnime, T.D, J.gakuranBlack, S.blackSchool, {
		ears="Horse Ears", hair="Anime Girl Hair (Black)", tail="Horse Tail",
		jacket="Gakuran Japanese Black School Uniform Jacket", skirt="School Uniform Outfit (Black)",
	}),
	reina_overdrive = L(C(232,198,186), C(190,46,70), C(232,198,186), C(118,28,48), E.B, H.blondePigtails, T.G, J.pinkBunny, S.blueSchool, {
		ears="Horse Ears", hair="Blonde Wavy Pigtails w Kawaii Clips", tail="Horse Tail",
		jacket="Adorable Pink Bunny School Uniform Jacket", skirt="School Uniform (Blue)",
	}),
	aurora_valkyrie = L(C(240,220,210), C(210,176,88), C(240,220,210), C(176,148,68), E.E, H.goldAnime, T.A, J.whiteHigh, S.blueSchool, {
		ears="Horse Ears", hair="Golden Anime Girl Hair", tail="Horse Tail",
		jacket="Anime High School White Jacket Cosplay Uniform", skirt="School Uniform (Blue)",
	}),
	mythos_helios = L(C(238,216,200), C(216,136,48), C(238,216,200), C(176,98,28), E.C, H.blondeStar, T.Rainbow, J.animeSchool, S.blueSchool, {
		ears="Horse Ears", hair="Blonde Anime Superstar", tail="Stylish Rainbow Horse Tail",
		jacket="Japanese Anime School Uniform Jacket", skirt="School Uniform (Blue)",
	}),
}

local Avatars = {}

function Avatars.Get(cardId: string): Loadout?
	return Loadouts[cardId]
end

function Avatars.All(): { [string]: Loadout }
	return Loadouts
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
	d.WaistAccessory = tostring(loadout.tail)
	d.JacketAccessory = tostring(loadout.jacket)
	d.DressSkirtAccessory = tostring(loadout.skirt)
	return d
end

return Avatars
