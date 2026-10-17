--[[
  Botão grande na tela. ProximityPrompt no celular some; toque aqui não.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
end)

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("HarvestRequest", 60)
if not remote then
	warn("[Aetherion] Harvest: sem RemoteEvent")
	return
end

local FONT = Enum.Font.SourceSans
pcall(function()
	FONT = Enum.Font.BuilderSans
end)

local gui = Instance.new("ScreenGui")
gui.Name = "AetherionHarvest"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

-- Acima da barra de madeira/pedra. Scale + safe-zone.
local btn = Instance.new("TextButton")
btn.Name = "DoHarvest"
btn.AnchorPoint = Vector2.new(0.5, 1)
btn.Position = UDim2.fromScale(0.5, 0.78)
btn.Size = UDim2.fromScale(0.42, 0.09)
btn.BackgroundColor3 = Color3.fromRGB(48, 92, 44)
btn.BackgroundTransparency = 0.08
btn.Text = "Cortar"
btn.TextColor3 = Color3.fromRGB(240, 242, 230)
btn.Font = FONT
btn.TextScaled = true
btn.Visible = false
btn.AutoButtonColor = true
btn.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.35, 0)
corner.Parent = btn
local ar = Instance.new("UIAspectRatioConstraint")
ar.AspectRatio = 4.2
ar.Parent = btn
local pad = Instance.new("UIPadding")
pad.PaddingLeft = UDim.new(0.08, 0)
pad.PaddingRight = UDim.new(0.08, 0)
pad.PaddingTop = UDim.new(0.12, 0)
pad.PaddingBottom = UDim.new(0.12, 0)
pad.Parent = btn

local current = nil
local RANGE = 16

local function nearest()
	local folder = workspace:FindFirstChild("WorldScenery")
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not folder or not hrp then
		return nil
	end
	local best, bestD = nil, RANGE
	for _, m in ipairs(folder:GetChildren()) do
		if m:IsA("Model") then
			local p = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
			if p and m:FindFirstChild("HarvestBeacon") then
				local d = (p.Position - hrp.Position).Magnitude
				if d < bestD then
					best = m
					bestD = d
				end
			end
		end
	end
	return best
end

btn.MouseButton1Click:Connect(function()
	if current and remote then
		remote:FireServer(current)
	end
end)

local acc = 0
RunService.Heartbeat:Connect(function(dt)
	acc += dt
	if acc < 0.15 then
		return
	end
	acc = 0
	current = nearest()
	if current then
		local kind = tostring(current:GetAttribute("Kind") or current.Name)
		btn.Text = (kind == "rock" or kind == "Rock") and "Quebrar" or "Cortar"
		btn.Visible = true
	else
		btn.Visible = false
	end
end)

print("[Aetherion] Harvest client ready")
