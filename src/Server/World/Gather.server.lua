--[[
  Coleta em Script separado. Se isto quebrar, a ilha da World continua.
  Sem --!strict, sem type, sem require.
]]

print("[Aetherion] Gather v242 start")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local HIT_CD = 0.4
local invs = {}
local lastHit = {}

local function getInv(player)
	local bag = invs[player.UserId]
	if not bag then
		bag = { madeira = 0, pedra = 0 }
		invs[player.UserId] = bag
	end
	return bag
end

local function fontOk()
	local ok, font = pcall(function()
		return Enum.Font.BuilderSans
	end)
	if ok then
		return font
	end
	return Enum.Font.SourceSans
end

local FONT = fontOk()

local function updateHud(player)
	local gui = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("AetherionInv")
	if not gui then
		return
	end
	local bag = getInv(player)
	local wood = gui:FindFirstChild("WoodCount", true)
	local stone = gui:FindFirstChild("StoneCount", true)
	if wood and wood:IsA("TextLabel") then
		wood.Text = tostring(bag.madeira)
	end
	if stone and stone:IsA("TextLabel") then
		stone.Text = tostring(bag.pedra)
	end
end

local function mkSlot(parent, name, title, color, xScale)
	local slot = Instance.new("Frame")
	slot.Name = name
	slot.BackgroundColor3 = Color3.fromRGB(28, 30, 26)
	slot.BackgroundTransparency = 0.12
	slot.AnchorPoint = Vector2.new(0, 0.5)
	slot.Position = UDim2.fromScale(xScale, 0.5)
	slot.Size = UDim2.fromScale(0.46, 0.78)
	slot.Parent = parent
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0.22, 0)
	c.Parent = slot
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(48, 52, 44)
	stroke.Thickness = 1.4
	stroke.Parent = slot
	local swatch = Instance.new("Frame")
	swatch.BackgroundColor3 = color
	swatch.AnchorPoint = Vector2.new(0, 0.5)
	swatch.Position = UDim2.fromScale(0.07, 0.5)
	swatch.Size = UDim2.fromScale(0.22, 0.62)
	swatch.Parent = slot
	local sc = Instance.new("UICorner")
	sc.CornerRadius = UDim.new(0.28, 0)
	sc.Parent = swatch
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromScale(0.34, 0.08)
	label.Size = UDim2.fromScale(0.62, 0.38)
	label.Font = FONT
	label.Text = title
	label.TextColor3 = Color3.fromRGB(210, 214, 200)
	label.TextScaled = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = slot
	local count = Instance.new("TextLabel")
	count.Name = name .. "Count"
	count.BackgroundTransparency = 1
	count.Position = UDim2.fromScale(0.34, 0.46)
	count.Size = UDim2.fromScale(0.62, 0.46)
	count.Font = FONT
	count.Text = "0"
	count.TextColor3 = Color3.fromRGB(240, 242, 230)
	count.TextScaled = true
	count.TextXAlignment = Enum.TextXAlignment.Left
	count.Parent = slot
end

local function buildHud(player)
	local pg = player:FindFirstChild("PlayerGui")
	if not pg then
		return
	end
	local old = pg:FindFirstChild("AetherionInv")
	if old then
		old:Destroy()
	end
	local gui = Instance.new("ScreenGui")
	gui.Name = "AetherionInv"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = pg
	local bar = Instance.new("Frame")
	bar.Name = "Bar"
	bar.AnchorPoint = Vector2.new(0.5, 1)
	bar.Position = UDim2.fromScale(0.5, 0.9)
	bar.Size = UDim2.fromScale(0.42, 0.09)
	bar.BackgroundColor3 = Color3.fromRGB(16, 18, 14)
	bar.BackgroundTransparency = 0.18
	bar.Parent = gui
	local ar = Instance.new("UIAspectRatioConstraint")
	ar.AspectRatio = 5.6
	ar.Parent = bar
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.28, 0)
	corner.Parent = bar
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0.03, 0)
	pad.PaddingRight = UDim.new(0.03, 0)
	pad.Parent = bar
	mkSlot(bar, "Wood", "Madeira", Color3.fromRGB(92, 64, 40), 0.02)
	mkSlot(bar, "Stone", "Pedra", Color3.fromRGB(120, 118, 112), 0.52)
	updateHud(player)
end

local function hookPlayer(player)
	getInv(player)
	task.spawn(function()
		player:WaitForChild("PlayerGui", 20)
		local ok, err = pcall(buildHud, player)
		if not ok then
			warn("[Aetherion] hud FAIL ", err)
		end
	end)
end

Players.PlayerAdded:Connect(hookPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	hookPlayer(player)
end
Players.PlayerRemoving:Connect(function(player)
	invs[player.UserId] = nil
	lastHit[player.UserId] = nil
end

local function breakModel(model)
	local pivot = model:GetPivot()
	local goal = pivot * CFrame.Angles(0, 0, math.rad(86))
	local info = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") then
			d.CanCollide = false
			local rel = pivot:ToObjectSpace(d.CFrame)
			TweenService:Create(d, info, { CFrame = goal * rel }):Play()
		elseif d:IsA("ProximityPrompt") then
			d.Enabled = false
		end
	end
	task.delay(0.55, function()
		if model.Parent then
			model:Destroy()
		end
	end)
end

local function onHarvest(player, model)
	if not player.Parent or not model.Parent then
		return
	end
	local now = os.clock()
	if (lastHit[player.UserId] or 0) + HIT_CD > now then
		return
	end
	lastHit[player.UserId] = now
	local root = model.PrimaryPart
	if not root then
		return
	end
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end
	if (hrp.Position - root.Position).Magnitude > 16 then
		return
	end
	local left = tonumber(model:GetAttribute("HitsLeft")) or 1
	left = left - 1
	model:SetAttribute("HitsLeft", left)
	local bill = root:FindFirstChild("HitsBillboard")
	local label = bill and bill:FindFirstChild("Hits")
	if label and label:IsA("TextLabel") then
		label.Text = tostring(math.max(left, 0))
	end
	if left > 0 then
		return
	end
	local kind = tostring(model:GetAttribute("Kind") or model.Name)
	local yieldAmt = tonumber(model:GetAttribute("Yield")) or 3
	local bag = getInv(player)
	if kind == "rock" or kind == "Rock" then
		bag.pedra = bag.pedra + yieldAmt
	else
		bag.madeira = bag.madeira + yieldAmt
	end
	updateHud(player)
	print("[Aetherion] harvest", player.Name, kind, yieldAmt, "wood", bag.madeira, "stone", bag.pedra)
	breakModel(model)
end

local function attach(model)
	if model:FindFirstChild("Harvest", true) then
		return
	end
	local root = model.PrimaryPart
	if not root then
		for _, d in ipairs(model:GetDescendants()) do
			if d:IsA("BasePart") and d.CanCollide then
				root = d
				break
			end
		end
	end
	if not root then
		return
	end
	model.PrimaryPart = root
	local isRock = model.Name == "Rock"
	model:SetAttribute("Kind", isRock and "rock" or string.lower(model.Name))
	model:SetAttribute("HitsLeft", isRock and 4 or 3)
	model:SetAttribute("Yield", isRock and 3 or (model.Name == "Oak" and 4 or 3))

	-- Copa da árvore tapa o tronco. No celular o prompt some se exigir linha de visão.
	local att = Instance.new("Attachment")
	att.Name = "HarvestAtt"
	att.Position = Vector3.new(0, 3, 0)
	att.Parent = root

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "Harvest"
	prompt.ActionText = isRock and "Quebrar" or "Cortar"
	prompt.ObjectText = isRock and "Pedra" or "Árvore"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 20
	prompt.RequiresLineOfSight = false
	prompt.ClickablePrompt = true
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.Parent = att

	local bb = Instance.new("BillboardGui")
	bb.Name = "HitsBillboard"
	bb.Size = UDim2.fromScale(2.4, 0.8)
	bb.StudsOffset = Vector3.new(0, 5.5, 0)
	bb.Parent = root
	local tl = Instance.new("TextLabel")
	tl.Name = "Hits"
	tl.BackgroundTransparency = 1
	tl.Size = UDim2.fromScale(1, 1)
	tl.Font = FONT
	tl.Text = tostring(model:GetAttribute("HitsLeft"))
	tl.TextColor3 = Color3.fromRGB(230, 230, 220)
	tl.TextScaled = true
	tl.Parent = bb

	prompt.Triggered:Connect(function(player)
		onHarvest(player, model)
	end)
end

task.spawn(function()
	local deadline = os.clock() + 90
	while os.clock() < deadline do
		if workspace:GetAttribute("AetherionWorld") ~= nil then
			break
		end
		task.wait(0.4)
	end
	local folder = workspace:FindFirstChild("WorldScenery")
	if not folder then
		warn("[Aetherion] Gather: sem WorldScenery — ilha pode ter falhado")
		print("[Aetherion] Gather v242 ready (no scenery)")
		return
	end
	local n = 0
	for _, child in ipairs(folder:GetChildren()) do
		if child:IsA("Model") then
			local ok, err = pcall(attach, child)
			if ok then
				n = n + 1
			else
				warn("[Aetherion] attach FAIL ", child.Name, err)
			end
		end
	end
	print("[Aetherion] Gather v242 hooked", n)
	print("[Aetherion] Gather v242 ready")
end)
