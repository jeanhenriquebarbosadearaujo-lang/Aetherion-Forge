--[[
	Aetherion Forge — PreviewHub
	HUB de preview mobile-first (preto / cinza escuro).
	Toda arte de GUI é gerada em código. Sem Toolbox.

	Slot #1 = Girar / Rolls (abre o GachaMenu).
	Slots #2–#8 = marcadores futuros.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local Assets = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Gacha"):WaitForChild("Assets"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local SLOT_COUNT = 8

local C = {
	Void = Color3.fromRGB(8, 8, 10),
	Panel = Color3.fromRGB(16, 16, 18),
	PanelEdge = Color3.fromRGB(38, 38, 42),
	Slot = Color3.fromRGB(24, 24, 27),
	SlotInner = Color3.fromRGB(32, 32, 36),
	SlotHover = Color3.fromRGB(44, 44, 50),
	SlotPress = Color3.fromRGB(12, 12, 14),
	SlotOn = Color3.fromRGB(52, 52, 58),
	Text = Color3.fromRGB(228, 228, 230),
	Muted = Color3.fromRGB(132, 132, 138),
	Hairline = Color3.fromRGB(70, 70, 76),
	Accent = Color3.fromRGB(186, 186, 190),
	Rolls = Color3.fromRGB(210, 186, 110),
}

local TWEEN_HOVER = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_PRESS = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local selectedIndex: number? = nil

local function corner(parent: Instance, scale: number): UICorner
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(scale, 0)
	c.Parent = parent
	return c
end

local function stroke(parent: Instance, color: Color3, thickness: number, transparency: number): UIStroke
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness
	s.Transparency = transparency
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.LineJoinMode = Enum.LineJoinMode.Round
	s.Parent = parent
	return s
end

local function gradient(parent: Instance, c0: Color3, c1: Color3, rotation: number): UIGradient
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(c0, c1)
	g.Rotation = rotation
	g.Parent = parent
	return g
end

local function pxPad(parent: Instance, t: number, b: number, l: number, r: number)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(t, 0)
	p.PaddingBottom = UDim.new(b, 0)
	p.PaddingLeft = UDim.new(l, 0)
	p.PaddingRight = UDim.new(r, 0)
	p.Parent = parent
	return p
end

local function paintGlyph(host: Frame, index: number)
	local function cell(rel: UDim2, size: UDim2, rot: number?, transparency: number?, color: Color3?): Frame
		local f = Instance.new("Frame")
		f.BackgroundColor3 = color or C.Accent
		f.BackgroundTransparency = transparency or 0.12
		f.BorderSizePixel = 0
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Position = rel
		f.Size = size
		f.Rotation = rot or 0
		f.ZIndex = host.ZIndex + 1
		f.Parent = host
		corner(f, 0.2)
		return f
	end

	if index == 1 then
		-- ícone temático de giro: anel + eixo
		local ring = cell(UDim2.fromScale(0.5, 0.48), UDim2.fromScale(0.56, 0.56), 0, 1, C.Rolls)
		corner(ring, 1)
		local st = stroke(ring, C.Rolls, 2, 0.1)
		st.Parent = ring
		cell(UDim2.fromScale(0.72, 0.28), UDim2.fromScale(0.18, 0.10), 40, 0.05, C.Rolls)
		cell(UDim2.fromScale(0.28, 0.70), UDim2.fromScale(0.18, 0.10), 40, 0.05, C.Rolls)
		cell(UDim2.fromScale(0.5, 0.48), UDim2.fromScale(0.14, 0.14), 0, 0.05, C.Rolls)
		corner(host:FindFirstChildWhichIsA("Frame", true) :: Frame, 1)
	elseif index == 2 then
		local ring = cell(UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.5, 0.5))
		corner(ring, 1)
		ring.BackgroundTransparency = 1
		stroke(ring, C.Accent, 2, 0.15)
	elseif index == 3 then
		local q = cell(UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.42, 0.42))
		q.BackgroundTransparency = 1
		stroke(q, C.Accent, 2, 0.15)
	elseif index == 4 then
		cell(UDim2.fromScale(0.32, 0.55), UDim2.fromScale(0.14, 0.38))
		cell(UDim2.fromScale(0.5, 0.48), UDim2.fromScale(0.14, 0.52))
		cell(UDim2.fromScale(0.68, 0.42), UDim2.fromScale(0.14, 0.64))
	elseif index == 5 then
		cell(UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.14, 0.5))
		cell(UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.5, 0.14))
	elseif index == 6 then
		local a = cell(UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.52, 0.52))
		corner(a, 1)
		a.BackgroundTransparency = 1
		stroke(a, C.Accent, 2, 0.2)
		local b = cell(UDim2.fromScale(0.5, 0.5), UDim2.fromScale(0.18, 0.18))
		corner(b, 1)
	elseif index == 7 then
		cell(UDim2.fromScale(0.5, 0.38), UDim2.fromScale(0.46, 0.12), 35)
		cell(UDim2.fromScale(0.5, 0.62), UDim2.fromScale(0.46, 0.12), -35)
	else
		cell(UDim2.fromScale(0.36, 0.36), UDim2.fromScale(0.22, 0.22))
		cell(UDim2.fromScale(0.64, 0.36), UDim2.fromScale(0.22, 0.22))
		cell(UDim2.fromScale(0.36, 0.64), UDim2.fromScale(0.22, 0.22))
		cell(UDim2.fromScale(0.64, 0.64), UDim2.fromScale(0.22, 0.22))
	end
end

local function tween(inst: Instance, info: TweenInfo, props: { [string]: any })
	local t = TweenService:Create(inst, info, props)
	t:Play()
	return t
end

local gui = Instance.new("ScreenGui")
gui.Name = "PreviewHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 120
gui.Parent = playerGui

local hubAction = Instance.new("BindableEvent")
hubAction.Name = "HubAction"
hubAction.Parent = gui

local root = Instance.new("Frame")
root.Name = "Root"
root.BackgroundTransparency = 1
root.BorderSizePixel = 0
root.Size = UDim2.fromScale(1, 1)
root.Position = UDim2.fromScale(0, 0)
root.Parent = gui

local brand = Instance.new("Frame")
brand.Name = "BrandChip"
brand.BackgroundColor3 = C.Panel
brand.BackgroundTransparency = 0.12
brand.BorderSizePixel = 0
brand.AnchorPoint = Vector2.new(0, 0)
brand.Position = UDim2.fromScale(0.03, 0.03)
brand.Size = UDim2.fromScale(0.28, 0.055)
brand.ZIndex = 10
brand.Parent = root
corner(brand, 0.28)
stroke(brand, C.PanelEdge, 1, 0.25)
gradient(brand, Color3.fromRGB(28, 28, 32), C.Panel, 90)

local brandAspect = Instance.new("UIAspectRatioConstraint")
brandAspect.AspectRatio = 4.6
brandAspect.AspectType = Enum.AspectType.FitWithinMaxSize
brandAspect.DominantAxis = Enum.DominantAxis.Width
brandAspect.Parent = brand

local brandLabel = Instance.new("TextLabel")
brandLabel.Name = "Title"
brandLabel.BackgroundTransparency = 1
brandLabel.Size = UDim2.fromScale(1, 1)
brandLabel.Font = Enum.Font.GothamMedium
brandLabel.Text = "AETHERION"
brandLabel.TextColor3 = C.Text
brandLabel.TextTransparency = 0.08
brandLabel.TextScaled = true
brandLabel.ZIndex = 11
brandLabel.Parent = brand
pxPad(brandLabel, 0.18, 0.18, 0.08, 0.08)
local brandTextLimit = Instance.new("UITextSizeConstraint")
brandTextLimit.MinTextSize = 10
brandTextLimit.MaxTextSize = 18
brandTextLimit.Parent = brandLabel

local dock = Instance.new("Frame")
dock.Name = "Dock"
dock.BackgroundColor3 = C.Panel
dock.BackgroundTransparency = 0.06
dock.BorderSizePixel = 0
dock.AnchorPoint = Vector2.new(0.5, 1)
dock.Position = UDim2.fromScale(0.5, 0.975)
dock.Size = UDim2.fromScale(0.92, 0.16)
dock.ZIndex = 10
dock.Parent = root
corner(dock, 0.12)
stroke(dock, C.PanelEdge, 1, 0.2)
gradient(dock, Color3.fromRGB(26, 26, 30), C.Void, 90)

local dockAspect = Instance.new("UIAspectRatioConstraint")
dockAspect.Name = "DockAspect"
dockAspect.AspectRatio = 6.4
dockAspect.AspectType = Enum.AspectType.FitWithinMaxSize
dockAspect.DominantAxis = Enum.DominantAxis.Width
dockAspect.Parent = dock

local hairline = Instance.new("Frame")
hairline.Name = "Hairline"
hairline.BackgroundColor3 = C.Hairline
hairline.BackgroundTransparency = 0.35
hairline.BorderSizePixel = 0
hairline.AnchorPoint = Vector2.new(0.5, 0)
hairline.Position = UDim2.fromScale(0.5, 0)
hairline.Size = UDim2.fromScale(0.94, 0.018)
hairline.ZIndex = 12
hairline.Parent = dock
corner(hairline, 1)

local slotRow = Instance.new("Frame")
slotRow.Name = "SlotRow"
slotRow.BackgroundTransparency = 1
slotRow.BorderSizePixel = 0
slotRow.Size = UDim2.fromScale(1, 1)
slotRow.ZIndex = 11
slotRow.Parent = dock
pxPad(slotRow, 0.14, 0.16, 0.03, 0.03)

local list = Instance.new("UIListLayout")
list.FillDirection = Enum.FillDirection.Horizontal
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.VerticalAlignment = Enum.VerticalAlignment.Center
list.Padding = UDim.new(0.012, 0)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = slotRow

local slots: { TextButton } = {}

local function setSelected(index: number)
	selectedIndex = index
	for i, btn in ipairs(slots) do
		local on = i == index
		tween(btn, TWEEN_HOVER, {
			BackgroundColor3 = on and C.SlotOn or C.Slot,
			BackgroundTransparency = on and 0.02 or 0.08,
		})
		local pip = btn:FindFirstChild("ActivePip")
		if pip and pip:IsA("Frame") then
			tween(pip, TWEEN_HOVER, { BackgroundTransparency = on and 0.05 or 1 })
		end
	end
end

local function makeSlot(index: number): TextButton
	local isRolls = index == 1
	local btn = Instance.new("TextButton")
	btn.Name = isRolls and "Slot_Rolls" or string.format("Slot_%02d", index)
	btn.LayoutOrder = index
	btn.AutoButtonColor = false
	btn.Text = ""
	btn.BackgroundColor3 = C.Slot
	btn.BackgroundTransparency = 0.08
	btn.BorderSizePixel = 0
	btn.Size = UDim2.fromScale(0.11, 0.86)
	btn.ZIndex = 12
	btn.Parent = slotRow

	corner(btn, 0.18)
	stroke(btn, isRolls and C.Rolls or C.PanelEdge, 1, isRolls and 0.45 or 0.28)
	gradient(btn, C.SlotInner, C.Slot, 90)

	local aspect = Instance.new("UIAspectRatioConstraint")
	aspect.AspectRatio = 1
	aspect.AspectType = Enum.AspectType.FitWithinMaxSize
	aspect.DominantAxis = Enum.DominantAxis.Height
	aspect.Parent = btn

	local glyphHost = Instance.new("Frame")
	glyphHost.Name = "Glyph"
	glyphHost.BackgroundTransparency = 1
	glyphHost.BorderSizePixel = 0
	glyphHost.AnchorPoint = Vector2.new(0.5, 0)
	glyphHost.Position = UDim2.fromScale(0.5, 0.06)
	glyphHost.Size = UDim2.fromScale(0.72, 0.46)
	glyphHost.ZIndex = 13
	glyphHost.Parent = btn
	paintGlyph(glyphHost, index)
	if isRolls then
		glyphHost.Visible = false
		local rollsImg = Instance.new("ImageLabel")
		rollsImg.Name = "RollsIcon"
		rollsImg.BackgroundTransparency = 1
		rollsImg.Image = Assets.RollsIcon
		rollsImg.ScaleType = Enum.ScaleType.Fit
		rollsImg.AnchorPoint = Vector2.new(0.5, 0)
		rollsImg.Position = UDim2.fromScale(0.5, 0.06)
		rollsImg.Size = UDim2.fromScale(0.62, 0.44)
		rollsImg.ZIndex = 14
		rollsImg.Parent = btn
	end

	local label = Instance.new("TextLabel")
	label.Name = "IndexLabel"
	label.BackgroundTransparency = 1
	label.AnchorPoint = Vector2.new(0.5, 1)
	label.Position = UDim2.fromScale(0.5, 0.96)
	label.Size = UDim2.fromScale(0.94, 0.38)
	label.Font = Enum.Font.GothamBold
	label.Text = isRolls and "GIRAR" or ("#" .. tostring(index))
	label.TextColor3 = isRolls and C.Rolls or C.Text
	label.TextTransparency = 0.05
	label.TextScaled = true
	label.ZIndex = 14
	label.Parent = btn
	local ts = Instance.new("UITextSizeConstraint")
	ts.MinTextSize = 8
	ts.MaxTextSize = isRolls and 12 or 16
	ts.Parent = label

	if isRolls then
		local sub = Instance.new("TextLabel")
		sub.Name = "SubLabel"
		sub.BackgroundTransparency = 1
		sub.AnchorPoint = Vector2.new(0.5, 1)
		sub.Position = UDim2.fromScale(0.5, 0.70)
		sub.Size = UDim2.fromScale(0.9, 0.16)
		sub.Font = Enum.Font.Gotham
		sub.Text = "ROLLS"
		sub.TextColor3 = C.Muted
		sub.TextScaled = true
		sub.ZIndex = 14
		sub.Parent = btn
		local sts = Instance.new("UITextSizeConstraint")
		sts.MinTextSize = 6
		sts.MaxTextSize = 10
		sts.Parent = sub
		label.Position = UDim2.fromScale(0.5, 0.98)
		label.Size = UDim2.fromScale(0.94, 0.26)
	end

	local pip = Instance.new("Frame")
	pip.Name = "ActivePip"
	pip.BackgroundColor3 = isRolls and C.Rolls or C.Accent
	pip.BackgroundTransparency = 1
	pip.BorderSizePixel = 0
	pip.AnchorPoint = Vector2.new(0.5, 0)
	pip.Position = UDim2.fromScale(0.5, 0.045)
	pip.Size = UDim2.fromScale(0.36, 0.045)
	pip.ZIndex = 15
	pip.Parent = btn
	corner(pip, 1)

	btn.MouseEnter:Connect(function()
		if selectedIndex ~= index then
			tween(btn, TWEEN_HOVER, { BackgroundColor3 = C.SlotHover, BackgroundTransparency = 0.02 })
		end
	end)
	btn.MouseLeave:Connect(function()
		if selectedIndex ~= index then
			tween(btn, TWEEN_HOVER, { BackgroundColor3 = C.Slot, BackgroundTransparency = 0.08 })
		end
	end)
	btn.MouseButton1Down:Connect(function()
		tween(btn, TWEEN_PRESS, { BackgroundColor3 = C.SlotPress })
	end)
	btn.Activated:Connect(function()
		setSelected(index)
		btn:SetAttribute("PreviewSlot", index)
		if isRolls then
			hubAction:Fire("OpenGacha")
		end
	end)

	return btn
end

for i = 1, SLOT_COUNT do
	table.insert(slots, makeSlot(i))
end

local function applyLayout()
	local cam = workspace.CurrentCamera
	local vp = (cam and cam.ViewportSize) or Vector2.new(800, 600)
	local inset = GuiService:GetGuiInset()
	local isTouch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	local landscape = vp.X > vp.Y * 1.15
	local wideDesktop = (not isTouch) and vp.X >= 1100

	local topPad = math.max(0.018, inset.Y / math.max(vp.Y, 1) * 0.25)
	brand.Position = UDim2.fromScale(0.03, 0.02 + topPad)
	brand.Size = UDim2.fromScale(wideDesktop and 0.16 or 0.3, 0.055)

	if wideDesktop then
		dock.Size = UDim2.fromScale(0.52, 0.13)
		dock.Position = UDim2.fromScale(0.5, 0.97)
		dockAspect.AspectRatio = 7.2
		brandAspect.AspectRatio = 4.8
	elseif landscape then
		dock.Size = UDim2.fromScale(0.72, 0.18)
		dock.Position = UDim2.fromScale(0.5, 0.975)
		dockAspect.AspectRatio = 7.6
	else
		dock.Size = UDim2.fromScale(0.94, 0.17)
		dock.Position = UDim2.fromScale(0.5, 0.978)
		dockAspect.AspectRatio = 5.8
	end
end

applyLayout()
if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyLayout)
end
UserInputService.LastInputTypeChanged:Connect(applyLayout)

gui:SetAttribute("SlotCount", SLOT_COUNT)
gui:SetAttribute("AuthoredUI", true)
