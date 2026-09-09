--[[
	Catálogo de cartas do Gacha.
	Personagens originais no gênero horse-girl / trainer (cartas autorais).
	Chances são da raridade (pool). Cartas da mesma raridade compartilham o pool com peso igual.
]]

export type RarityId = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary"

export type RarityDef = {
	id: RarityId,
	label: string,
	chance: number, -- 0–1, soma de todas = 1
	order: number,
	color: Color3,
	pip: Color3,
}

export type CardDef = {
	id: string,
	name: string,
	rarity: RarityId,
	baseValue: number,
	yieldPerSecond: number,
	-- paleta autoral da ilustração de UI
	mane: Color3,
	coat: Color3,
	accent: Color3,
	bg0: Color3,
	bg1: Color3,
}

local Rarities: { RarityDef } = {
	{
		id = "Common",
		label = "Comum",
		chance = 0.50,
		order = 1,
		color = Color3.fromRGB(168, 168, 172),
		pip = Color3.fromRGB(150, 150, 154),
	},
	{
		id = "Uncommon",
		label = "Incomum",
		chance = 0.30,
		order = 2,
		color = Color3.fromRGB(126, 176, 142),
		pip = Color3.fromRGB(98, 160, 118),
	},
	{
		id = "Rare",
		label = "Raro",
		chance = 0.15,
		order = 3,
		color = Color3.fromRGB(110, 158, 210),
		pip = Color3.fromRGB(80, 140, 200),
	},
	{
		id = "Epic",
		label = "Épico",
		chance = 0.049,
		order = 4,
		color = Color3.fromRGB(176, 122, 214),
		pip = Color3.fromRGB(158, 96, 204),
	},
	{
		id = "Legendary",
		label = "Lendário",
		chance = 0.001, -- 0.1%
		order = 5,
		color = Color3.fromRGB(232, 198, 110),
		pip = Color3.fromRGB(240, 200, 86),
	},
}

local Cards: { CardDef } = {
	-- Comum (50%)
	{
		id = "nami_hayate",
		name = "Nami Hayate",
		rarity = "Common",
		baseValue = 40,
		yieldPerSecond = 0.80,
		mane = Color3.fromRGB(70, 90, 140),
		coat = Color3.fromRGB(210, 186, 168),
		accent = Color3.fromRGB(120, 140, 180),
		bg0 = Color3.fromRGB(36, 38, 46),
		bg1 = Color3.fromRGB(18, 18, 22),
	},
	{
		id = "koma_dust",
		name = "Koma Dust",
		rarity = "Common",
		baseValue = 38,
		yieldPerSecond = 0.75,
		mane = Color3.fromRGB(92, 78, 70),
		coat = Color3.fromRGB(198, 170, 150),
		accent = Color3.fromRGB(140, 128, 118),
		bg0 = Color3.fromRGB(42, 38, 36),
		bg1 = Color3.fromRGB(18, 16, 16),
	},
	{
		id = "rin_terrace",
		name = "Rin Terrace",
		rarity = "Common",
		baseValue = 42,
		yieldPerSecond = 0.85,
		mane = Color3.fromRGB(160, 96, 88),
		coat = Color3.fromRGB(220, 196, 180),
		accent = Color3.fromRGB(188, 120, 110),
		bg0 = Color3.fromRGB(46, 36, 36),
		bg1 = Color3.fromRGB(20, 16, 16),
	},
	{
		id = "sora_paddock",
		name = "Sora Paddock",
		rarity = "Common",
		baseValue = 45,
		yieldPerSecond = 0.90,
		mane = Color3.fromRGB(200, 200, 208),
		coat = Color3.fromRGB(228, 210, 198),
		accent = Color3.fromRGB(160, 168, 184),
		bg0 = Color3.fromRGB(40, 42, 50),
		bg1 = Color3.fromRGB(16, 18, 22),
	},
	-- Incomum (30%)
	{
		id = "hana_straight",
		name = "Hana Straight",
		rarity = "Uncommon",
		baseValue = 80,
		yieldPerSecond = 1.60,
		mane = Color3.fromRGB(198, 86, 120),
		coat = Color3.fromRGB(232, 200, 188),
		accent = Color3.fromRGB(120, 176, 132),
		bg0 = Color3.fromRGB(32, 48, 40),
		bg1 = Color3.fromRGB(14, 20, 18),
	},
	{
		id = "miki_furlong",
		name = "Miki Furlong",
		rarity = "Uncommon",
		baseValue = 88,
		yieldPerSecond = 1.80,
		mane = Color3.fromRGB(48, 48, 56),
		coat = Color3.fromRGB(214, 188, 170),
		accent = Color3.fromRGB(110, 168, 130),
		bg0 = Color3.fromRGB(28, 44, 36),
		bg1 = Color3.fromRGB(12, 18, 16),
	},
	{
		id = "yuki_stirrup",
		name = "Yuki Stirrup",
		rarity = "Uncommon",
		baseValue = 84,
		yieldPerSecond = 1.70,
		mane = Color3.fromRGB(232, 232, 236),
		coat = Color3.fromRGB(236, 214, 204),
		accent = Color3.fromRGB(140, 190, 160),
		bg0 = Color3.fromRGB(36, 50, 46),
		bg1 = Color3.fromRGB(14, 20, 20),
	},
	-- Raro (15%)
	{
		id = "akira_stretch",
		name = "Akira Stretch",
		rarity = "Rare",
		baseValue = 140,
		yieldPerSecond = 3.20,
		mane = Color3.fromRGB(64, 84, 150),
		coat = Color3.fromRGB(222, 194, 178),
		accent = Color3.fromRGB(96, 150, 210),
		bg0 = Color3.fromRGB(28, 40, 62),
		bg1 = Color3.fromRGB(10, 14, 24),
	},
	{
		id = "fuyumi_crown",
		name = "Fuyumi Crown",
		rarity = "Rare",
		baseValue = 155,
		yieldPerSecond = 3.60,
		mane = Color3.fromRGB(176, 196, 220),
		coat = Color3.fromRGB(230, 210, 200),
		accent = Color3.fromRGB(120, 164, 214),
		bg0 = Color3.fromRGB(32, 44, 66),
		bg1 = Color3.fromRGB(12, 16, 28),
	},
	{
		id = "touka_mile",
		name = "Touka Mile",
		rarity = "Rare",
		baseValue = 148,
		yieldPerSecond = 3.40,
		mane = Color3.fromRGB(120, 52, 64),
		coat = Color3.fromRGB(218, 184, 170),
		accent = Color3.fromRGB(88, 140, 200),
		bg0 = Color3.fromRGB(40, 32, 52),
		bg1 = Color3.fromRGB(14, 12, 22),
	},
	-- Épico (4.9%)
	{
		id = "kagura_eclipse",
		name = "Kagura Eclipse",
		rarity = "Epic",
		baseValue = 260,
		yieldPerSecond = 7.50,
		mane = Color3.fromRGB(28, 24, 40),
		coat = Color3.fromRGB(196, 168, 160),
		accent = Color3.fromRGB(168, 110, 210),
		bg0 = Color3.fromRGB(40, 28, 56),
		bg1 = Color3.fromRGB(12, 8, 20),
	},
	{
		id = "reina_overdrive",
		name = "Reina Overdrive",
		rarity = "Epic",
		baseValue = 280,
		yieldPerSecond = 8.20,
		mane = Color3.fromRGB(196, 48, 72),
		coat = Color3.fromRGB(232, 198, 186),
		accent = Color3.fromRGB(186, 120, 220),
		bg0 = Color3.fromRGB(52, 28, 48),
		bg1 = Color3.fromRGB(18, 10, 20),
	},
	-- Lendário (0.1%)
	{
		id = "aurora_valkyrie",
		name = "Aurora Valkyrie",
		rarity = "Legendary",
		baseValue = 900,
		yieldPerSecond = 28.0,
		mane = Color3.fromRGB(236, 214, 150),
		coat = Color3.fromRGB(240, 220, 210),
		accent = Color3.fromRGB(232, 196, 96),
		bg0 = Color3.fromRGB(58, 46, 24),
		bg1 = Color3.fromRGB(18, 14, 8),
	},
	{
		id = "mythos_helios",
		name = "Mythos Helios",
		rarity = "Legendary",
		baseValue = 950,
		yieldPerSecond = 32.0,
		mane = Color3.fromRGB(244, 168, 64),
		coat = Color3.fromRGB(238, 216, 200),
		accent = Color3.fromRGB(250, 210, 110),
		bg0 = Color3.fromRGB(62, 42, 16),
		bg1 = Color3.fromRGB(20, 12, 6),
	},
}

local rarityById: { [string]: RarityDef } = {}
for _, r in ipairs(Rarities) do
	rarityById[r.id] = r
end

local cardsById: { [string]: CardDef } = {}
local cardsByRarity: { [string]: { CardDef } } = {}
for _, c in ipairs(Cards) do
	cardsById[c.id] = c
	local bucket = cardsByRarity[c.rarity]
	if not bucket then
		bucket = {}
		cardsByRarity[c.rarity] = bucket
	end
	table.insert(bucket, c)
end

local Catalog = {}

function Catalog.GetRarities(): { RarityDef }
	return Rarities
end

function Catalog.GetRarity(id: string): RarityDef?
	return rarityById[id]
end

function Catalog.GetCards(): { CardDef }
	return Cards
end

function Catalog.GetCard(id: string): CardDef?
	return cardsById[id]
end

function Catalog.GetPool(rarityId: string): { CardDef }
	return cardsByRarity[rarityId] or {}
end

-- Chance individual (pool da raridade dividido igualmente).
function Catalog.GetCardChance(card: CardDef): number
	local rarity = rarityById[card.rarity]
	local pool = cardsByRarity[card.rarity]
	if not rarity or not pool or #pool == 0 then
		return 0
	end
	return rarity.chance / #pool
end

function Catalog.ToPublic(card: CardDef): { [string]: any }
	local rarity = rarityById[card.rarity]
	return {
		id = card.id,
		name = card.name,
		rarity = card.rarity,
		rarityLabel = rarity and rarity.label or card.rarity,
		rarityChance = rarity and rarity.chance or 0,
		cardChance = Catalog.GetCardChance(card),
		baseValue = card.baseValue,
		yieldPerSecond = card.yieldPerSecond,
		mane = { card.mane.R, card.mane.G, card.mane.B },
		coat = { card.coat.R, card.coat.G, card.coat.B },
		accent = { card.accent.R, card.accent.G, card.accent.B },
		bg0 = { card.bg0.R, card.bg0.G, card.bg0.B },
		bg1 = { card.bg1.R, card.bg1.G, card.bg1.B },
		rarityColor = rarity and { rarity.color.R, rarity.color.G, rarity.color.B } or { 1, 1, 1 },
	}
end

function Catalog.FromPublic(pub: { [string]: any }): CardDef?
	if typeof(pub) ~= "table" or typeof(pub.id) ~= "string" then
		return nil
	end
	return cardsById[pub.id]
end

return Catalog
