--[[
	GachaService — sorteio autoritativo no servidor.
	O cliente nunca escolhe raridade. Cooldown por jogador evita flood do Auto-Roll.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Catalog = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Gacha"):WaitForChild("Catalog"))

local COOLDOWN = 0.55
local rng = Random.new()

local remotesFolder = ReplicatedStorage:FindFirstChild("AetherionRemotes")
if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "AetherionRemotes"
	remotesFolder.Parent = ReplicatedStorage
end

local rollFn = remotesFolder:FindFirstChild("RollOnce")
if not rollFn then
	rollFn = Instance.new("RemoteFunction")
	rollFn.Name = "RollOnce"
	rollFn.Parent = remotesFolder
end

type InvEntry = { id: string, at: number }
local inventory: { [number]: { InvEntry } } = {}
local lastRollAt: { [number]: number } = {}

local function getInv(userId: number): { InvEntry }
	local list = inventory[userId]
	if not list then
		list = {}
		inventory[userId] = list
	end
	return list
end

local function pickCard()
	local rarities = Catalog.GetRarities()
	local roll = rng:NextNumber()
	local acc = 0
	local chosenRarity = rarities[#rarities]
	for _, rarity in ipairs(rarities) do
		acc += rarity.chance
		if roll <= acc then
			chosenRarity = rarity
			break
		end
	end
	local pool = Catalog.GetPool(chosenRarity.id)
	if #pool == 0 then
		return nil
	end
	return pool[rng:NextInteger(1, #pool)]
end

local function countOwned(list: { InvEntry }, cardId: string): number
	local n = 0
	for _, e in ipairs(list) do
		if e.id == cardId then
			n += 1
		end
	end
	return n
end

rollFn.OnServerInvoke = function(player: Player)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return { ok = false, err = "invalid_player" }
	end

	local now = os.clock()
	local prev = lastRollAt[player.UserId]
	if prev and (now - prev) < COOLDOWN then
		return { ok = false, err = "cooldown", wait = COOLDOWN - (now - prev) }
	end
	lastRollAt[player.UserId] = now

	local card = pickCard()
	if not card then
		return { ok = false, err = "empty_catalog" }
	end

	local inv = getInv(player.UserId)
	table.insert(inv, { id = card.id, at = os.time() })

	return {
		ok = true,
		card = Catalog.ToPublic(card),
		inventoryCount = #inv,
		ownedOfThis = countOwned(inv, card.id),
	}
end

Players.PlayerRemoving:Connect(function(player)
	lastRollAt[player.UserId] = nil
	-- inventário de sessão: libera memória ao sair (sem persistência ainda)
	inventory[player.UserId] = nil
end)

print("[Aetherion] GachaService ready")
