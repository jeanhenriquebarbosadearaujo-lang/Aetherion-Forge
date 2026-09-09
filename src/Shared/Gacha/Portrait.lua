--[[
	Ilustração autoral de UI (vetor programado). Sem Toolbox, sem rbxassetid.
	Retrato estilizado horse-girl: crina, orelhas, silhueta, gema de raridade.
]]

local Portrait = {}

local function corner(parent: Instance, scale: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(scale, 0)
	c.Parent = parent
	return c
end

local function stroke(parent: Instance, color: Color3, thickness: number, transparency: number)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness
	s.Transparency = transparency
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function rect(parent: Instance, name: string, pos: UDim2, size: UDim2, color: Color3, rot: number, z: number, trans: number): Frame
	local f = Instance.new("Frame")
	f.Name = name
	f.BackgroundColor3 = color
	f.BackgroundTransparency = trans
	f.BorderSizePixel = 0
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Position = pos
	f.Size = size
	f.Rotation = rot
	f.ZIndex = z
	f.Parent = parent
	return f
end

local function asColor(v: any, fallback: Color3): Color3
	if typeof(v) == "Color3" then
		return v
	end
	if typeof(v) == "table" and #v >= 3 then
		return Color3.new(v[1], v[2], v[3])
	end
	return fallback
end

function Portrait.Paint(host: Frame, card: { [string]: any })
	for _, child in ipairs(host:GetChildren()) do
		if not child:IsA("UICorner") and not child:IsA("UIStroke") and not child:IsA("UIGradient") then
			child:Destroy()
		end
	end

	local bg0 = asColor(card.bg0, Color3.fromRGB(24, 24, 28))
	local bg1 = asColor(card.bg1, Color3.fromRGB(10, 10, 12))
	local mane = asColor(card.mane, Color3.fromRGB(80, 80, 90))
	local coat = asColor(card.coat, Color3.fromRGB(210, 190, 175))
	local accent = asColor(card.accent, Color3.fromRGB(180, 180, 186))
	local rarityColor = asColor(card.rarityColor, Color3.fromRGB(180, 180, 180))

	host.BackgroundColor3 = bg0
	host.BackgroundTransparency = 0
	local g = host:FindFirstChildOfClass("UIGradient")
	if not g then
		g = Instance.new("UIGradient")
		g.Parent = host
	end
	g.Color = ColorSequence.new(bg0, bg1)
	g.Rotation = 110

	local z = host.ZIndex

	-- crina (camadas)
	local maneBack = rect(host, "ManeBack", UDim2.fromScale(0.50, 0.46), UDim2.fromScale(0.62, 0.58), mane, -8, z + 1, 0.05)
	corner(maneBack, 0.45)
	local maneSide = rect(host, "ManeSide", UDim2.fromScale(0.28, 0.52), UDim2.fromScale(0.22, 0.48), mane:Lerp(bg1, 0.15), 18, z + 2, 0.08)
	corner(maneSide, 0.5)
	local streak = rect(host, "Streak", UDim2.fromScale(0.58, 0.40), UDim2.fromScale(0.12, 0.42), accent, -16, z + 3, 0.2)
	corner(streak, 0.5)

	-- orelhas (horse-girl)
	local earL = rect(host, "EarL", UDim2.fromScale(0.34, 0.20), UDim2.fromScale(0.13, 0.22), mane, -18, z + 4, 0)
	corner(earL, 0.35)
	local earR = rect(host, "EarR", UDim2.fromScale(0.66, 0.20), UDim2.fromScale(0.13, 0.22), mane, 18, z + 4, 0)
	corner(earR, 0.35)
	local innerL = rect(host, "EarInnerL", UDim2.fromScale(0.35, 0.22), UDim2.fromScale(0.06, 0.12), coat, -18, z + 5, 0.15)
	corner(innerL, 0.4)
	local innerR = rect(host, "EarInnerR", UDim2.fromScale(0.65, 0.22), UDim2.fromScale(0.06, 0.12), coat, 18, z + 5, 0.15)
	corner(innerR, 0.4)

	-- cabeça / ombros
	local head = rect(host, "Head", UDim2.fromScale(0.50, 0.48), UDim2.fromScale(0.42, 0.40), coat, 0, z + 6, 0)
	corner(head, 0.42)
	local shadow = rect(host, "FaceShade", UDim2.fromScale(0.50, 0.55), UDim2.fromScale(0.36, 0.22), coat:Lerp(bg1, 0.25), 0, z + 7, 0.35)
	corner(shadow, 0.5)

	-- olhos (dois pontos)
	local eyeL = rect(host, "EyeL", UDim2.fromScale(0.42, 0.46), UDim2.fromScale(0.07, 0.055), bg1, 0, z + 8, 0.1)
	corner(eyeL, 1)
	local eyeR = rect(host, "EyeR", UDim2.fromScale(0.58, 0.46), UDim2.fromScale(0.07, 0.055), bg1, 0, z + 8, 0.1)
	corner(eyeR, 1)
	local glL = rect(host, "GlintL", UDim2.fromScale(0.435, 0.45), UDim2.fromScale(0.025, 0.02), Color3.new(1, 1, 1), 0, z + 9, 0.25)
	corner(glL, 1)
	local glR = rect(host, "GlintR", UDim2.fromScale(0.595, 0.45), UDim2.fromScale(0.025, 0.02), Color3.new(1, 1, 1), 0, z + 9, 0.25)
	corner(glR, 1)

	-- corpo / uniforme
	local torso = rect(host, "Torso", UDim2.fromScale(0.50, 0.86), UDim2.fromScale(0.70, 0.36), accent:Lerp(bg1, 0.45), 0, z + 5, 0)
	corner(torso, 0.2)
	local stripe = rect(host, "Stripe", UDim2.fromScale(0.50, 0.78), UDim2.fromScale(0.70, 0.045), rarityColor, 0, z + 6, 0.15)
	corner(stripe, 0.2)

	-- gema de raridade
	local gem = rect(host, "Gem", UDim2.fromScale(0.88, 0.12), UDim2.fromScale(0.12, 0.12), rarityColor, 45, z + 12, 0.05)
	corner(gem, 0.2)
	stroke(gem, Color3.new(1, 1, 1), 1, 0.65)
end

return Portrait
