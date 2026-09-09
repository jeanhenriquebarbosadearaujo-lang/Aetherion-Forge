--[[
	GachaClient — menu Girar / Rolls.
	Preview 3D R6 com itens do Catálogo + ícone rbxthumb.
	Layout com folga (Scale + UIListLayout). Sem overlap.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Shared = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Gacha")
local Avatars = require(Shared:WaitForChild("Avatars"))

local remotes = ReplicatedStorage:WaitForChild("AetherionRemotes", 15)
if not remotes then
	warn("[Aetherion] AetherionRemotes ausente")
	return
end
local rollOnce = remotes:WaitForChild("RollOnce") :: RemoteFunction

local C = {
	Void = Color3.fromRGB(8, 8, 10),
	Panel = Color3.fromRGB(16, 16, 18),
	PanelEdge = Color3.fromRGB(48, 48, 54),
	Slot = Color3.fromRGB(26, 26, 30),
	Text = Color3.fromRGB(230, 230, 232),
	Muted = Color3.fromRGB(148, 148, 154),
	Accent = Color3.fromRGB(186, 186, 190),
	On = Color3.fromRGB(120, 186, 140),
	Danger = Color3.fromRGB(200, 90, 90),
}

local T_FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local AUTO_INTERVAL = 0.90 -- > cooldown do servidor (0.55)

local autoOn = false
local rolling = false
local autoGen = 0
local rotConn: RBXScriptConnection? = nil
local lastCardId: string? = nil

local function corner(p: Instance, s: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(s, 0)
	c.Parent = p
	return c
end
local function stroke(p: Instance, col: Color3, th: number, tr: number)
	local s = Instance.new("UIStroke")
	s.Color = col
	s.Thickness = th
	s.Transparency = tr
	s.Parent = p
	return s
end
local function pad(p: Instance, t: number, b: number, l: number, r: number)
	local x = Instance.new("UIPadding")
	x.PaddingTop = UDim.new(t, 0)
	x.PaddingBottom = UDim.new(b, 0)
	x.PaddingLeft = UDim.new(l, 0)
	x.PaddingRight = UDim.new(r, 0)
	x.Parent = p
	return x
end
local function textLimit(inst: TextLabel | TextButton, minS: number, maxS: number)
	local lim = Instance.new("UITextSizeConstraint")
	lim.MinTextSize = minS
	lim.MaxTextSize = maxS
	lim.Parent = inst
end

local gui = Instance.new("ScreenGui")
gui.Name = "GachaMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 140
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Enabled = false
gui.Parent = playerGui

local overlay = Instance.new("TextButton")
overlay.Name = "Overlay"
overlay.AutoButtonColor = false
overlay.Text = ""
overlay.BackgroundColor3 = Color3.new(0, 0, 0)
overlay.BackgroundTransparency = 0.5
overlay.Size = UDim2.fromScale(1, 1)
overlay.ZIndex = 1
overlay.Parent = gui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromScale(0.86, 0.78)
panel.BackgroundColor3 = C.Panel
panel.BorderSizePixel = 0
panel.ZIndex = 2
panel.Parent = gui
corner(panel, 0.035)
stroke(panel, C.PanelEdge, 1, 0.15)
pad(panel, 0.04, 0.045, 0.055, 0.055)

local panelAspect = Instance.new("UIAspectRatioConstraint")
panelAspect.AspectRatio = 0.62
panelAspect.AspectType = Enum.AspectType.FitWithinMaxSize
panelAspect.Parent = panel

local col = Instance.new("UIListLayout")
col.FillDirection = Enum.FillDirection.Vertical
col.HorizontalAlignment = Enum.HorizontalAlignment.Center
col.VerticalAlignment = Enum.VerticalAlignment.Top
col.Padding = UDim.new(0.018, 0)
col.SortOrder = Enum.SortOrder.LayoutOrder
col.Parent = panel

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundTransparency = 1
header.Size = UDim2.fromScale(1, 0.08)
header.LayoutOrder = 1
header.ZIndex = 3
header.Parent = panel

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.fromScale(0.72, 1)
title.Position = UDim2.fromScale(0, 0)
title.Font = Enum.Font.GothamBold
title.Text = "GIRAR / ROLLS"
title.TextColor3 = C.Text
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 4
title.Parent = header
textLimit(title, 14, 24)

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "Close"
closeBtn.AutoButtonColor = false
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
closeBtn.TextColor3 = C.Muted
closeBtn.BackgroundColor3 = C.Slot
closeBtn.AnchorPoint = Vector2.new(1, 0.5)
closeBtn.Position = UDim2.fromScale(1, 0.5)
closeBtn.Size = UDim2.fromScale(0.12, 0.86)
closeBtn.ZIndex = 5
closeBtn.Parent = header
corner(closeBtn, 0.22)
stroke(closeBtn, C.PanelEdge, 1, 0.35)
textLimit(closeBtn, 12, 20)
do
	local a = Instance.new("UIAspectRatioConstraint")
	a.AspectRatio = 1
	a.Parent = closeBtn
end

-- Palco 3D + ícone
local stage = Instance.new("Frame")
stage.Name = "Stage"
stage.BackgroundColor3 = C.Slot
stage.BorderSizePixel = 0
stage.Size = UDim2.fromScale(0.92, 0.46)
stage.LayoutOrder = 2
stage.ZIndex = 3
stage.ClipsDescendants = true
stage.Parent = panel
corner(stage, 0.06)
stroke(stage, C.PanelEdge, 1, 0.3)

local stageAspect = Instance.new("UIAspectRatioConstraint")
stageAspect.AspectRatio = 0.78
stageAspect.AspectType = Enum.AspectType.FitWithinMaxSize
stageAspect.Parent = stage

local viewport = Instance.new("ViewportFrame")
viewport.Name = "R6View"
viewport.BackgroundTransparency = 1
viewport.Size = UDim2.fromScale(1, 1)
viewport.Ambient = Color3.fromRGB(90, 90, 100)
viewport.LightColor = Color3.fromRGB(255, 255, 255)
viewport.LightDirection = Vector3.new(-0.6, -1, -0.4)
viewport.ZIndex = 4
viewport.Parent = stage

local world = Instance.new("WorldModel")
world.Name = "World"
world.Parent = viewport

local cam = Instance.new("Camera")
cam.FieldOfView = 50
cam.Parent = viewport
viewport.CurrentCamera = cam
cam.CFrame = CFrame.lookAt(Vector3.new(0, 2.6, 12), Vector3.new(0, 2.4, 0))

local icon = Instance.new("ImageLabel")
icon.Name = "CatalogIcon"
icon.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
icon.BackgroundTransparency = 0.15
icon.BorderSizePixel = 0
icon.AnchorPoint = Vector2.new(0, 1)
icon.Position = UDim2.fromScale(0.04, 0.95)
icon.Size = UDim2.fromScale(0.18, 0.18)
icon.Image = ""
icon.ScaleType = Enum.ScaleType.Fit
icon.ZIndex = 6
icon.Parent = stage
corner(icon, 0.18)
stroke(icon, C.PanelEdge, 1, 0.25)
do
	local a = Instance.new("UIAspectRatioConstraint")
	a.AspectRatio = 1
	a.Parent = icon
end

local nameLbl = Instance.new("TextLabel")
nameLbl.Name = "CardName"
nameLbl.BackgroundTransparency = 1
nameLbl.Size = UDim2.fromScale(1, 0.055)
nameLbl.LayoutOrder = 3
nameLbl.Font = Enum.Font.GothamBold
nameLbl.Text = "—"
nameLbl.TextColor3 = C.Text
nameLbl.TextScaled = true
nameLbl.ZIndex = 4
nameLbl.Parent = panel
textLimit(nameLbl, 12, 22)

local rarityLbl = Instance.new("TextLabel")
rarityLbl.Name = "Rarity"
rarityLbl.BackgroundTransparency = 1
rarityLbl.Size = UDim2.fromScale(1, 0.04)
rarityLbl.LayoutOrder = 4
rarityLbl.Font = Enum.Font.Gotham
rarityLbl.Text = "toque em GIRAR"
rarityLbl.TextColor3 = C.Muted
rarityLbl.TextScaled = true
rarityLbl.ZIndex = 4
rarityLbl.Parent = panel
textLimit(rarityLbl, 10, 16)

local statsLbl = Instance.new("TextLabel")
statsLbl.Name = "Stats"
statsLbl.BackgroundTransparency = 1
statsLbl.Size = UDim2.fromScale(1, 0.09)
statsLbl.LayoutOrder = 5
statsLbl.Font = Enum.Font.Gotham
statsLbl.Text = "Valor  —\nRendimento  — /seg\nChance  —"
statsLbl.TextColor3 = C.Accent
statsLbl.TextScaled = true
statsLbl.ZIndex = 4
statsLbl.Parent = panel
textLimit(statsLbl, 10, 16)

local countLbl = Instance.new("TextLabel")
countLbl.Name = "Counts"
countLbl.BackgroundTransparency = 1
countLbl.Size = UDim2.fromScale(1, 0.035)
countLbl.LayoutOrder = 6
countLbl.Font = Enum.Font.Gotham
countLbl.Text = ""
countLbl.TextColor3 = C.Muted
countLbl.TextScaled = true
countLbl.ZIndex = 4
countLbl.Parent = panel
textLimit(countLbl, 9, 14)

-- folga antes dos botões
local spacer = Instance.new("Frame")
spacer.Name = "Spacer"
spacer.BackgroundTransparency = 1
spacer.Size = UDim2.fromScale(1, 0.012)
spacer.LayoutOrder = 7
spacer.Parent = panel

local actions = Instance.new("Frame")
actions.Name = "Actions"
actions.BackgroundTransparency = 1
actions.Size = UDim2.fromScale(1, 0.13)
actions.LayoutOrder = 8
actions.ZIndex = 4
actions.Parent = panel

local actionsList = Instance.new("UIListLayout")
actionsList.FillDirection = Enum.FillDirection.Horizontal
actionsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
actionsList.VerticalAlignment = Enum.VerticalAlignment.Center
actionsList.Padding = UDim.new(0.06, 0)
actionsList.Parent = actions

local function makeAction(name: string, text: string, order: number): TextButton
	local b = Instance.new("TextButton")
	b.Name = name
	b.LayoutOrder = order
	b.AutoButtonColor = false
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.TextColor3 = C.Text
	b.BackgroundColor3 = C.Slot
	b.Size = UDim2.fromScale(0.42, 0.84)
	b.ZIndex = 5
	b.Parent = actions
	corner(b, 0.14)
	stroke(b, C.PanelEdge, 1, 0.25)
	pad(b, 0.16, 0.16, 0.04, 0.04)
	textLimit(b, 11, 18)
	return b
end

local rollBtn = makeAction("Roll", "GIRAR", 1)
local autoBtn = makeAction("Auto", "AUTO-ROLL", 2)

local function layoutMenu()
	local camNow = workspace.CurrentCamera
	local vp = (camNow and camNow.ViewportSize) or Vector2.new(800, 600)
	local isTouch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	local wide = (not isTouch) and vp.X >= 1100
	if wide then
		panel.Size = UDim2.fromScale(0.34, 0.74)
		panel.Position = UDim2.fromScale(0.5, 0.5)
		panelAspect.AspectRatio = 0.58
	elseif vp.X > vp.Y * 1.15 then
		panel.Size = UDim2.fromScale(0.42, 0.82)
		panelAspect.AspectRatio = 0.72
	else
		panel.Size = UDim2.fromScale(0.88, 0.78)
		panelAspect.AspectRatio = 0.60
	end
end

local function stopRotate()
	if rotConn then
		rotConn:Disconnect()
		rotConn = nil
	end
end

local function clearWorld()
	stopRotate()
	for _, ch in ipairs(world:GetChildren()) do
		ch:Destroy()
	end
end

local function mountR6(cardId: string)
	clearWorld()
	local loadout = Avatars.Get(cardId)
	if not loadout then
		icon.Image = ""
		return
	end
	icon.Image = Avatars.Thumb(loadout.icon)

	local ok, modelOrErr = pcall(function()
		local desc = Avatars.ToDescription(loadout)
		return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R6)
	end)
	if not ok or typeof(modelOrErr) ~= "Instance" then
		warn("[Aetherion] R6 preview falhou:", modelOrErr)
		return
	end
	local model = modelOrErr :: Model
	model.Name = "PreviewDummy"
	model.Parent = world
	local hum = model:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		pcall(function()
			hum.AutoRotate = false
		end)
	end
	local function frameFullBody()
		if not model.Parent then
			return CFrame.new()
		end
		local cf, size = model:GetBoundingBox()
		if size.Y < 1 then
			size = Vector3.new(2, 5, 1)
			cf = model:GetPivot()
		end
		-- pés no chão, centro XZ em 0, corpo inteiro no quadro
		local delta = Vector3.new(0, size.Y * 0.5, 0) - cf.Position
		model:PivotTo(model:GetPivot() + delta)
		cf, size = model:GetBoundingBox()
		local dist = math.max(size.Y * 1.65, size.X * 2.4, 10)
		cam.FieldOfView = 50
		cam.CFrame = CFrame.lookAt(
			Vector3.new(0, size.Y * 0.50, dist),
			Vector3.new(0, size.Y * 0.48, 0)
		)
		return model:GetPivot()
	end

	local pivot = frameFullBody()
	local yaw = 0
	local function startSpin(base: CFrame)
		stopRotate()
		pivot = base
		yaw = 0
		rotConn = RunService.RenderStepped:Connect(function(dt)
			if not model.Parent then
				stopRotate()
				return
			end
			yaw += dt * 0.45
			model:PivotTo(pivot * CFrame.Angles(0, yaw, 0))
		end)
	end
	startSpin(pivot)
	-- acessórios do catálogo entram com delay; reenquadra o corpo inteiro
	task.delay(0.5, function()
		if model.Parent then
			startSpin(frameFullBody())
		end
	end)
end

local function setAutoVisual()
	autoBtn.Text = autoOn and "AUTO  ON" or "AUTO-ROLL"
	TweenService:Create(autoBtn, T_FAST, {
		BackgroundColor3 = autoOn and Color3.fromRGB(32, 52, 40) or C.Slot,
	}):Play()
	autoBtn.TextColor3 = autoOn and C.On or C.Text
end

local function showCard(pub: { [string]: any }, owned: number, total: number)
	local chancePct = (pub.rarityChance or 0) * 100
	local chanceStr
	if chancePct < 1 then
		chanceStr = string.format("%.1f%%", chancePct)
	else
		chanceStr = string.format("%.0f%%", chancePct)
	end
	nameLbl.Text = pub.name or "—"
	rarityLbl.Text = string.format("%s  ·  %s", pub.rarityLabel or "?", chanceStr)
	if typeof(pub.rarityColor) == "table" then
		rarityLbl.TextColor3 = Color3.new(pub.rarityColor[1], pub.rarityColor[2], pub.rarityColor[3])
	end
	local y = pub.yieldPerSecond or 0
	local yStr
	if y >= 10 then
		yStr = string.format("%.1f", y)
	else
		yStr = string.format("%.2f", y)
	end
	statsLbl.Text = string.format("Valor base  %d\nRendimento  %s /seg\nChance  %s", pub.baseValue or 0, yStr, chanceStr)
	countLbl.Text = string.format("desta carta: %d     sessão: %d", owned or 0, total or 0)

	if typeof(pub.id) == "string" and pub.id ~= lastCardId then
		lastCardId = pub.id
		mountR6(pub.id)
	end
end

local function doRoll(): boolean
	if rolling then
		return false
	end
	rolling = true
	rollBtn.Text = "..."
	local okCall, result = pcall(function()
		return rollOnce:InvokeServer()
	end)
	rolling = false
	rollBtn.Text = "GIRAR"
	if not okCall then
		rarityLbl.Text = "falha de rede"
		rarityLbl.TextColor3 = C.Danger
		return false
	end
	if typeof(result) ~= "table" or not result.ok then
		if result and result.err == "cooldown" then
			return false
		end
		rarityLbl.Text = "não foi possível girar"
		rarityLbl.TextColor3 = C.Danger
		return false
	end
	showCard(result.card, result.ownedOfThis, result.inventoryCount)
	return true
end

local function stopAuto()
	autoOn = false
	autoGen += 1
	setAutoVisual()
end

local function startAuto()
	autoOn = true
	autoGen += 1
	local my = autoGen
	setAutoVisual()
	task.spawn(function()
		while autoOn and my == autoGen and gui.Enabled do
			doRoll()
			local elapsed = 0
			while elapsed < AUTO_INTERVAL and autoOn and my == autoGen and gui.Enabled do
				elapsed += task.wait()
			end
		end
		if my == autoGen then
			autoOn = false
			setAutoVisual()
		end
	end)
end

local function openMenu()
	gui.Enabled = true
	layoutMenu()
	if lastCardId then
		mountR6(lastCardId)
	end
end

local function closeMenu()
	stopAuto()
	rolling = false
	gui.Enabled = false
	stopRotate()
end

rollBtn.Activated:Connect(function()
	if autoOn then
		stopAuto()
	end
	doRoll()
end)
autoBtn.Activated:Connect(function()
	if autoOn then
		stopAuto()
	else
		startAuto()
	end
end)
closeBtn.Activated:Connect(closeMenu)
overlay.Activated:Connect(closeMenu)

layoutMenu()
if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		if gui.Enabled then
			layoutMenu()
		end
	end)
end

task.spawn(function()
	local hub = playerGui:WaitForChild("PreviewHub", 30)
	if not hub then
		warn("[Aetherion] PreviewHub não encontrado")
		return
	end
	local action = hub:WaitForChild("HubAction", 10)
	if action and action:IsA("BindableEvent") then
		action.Event:Connect(function(kind)
			if kind == "OpenGacha" then
				openMenu()
			end
		end)
	end
end)

print("[Aetherion] GachaClient ready")
