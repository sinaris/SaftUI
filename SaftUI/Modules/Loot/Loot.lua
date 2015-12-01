local S, L, F = select(2, ...):unpack() --Import: Addon/Functions/Data, Locales, LibStringFormat

local LT = S:NewModule('Loot', 'AceHook-3.0', 'AceEvent-3.0')

--Create a function to hook in other modules
function LT:START_LOOT_ROLL(...)
	self:HandleNewGroupRoll(...)
	self:CheckAutoRoll(...)
end

function LT:OnInitialize()
	self:InitializeGroupLootFrames()
	self:InitializeAutoLoot()

	self:RegisterEvent('START_LOOT_ROLL')
end



