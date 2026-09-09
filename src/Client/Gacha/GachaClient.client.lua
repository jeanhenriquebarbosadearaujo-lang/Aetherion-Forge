--[[
	GachaClient — menu Girar / Rolls + Auto-Roll.
	UI mobile-first, chrome preto/cinza. Ilustrações via Portrait (código).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Shared = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Gacha")
local Catalog = require(Shared:WaitForChild("Catalog"))
local Portrait = require(Shared:WaitForChild("Portrait"))

local remotes = ReplicatedStorage:WaitForChild("AetherionRemotes", 15)
if not remotes then
	warn("[Aetherion] AetherionRemotes ausente — GachaClient aborta")
	return
end
local rollOnce = remotes:WaitForChild("RollOnce") :: RemoteFunction

local C = {
	Void = Color3.fromRGB(8, 8, 10),
	Panel = Color3.fromRGB(16, 16, 18),
	PanelEdge = Color3.fromRGB(42, 42, 48),
	Slot = Color3.fromRGB(26, 26, 30),
	Text = Color3.fromRGB(230, 230, 232),
	Muted = Color3.fromRGB(140, 140, 146),
	Accent = Color3.fromRGB(186, 186, 190),
	Danger = Color3.fromRGB(200, 80, 80),
	On = Color3.fromRGB(120, 186, 140),
}

local T_FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local T_CARD = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local T_OUT = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local autoOn = false
local rolling = false
local autoToken = 0

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
local function gradient(p: Instance, a: Color3, b: Color3, rot: number)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(a, b)
	g.Rotation = rot
	g.Parent = p
	return g
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
local function label(parent: Instance, name: string, text: string, size: UDim2, pos: UDim2, anchor: Vector2, color: Color3, bold: boolean, z: number): TextLabel
	local l = Instance.new("TextLabel")
	l.Name = name
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = color
	l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
	l.TextScaled = true
	l.Size = size
	l.Position = pos
	l.AnchorPoint = anchor
	l.ZIndex = z
	l.Parent = parent
	local lim = Instance.new("UITextSizeConstraint")
	lim.MinTextSize = 9
	lim.MaxTextSize = 22
	lim.Parent = l
	return l
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
overlay.BackgroundTransparency = 0.42
overlay.Size = UDim2.fromScale(1, 1)
overlay.ZIndex = 1
overlay.Parent = gui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromScale(0.92, 0.78)
panel.BackgroundColor3 = C.Panel
panel.BorderSizePixel = 0
panel.ZIndex = 2
panel.Parent = gui
corner(panel, 0.04)
stroke(panel, C.PanelEdge, 1, 0.2)
gradient(panel, Color3.fromRGB(28, 28, 32), C.Void, 90)

local panelAspect = Instance.new("UIAspectRatioConstraint")
panelAspect.Name = "PanelAspect"
panelAspect.AspectRatio = 0.72
panelAspect.AspectType = Enum.AspectType.FitWithinMaxSize
panelAspect.Parent = panel

local title = label(panel, "Title", "GIRAR / ROLLS", UDim2.fromScale(0.7, 0.07), UDim2.fromScale(0.06, 0.03), Vector2.new(0, 0), C.Text, true, 4)
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "Close"
closeBtn.AutoButtonColor = false
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
closeBtn.TextColor3 = C.Muted
closeBtn.BackgroundColor3 = C.Slot
closeBtn.BackgroundTransparency = 0.1
closeBtn.AnchorPoint = Vector2.new(1, 0)
closeBtn.Position = UDim2.fromScale(0.96, 0.03)
closeBtn.Size = UDim2.fromScale(0.1, 0.07)
closeBtn.ZIndex = 5
closeBtn.Parent = panel
corner(closeBtn, 0.22)
stroke(closeBtn, C.PanelEdge, 1, 0.35)
do
	local a = Instance.new("UIAspectRatioConstraint")
	a.AspectRatio = 1
	a.Parent = closeBtn
end

-- Carta
local cardFrame = Instance.new("Frame")
cardFrame.Name = "Card"
cardFrame.AnchorPoint = Vector2.new(0.5, 0)
cardFrame.Position = UDim2.fromScale(0.5, 0.12)
cardFrame.Size = UDim2.fromScale(0.78, 0.52)
cardFrame.BackgroundColor3 = C.Slot
cardFrame.BorderSizePixel = 0
cardFrame.ZIndex = 3
cardFrame.ClipsDescendants = true
cardFrame.Parent = panel
corner(cardFrame, 0.05)
stroke(cardFrame, C.PanelEdge, 1, 0.25)

local cardAspect = Instance.new("UIAspectRatioConstraint")
cardAspect.AspectRatio = 0.72
cardAspect.AspectType = Enum.AspectType.FitWithinMaxSize
cardAspect.Parent = cardFrame

local art = Instance.new("Frame")
art.Name = "Art"
art.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
art.BorderSizePixel = 0
art.Position = UDim2.fromScale(0, 0)
art.Size = UDim2.fromScale(1, 0.58)
art.ZIndex = 4
art.Parent = cardFrame
art.ClipsDescendants = true

local nameLbl = label(cardFrame, "CardName", "—", UDim2.fromScale(0.9, 0.1), UDim2.fromScale(0.5, 0.60), Vector2.new(0.5, 0), C.Text, true, 6)
local rarityLbl = label(cardFrame, "Rarity", "aguardando giro", UDim2.fromScale(0.9, 0.07), UDim2.fromScale(0.5, 0.70), Vector2.new(0.5, 0), C.Muted, false, 6)
local statsLbl = label(cardFrame, "Stats", "Valor  —    •    — /seg    •    chance —", UDim2.fromScale(0.92, 0.16), UDim2.fromScale(0.5, 0.78), Vector2.new(0.5, 0), C.Accent, false, 6)
statsLbl.TextWrapped = true

local countLbl = label(panel, "Counts", "cartas nesta sessão: 0", UDim2.fromScale(0.88, 0.045), UDim2.fromScale(0.5, 0.655), Vector2.new(0.5, 0), C.Muted, false, 4)

-- Botões de ação
local actions = Instance.new("Frame")
actions.Name = "Actions"
actions.BackgroundTransparency = 1
actions.AnchorPoint = Vector2.new(0.5, 1)
actions.Position = UDim2.fromScale(0.5, 0.97)
actions.Size = UDim2.fromScale(0.9, 0.14)
actions.ZIndex = 4
actions.Parent = panel

local actionsList = Instance.new("UIListLayout")
actionsList.FillDirection = Enum.FillDirection.Horizontal
actionsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
actionsList.VerticalAlignment = Enum.VerticalAlignment.Center
actionsList.Padding = UDim.new(0.03, 0)
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
	b.BackgroundTransparency = 0.04
	b.Size = UDim2.fromScale(0.46, 0.86)
	b.ZIndex = 5
	b.Parent = actions
	corner(b, 0.16)
	stroke(b, C.PanelEdge, 1, 0.28)
	gradient(b, Color3.fromRGB(40, 40, 46), C.Slot, 90)
	pad(b, 0.18, 0.18, 0.04, 0.04)
	local lim = Instance.new("UITextSizeConstraint")
	lim.MinTextSize = 11
	lim.MaxTextSize = 20
	lim.Parent = b
	return b
end

local rollBtn = makeAction("Roll", "GIRAR / ROLLS", 1)
local autoBtn = makeAction("Auto", "AUTO-ROLL  OFF", 2)

local function layoutMenu()
	local cam = workspace.CurrentCamera
	local vp = (cam and cam.ViewportSize) or Vector2.new(800, 600)
	local isTouch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	local wide = (not isTouch) and vp.X >= 1100
	if wide then
		panel.Size = UDim2.fromScale(0.38, 0.78)
		panelAspect.AspectRatio = 0.70
	elseif vp.X > vp.Y * 1.15 then
		panel.Size = UDim2.fromScale(0.48, 0.86)
		panelAspect.AspectRatio = 0.85
	else
		panel.Size = UDim2.fromScale(0.92, 0.80)
		panelAspect.AspectRatio = 0.68
	end
end

local function setAutoVisual()
	autoBtn.Text = autoOn and "AUTO-ROLL  ON" or "AUTO-ROLL  OFF"
	TweenService:Create(autoBtn, T_FAST, {
		BackgroundColor3 = autoOn and Color3.fromRGB(32, 52, 40) or C.Slot,
	}):Play()
	autoBtn.TextColor3 = autoOn and C.On or C.Text
end

local function showCard(pub: { [string]: any }, owned: number, total: number)
	Portrait.Paint(art, pub)
	nameLbl.Text = pub.name or "—"
	local chancePct = (pub.rarityChance or 0) * 100
	local chanceStr = if chancePct < 1 then string.format("%.1f%%", chancePct) else string.format("%.0f%%", chancePct)
	rarityLbl.Text = string.format("%s  ·  %s", pub.rarityLabel or "?", chanceStr)
	if typeof(pub.rarityColor) == "table" then
		rarityLbl.TextColor3 = Color3.new(pub.rarityColor[1], pub.rarityColor[2], pub.rarityColor[3])
	end
	local y = pub.yieldPerSecond or 0
	local yStr = if y >= 10 then string.format("%.1f", y) else string.format("%.2f", y)
	statsLbl.Text = string.format("Valor base  %d     ·     %s /seg\nChance de obtenção  %s", pub.baseValue or 0, yStr, chanceStr)
	countLbl.Text = string.format("desta carta: %d    ·    cartas na sessão: %d", owned or 0, total or 0)

	cardFrame.Size = UDim2.fromScale(0.70, 0.48)
	TweenService:Create(cardFrame, T_CARD, { Size = UDim2.fromScale(0.78, 0.52) }):Play()
end

local function doRoll()
	if rolling then
		return
	end
	rolling = true
	rollBtn.Text = "..."
	cardFrame.BackgroundTransparency = 0.2
	TweenService:Create(cardFrame, T_OUT, { BackgroundTransparency = 0 }):Play()

	local okCall, result = pcall(function()
		return rollOnce:InvokeServer()
	end)
	rolling = false
	rollBtn.Text = "GIRAR / ROLLS"

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
	autoToken += 1
	setAutoVisual()
end

local function startAuto()
	autoOn = true
	autoToken += 1
	local my = autoToken
	setAutoVisual()
	task.spawn(function()
		while autoOn and my == autoToken and gui.Enabled do
			doRoll()
			task.wait(0.7)
		end
		if my == autoToken then
			stopAuto()
		end
	end)
end

local function openMenu()
	gui.Enabled = true
	layoutMenu()
end

local function closeMenu()
	stopAuto()
	gui.Enabled = false
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

-- Liga no botão #1 do PreviewHub
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
