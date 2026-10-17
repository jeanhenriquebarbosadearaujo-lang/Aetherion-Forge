--!strict
--[[
  Esconde a mochila padrão do Roblox. O loot vai só na barra Madeira/Pedra.
]]

local StarterGui = game:GetService("StarterGui")

local function hide()
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	end)
end

hide()
task.defer(hide)
